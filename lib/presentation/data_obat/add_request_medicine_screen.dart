import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/presentation/data_obat/medicine_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class AddRequestMedicineScreen extends HookConsumerWidget {
  final Product medicine;

  const AddRequestMedicineScreen({
    super.key,
    required this.medicine,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      medicineControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final controller = ref.watch(medicineControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final description = useTextEditingController();
    final key = '${currentUser?.key}';
    final medicines = useState<List<Product>>(
      [
        medicine.copyWith(amount: 1),
      ],
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Permintaan Obat'),
          actions: [
            TextButton(
              onPressed: () async {
                final items = medicines.value
                    .map(
                      (e) => Barang(
                        idProduct: e.idProduct,
                        amountProduct: e.amount,
                        newPrice: '0',
                      ),
                    )
                    .toList();

                final result = await ref
                    .read(medicineControllerProvider.notifier)
                    .addMedicineRequest(
                      requestTransaction: RequestTransaction(
                        key: key,
                        note: description.text,
                        paymentAmount: 0,
                        paymentType: 1,
                        totalOrder: 0,
                        product: items,
                      ),
                    );
                if (result == null || !context.mounted) return;
                context.showSuccessMessage(
                  'Berhasil menambah permohonan obat ${result.invoice}',
                );
                ref.invalidate(historyMedicineRequestProvider);
                context.goNamed(AppRoute.medicineRequest.name);
              },
              child: const Text('Simpan'),
            )
          ],
        ),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: medicines.value.length,
              itemBuilder: (ctx, index) {
                final medicine = medicines.value.elementAt(index);
                return _buildItemMedicine(context, medicine, medicines, index);
              },
            ),
            Visibility(
              visible: controller.isLoading,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DropdownSearch<Product>(
                  asyncItems: (String filter) {
                    return ref.watch(
                      fetchAllMedicineProvider(
                        key: key,
                        haveStock: '',
                        trx: 'YES',
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
                  itemAsString: (item) => '${item.nameProduct}',
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Tambah Obat',
                      labelText: 'Tambah Obat',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.health_and_safety),
                    ),
                  ),
                  onChanged: (item) {
                    if (item == null) {
                      return;
                    }
                    final currentIndex = medicines.value.indexWhere(
                      (element) => element.idProduct == item.idProduct,
                    );
                    if (currentIndex != -1) {
                      context.showErrorMessage(
                        'obat sudah ada, silahkan rubah kuantitas',
                      );
                      return;
                    }
                    medicines.value.add(
                      item.copyWith(
                        amount: 1,
                      ),
                    );
                    medicines.value = [...medicines.value];
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: description,
                  textInputAction: TextInputAction.done,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    labelText: 'Keterangan Tambahan'.hardcoded,
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: FormBuilderValidators.required(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemMedicine(
    BuildContext context,
    Product medicine,
    ValueNotifier<List<Product>> medicines,
    int index,
  ) {
    return ListTile(
      leading: CustomAvatar(
        name: '${medicine.nameProduct}',
        imageUrl: '${medicine.img}',
        size: 40,
      ),
      title: Text(
        '${medicine.nameProduct}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        '${medicine.description}',
        style: context.bodyMedium,
      ),
      trailing: Transform.translate(
        offset: const Offset(8, 0),
        child: InputQty.double(
          initVal: medicine.amount ?? 1,
          onQtyChanged: (qty) {
            if (qty <= 0) {
              final currentList = medicines.value;
              currentList.remove(medicine);
              medicines.value = [...currentList];
              return;
            }
            final currentItem = medicine.copyWith(amount: qty);
            medicines.value[index] = currentItem;
            medicines.value = [...medicines.value];
          },
        ),
      ),
    );
  }
}
