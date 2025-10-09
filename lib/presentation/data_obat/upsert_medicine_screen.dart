import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/medicine/medicine.dart';
import 'package:syathiby/models/unit/unit.dart';
import 'package:syathiby/presentation/data_obat/medicine_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';

class UpsertMedicineScreen extends HookConsumerWidget {
  final DataObat? medicine;

  const UpsertMedicineScreen({super.key, this.medicine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(medicineControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final medicineController = ref.watch(medicineControllerProvider);
    final name = useTextEditingController();
    final detail = useTextEditingController();
    final unitTypeSelected = useState<Unit?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = medicine != null;

    useEffect(() {
      if (!isUpdate) return;
      detail.text = medicine?.description ?? '';
      name.text = medicine?.name ?? '';
      unitTypeSelected.value = Unit(
        name_unit: '${medicine?.unit}',
      );
      return null;
    }, []);

    Future<void> addMedicine() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      if (unitTypeSelected.value == null) {
        context.showErrorMessage('Satuan unit harus diisi');
        return;
      }
      final future = isUpdate
          ? ref.read(medicineControllerProvider.notifier).updateMedicine(
                key: key,
                medicineId: '${medicine?.id_data_obat}',
                unit: '${unitTypeSelected.value?.name_unit}',
                name: name.text,
                description: detail.text,
                stock: '0',
              )
          : ref.read(medicineControllerProvider.notifier).addMedicine(
                key: key,
                unit: '${unitTypeSelected.value?.name_unit}',
                name: name.text,
                description: detail.text,
                stock: '0',
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllMedicineDataProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Obat'.hardcoded),
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
                  TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Nama Obat'.hardcoded,
                      prefixIcon: const Icon(Icons.medical_information),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  DropdownSearch<Unit>(
                    selectedItem: unitTypeSelected.value,
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
                      unitTypeSelected.value = item;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: detail,
                    decoration: InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      labelText: 'Keterangan'.hardcoded,
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        medicineController.isLoading ? null : addMedicine,
                    child: medicineController.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            isUpdate ? 'Edit' : 'Simpan'.hardcoded,
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
