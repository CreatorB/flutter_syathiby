import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/presentation/transaction/transaction_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class ItemsScreen extends HookConsumerWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final transactionController = ref.watch(transactionControllerProvider);
    ref.listen(
      transactionControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );

    ref.listen(
      fetchAllItemProvider(key: key, trx: 'YES', haveStock: '', page: 1),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllItem = ref.watch(
      fetchAllItemProvider(key: key, trx: 'YES', haveStock: '', page: 1),
    );
    final itemCount =
        fetchAllItem.isLoading ? 10 : fetchAllItem.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Barang atau Jasa'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Product>(
                  items: fetchAllItem.valueOrNull ?? [],
                  searchLabel: 'Cari nama barang',
                  failure: const Center(
                    child: Text('Nama barang tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.nameProduct,
                  ],
                  builder: (item) => _buildItem(
                    context,
                    ref,
                    item,
                    key,
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
          fetchAllItemProvider(
            key: key,
            trx: 'YES',
            haveStock: '',
            page: 1,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllItem.isLoading || transactionController.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final item = fetchAllItem.valueOrNull?.elementAtOrNull(index);
              return _buildItem(context, ref, item, key);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.addItem.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    WidgetRef ref,
    Product? item,
    String key,
  ) {
    final total = ref.watch(formatCurrencyProvider('${item?.sellingPrice}'));
    final stockAvailable = (item?.stock ?? 0) > 0;
    final haveStock = item?.haveStock == '0';
    return ListTile(
      onTap: () {
        if (stockAvailable || haveStock) {
          context.goNamed(
            AppRoute.orderItem.name,
            extra: item,
          );
          return;
        }
        context.showErrorMessage(
          'Stok Habis. Mohon perbarui stok terlebih dahulu',
        );
      },
      leading: CustomAvatar(
        name: '${item?.nameProduct}',
        imageUrl: '${item?.img}',
        size: 40,
      ),
      title: Text(
        '${item?.nameProduct}',
        style: context.bodyMediumBold,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$total / ${item?.unit}',
            style: context.bodyMedium,
          ),
          Visibility(
            visible: item?.haveStock != '0',
            child: Text(
              stockAvailable
                  ? 'Stok: ${item?.stock} ${item?.unit}'
                  : 'Stok Habis',
              style: context.bodyMedium?.copyWith(
                color: stockAvailable
                    ? context.colorOnSurface
                    : context.colorError,
              ),
            ),
          ),
        ],
      ),
      // trailing: Transform.translate(
      //   offset: const Offset(16, 0),
      //   child: IconButton(
      //     onPressed: () async {
      //       final dialog = await showOkCancelAlertDialog(
      //         context: context,
      //         title: 'Info',
      //         message: 'Anda yakin menghapus data ini?',
      //       );
      //       if (dialog == OkCancelResult.cancel) return;
      //       final result = await ref
      //           .read(transactionControllerProvider.notifier)
      //           .deleteItem(
      //             key: key,
      //             id: '${item?.idProduct}',
      //           );
      //       if (result == null || !context.mounted) return;
      //       context.showSuccessMessage(result.msg);
      //       ref.invalidate(fetchAllItemProvider);
      //     },
      //     icon: const Icon(Icons.delete),
      //   ),
      // ),
    );
  }
}
