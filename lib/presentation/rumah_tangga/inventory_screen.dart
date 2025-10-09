import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/place/inventaris.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'inventory_controller.dart';

class InventoryScreen extends HookConsumerWidget {
  final String? placeId;
  final String? placeName;

  const InventoryScreen({
    super.key,
    this.placeId,
    this.placeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllInventoryProvider(key: key, placeId: '$placeId'),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllInventory = ref.watch(
      fetchAllInventoryProvider(key: key, placeId: '$placeId'),
    );
    final itemCount = fetchAllInventory.isLoading
        ? 10
        : fetchAllInventory.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('$placeName'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Inventaris>(
                  items: fetchAllInventory.valueOrNull ?? [],
                  searchLabel: 'Cari nama barang',
                  failure: const Center(
                    child: Text('nama barang tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.nama_inventaris,
                  ],
                  builder: (item) => _buildItemInventory(
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
          fetchAllInventoryProvider(key: key, placeId: '$placeId').future,
        ),
        child: Skeletonizer(
          enabled: fetchAllInventory.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final inventory =
                  fetchAllInventory.valueOrNull?.elementAtOrNull(index);

              return _buildItemInventory(context, ref, inventory, key);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(
            AppRoute.upsertInventory.name,
            queryParameters: {
              'placeId': '$placeId',
              'placeName': '$placeName',
            },
          );
        },
        label: const Text('Tambah Barang'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  _buildItemInventory(
    BuildContext context,
    WidgetRef ref,
    Inventaris? inventory,
    String key,
  ) {
    return InkWell(
      onTap: () {
        context.goNamed(
          AppRoute.upsertInventory.name,
          extra: inventory,
          queryParameters: {
            'placeId': '$placeId',
            'placeName': '$placeName',
          },
        );
      },
      child: Card.outlined(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 12),
                InkWell(
                  onTap: () {
                    final imageProvider = CachedNetworkImageProvider(
                      '${inventory?.img}',
                    );
                    showImageViewer(context, imageProvider);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: '${inventory?.img}',
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          width: 70,
                          height: 70,
                          color: context.colorOutline,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      '${inventory?.nama_inventaris}',
                      style: context.bodyMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Kode barang: ${inventory?.code}',
                          style: context.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Lokasi: ${inventory?.nama_tempat}',
                          style: context.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: context.colorPrimary,
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        'Kondisi Baik',
                        style: context.bodySmall?.copyWith(
                          color: context.colorOnPrimary,
                        ),
                      ),
                      Text(
                        '${inventory?.bagus}',
                        style: context.bodyMediumBold?.copyWith(
                          color: context.colorOnPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Kondisi Cukup Baik',
                        style: context.bodySmall?.copyWith(
                          color: context.colorOnPrimary,
                        ),
                      ),
                      Text(
                        '${inventory?.cukupbaik}',
                        style: context.bodyMediumBold?.copyWith(
                          color: context.colorOnPrimary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Kondisi Rusak',
                        style: context.bodySmall?.copyWith(
                          color: context.colorOnPrimary,
                        ),
                      ),
                      Text(
                        '${inventory?.rusak}',
                        style: context.bodyMediumBold?.copyWith(
                          color: context.colorOnPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
