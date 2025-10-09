import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/presence/presence_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class VisitingPresenceScreen extends HookConsumerWidget {
  const VisitingPresenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(presenceControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchAttendanceVisiting = ref.watch(
      fetchAttendanceVisitingProvider(key: key),
    );
    final itemCount = fetchAttendanceVisiting.isLoading
        ? 10
        : fetchAttendanceVisiting.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Kunjungan'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAttendanceVisitingProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchAttendanceVisiting.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final attendance =
                  fetchAttendanceVisiting.valueOrNull?.elementAtOrNull(index);
              final formatDate = ref.watch(formatDateProvider(
                  '${attendance?.date}',
                  format: 'EEEE, dd MMMM yyyy'));
              final isStartAttendance = attendance?.status == "start";
              return ListTile(
                leading: CustomAvatar(
                  imageUrl: '${attendance?.img}',
                  name: '${attendance?.name_staff}',
                  size: 56,
                ),
                title: Text(
                  '${attendance?.during}',
                  style: context.titleMediumBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('$formatDate - ${attendance?.hour}'),
                trailing: isStartAttendance
                    ? Transform.translate(
                        offset: const Offset(8, 0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            surfaceTintColor: context.colorError,
                            foregroundColor: context.colorError,
                          ),
                          onPressed: () async {
                            final result = await ref
                                .read(presenceControllerProvider.notifier)
                                .finishVisiting(
                                  key: key,
                                  visitingId: '${attendance?.id_attendance}',
                                );
                            if (result == null || !context.mounted) return;
                            context.showSuccessMessage('Success');
                            ref.invalidate(
                              fetchAttendanceVisitingProvider(key: key),
                            );
                          },
                          child: const Text('Akhiri'),
                        ),
                      )
                    : null,
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.goNamed(AppRoute.addVisiting.name);
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
