import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/event/event.dart';
import 'package:syathiby/presentation/laporan_aktivitas/activity_report_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';

class AddActivityReportScreen extends HookConsumerWidget {
  final String? type;
  final String? date;

  const AddActivityReportScreen({super.key, this.type, this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(activityReportControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final activityController = ref.watch(activityReportControllerProvider);
    final imageSelected = useState<File?>(null);
    final activityNameSelected = useState<Event?>(null);
    final description = useTextEditingController();

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addActivityReport() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (imageSelected.value == null) {
        context.showErrorMessage('Foto hasil pekerjaan harus diisi');
        return;
      }
      final result = await ref
          .read(
            activityReportControllerProvider.notifier,
          )
          .addActivityReport(
            key: key,
            activityName: '${activityNameSelected.value?.name_event}',
            description: description.text,
            type: '$type',
            image: imageSelected.value,
          );
      if (result == null || !context.mounted) return;
      context.showSuccessMessage(result.msg);
      ref.invalidate(
        fetchAllActivityReportProvider(
          key: key,
          dateStart: '$date',
          dateEnd: '$date',
          type: '$type',
        ),
      );
      context.pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Laporan Aktivitas'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchViolationTypeProvider(key: key, type: '$type').future,
        ),
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
                          Icons.camera_alt,
                          size: 50,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Center(
                      child: Text(
                        'Foto Hasil Pekerjaan',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    DropdownSearch<Event>(
                      selectedItem: activityNameSelected.value,
                      asyncItems: (String filter) {
                        return ref.watch(
                          fetchAllActivityNameProvider(
                            key: key,
                            type: '$type',
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
                      itemAsString: (item) => '${item.name_event}',
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: 'Nama Aktivitas',
                          labelText: 'Nama Aktivitas',
                          border: OutlineInputBorder(),
                          isDense: true,
                          prefixIcon: Icon(Icons.work),
                        ),
                      ),
                      validator: FormBuilderValidators.required(),
                      onChanged: (student) {
                        if (student == null) {
                          return;
                        }
                        activityNameSelected.value = student;
                      },
                    ),
                    const Gap(16),
                    TextFormField(
                      controller: description,
                      textInputAction: TextInputAction.done,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Keterangan'.hardcoded,
                        prefixIcon: const Icon(Icons.description),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                    const Gap(24),
                    FilledButton(
                      onPressed: activityController.isLoading
                          ? null
                          : addActivityReport,
                      child: activityController.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Text(
                              'Lapor Sekarang'.hardcoded,
                            ),
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
    XFile? image = await picker.pickImage(source: ImageSource.camera);
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
