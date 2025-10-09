import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/transaction/request_spending.dart';
import 'package:syathiby/presentation/keuangan/bottomsheet_add_expanse.dart';
import 'package:syathiby/presentation/keuangan/student_savings_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class AddSpendingScreen extends HookConsumerWidget {
  const AddSpendingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      studentSavingsControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final controller = ref.watch(studentSavingsControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final description = useTextEditingController();
    final key = '${currentUser?.key}';
    final spendingList = useState<List<BarangSpending>>([]);
    final date = useTextEditingController();
    final dateSelected = useState<DateTime>(DateTime.now());
    final fileSelected = useState<File?>(null);
    final total = _getTotalSpending(spendingList.value);
    final nominal = ref.read(formatCurrencyProvider(total));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengeluaran'),
        actions: [
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              if (spendingList.value.isEmpty == true) {
                context.showErrorMessage(
                  'Data Pengeluaran kosong, silahkan tambahkan data pengeluaran terlebih dahulu',
                );
                return;
              }
              final formatDate = DateFormat('yyyy-MM-dd').format(
                dateSelected.value,
              );
              final result = await ref
                  .read(studentSavingsControllerProvider.notifier)
                  .addSpending(
                    requestSpending: RequestSpending(
                      key: key,
                      spending: spendingList.value,
                      amount: total.toDouble(),
                      date: formatDate,
                      // img: fileSelected.value?.path,
                    ),
                    image: fileSelected.value,
                  );
              if (result == null || !context.mounted) return;
              context.showSuccessMessage(
                'Berhasil menyimpan pengeluaran dengan id Transaksi: ${result.invoice}',
              );
              ref.invalidate(fetchAllSpendingProvider);
              context.pop();
            },
            child: const Text('Simpan'),
          )
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: spendingList.value.length,
            itemBuilder: (ctx, index) {
              final spending = spendingList.value.elementAt(index);
              return _buildItemSpending(
                context,
                ref,
                spending,
                spendingList,
                index,
              );
            },
          ),
          Visibility(
            visible: controller.isLoading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Form(
        key: formKey,
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16,
            ),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Pengeluaran',
                      style: context.bodyMediumBold,
                    ),
                    Text(
                      nominal,
                      style: context.bodyMediumBold?.copyWith(
                        color: context.colorPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Visibility(
                      visible: fileSelected.value != null,
                      child: InkWell(
                        onTap: () {
                          final imageProvider = FileImage(fileSelected.value!);
                          showImageViewer(context, imageProvider);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: fileSelected.value != null
                              ? Image.file(
                                  fileSelected.value!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.image,
                                  size: 60,
                                ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: fileSelected.value != null,
                      child: const SizedBox(width: 16),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: date,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Tanggal Pengeluaran'.hardcoded,
                          prefixIcon: const Icon(Icons.today),
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(),
                          ],
                        ),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            initialDate: dateSelected.value,
                            lastDate: DateTime.now(),
                          );
                          if (selected == null) return;
                          final formatDateText =
                              DateFormat('EEE, d MMMM yyyy').format(selected);
                          date.text = formatDateText;
                          dateSelected.value = selected;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final file = await _openImagePicker(context);
                          fileSelected.value = file;
                        },
                        label: const Text('Lampiran'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          BarangSpending? item = await showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            isScrollControlled: true,
                            builder: (context) => const FractionallySizedBox(
                              heightFactor: 0.7,
                              child: BottomSheetAddExpanse(),
                            ),
                          );
                          if (item == null) return;
                          spendingList.value.add(item);
                          spendingList.value = [...spendingList.value];
                        },
                        label: const Text('Pengeluaran'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemSpending(
    BuildContext context,
    WidgetRef ref,
    BarangSpending spending,
    ValueNotifier<List<BarangSpending>> items,
    int index,
  ) {
    final nominal = ref.read(formatCurrencyProvider(spending.nominal));

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colorPrimary,
        ),
        child: Center(
          child: Text(
            '${index + 1}',
            style: context.bodyLarge?.copyWith(
              color: context.colorOnPrimary,
            ),
          ),
        ),
      ),
      title: Text(
        '${spending.nameSpending} - ${spending.note ?? ''}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        nominal,
        style: context.bodyMedium,
      ),
      trailing: Transform.translate(
        offset: const Offset(16, 0),
        child: IconButton(
          onPressed: () {
            final currentList = items.value;
            currentList.remove(spending);
            items.value = [...currentList];
            return;
          },
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }

  num _getTotalSpending(List<BarangSpending> items) {
    num total = 0;
    for (final i in items) {
      total = total + (i.nominal ?? 0);
    }
    return total;
  }

  Future<File?> _openImagePicker(
    BuildContext context,
  ) async {
    final ImagePicker picker = ImagePicker();
    final result = await showModalActionSheet(
      title: 'Pilih foto menggunakan',
      context: context,
      actions: [
        SheetAction(
          key: 'photo',
          label: 'Ambil foto'.hardcoded,
          icon: Icons.camera_alt,
        ),
        SheetAction(
          key: 'galery',
          label: 'Pilih dari galeri'.hardcoded,
          icon: Icons.photo,
        ),
      ],
    );
    XFile? image;
    if (result == 'galery') {
      image = await picker.pickImage(source: ImageSource.gallery);
    } else if (result == 'photo') {
      image = await picker.pickImage(source: ImageSource.camera);
    } else {
      return null;
    }
    if (image == null) return null;
    final imageCompressed = await FlutterImageCompress.compressWithList(
      await image.readAsBytes(),
      quality: 10,
    );
    final tempDir = await getTemporaryDirectory();
    File file = await File('${tempDir.path}/${DateTime.timestamp()}').create();
    file.writeAsBytesSync(imageCompressed);
    return file;
  }
}
