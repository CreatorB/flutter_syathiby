import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/tahfidz/tahfidz.dart';
import 'package:syathiby/presentation/tahfidzh/tahfidz_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';

class UpsertTahfidzGradeScreen extends HookConsumerWidget {
  final Tahfidz? tahfidz;

  const UpsertTahfidzGradeScreen({super.key, this.tahfidz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(tahfidzControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final tahfidzController = ref.watch(tahfidzControllerProvider);
    final grade = useTextEditingController();
    final detail = useTextEditingController();
    final studentSelected = useState<Siswa?>(null);
    final tahfidzGradeTypeSelected = useState<Tahfidz?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = tahfidz != null;

    useEffect(() {
      if (!isUpdate) return;
      debugPrint('CEK NILAI: $tahfidz');
      detail.text = tahfidz?.detail ?? '';
      grade.text = tahfidz?.halaman ?? '';
      studentSelected.value = Siswa(
        nis: '${tahfidz?.nis}',
        namaLengkap: '${tahfidz?.nama_siswa}',
      );
      tahfidzGradeTypeSelected.value = tahfidz?.copyWith(
        waktu_tahfidz: tahfidz?.jenis_tahfidz,
      );
      return null;
    }, [fetchDetailTahfidz]);

    Future<void> addPermit() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (studentSelected.value == null) {
        context.showErrorMessage('Nama siswa harus diisi');
      }
      final future = isUpdate
          ? ref
              .read(tahfidzControllerProvider.notifier)
              .editTahfidzGradeStudent(
                key: key,
                tahfidzId: '${tahfidz?.id_tahfidz}',
                gradeTypeId: '${tahfidzGradeTypeSelected.value?.waktu_tahfidz}',
                grade: grade.text,
                detail: detail.text.isEmpty ? null : detail.text,
              )
          : ref.read(tahfidzControllerProvider.notifier).insertGradeTahfidz(
                key: key,
                studentId: '${studentSelected.value?.nis}',
                gradeTypeId: '${tahfidzGradeTypeSelected.value?.waktu_tahfidz}',
                classId: '${studentSelected.value?.idKelas}',
                grade: grade.text,
                detail: detail.text.isEmpty ? null : detail.text,
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllTahfidzGradeProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Hafalan'.hardcoded),
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
                  SearchableDropdown<Siswa>.paginated(
                    isEnabled: !isUpdate,
                    hasTrailingClearIcon: !isUpdate,
                    initialValue: studentSelected.value == null
                        ? null
                        : SearchableDropdownMenuItem(
                            value: studentSelected.value,
                            label: '${studentSelected.value?.namaLengkap}',
                            child: Text(
                              studentSelected.value?.namaLengkap ?? '',
                            ),
                          ),
                    hintText: const Text('  Nama Siswa'),
                    leadingIcon: const Icon(Icons.person),
                    backgroundDecoration: (child) => Card.outlined(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                          width: 1,
                          color: context.colorOutline,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4,
                        ),
                        child: child,
                      ),
                    ),
                    paginatedRequest: (int page, String? searchKey) async {
                      var paginatedList = await ref.watch(
                        fetchStudentTahfidzFilterProvider(
                          key: key,
                          page: page,
                        ).future,
                      );
                      if (searchKey != null) {
                        final filteredList = paginatedList.where(
                          (element) {
                            final isFind = element.namaLengkap
                                    ?.toLowerCase()
                                    .contains(searchKey.toLowerCase()) ??
                                false;
                            return isFind;
                          },
                        ).toList();
                        paginatedList = filteredList;
                      }
                      return paginatedList
                          .map(
                            (e) => SearchableDropdownMenuItem(
                              value: e,
                              label: e.namaLengkap ?? '',
                              child: Text(e.namaLengkap ?? ''),
                            ),
                          )
                          .toList();
                    },
                    onChanged: (value) {
                      studentSelected.value = value;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<Tahfidz>(
                    asyncItems: (text) => ref.read(
                      fetchTahfidzGradeTypeProvider(key: key, type: 'santri')
                          .future,
                    ),
                    selectedItem: tahfidzGradeTypeSelected.value,
                    itemAsString: (item) => '${item.waktu_tahfidz}',
                    dropdownDecoratorProps: const DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        hintText: 'Jenis Penilaian',
                        labelText: 'Jenis Penilaian',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.type_specimen),
                      ),
                    ),
                    validator: FormBuilderValidators.required(),
                    onChanged: (selected) {
                      tahfidzGradeTypeSelected.value = selected;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: grade,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Nilai'.hardcoded,
                      prefixIcon: const Icon(Icons.grade),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                      FormBuilderValidators.integer(),
                    ]),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: detail,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Catatan'.hardcoded,
                      prefixIcon: const Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: tahfidzController.isLoading ? null : addPermit,
                    child: tahfidzController.isLoading
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
