import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/medicine/medicine.dart';
import 'package:syathiby/presentation/data_obat/medicine_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:search_page/search_page.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';

class MedicineDatabaseScreen extends HookConsumerWidget {
  const MedicineDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final medicineController = ref.watch(medicineControllerProvider);
    ref.listen(
      medicineControllerProvider,
      (previous, next) {
        next.showToastOnError(context);
      },
    );

    ref.listen(
      fetchAllMedicineDataProvider(key: key),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllMedicine = ref.watch(
      fetchAllMedicineDataProvider(key: key),
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
                delegate: SearchPage<DataObat>(
                  items: fetchAllMedicine.valueOrNull ?? [],
                  searchLabel: 'Cari nama obat',
                  failure: const Center(
                    child: Text('Nama obat tidak ditemukan'),
                  ),
                  filter: (item) => [
                    item.name,
                  ],
                  builder: (item) => _buildItemMedicine(
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
          fetchAllMedicineDataProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllMedicine.isLoading || medicineController.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final medicine =
                  fetchAllMedicine.valueOrNull?.elementAtOrNull(index);
              return _buildItemMedicine(context, ref, medicine, key);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.upsertMedicine.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemMedicine(
    BuildContext context,
    WidgetRef ref,
    DataObat? medicine,
    String key,
  ) {
    return ListTile(
      onTap: () {
        context.goNamed(AppRoute.upsertMedicine.name, extra: medicine);
      },
      leading: CustomAvatar(
        name: '${medicine?.name}',
        imageUrl: '${medicine?.img}',
        size: 40,
      ),
      title: Text(
        '${medicine?.name}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        '${medicine?.description}',
        style: context.bodyMedium,
      ),
      trailing: Transform.translate(
        offset: const Offset(16, 0),
        child: IconButton(
          onPressed: () async {
            final dialog = await showOkCancelAlertDialog(
              context: context,
              title: 'Info',
              message: 'Anda yakin menghapus data ini?',
            );
            if (dialog == OkCancelResult.cancel) return;
            final result = await ref
                .read(medicineControllerProvider.notifier)
                .removeMedicine(
                  key: key,
                  medicineId: '${medicine?.id_data_obat}',
                );
            if (result == null || !context.mounted) return;
            context.showSuccessMessage(result.msg);
            ref.invalidate(fetchAllMedicineDataProvider);
          },
          icon: const Icon(Icons.delete),
        ),
      ),
    );
  }
}
