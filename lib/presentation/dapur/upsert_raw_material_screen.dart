import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../models/unit/unit.dart';
import '../data_obat/medicine_controller.dart';

class UpsertRawMaterialScreen extends HookConsumerWidget {
  final RawMaterial? rawMaterial;

  const UpsertRawMaterialScreen({
    super.key,
    this.rawMaterial,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = CurrencyTextInputFormatter.currency(
      locale: 'id',
      decimalDigits: 0,
      symbol: 'Rp',
    );

    ref.listen(kitchenControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final kitchenController = ref.watch(kitchenControllerProvider);
    final name = useTextEditingController();
    final price = useTextEditingController();
    final stock = useTextEditingController();
    final description = useTextEditingController();
    final unitTypeSelected = useState<Unit?>(null);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final isUpdate = rawMaterial != null;

    useEffect(() {
      if (!isUpdate) return;
      name.text = rawMaterial?.name ?? '';
      price.text =
          formatter.formatDouble(double.tryParse('${rawMaterial?.price}') ?? 0);
      stock.text = '${rawMaterial?.stock}';
      description.text = rawMaterial?.description ?? '';
      unitTypeSelected.value = Unit(
        name_unit: '${rawMaterial?.unit}',
      );
      return null;
    }, []);

    Future<void> upsertInventory() async {
      if (!formKey.currentState!.validate()) {
        return;
      }
      final future = isUpdate
          ? ref.read(kitchenControllerProvider.notifier).editRawMaterial(
                key: key,
                id: '${rawMaterial?.idRawMaterial}',
                name: name.text,
                description: description.text,
                stock: double.parse(stock.text),
                sellPrice: formatter.numberFormat.parse(price.text).toDouble(),
                unit: '${unitTypeSelected.value?.name_unit}',
              )
          : ref.read(kitchenControllerProvider.notifier).addRawMaterial(
                key: key,
                name: name.text,
                description: description.text,
                stock: double.parse(stock.text),
                sellPrice: formatter.numberFormat.parse(price.text).toDouble(),
                unit: '${unitTypeSelected.value?.name_unit}',
              );
      final result = await future;

      if (result == null || !context.mounted) return;
      context.showSuccessMessage(
        result.msg,
      );
      context.pop();
      ref.invalidate(fetchAllRawMaterialProvider);
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${isUpdate ? 'Ubah' : 'Tambah'} Bahan Baku'.hardcoded),
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
                        labelText: 'Nama Bahan Baku'.hardcoded,
                        prefixIcon: const Icon(Icons.fastfood),
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
                      controller: price,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Harga Bahan Baku'.hardcoded,
                        prefixIcon: const Icon(Icons.monetization_on),
                      ),
                      inputFormatters: [
                        formatter,
                      ],
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                      ]),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: stock,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Stock Awal'.hardcoded,
                        prefixIcon: const Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: description,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        labelText: 'Keterangan'.hardcoded,
                        prefixIcon: const Icon(Icons.description),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed:
                          kitchenController.isLoading ? null : upsertInventory,
                      child: kitchenController.isLoading
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
      ),
    );
  }
}
