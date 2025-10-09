import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/place/tempat.dart';
import 'package:syathiby/presentation/rumah_tangga/place_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PlacesScreen extends HookConsumerWidget {
  // final String? placeId;

  const PlacesScreen({
    super.key,
    // this.placeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      placesControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final placeController = ref.watch(placesControllerProvider);
    ref.listen(
      fetchAllPlaceProvider(
        key: key,
        id: '',
      ),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllPlace = ref.watch(fetchAllPlaceProvider(
      key: key,
      id: '',
    ));
    final itemCount =
        fetchAllPlace.isLoading ? 10 : fetchAllPlace.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Inventaris'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchPage<Tempat>(
                  items: fetchAllPlace.valueOrNull ?? [],
                  searchLabel: 'Cari nama lokasi',
                  failure: const Center(
                    child: Text('nama lokasi tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.nama_tempat,
                  ],
                  builder: (item) => _buildItemPlace(
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
          fetchAllPlaceProvider(
            key: key,
            id: '',
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllPlace.isLoading || placeController.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final place = fetchAllPlace.valueOrNull?.elementAtOrNull(index);

              return _buildItemPlace(context, ref, place, key);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddPlace(context, ref, key);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddPlace(
    BuildContext context,
    WidgetRef ref,
    String key, {
    Tempat? place,
  }) async {
    final isUpdate = place != null;

    final input = await showTextInputDialog(
      context: context,
      title: '${isUpdate ? 'Edit' : 'Tambah'} Lokasi Inventaris',
      message: 'Silahkan masukkan nama lokasi',
      textFields: [
        DialogTextField(
          initialText: place?.nama_tempat,
          hintText: 'Lokasi Inventaris',
          keyboardType: TextInputType.text,
          validator: (value) {
            if (value == null) return 'tidak boleh kosong';
            return null;
          },
          autocorrect: true,
        ),
      ],
    );
    final name = input?.firstOrNull;
    if (name == null) return;

    Message? result;
    if (isUpdate) {
      result = await ref.read(placesControllerProvider.notifier).updatePlace(
            key: key,
            placeId: '${place.id_tempat}',
            name: name,
          );
    } else {
      result = await ref.read(placesControllerProvider.notifier).addPlace(
            key: key,
            name: name,
          );
    }
    if (result == null || !context.mounted) return;
    context.showSuccessMessage(result.msg);
    ref.invalidate(fetchAllPlaceProvider);
  }

  _buildItemPlace(
    BuildContext context,
    WidgetRef ref,
    Tempat? place,
    String key,
  ) {
    return Card.outlined(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
        child: ListTile(
          onTap: () {
            context.goNamed(
              AppRoute.inventories.name,
              queryParameters: {
                'placeId': '${place?.id_tempat}',
                'placeName': '${place?.nama_tempat}'
              },
            );
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${place?.nama_tempat}',
                style: context.titleMediumBold,
              ),
              Transform.translate(
                offset: const Offset(16, 0),
                child: IconButton(
                  onPressed: () {
                    _showAddPlace(
                      context,
                      ref,
                      key,
                      place: place,
                    );
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jumlah Barang: '),
                    Text('${place?.jumlah_barang} barang'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kondisi Baik: '),
                    Text('${place?.bagus} barang'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kondisi Cukup Baik: '),
                    Text('${place?.cukupbaik} barang'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kondisi Rusak: '),
                    Text('${place?.rusak} barang'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
