import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/models/violation/violation.dart';
import 'package:syathiby/presentation/pelanggaran/violation_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import '../../di/providers.dart';
import '../../routing/app_router.dart';
import '../../utils/rest_exception.dart';

class ViolationListScreen extends HookConsumerWidget {
  final String? type;

  const ViolationListScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final pagingController = useMemoized(
      () => PagingController<int, Pelanggaran>(
        firstPageKey: 1,
      ),
    );
    Future<void> fetchData(int pageKey) async {
      try {
        final result = await ref.watch(
          fetchListViolationProvider(key: key, page: pageKey, type: '$type')
              .future,
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
        title: const Text('Pelanggaran'),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () => Future.sync(pagingController.refresh),
            child: PagedListView(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<Pelanggaran>(
                itemBuilder: (context, violation, index) {
                  final dateFormat = ref.watch(formatDateProvider(
                    '${violation.date}',
                    format: 'EEE, dd MMMM yyyy',
                  ));
                  final status = violation.status;
                  final isStatusRejected = status == "Laporan Ditolak";
                  final isStatusAccepted = status == "Selesai";

                  return ListTile(
                    title: Text(
                      '${violation.namaSiswa}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.bodyMediumBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${violation.namaPelanggaran}',
                          style: context.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$dateFormat',
                          style: context.bodySmall?.copyWith(
                            color: context.colorOnSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    leading: CustomAvatar(
                      name: '${violation.namaSiswa}',
                      imageUrl: '${violation.img}',
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
                        AppRoute.detailViolation.name,
                        extra: '${violation.idPelanggaran}',
                      );
                    },
                  );
                },
                firstPageErrorIndicatorBuilder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage(pagingController.error),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        pagingController.refresh();
                      },
                      child: const Text('Coba Lagi'),
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton.extended(
              heroTag: 'violation',
              onPressed: () async {
                context.goNamed(
                  AppRoute.addViolation.name,
                  queryParameters: {
                    'type': type,
                  },
                );
              },
              label: const Text('Tambah'),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is DioException) {
      final dioError = error.error;
      if (dioError is RestException) {
        return dioError.message;
      }
      return 'Telah terjadi kesalahan';
    } else {
      return 'Telah terjadi kesalahan';
    }
  }
}
