import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/jadwal/teaching_controller.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TeachingScheduleScreen extends HookConsumerWidget {
  const TeachingScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchTeachingSchedule = ref.watch(
      fetchTeachingScheduleProvider(key: key),
    );
    final itemCount = fetchTeachingSchedule.isLoading
        ? 10
        : fetchTeachingSchedule.valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Mengajar'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchTeachingScheduleProvider(key: key).future,
        ),
        child: Skeletonizer(
          enabled: fetchTeachingSchedule.isLoading,
          child: ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              final schedule =
                  fetchTeachingSchedule.valueOrNull?.elementAtOrNull(index);
              final isNotAbsence =
                  schedule?.today == schedule?.hari && schedule?.absense == "0";
              final isAlreadyAbsence =
                  schedule?.today == schedule?.hari && schedule?.absense == "1";

              final textColor = isNotAbsence
                  ? context.colorOnError
                  : isAlreadyAbsence
                      ? context.colorOnPrimary
                      : context.colorOnSurface;
              final backgroundColor = isNotAbsence
                  ? context.colorError
                  : isAlreadyAbsence
                      ? context.colorPrimary
                      : context.colorSurface;

              return Card.outlined(
                color: backgroundColor,
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4),
                  child: ListTile(
                    title: Text(
                      '${schedule?.mata_pelajaran}',
                      style: context.titleMediumBold?.copyWith(
                        color: textColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          'Kelas: ${schedule?.nama_kelas}',
                          style: context.titleMedium?.copyWith(
                            color: textColor,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Setiap Hari: ${schedule?.hari}',
                                style: context.bodyMedium?.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ),
                            Text(
                              'Jam: ${schedule?.jam}',
                              style: context.bodyMedium?.copyWith(
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: isNotAbsence || isAlreadyAbsence
                        ? () {
                            if (schedule == null) return;
                            context.goNamed(
                              AppRoute.classroom.name,
                              extra: schedule,
                            ); // TODO
                          }
                        : () async {
                            await showOkAlertDialog(
                              context: context,
                              title: 'Info',
                              message: 'Pelajaran belum bisa dimulai',
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
