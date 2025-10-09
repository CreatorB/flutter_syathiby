import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../routing/app_router.dart';
import 'homeroom_teacher_controller.dart';

class HomeroomTeacherScreen extends HookConsumerWidget {
  const HomeroomTeacherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(fetchHomeroomTeacherProvider(key: key), (previous, next) {
      next.showToastOnError(context);
    });
    final fetchHomeroomTeacher = ref.watch(
      fetchHomeroomTeacherProvider(key: key),
    );
    final itemCount = fetchHomeroomTeacher.isLoading
        ? 10
        : fetchHomeroomTeacher.valueOrNull?.length ?? 0;

    final homeroomTeacher = fetchHomeroomTeacher.valueOrNull?.firstOrNull;

    debugPrint('$fetchHomeroomTeacher');

    return Scaffold(
      appBar: AppBar(
        title: Text(homeroomTeacher?.kelas ?? 'Kelas'),
        bottom: Tab(
          child: Column(
            children: [
              Text('Wali Kelas: ${homeroomTeacher?.waliKelas ?? ''}'),
              Text('Jumlah Siswa: ${homeroomTeacher?.jumlahSiswa ?? ''}'),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchHomeroomTeacherProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchHomeroomTeacher.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final student =
                  fetchHomeroomTeacher.valueOrNull?.elementAtOrNull(index);

              return ListTile(
                title: Text(
                  '${student?.namaLengkap}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.bodyLargeBold?.copyWith(
                    color: context.colorOnSurface,
                  ),
                ),
                subtitle: Text(
                  'NIS: ${student?.nis}',
                  style: context.bodyMedium?.copyWith(
                    color: context.colorOnSurface.withOpacity(0.78),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                leading: CustomAvatar(
                  name: '${student?.namaLengkap}',
                  imageUrl: '${student?.img}',
                  size: 48,
                ),
                trailing: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colorPrimary,
                  ),
                  child: Center(
                    child: Text(
                      '${student?.rangking}',
                      style: context.labelLarge?.copyWith(
                        color: context.colorOnPrimary,
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  context.goNamed(
                    AppRoute.reportCard.name,
                    extra: student,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
