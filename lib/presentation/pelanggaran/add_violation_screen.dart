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
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:syathiby/models/violation/violation.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddViolationScreen extends HookConsumerWidget {
  final String? type;

  const AddViolationScreen({super.key, this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(violationControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final violationController = ref.watch(violationControllerProvider);
    final fetchViolationType = ref.watch(
      fetchViolationTypeProvider(key: key, type: '$type'),
    );
    final date = useTextEditingController();
    final hour = useTextEditingController();
    final location = useTextEditingController();
    final detail = useTextEditingController();
    final imageSelected = useState<File?>((null));
    final violationSelected = useState<Pelanggaran?>((null));
    final studentSelected = useState<Siswa?>((null));

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addViolation() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final result = await ref
          .read(
            violationControllerProvider.notifier,
          )
          .addViolation(
            key: key,
            violationName: '${violationSelected.value?.namaPelanggaran}',
            date: date.text,
            hour: hour.text,
            location: location.text,
            studentName: '${studentSelected.value?.nis}',
            detail: detail.text,
            type: '$type',
            image: imageSelected.value,
          );
      if (result == null || !context.mounted) return;
      context.pop();
      context.showSuccessMessage(
        '${result.msg}! swipe refresh untuk mendapatkan data terbaru',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Pelanggaran'.hardcoded),
      ),
      body: Skeletonizer(
        enabled: fetchViolationType.isLoading,
        child: RefreshIndicator(
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
                          'Foto Pelanggaran',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      DropdownSearch<Siswa>(
                        selectedItem: studentSelected.value,
                        asyncItems: (String filter) {
                          return ref.watch(
                            fetchSearchStudentProvider(
                              key: key,
                              query: filter,
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
                        itemAsString: (item) => '${item.namaLengkap}',
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Nama Siswa',
                            labelText: 'Nama Siswa',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        validator: FormBuilderValidators.required(),
                        onChanged: (student) {
                          if (student == null) {
                            return;
                          }
                          studentSelected.value = student;
                        },
                      ),
                      const Gap(16),
                      DropdownSearch<Pelanggaran>(
                        items: fetchViolationType.valueOrNull ?? [],
                        selectedItem: violationSelected.value,
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
                        itemAsString: (item) => '${item.namaPelanggaran}',
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                              hintText: 'Nama Pelanggaran',
                              labelText: 'Nama Pelanggaran',
                              border: OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: Icon(Icons.warning)),
                        ),
                        validator: FormBuilderValidators.required(),
                        onChanged: (violation) {
                          if (violation == null) {
                            return;
                          }
                          violationSelected.value = violation;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: date,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Tanggal Pelanggaran'.hardcoded,
                          prefixIcon: const Icon(Icons.today),
                        ),
                        validator: FormBuilderValidators.compose(
                          [
                            FormBuilderValidators.required(),
                            FormBuilderValidators.date(),
                          ],
                        ),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selected == null) return;
                          final formatDate =
                              DateFormat('yyyy-MM-dd').format(selected);
                          date.text = formatDate;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: hour,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Jam pelanggaran'.hardcoded,
                          prefixIcon: const Icon(Icons.watch_later),
                        ),
                        validator: FormBuilderValidators.required(),
                        keyboardType: TextInputType.datetime,
                        onTap: () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selected == null) return;
                          hour.text = selected.format(context);
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: location,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Lokasi Pelanggaran'.hardcoded,
                          prefixIcon: const Icon(Icons.location_on),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: detail,
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Detail Pelanggaran'.hardcoded,
                          prefixIcon: const Icon(Icons.details),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed:
                            violationController.isLoading ? null : addViolation,
                        child: violationController.isLoading
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
