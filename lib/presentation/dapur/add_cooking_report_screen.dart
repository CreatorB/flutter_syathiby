import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/allocation/allocation.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class AddCokingReportScreen extends HookConsumerWidget {
  const AddCokingReportScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      kitchenControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final controller = ref.watch(kitchenControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final description = useTextEditingController();
    final key = '${currentUser?.key}';
    final cookingTimeSelected = useState<Allocation?>(null);
    final cookingItems = useState<List<Product>>([]);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laporan Masak'),
          actions: [
            TextButton(
              onPressed: () async {
                if (cookingItems.value.isEmpty) {
                  context.showErrorMessage(
                    'Menu masakan masih kosong, silahkan ditambah terlebih dahulu',
                  );
                  return;
                }
                if (cookingTimeSelected.value == null) {
                  context.showErrorMessage('Waktu memasak tidak boleh kosong');
                  return;
                }
                final items = cookingItems.value
                    .map(
                      (e) => Barang(
                        idProduct: e.idProduct,
                        amountProduct: e.amount,
                        newPrice: '0',
                      ),
                    )
                    .toList();

                final result = await ref
                    .read(kitchenControllerProvider.notifier)
                    .addReportCooking(
                      requestTransaction: RequestTransaction(
                        key: key,
                        note: description.text,
                        paymentAmount: 0,
                        paymentType: 1,
                        totalOrder: 0,
                        waktu: '${cookingTimeSelected.value?.allocationName}',
                        product: items,
                      ),
                    );
                if (result == null || !context.mounted) return;
                context.showSuccessMessage(
                  'Berhasil menambah laporan masak dengan ID Laporan: ${result.invoice}',
                );
                ref.invalidate(fetchReportCookingProvider);
                context.pop();
              },
              child: const Text('Simpan'),
            )
          ],
        ),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: cookingItems.value.length,
              itemBuilder: (ctx, index) {
                final cook = cookingItems.value.elementAt(index);
                return _buildItemCooking(context, cook, cookingItems, index);
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
                const Divider(),
                const SizedBox(height: 16),
                DropdownSearch<Product>(
                  asyncItems: (String filter) {
                    return ref.watch(
                      fetchAllFoodMenuProvider(
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
                  itemAsString: (item) => '${item.nameProduct}',
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Tambah Menu Masakan',
                      labelText: 'Tambah Menu Masakan',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.fastfood),
                    ),
                  ),
                  onChanged: (item) {
                    if (item == null) {
                      return;
                    }
                    final currentIndex = cookingItems.value.indexWhere(
                      (element) => element.idProduct == item.idProduct,
                    );
                    if (currentIndex != -1) {
                      context.showErrorMessage(
                        'obat sudah ada, silahkan rubah kuantitas',
                      );
                      return;
                    }
                    cookingItems.value.add(
                      item.copyWith(
                        amount: 1,
                      ),
                    );
                    cookingItems.value = [...cookingItems.value];
                  },
                ),
                const SizedBox(height: 16),
                DropdownSearch<Allocation>(
                  asyncItems: (String filter) {
                    return ref.watch(
                      fetchCookingTimeProvider(
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
                  itemAsString: (item) => '${item.allocationName}',
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Waktu Memasak',
                      labelText: 'Waktu Memasak',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                  onChanged: (item) {
                    if (item == null) {
                      return;
                    }
                    cookingTimeSelected.value = item;
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

  Widget _buildItemCooking(
    BuildContext context,
    Product item,
    ValueNotifier<List<Product>> items,
    int index,
  ) {
    return ListTile(
      leading: CustomAvatar(
        name: '${item.nameProduct}',
        imageUrl: '${item.img}',
        size: 40,
      ),
      title: Text(
        '${item.nameProduct}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        '${item.description}',
        style: context.bodyMedium,
      ),
      trailing: Transform.translate(
        offset: const Offset(8, 0),
        child: InputQty.double(
          initVal: item.amount ?? 1,
          onQtyChanged: (qty) {
            if (qty <= 0) {
              final currentList = items.value;
              currentList.remove(item);
              items.value = [...currentList];
              return;
            }
            final currentItem = item.copyWith(amount: qty);
            items.value[index] = currentItem;
            items.value = [...items.value];
          },
        ),
      ),
    );
  }
}
