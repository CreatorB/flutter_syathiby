import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/presentation/rekap/recap_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../di/providers.dart';
import '../../utils/custom_avatar_widget.dart';

class ManualAttendanceScreen extends HookConsumerWidget {
  const ManualAttendanceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(recapControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(fetchAllManualAttendanceProvider(key: key), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchManualAttendance = ref.watch(
      fetchAllManualAttendanceProvider(key: key),
    );
    final itemCount = fetchManualAttendance.isLoading
        ? 10
        : fetchManualAttendance.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Absensi Manual'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllManualAttendanceProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchManualAttendance.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final attendance =
                  fetchManualAttendance.valueOrNull?.elementAtOrNull(index);
              final formatDate = ref.watch(formatDateProvider(
                '${attendance?.date}',
                format: 'EEEE, dd MMMM yyyy',
              ));

              return ListTile(
                onTap: () async {
                  final dialog = await showOkCancelAlertDialog(
                    context: context,
                    title: 'Info',
                    message:
                        'Tekan OK untuk mengakhiri absensi pekerjaan ${attendance?.name_staff}',
                  );
                  if (dialog == OkCancelResult.cancel) return;

                  final result = await ref
                      .read(recapControllerProvider.notifier)
                      .finishAttendance(
                        key: key,
                        staffId: '${attendance?.staff}',
                      );
                  if (result == null || !context.mounted) return;
                  context.showSuccessMessage(result.msg);
                  ref.invalidate(fetchAllManualAttendanceProvider);
                },
                leading: CustomAvatar(
                  imageUrl: '${attendance?.img}',
                  name: '${attendance?.name_staff}',
                  size: 48,
                ),
                title: Text(
                  '$formatDate',
                  style: context.bodyMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nama Pegawai: ',
                          style: context.bodySmall,
                        ),
                        Text(
                          '${attendance?.name_staff}',
                          style: context.bodySmallBold,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Absensi: ',
                          style: context.bodySmall,
                        ),
                        Text(
                          '${attendance?.hour}',
                          style: context.bodySmallBold,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bekerja Selama: ',
                          style: context.bodySmall,
                        ),
                        Text(
                          '${attendance?.during}',
                          style: context.bodySmallBold,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.addManualAttendance.name);
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
