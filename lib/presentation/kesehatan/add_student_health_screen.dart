import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:syathiby/presentation/kesehatan/student_health_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/health/diagnose.dart';

class AddStudentHealthScreen extends HookConsumerWidget {
  final String? studentHealthId;
  const AddStudentHealthScreen({super.key, this.studentHealthId});

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

    // Load existing data when editing
    final isEdit = studentHealthId != null && studentHealthId!.isNotEmpty;
    final existingDetail = isEdit
        ? ref.watch(fetchDetailStudentHealthProvider(
            key: key,
            studentHealthId: studentHealthId!,
          ))
        : null;
    final existing = existingDetail?.valueOrNull?.firstOrNull;

    final imageSelected = useState<File?>(null);
    final studentSelected = useState<Siswa?>(null);
    final healthTypeSelected = useState<Diagnosa?>((null));
    final complaint = useTextEditingController();
    final date = useTextEditingController();
    final hour = useTextEditingController();
    final detail = useTextEditingController();
    final istirahatMulai = useTextEditingController();
    final istirahatSelesai = useTextEditingController();
    final pickedUp = useTextEditingController();
    final tellParent = useTextEditingController();
    final statusAbsen = useState<String>('sakit');

    // Populate controllers when editing existing record (only once)
    useEffect(() {
      if (existing == null) return null;
      if (complaint.text.isEmpty) complaint.text = existing.keluhan ?? '';
      if (date.text.isEmpty) {
        final d = '${existing.date ?? ''}';
        date.text = d.length >= 10 ? d.substring(0, 10) : d;
      }
      if (hour.text.isEmpty) hour.text = '${existing.hour ?? ''}';
      if (detail.text.isEmpty) detail.text = '${existing.penanganan ?? ''}';
      if (istirahatMulai.text.isEmpty) istirahatMulai.text = '${existing.istirahatMulai ?? ''}';
      if (istirahatSelesai.text.isEmpty) istirahatSelesai.text = '${existing.istirahatSelesai ?? ''}';
      if (pickedUp.text.isEmpty) pickedUp.text = '${existing.dijemput ?? ''}';
      if (tellParent.text.isEmpty) tellParent.text = '${existing.info_ortu ?? ''}';
      // Diagnosa match by name
      final types = fetchHealthType.valueOrNull ?? [];
      final match = types.where((t) => t.name_diagnosa == existing.diagnosa).firstOrNull;
      if (match != null && healthTypeSelected.value == null) {
        healthTypeSelected.value = match;
      }
      // Status absen - default 'sakit', preserve from existing when editing
      final existingStatus = '${existing.statusAbsen ?? ''}';
      if (existingStatus.isNotEmpty && statusAbsen.value == 'sakit') {
        statusAbsen.value = existingStatus;
      }
      return null;
    }, [existing]);

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> submitHealth() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (isEdit && studentHealthId != null) {
        final result = await ref
            .read(studentHealthControllerProvider.notifier)
            .updateStudentHealth(
              key: key,
              studentHealthId: studentHealthId!,
              diagnose: '${healthTypeSelected.value?.name_diagnosa}',
              complaint: complaint.text,
              date: date.text,
              hour: hour.text,
              handling: detail.text,
              studentName: '${studentSelected.value?.nis ?? existing?.staff ?? ''}',
              classId: '${studentSelected.value?.idKelas ?? existing?.kelas ?? ''}',
              pickedUp: pickedUp.text,
              tellParent: tellParent.text,
              istirahatMulai: istirahatMulai.text,
              istirahatSelesai: istirahatSelesai.text,
              statusAbsen: statusAbsen.value,
              image: imageSelected.value,
            );
        if (result == null || !context.mounted) return;
        context.pop();
        context.showSuccessMessage(result.msg.isNotEmpty ? result.msg : 'Data diperbarui');
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
            istirahatMulai: istirahatMulai.text,
            istirahatSelesai: istirahatSelesai.text,
            statusAbsen: statusAbsen.value,
            image: imageSelected.value,
          );
      if (result == null || !context.mounted) return;
      context.pop();
      context.showSuccessMessage(result.msg);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Kesehatan'.hardcoded : 'Input Kesehatan'.hardcoded),
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
                      const SizedBox(height: 8.0),
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
                        controller: istirahatMulai,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Istirahat Mulai'.hardcoded,
                          prefixIcon: const Icon(Icons.play_circle_outline),
                          suffixIcon: istirahatMulai.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => istirahatMulai.clear(),
                                ),
                        ),
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year - 1),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate == null) return;
                          if (!context.mounted) return;
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime == null) return;
                          final dt = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          istirahatMulai.text = DateFormat('yyyy-MM-dd HH:mm').format(dt);
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: istirahatSelesai,
                        readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Istirahat Selesai'.hardcoded,
                          prefixIcon: const Icon(Icons.stop_circle_outlined),
                          suffixIcon: istirahatSelesai.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => istirahatSelesai.clear(),
                                ),
                        ),
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(DateTime.now().year - 1),
                            initialDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate == null) return;
                          if (!context.mounted) return;
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (selectedTime == null) return;
                          final dt = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );
                          istirahatSelesai.text = DateFormat('yyyy-MM-dd HH:mm').format(dt);
                        },
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
                        textInputAction: TextInputAction.newline,
                        maxLines: 3,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Detail Penanganan'.hardcoded,
                          prefixIcon: const Icon(Icons.medical_services_outlined),
                        ),
                        validator: FormBuilderValidators.required(),
                      ),
                      const Gap(16),
                      DropdownButtonFormField<String>(
                        initialValue: statusAbsen.value,
                        items: const [
                          DropdownMenuItem(
                            value: 'sakit',
                            child: Text('Sakit'),
                          ),
                          DropdownMenuItem(
                            value: 'hadir',
                            child: Text('Hadir'),
                          ),
                          DropdownMenuItem(
                            value: 'izin',
                            child: Text('Izin'),
                          ),
                          DropdownMenuItem(
                            value: 'alfa',
                            child: Text('Alfa'),
                          ),
                        ],
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          labelText: 'Status Absen Santri'.hardcoded,
                          prefixIcon: const Icon(Icons.assignment_turned_in_outlined),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            statusAbsen.value = value;
                          }
                        },
                      ),
                      const Gap(16),
                      TextFormField(
                        controller: tellParent,
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
                      ),
                      const Gap(24),
                      FilledButton(
                        onPressed: studentHealthController.isLoading
                            ? null
                            : submitHealth,
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
}
