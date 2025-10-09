import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/models/change_schedule/change_schedule.dart';
import 'package:syathiby/presentation/ubah_jadwal/change_shift_controller.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import '../../di/providers.dart';
import '../../routing/app_router.dart';

class TabShiftScreen extends HookConsumerWidget {
  final String status;
  final String? level;

  const TabShiftScreen({super.key, required this.status, this.level});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final pagingController = useMemoized(
      () => PagingController<int, ChangeSchedule>(
        firstPageKey: 1,
      ),
    );

    Future<void> fetchData(int pageKey) async {
      try {
        final result = await ref.watch(
          fetchAllChangeShiftProvider(
            key: key,
            page: pageKey,
            status: status,
          ).future,
        );
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(result, nextPageKey);
      } catch (error) {
        pagingController.error = error;
      }
    }

    useEffect(() {
      pagingController.addPageRequestListener((pageKey) {
        fetchData(pageKey);
      });

      return null;
    }, []);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => Future.sync(pagingController.refresh),
          child: PagedListView(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<ChangeSchedule>(
              itemBuilder: (context, permit, index) {
                final dateFormat = ref.watch(formatDateProvider(
                  '${permit.date}',
                  format: 'EEEE, dd MMMM yyyy',
                ));
                final status = permit.status;
                final isStatusRejected = status == "Ditolak";
                final isStatusAccepted = status == "Disetujui";

                return Card.outlined(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                      left: 8,
                      right: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        '$dateFormat',
                        style: context.bodyMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status :',
                                style: context.bodyMedium,
                              ),
                              Text(
                                '$status',
                                style: context.bodySmall?.copyWith(
                                  color: isStatusAccepted
                                      ? context.colorOnPrimary
                                      : isStatusRejected
                                          ? context.colorOnError
                                          : context.colorOnSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Yang Mengajukan :',
                                style: context.bodyMedium,
                              ),
                              Text(
                                '${permit.staff}',
                                style: context.bodyMediumBold,
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pengganti : ',
                                style: context.bodyMedium,
                              ),
                              Text(
                                '${permit.staff2}',
                                style: context.bodyMediumBold,
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        context.goNamed(
                          AppRoute.detailChangeShift.name,
                          queryParameters: {
                            'shiftId': permit.id_ubah_jadwal,
                            'level': level,
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              context.goNamed(
                AppRoute.addChangeShift.name,
                queryParameters: {
                  'level': level,
                },
              );
            },
            label: const Text('Ajukan'),
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
