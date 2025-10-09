import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:syathiby/presentation/dapur/kitchen_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class StockOpnameScreen extends HookConsumerWidget {
  const StockOpnameScreen({super.key});

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
      fetchRealStockRawMaterialProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchRawMaterials =
        ref.watch(fetchRealStockRawMaterialProvider(key: key));
    final itemCount = fetchRawMaterials.isLoading
        ? 10
        : fetchRawMaterials.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Opname'),
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
          fetchRealStockRawMaterialProvider(
            key: key,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchRawMaterials.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final item =
                  fetchRawMaterials.valueOrNull?.elementAtOrNull(index);
              return _buildItemMenu(context, ref, key, item);
            },
          ),
        ),
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
          _showUpdateRealStock(context, ref, key, item);
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
          child: IconButton(
            onPressed: () {
              _showUpdateRealStock(context, ref, key, item);
            },
            icon: const Icon(Icons.edit),
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateRealStock(
    BuildContext context,
    WidgetRef ref,
    String key,
    RawMaterial? item,
  ) async {
    final input = await showTextInputDialog(
      context: context,
      title: 'Edit Stok ${item?.name}',
      message: 'Masukkan stok fisik sebenernya',
      textFields: [
        DialogTextField(
          hintText: 'Stok fisik',
          initialText: '${item?.stock}',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.isEmpty == true) return 'Tidak boleh kosong';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final value = input?.firstOrNull;
    if (value == null) return;
    final result =
        await ref.refresh(kitchenControllerProvider.notifier).editRealStock(
              key: key,
              id: '${item?.idRawMaterial}',
              stock: value,
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(
      fetchRealStockRawMaterialProvider(key: key),
    );
  }
}
