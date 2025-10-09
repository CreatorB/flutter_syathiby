import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/presentation/permit/permit_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

class PermitScreen extends HookConsumerWidget {
  const PermitScreen({super.key});

  static const int pagedSize = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final pagingController = useMemoized(
      () => PagingController<int, Permit>(
        firstPageKey: 1,
      ),
    );

    Future<void> fetchData(int pageKey) async {
      try {
        final result = await ref.watch(
          fetchPermitListProvider(key: key, page: pageKey).future,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Izin'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => Future.sync(pagingController.refresh),
            child: PagedListView(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<Permit>(
                itemBuilder: (context, permit, index) {
                  final dateFormat = ref.watch(formatDateProvider(
                    '${permit.date}',
                    format: 'EEE, dd MMMM yyyy',
                  ));
                  final status = permit.status;
                  final isStatusRejected = status == "Ditolak";
                  final isStatusAccepted = status == "Disetujui";

                  return ListTile(
                    title: Text(
                      '${permit.staff}',
                      style: context.bodyMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${permit.namePermit}',
                          style: context.bodyMedium,
                        ),
                        Text(
                          '$dateFormat',
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                    leading: CustomAvatar(
                      name: '${permit.staff}',
                      imageUrl: '${permit.img}',
                      size: 40,
                    ),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: Chip(
                        label: Text(
                          '$status',
                          style: context.bodySmall?.copyWith(
                            color: isStatusAccepted
                                ? context.colorOnPrimary
                                : isStatusRejected
                                    ? context.colorOnError
                                    : context.colorOnSurfaceVariant,
                          ),
                        ),
                        shape: const StadiumBorder(
                          side: BorderSide(),
                        ),
                        backgroundColor: isStatusAccepted
                            ? context.colorPrimary
                            : isStatusRejected
                                ? context.colorError
                                : context.colorSurfaceVariant,
                        side: BorderSide(
                          color: isStatusAccepted
                              ? context.colorPrimary
                              : isStatusRejected
                                  ? context.colorError
                                  : context.colorOnSurfaceVariant,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                    ),
                    onTap: () {
                      context.goNamed(
                        AppRoute.detailPermit.name,
                        extra: permit.idPermit,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'permit',
              onPressed: () {
                context.goNamed(AppRoute.addPermit.name);
              },
              label: const Text('Ajukan'),
              icon: const Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
