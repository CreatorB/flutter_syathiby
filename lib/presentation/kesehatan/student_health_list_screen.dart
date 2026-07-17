import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:syathiby/models/health/health.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/presentation/kesehatan/student_health_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import '../../di/providers.dart';
import '../../routing/app_router.dart';

class StudentHealthListScreen extends HookConsumerWidget {
  const StudentHealthListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

    final pagingController = useMemoized(
      () => PagingController<int, Kesehatan>(firstPageKey: 1),
      const [],
    );

    Future<void> fetchPage(int pageKey) async {
      try {
        final newItems =
            await ref.read(healthServiceProvider).get(key, pageKey);
        final isLastPage = newItems.isEmpty;
        if (isLastPage) {
          pagingController.appendLastPage(newItems);
        } else {
          pagingController.appendPage(newItems, pageKey + 1);
        }
      } catch (error) {
        pagingController.error = error;
      }
    }

    useEffect(() {
      pagingController.addPageRequestListener(fetchPage);
      return () => pagingController.removePageRequestListener(fetchPage);
    }, [pagingController]);

    ref.listen(studentHealthControllerProvider, (previous, next) {
      if (previous?.isLoading == true && !next.isLoading && next.hasValue) {
        pagingController.refresh();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          pagingController.refresh();
        },
        child: PagedListView<int, Kesehatan>(
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<Kesehatan>(
            itemBuilder: (context, studentHealth, index) {
              return _studentHealthItem(context, ref, studentHealth);
            },
            firstPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            newPageProgressIndicatorBuilder: (_) =>
                const Center(child: CircularProgressIndicator()),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Belum ada catatan kesehatan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            firstPageErrorIndicatorBuilder: (_) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data. Tarik ke bawah untuk coba lagi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'student_health',
        onPressed: () async {
          await context.pushNamed(
            AppRoute.addStudentHealth.name,
          );
          if (!context.mounted) return;
          pagingController.refresh();
        },
        label: const Text('Tambah'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _studentHealthItem(
    BuildContext context,
    WidgetRef ref,
    Kesehatan studentHealth,
  ) {
    final dateFormat = ref.watch(formatDateProvider(
      '${studentHealth.date}',
      format: 'EEE, dd MMMM yyyy',
    ));
    return ListTile(
      title: Text(
        '${studentHealth.nama_siswa}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.bodyLargeBold,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${studentHealth.diagnosa}',
            style: context.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$dateFormat - ${studentHealth.hour}',
            style: context.bodySmall?.copyWith(
              color: context.colorOnSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
      leading: CustomAvatar(
        name: '${studentHealth.nama_siswa}',
        imageUrl: '${studentHealth.img}',
        size: 40,
      ),
      onTap: () {
        context.goNamed(
          AppRoute.detailStudentHealth.name,
          extra: '${studentHealth.id_kesehatan}',
        );
      },
    );
  }
}