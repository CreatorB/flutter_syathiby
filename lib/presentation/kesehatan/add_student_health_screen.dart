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
import 'package:syathiby/presentation/kesehatan/paging_student_health_controller.dart';
import 'package:syathiby/presentation/kesehatan/student_health_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/health/diagnose.dart';

class AddStudentHealthScreen extends HookConsumerWidget {
  const AddStudentHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(studentHealthControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final studentHealthController = ref.watch(studentHealthControllerProvider);
    final fetchHealthType = ref.watch(
      fetchHealthTypeProvider(key: key),
    );
    final imageSelected = useState<File?>((null));
    final studentSelected = useState<Siswa?>((null));
    final healthTypeSelected = useState<Diagnosa?>((null));
    final complaint = useTextEditingController();
    final date = useTextEditingController();
    final hour = useTextEditingController();
    final detail = useTextEditingController();
    final howManyDays = useTextEditingController();
    final pickedUp = useTextEditingController();
    final tellParent = useTextEditingController();

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addStudentHealth() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final result = await ref
          .read(
            studentHealthControllerProvider.notifier,
          )
          .addStudentHealth(
            key: key,
            diagnose: '${healthTypeSelected.value?.name_diagnosa}',
            complaint: complaint.text,
            date: date.text,
            hour: hour.text,
            handling: detail.text,
            studentName: '${studentSelected.value?.nis}',
            classId: '${studentSelected.value?.idKelas}',
            pickedUp: pickedUp.text,
            tellParent: tellParent.text,
            rest: howManyDays.text,
            image: imageSelected.value,
          );
      if (result == null || !context.mounted) return;
      context.pop();
      context.showSuccessMessage(result.msg);
      ref.invalidate(pagingStudentHealthControllerProvider(key: key));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Kesehatan'.hardcoded),
      ),
      body: Skeletonizer(
        enabled: fetchHealthType.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchHealthTypeProvider(key: key).future,
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
                          'Foto Pendukung (Opsional)',
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
                        itemAsString: (item) => '${item.namaLengkap} - ${item.kelas}',
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
                      DropdownSearch<Diagnosa>(
                        selectedItem: healthTypeSelected.value,
                        items: fetchHealthType.valueOrNull ?? [],
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
                        itemAsString: (item) => '${item.name_diagnosa}',
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Jenis Penyakit',
                            labelText: 'Jenis Penyakit',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.warning),
                          ),
                        ),
                        validator: FormBuilderValidators.required(),
                        onChanged: (healthType) {
                          if (healthType == null) {
                            return;
                          }
                          healthTypeSelected.value = healthType;
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: complaint,
                        textInputAction: TextInputAction.done,
                        maxLines: 3,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Keluhan Siswa'.hardcoded,
                          prefixIcon: const Icon(Icons.question_answer),
                        ),
                        validator: FormBuilderValidators.required(),
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
                          labelText: 'Tanggal Pemeriksaan'.hardcoded,
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
                          labelText: 'Jam Pemeriksaan'.hardcoded,
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
                        controller: howManyDays,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Jumlah Waktu Istirahat'.hardcoded,
                          prefixIcon: const Icon(Icons.numbers),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                        ]),
                      ),
                      const Gap(16),
                      DropdownSearch<String>(
                        selectedItem:
                            pickedUp.text.isEmpty ? null : pickedUp.text,
                        items: const ['Tidak Perlu', 'Perlu'],
                        popupProps: const PopupProps.menu(),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Perlu dijemput?',
                            labelText: 'Perlu dijemput?',
                            border: OutlineInputBorder(),
                            isDense: true,
                            prefixIcon: Icon(Icons.emoji_transportation),
                          ),
                        ),
                        validator: FormBuilderValidators.required(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          pickedUp.text = value;
                        },
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
                          labelText: 'Informasi untuk orang tua'.hardcoded,
                          prefixIcon: const Icon(Icons.info),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed: studentHealthController.isLoading
                            ? null
                            : addStudentHealth,
                        child: studentHealthController.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : Text(
                                'Proses'.hardcoded,
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
