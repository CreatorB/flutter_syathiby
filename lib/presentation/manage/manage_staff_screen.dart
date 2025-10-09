import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/models/staff/staff.dart';
import 'package:syathiby/presentation/manage/manage_staff_controller.dart';
import 'package:syathiby/presentation/rapat/meeting_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class ManageStaffScreen extends HookConsumerWidget {
  const ManageStaffScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(manageStaffControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final searchQuery = useTextEditingController();

    final fetchAllStaff = ref.watch(
      searchStaffProvider(
        key: key,
        query: searchQuery.text,
      ),
    );

    ref.listen(
      searchStaffProvider(
        key: key,
        query: searchQuery.text,
      ),
      (previous, next) => next.showToastOnError(context),
    );

    final itemCount =
        fetchAllStaff.isLoading ? 10 : fetchAllStaff.valueOrNull?.length ?? 0;

    useListenable(searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pegawai'.hardcoded),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextFormField(
              controller: searchQuery,
              decoration: InputDecoration(
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                labelText: 'Cari Pegawai'.hardcoded,
                prefixIcon: const Icon(Icons.search),
              ),
              keyboardType: TextInputType.text,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          searchStaffProvider(
            key: key,
            query: searchQuery.text,
          ).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllStaff.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (ctx, index) {
              final staff = fetchAllStaff.valueOrNull?.elementAtOrNull(index);
              return _buildItemList(context, ref, key, staff);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(
            AppRoute.upsertStaff.name,
          );
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _removeStaff(
    BuildContext context,
    WidgetRef ref,
    String key,
    String name,
    String? id,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
      context: context,
      title: 'Hapus Data Ini?',
      message: name,
    );
    if (dialogResult == OkCancelResult.cancel) return;

    final result =
        await ref.read(manageStaffControllerProvider.notifier).deleteStaff(
              key: key,
              staffId: '$id',
            );
    if (result == null || !context.mounted) return;
    context.showSuccessMessage('Berhasil menghapus data');
    ref.invalidate(fetchAllStaffProvider);
  }

  Widget _buildItemList(
    BuildContext context,
    WidgetRef ref,
    String key,
    Staff? staff,
  ) {
    return ListTile(
      title: Text(
        '${staff?.fullName}',
        style: context.bodyMediumBold,
      ),
      subtitle: Text(
        '${staff?.phoneNumber}',
        style: context.bodyMedium,
      ),
      leading: CustomAvatar(
        imageUrl: '${staff?.img}',
        name: '${staff?.fullName}',
      ),
      trailing: Transform.translate(
        offset: const Offset(16, 0),
        child: IntrinsicWidth(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context.goNamed(
                    AppRoute.upsertStaff.name,
                    extra: staff,
                  );
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {
                  _removeStaff(
                    context,
                    ref,
                    key,
                    '${staff?.fullName}',
                    staff?.phoneNumber,
                  );
                },
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
