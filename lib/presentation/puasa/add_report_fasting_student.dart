import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/fasting/fasting.dart';
import 'package:syathiby/presentation/kepengasuhan/parenting_score_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/presentation/puasa/fasting_student_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';

class AddReportFastingStudentScreen extends HookConsumerWidget {
  const AddReportFastingStudentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(parentingScoreControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final parentingScoreController =
        ref.watch(parentingScoreControllerProvider);
    final studentSelected = useState<Siswa?>(null);
    final dateSelected = useState<DateTime>(DateTime.now());
    final dateFormat = DateFormat('yyyy-MM-dd').format(dateSelected.value);
    final date = useTextEditingController(text: dateFormat);

    final fastingTypeSelected = useState<Puasa?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addFastingStudent() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (studentSelected.value == null) {
        context.showErrorMessage('Nama siswa harus diisi');
        return;
      }
      final result = await ref
          .read(fastingStudentControllerProvider.notifier)
          .addFastingStudent(
            key: key,
            studentId: '${studentSelected.value?.nis}',
            typeId: '${fastingTypeSelected.value?.jenisPuasa}',
            classId: '${studentSelected.value?.idKelas}',
            hostelId: '${studentSelected.value?.idAsrama}',
            date: date.text,
          );
      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllFastingStudentProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Siswa Puasa'.hardcoded),
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
                  const SizedBox(height: 16),
                  DropdownSearch<Puasa>(
                    asyncItems: (text) => ref.read(
                      fetchAllFastingTypeProvider(
                        key: key,
                      ).future,
                    ),
                    selectedItem: fastingTypeSelected.value,
                    itemAsString: (item) => '${item.jenisPuasa}',
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Jenis Puasa',
                        labelText: 'Jenis Puasa',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.type_specimen),
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                    onChanged: (selected) {
                      fastingTypeSelected.value = selected;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: date,
                    readOnly: true,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Tanggal Puasa'.hardcoded,
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
                        firstDate: DateTime(2000),
                        initialDate: dateSelected.value,
                        lastDate: DateTime.now(),
                      );
                      if (selected == null) return;
                      final formatDate =
                          DateFormat('yyyy-MM-dd').format(selected);
                      date.text = formatDate;
                      dateSelected.value = selected;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: parentingScoreController.isLoading
                        ? null
                        : addFastingStudent,
                    child: parentingScoreController.isLoading
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
    );
  }
}
