import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/tahfidz/tahfidz.dart';
import 'package:syathiby/presentation/kepengasuhan/parenting_score_controller.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/presentation/tahfidzh/tahfidz_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/student/siswa.dart';

class UpsertParentingScoreScreen extends HookConsumerWidget {
  final Tahfidz? tahfidz;

  const UpsertParentingScoreScreen({super.key, this.tahfidz});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(parentingScoreControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final parentingScoreController =
        ref.watch(parentingScoreControllerProvider);
    final grade = useTextEditingController();
    final detail = useTextEditingController();
    final studentSelected = useState<Siswa?>(null);
    final parentingTypeSelected = useState<Tahfidz?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = tahfidz != null;

    useEffect(() {
      if (!isUpdate) return;
      detail.text = tahfidz?.detail ?? '';
      grade.text = tahfidz?.nilai ?? '';
      studentSelected.value = Siswa(
        nis: '${tahfidz?.nis}',
        namaLengkap: '${tahfidz?.nama_siswa}',
      );
      parentingTypeSelected.value = tahfidz?.copyWith(
        waktu_tahfidz: tahfidz?.jenis_tahfidz,
      );
      return null;
    }, [fetchDetailTahfidz]);

    Future<void> addParentingScore() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (studentSelected.value == null) {
        context.showErrorMessage('Nama siswa harus diisi');
        return;
      }
      final future = isUpdate
          ? ref
              .read(parentingScoreControllerProvider.notifier)
              .updateScoreParenting(
                key: key,
                tahfidzId: '${tahfidz?.id_tahfidz}',
                typeId: '${parentingTypeSelected.value?.id_tahfidz}',
                score: grade.text,
                detail: detail.text.isEmpty ? null : detail.text,
              )
          : ref
              .read(parentingScoreControllerProvider.notifier)
              .addScoreParenting(
                key: key,
                studentId: '${studentSelected.value?.nis}',
                typeId: '${parentingTypeSelected.value?.id_tahfidz}',
                classId: '${studentSelected.value?.idKelas}',
                score: grade.text,
                detail: detail.text.isEmpty ? null : detail.text,
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllScoreParentingProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Penilaian'.hardcoded),
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
                  DropdownSearch<Tahfidz>(
                    asyncItems: (text) => ref.read(
                      fetchAllParentingTypeProvider(
                        key: key,
                        type: 'Kepengasuhan',
                      ).future,
                    ),
                    selectedItem: parentingTypeSelected.value,
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
                      parentingTypeSelected.value = selected;
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
                    onPressed: parentingScoreController.isLoading
                        ? null
                        : addParentingScore,
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
