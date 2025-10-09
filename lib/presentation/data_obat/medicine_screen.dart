import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/presentation/data_obat/medicine_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class MedicineScreen extends HookConsumerWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllMedicineProvider(
        key: key,
        haveStock: '',
        trx: 'YES',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllMedicine = ref.watch(
      fetchAllMedicineProvider(
        key: key,
        haveStock: '',
        trx: 'YES',
      ),
    );
    final itemCount = fetchAllMedicine.isLoading
        ? 10
        : fetchAllMedicine.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Obat'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Product>(
                  items: fetchAllMedicine.valueOrNull ?? [],
                  searchLabel: 'Cari nama obat',
                  failure: const Center(
                    child: Text('Nama obat tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.nameProduct,
                  ],
                  builder: (item) => _buildItemMedicine(
                    context,
                    item,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllMedicineProvider(
            key: key,
            haveStock: '',
            trx: 'YES',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllMedicine.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final medicine =
                  fetchAllMedicine.valueOrNull?.elementAtOrNull(index);
              return _buildItemMedicine(context, medicine);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItemMedicine(BuildContext context, Product? medicine) {
    return ListTile(
      onTap: () {
        context.goNamed(
          AppRoute.addMedicineRequest.name,
          extra: medicine,
        );
      },
      leading: CustomAvatar(
        name: '${medicine?.nameProduct}',
        imageUrl: '${medicine?.img}',
        size: 40,
      ),
      title: Text(
        '${medicine?.nameProduct}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        '${medicine?.description}',
        style: context.bodyMedium,
      ),
    );
  }
}
