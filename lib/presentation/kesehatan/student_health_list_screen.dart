import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'; 
import 'package:syathiby/models/health/health.dart';
import 'package:syathiby/presentation/kesehatan/paging_student_health_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';

import '../../di/providers.dart';
import '../../routing/app_router.dart';

class StudentHealthListScreen extends ConsumerWidget {
  const StudentHealthListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';

final pagingController =
    ref.watch(pagingStudentHealthControllerProvider(key: key));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kesehatan'),
      ),
      body: RefreshIndicator(

onRefresh: () async {
  ref.watch(pagingStudentHealthControllerProvider(key: key)).refresh();
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
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'student_health',
        onPressed: () async {
          context.goNamed(
            AppRoute.addStudentHealth.name,
          );
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
              color: context.colorOnSurface.withOpacity(
                0.6,
              ),
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