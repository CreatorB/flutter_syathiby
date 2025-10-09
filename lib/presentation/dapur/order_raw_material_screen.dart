import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:syathiby/models/transaction/request_raw_material.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';
import '../keuangan/student_savings_controller.dart';

class OrderRawMaterialScreen extends HookConsumerWidget {
  const OrderRawMaterialScreen({super.key});

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
    final key = '${currentUser?.key}';
    final rawMaterials = useState<List<RawMaterial>>([]);
    final total = _getTotalSpending(rawMaterials.value);
    final nominal = ref.read(formatCurrencyProvider(total));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Belanja Bahan Baku'),
          actions: [
            TextButton(
              onPressed: () async {
                if (rawMaterials.value.isEmpty) {
                  context.showErrorMessage(
                    'Bahan baku masih kosong, silahkan tambahkan terlebih dahulu',
                  );
                  return;
                }
                final items = rawMaterials.value
                    .map(
                      (e) => BarangRaw(
                        idProduct: e.idRawMaterial,
                        amountProduct: e.amount,
                      ),
                    )
                    .toList();
                final result = await ref
                    .read(kitchenControllerProvider.notifier)
                    .orderRawMaterial(
                      requestRawMaterial: RequestRawMaterial(
                        key: key,
                        paymentType: 1,
                        totalOrder: total.toInt(),
                        product: items,
                      ),
                    );
                if (result == null || !context.mounted) return;
                context.showSuccessMessage(
                  'Belanja bahan baku berhasil dengan invoice: ${result.invoice}',
                );
                ref.invalidate(fetchAllSpendingProvider);
                context.goNamed(AppRoute.spending.name);
              },
              child: const Text('Simpan'),
            )
          ],
        ),
        body: Stack(
          children: [
            ListView.builder(
              itemCount: rawMaterials.value.length,
              itemBuilder: (ctx, index) {
                final item = rawMaterials.value.elementAt(index);
                return _buildItemRawMaterial(
                  context,
                  item,
                  rawMaterials,
                  index,
                );
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Belanja',
                      style: context.bodyMediumBold,
                    ),
                    Text(
                      nominal,
                      style: context.bodyMediumBold?.copyWith(
                        color: context.colorPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownSearch<RawMaterial>(
                  asyncItems: (String filter) {
                    return ref.watch(
                      fetchAllRawMaterialProvider(
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
                  itemAsString: (item) => '${item.name}',
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Tambah Bahan Baku',
                      labelText: 'Tambah Bahan Baku',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.fastfood),
                    ),
                  ),
                  onChanged: (item) {
                    if (item == null) {
                      return;
                    }
                    final currentIndex = rawMaterials.value.indexWhere(
                      (element) => element.idRawMaterial == item.idRawMaterial,
                    );
                    if (currentIndex != -1) {
                      context.showErrorMessage(
                        'bahan baku sudah ada, silahkan rubah kuantitas',
                      );
                      return;
                    }
                    rawMaterials.value.add(
                      item.copyWith(
                        amount: 1,
                      ),
                    );
                    rawMaterials.value = [...rawMaterials.value];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemRawMaterial(
    BuildContext context,
    RawMaterial item,
    ValueNotifier<List<RawMaterial>> rawMaterials,
    int index,
  ) {
    return ListTile(
      leading: CustomAvatar(
        name: '${item.name}',
        imageUrl: '${item.img}',
        size: 40,
      ),
      title: Text(
        '${item.name}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        'Sisa stok: ${item.stock}',
        style: context.bodyMedium,
      ),
      trailing: Transform.translate(
        offset: const Offset(8, 0),
        child: InputQty.double(
          initVal: item.amount ?? 1,
          onQtyChanged: (qty) {
            if (qty <= 0) {
              final currentList = rawMaterials.value;
              currentList.remove(item);
              rawMaterials.value = [...currentList];
              return;
            }
            final currentItem = item.copyWith(amount: qty);
            rawMaterials.value[index] = currentItem;
            rawMaterials.value = [...rawMaterials.value];
          },
        ),
      ),
    );
  }

  num _getTotalSpending(List<RawMaterial> items) {
    num total = 0;
    for (final i in items) {
      total = total + ((double.tryParse('${i.price}') ?? 0) * (i.amount ?? 0));
    }
    return total;
  }
}
