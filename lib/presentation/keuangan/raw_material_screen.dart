import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class RawMaterialScreen extends HookConsumerWidget {
  const RawMaterialScreen({super.key});

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
      fetchAllRawMaterialProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchRawMaterials = ref.watch(fetchAllRawMaterialProvider(key: key));
    final itemCount = fetchRawMaterials.isLoading
        ? 10
        : fetchRawMaterials.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bahan Baku'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<RawMaterial>(
                  items: fetchRawMaterials.valueOrNull ?? [],
                  searchLabel: 'Cari bahan baku',
                  failure: const Center(
                    child: Text('Nama bahan baku tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.name,
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
          fetchAllRawMaterialProvider(
            key: key,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchRawMaterials.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final menu =
                  fetchRawMaterials.valueOrNull?.elementAtOrNull(index);
              return _buildItemMenu(context, ref, key, menu);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.upsertRawMaterial.name);
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
    RawMaterial? item,
  ) {
    final stock = double.tryParse('${item?.stock}') ?? 0;
    final textStock =
        stock > 0 ? 'Sisa Stok : $stock ${item?.unit}' : '* stock habis';
    final textColorStock =
        stock > 0 ? context.colorOnSurface : context.colorError;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        onTap: () {
          context.goNamed(
            AppRoute.upsertRawMaterial.name,
            extra: item,
          );
        },
        leading: InkWell(
          onTap: () {
            final imageProvider = CachedNetworkImageProvider(
              '${item?.img}',
            );
            showImageViewer(context, imageProvider);
          },
          child: CustomAvatar(
            name: '${item?.name}',
            imageUrl: '${item?.img}',
            size: 50,
          ),
        ),
        title: Text(
          '${item?.name}',
          style: context.bodyMediumBold,
        ),
        subtitle: Text(
          textStock,
          style: context.bodyMedium?.copyWith(
            color: textColorStock,
          ),
        ),
        trailing: Transform.translate(
          offset: const Offset(16, 0),
          child: Wrap(
            children: [
              IconButton(
                onPressed: () {
                  context.goNamed(
                    AppRoute.upsertRawMaterial.name,
                    extra: item,
                  );
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  _removeRawMaterial(context, ref, key, item);
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeRawMaterial(
    BuildContext context,
    WidgetRef ref,
    String key,
    RawMaterial? item,
  ) async {
    final dialog = await showOkCancelAlertDialog(
      context: context,
      title: '${item?.name}',
      message: 'Ingin menghapus data ini?',
    );
    if (dialog == OkCancelResult.cancel) return;
    final result =
        await ref.read(kitchenControllerProvider.notifier).deleteRawMaterial(
              key: key,
              id: '${item?.idRawMaterial}',
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchAllRawMaterialProvider);
  }
}
