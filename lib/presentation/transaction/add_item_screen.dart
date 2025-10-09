import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/unit/unit.dart';
import '../data_obat/medicine_controller.dart';

class AddItemScreen extends HookConsumerWidget {
  const AddItemScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(transactionControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final formatter = NumberFormat.currency(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp',
    );
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final transactionController = ref.watch(transactionControllerProvider);
    final name = useTextEditingController();
    final barcode = useTextEditingController();
    final sellingPrice = useTextEditingController();
    final firstStock = useTextEditingController(text: '0');
    final warningStock = useTextEditingController(text: '0');
    final haveStock = useState<String>('0');
    final unitSelected = useState<Unit?>(null);
    final imageSelected =
        useState<(File? localFile, String? imageUrl)>((null, null));
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addItem() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final future = ref.read(transactionControllerProvider.notifier).addItem(
            key: key,
            unit: '${unitSelected.value?.name_unit}',
            alertStock: warningStock.text,
            name: name.text,
            stock: firstStock.text,
            haveStock: haveStock.value,
            sellingPrice: '${formatter.parse(sellingPrice.text)}',
            barcode: barcode.text,
            image: imageSelected.value.$1,
          );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage('Berhasil menambah produk');
      context.pop();
      ref.invalidate(fetchAllItemProvider);
    }

    debugPrint('$transactionController');

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tambah Produk'.hardcoded),
        ),
        body: ListView(
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InkWell(
                      onTap: () async {
                        final file = await _openImagePicker(context);
                        imageSelected.value = (file, null);
                      },
                      child: AdvancedAvatar(
                        size: 120,
                        decoration: BoxDecoration(
                          color: context.colorSurface,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.colorOutline,
                          ),
                        ),
                        image: imageSelected.value.$1 != null
                            ? FileImage(
                                imageSelected.value.$1!,
                              ) as ImageProvider
                            : NetworkImage('${imageSelected.value.$2}'),
                        child: const Icon(
                          Icons.image,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Center(
                      child: Text(
                        'Foto barang (jika ada)',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: barcode,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Barcode (opsional)'.hardcoded,
                        hintText: 'Barcode (opsional)'.hardcoded,
                        prefixIcon: const Icon(Icons.barcode_reader),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: name,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Nama Barang atau Jasa'.hardcoded,
                        hintText: 'Nama Barang atau Jasa'.hardcoded,
                        prefixIcon: const Icon(Icons.add_box),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<Unit>(
                      selectedItem: unitSelected.value,
                      asyncItems: (String filter) {
                        return ref.watch(
                          fetchAllUnitProvider(
                            key: key,
                          ).future,
                        );
                      },
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                            hintText: 'Pencarian...',
                            prefixIcon: const Icon(Icons.search),
                          ),
                        ),
                      ),
                      itemAsString: (item) => '${item.name_unit}',
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Pilih satuan unit',
                          labelText: 'Pilih satuan unit',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.ad_units),
                        ),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (item) {
                        unitSelected.value = item;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: sellingPrice,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Perkiraan Harga'.hardcoded,
                        hintText: 'Perkiraan Harga'.hardcoded,
                        prefixIcon: const Icon(Icons.monetization_on),
                      ),
                      inputFormatters: [
                        CurrencyTextInputFormatter.currency(
                          locale: 'id',
                          decimalDigits: 0,
                          symbol: 'Rp',
                        )
                      ],
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      value: haveStock.value == '1',
                      contentPadding: const EdgeInsets.only(left: 16),
                      title: const Text('Mempunyai Stok?'),
                      onChanged: (value) {
                        haveStock.value = value == true ? '1' : '0';
                      },
                    ),
                    const SizedBox(height: 4),
                    Visibility(
                      visible: haveStock.value == '1',
                      child: Column(
                        children: [
                          TextFormField(
                            controller: firstStock,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              labelText: 'Stok Awal'.hardcoded,
                              hintText: 'Stok Awal'.hardcoded,
                              prefixIcon: const Icon(Icons.numbers),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: warningStock,
                            decoration: InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              labelText: 'Stok Peringatan'.hardcoded,
                              hintText: 'Stok Peringatan'.hardcoded,
                              prefixIcon: const Icon(Icons.warning),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          transactionController.isLoading ? null : addItem,
                      child: transactionController.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Text('Simpan'.hardcoded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
