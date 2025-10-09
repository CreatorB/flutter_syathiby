import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/l10n/string_hardcoded.dart';
import 'package:syathiby/presentation/penilaian/score_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SubjectsScreen extends HookConsumerWidget {
  final String? scoreTypeId;

  const SubjectsScreen({
    super.key,
    this.scoreTypeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    ref.listen(
      fetchAllSubjectProvider(key: key, id: scoreTypeId),
      (previous, next) {
        next.showToastOnError(context);
      },
    );
    final fetchAllSubject = ref.watch(
      fetchAllSubjectProvider(key: key, id: scoreTypeId),
    );
    final itemCount = fetchAllSubject.isLoading
        ? 10
        : fetchAllSubject.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mata Pelajaran'.hardcoded),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchAllSubjectProvider(key: key, id: scoreTypeId).future,
        ),
        child: Skeletonizer(
          enabled: fetchAllSubject.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final schedule =
                  fetchAllSubject.valueOrNull?.elementAtOrNull(index);

              return Card.outlined(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Text(
                      '${schedule?.mata_pelajaran}',
                      style: context.titleLargeBold,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Kelas: ${schedule?.nama_kelas}',
                        ),
                        Text(
                          'Hari: ${schedule?.hari}',
                          style: context.bodyMedium?.copyWith(),
                        ),
                        Text(
                          '${schedule?.jam}',
                          style: context.bodyMedium?.copyWith(),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (schedule == null) return;
                      context.goNamed(
                        AppRoute.studentScore.name,
                        queryParameters: {
                          'classId': schedule.id_kelas,
                          'className': schedule.nama_kelas,
                          'subjectId': schedule.id_mapel,
                          'day': schedule.hari,
                          'hour': schedule.jam,
                          'scoreTypeId': schedule.id_jenis_penilaian,
                          'subjectName': schedule.mata_pelajaran,
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
    );
  }
}
