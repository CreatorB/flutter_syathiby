import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class FoodMenuScreen extends HookConsumerWidget {
  const FoodMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      kitchenControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllFoodMenuProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllMenu = ref.watch(fetchAllFoodMenuProvider(key: key));
    final itemCount =
        fetchAllMenu.isLoading ? 10 : fetchAllMenu.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Masakan'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Product>(
                  items: fetchAllMenu.valueOrNull ?? [],
                  searchLabel: 'Cari nama menu',
                  failure: const Center(
                    child: Text('Nama menu tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.nameProduct,
                  ],
                  builder: (item) => _buildItemMenu(
                    context,
                    ref,
                    key,
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
          fetchAllFoodMenuProvider(
            key: key,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllMenu.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final menu = fetchAllMenu.valueOrNull?.elementAtOrNull(index);
              return _buildItemMenu(context, ref, key, menu);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.upsertFoodMenu.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemMenu(
    BuildContext context,
    WidgetRef ref,
    String key,
    Product? item,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: () {
          context.goNamed(AppRoute.detailFoodMenu.name);
        },
        leading: InkWell(
          onTap: () {
            final imageProvider = CachedNetworkImageProvider(
              '${item?.img}',
            );
            showImageViewer(context, imageProvider);
          },
          child: CustomAvatar(
            name: '${item?.nameProduct}',
            imageUrl: '${item?.img}',
            size: 50,
          ),
        ),
        title: Text(
          '${item?.nameProduct}',
          style: context.bodyMediumBold,
        ),
        trailing: Transform.translate(
          offset: const Offset(16, 0),
          child: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  context.goNamed(
                    AppRoute.upsertFoodMenu.name,
                    extra: item,
                  );
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  _removeMenu(context, ref, key, item);
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeMenu(
    BuildContext context,
    WidgetRef ref,
    String key,
    Product? item,
  ) async {
    final dialog = await showOkCancelAlertDialog(
      context: context,
      title: '${item?.nameProduct}',
      message: 'Ingin menghapus data ini?',
    );
    if (dialog == OkCancelResult.cancel) return;
    final result =
        await ref.read(kitchenControllerProvider.notifier).deleteFoodMenu(
              key: key,
              menuId: '${item?.idProduct}',
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchAllFoodMenuProvider);
  }
}
