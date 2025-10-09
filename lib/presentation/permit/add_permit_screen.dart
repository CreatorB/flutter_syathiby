import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/presentation/permit/permit_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddPermitScreen extends HookConsumerWidget {
  const AddPermitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(permitControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final permitController = ref.watch(permitControllerProvider);
    final fetchPermitType = ref.watch(
      fetchPermitTypeProvider(key: key, type: 'staff'),
    );
    final permitName = useTextEditingController();
    final permitDate = useTextEditingController();
    final howManyDays = useTextEditingController();
    final permitDetail = useTextEditingController();
    final imageSelected = useState<File?>(null);

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addPermit() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final result = await ref
          .read(
            permitControllerProvider.notifier,
          )
          .addPermit(
            key: key,
            permitName: permitName.text,
            date: permitDate.text,
            day: howManyDays.text,
            detail: permitDetail.text,
            image: imageSelected.value,
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchPermitListProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Izin'.hardcoded),
      ),
      body: Skeletonizer(
        enabled: fetchPermitType.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref
              .refresh(fetchPermitTypeProvider(key: key, type: 'staff').future),
          child: ListView(
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
                          imageSelected.value = file;
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
                          image: imageSelected.value != null
                              ? FileImage(
                                  imageSelected.value!,
                                ) as ImageProvider
                              : null,
                          child: const Icon(
                            Icons.image,
                            size: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Center(
                        child: Text(
                          'Dokumen Pendukung',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      TextFormField(
                        controller: permitName,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Jenis Izin'.hardcoded,
                          prefixIcon: const Icon(Icons.info),
                          suffixIcon: const Icon(Icons.expand_more),
                        ),
                        validator: FormBuilderValidators.required(),
                        keyboardType: TextInputType.text,
                        onTap: () async {
                          final items = fetchPermitType.valueOrNull;
                          if (items == null) return;
                          final selected = await showModalActionSheet<Permit>(
                            context: context,
                            title: 'Jenis Izin',
                            actions: items
                                .map((e) => SheetAction(
                                    key: e, label: '${e.namePermit}'))
                                .toList(),
                          );
                          if (selected == null) return;
                          permitName.text = '${selected.namePermit}';
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: permitDate,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Tanggal izin'.hardcoded,
                          prefixIcon: const Icon(Icons.today),
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.date(),
                            FormBuilderValidators.required(),
                          ],
                        ),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selected == null) return;
                          final formatDate =
                              DateFormat('yyyy-MM-dd').format(selected);
                          permitDate.text = formatDate;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: howManyDays,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Berapa hari?'.hardcoded,
                          prefixIcon: const Icon(Icons.calendar_view_day),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.integer(),
                        ]),
                        keyboardType: TextInputType.number,
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: permitDetail,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Detail Izin'.hardcoded,
                          prefixIcon: const Icon(Icons.details),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed:
                            permitController.isLoading ? null : addPermit,
                        child: permitController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'Ajukan'.hardcoded,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
