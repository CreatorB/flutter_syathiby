import 'package:adaptive_dialog/adaptive_dialog.dart';
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
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/presentation/izin_santri/student_permit_controller.dart';
import 'package:syathiby/presentation/permit/permit_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/student/siswa.dart';
import '../pelanggaran/violation_controller.dart';

class AddStudentPermitScreen extends HookConsumerWidget {
  const AddStudentPermitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(studentPermitControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final studentPermitController = ref.watch(studentPermitControllerProvider);
    final fetchPermitType = ref.watch(
      fetchPermitTypeProvider(key: key, type: 'santri'),
    );
    final permitId = useTextEditingController();
    final permitName = useTextEditingController();
    final permitDate = useTextEditingController();
    final howManyDays = useTextEditingController();
    final permitDetail = useTextEditingController();
    final studentSelected = useState<Siswa?>(null);

    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    Future<void> addStudentPermit() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final result = await ref
          .read(
            studentPermitControllerProvider.notifier,
          )
          .addPermit(
            key: key,
            permitName: permitName.text,
            date: permitDate.text,
            day: howManyDays.text,
            detail: permitDetail.text,
            studentId: '${studentSelected.value?.nis}',
            classId: '${studentSelected.value?.idKelas}',
            permitId: permitId.text,
          );

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchStudentPermitListProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Izin'.hardcoded),
      ),
      body: Skeletonizer(
        enabled: fetchPermitType.isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.refresh(
            fetchPermitTypeProvider(key: key, type: 'santri').future,
          ),
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 16,
              ),
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
                const SizedBox(height: 16.0),
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
                          .map((e) =>
                              SheetAction(key: e, label: '${e.namePermit}'))
                          .toList(),
                    );
                    if (selected == null) return;
                    permitName.text = '${selected.namePermit}';
                    permitId.text = '${selected.idPermit}';
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
                    labelText: 'Izin berapa hari?'.hardcoded,
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
                  onPressed: studentPermitController.isLoading
                      ? null
                      : addStudentPermit,
                  child: studentPermitController.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Text(
                          'Tambah Izin'.hardcoded,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
