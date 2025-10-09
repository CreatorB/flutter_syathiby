import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/presentation/jadwal/teaching_controller.dart';
import 'package:syathiby/utils/custom_avatar_widget.dart';
import 'package:syathiby/utils/extension/typography.dart';
import 'package:syathiby/utils/extension/ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../models/schedule/schedule.dart';
import '../../routing/app_router.dart';

class ClassroomScreen extends HookConsumerWidget {
  final Jadwal schedule;

  const ClassroomScreen({
    super.key,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(teachingControllerProvider, (previous, next) {
      next.showToastOnError(context);
    });
    final teachingController = ref.watch(teachingControllerProvider);
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchStudentClassroom = ref.watch(
      fetchStudentClassroomProvider(
        key: key,
        classId: '${schedule.id_kelas}',
        subjectId: '${schedule.id_mapel}',
        timetableId: '${schedule.id_timetable}',
      ),
    );
    final itemCount = fetchStudentClassroom.isLoading
        ? 10
        : fetchStudentClassroom.valueOrNull?.length ?? 0;

    final formatDate = ref.watch(
        formatDateProvider('${schedule.date}', format: 'EEEE, dd MMMM yyyy'));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${schedule.nama_kelas}',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(
          fetchStudentClassroomProvider(
            key: key,
            classId: '${schedule.id_kelas}',
            subjectId: '${schedule.id_mapel}',
            timetableId: '${schedule.id_timetable}',
          ).future,
        ),
        child: ListView(
          children: [
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '${schedule.mata_pelajaran}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${schedule.hari} - ${schedule.jam}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '${schedule.staff}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      '$formatDate',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    OutlinedButton(
                      onPressed: teachingController.isLoading
                          ? null
                          : () async {
                              _addTeacherPresence(context, ref, key);
                            },
                      child: teachingController.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              'ABSEN MENGAJAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Skeletonizer(
              enabled: fetchStudentClassroom.isLoading,
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: itemCount, // Replace with your item count
                itemBuilder: (context, index) {
                  final student =
                      fetchStudentClassroom.valueOrNull?.elementAtOrNull(index);
                  debugPrint('STUDENT: ${student?.statusAbsen}');
                  return ListTile(
                    leading: CustomAvatar(
                      name: '${student?.namaLengkap}',
                      imageUrl: '${student?.img}',
                      size: 40,
                    ),
                    title: Text(
                      '${index + 1}. ${student?.namaLengkap}',
                      style: context.bodyLargeBold,
                    ),
                    subtitle: Text('NIS: ${student?.nis}'),
                    trailing: Transform.translate(
                      offset: const Offset(12, 0),
                      child: IntrinsicWidth(
                        child: DropdownButtonFormField<String>(
                          value: student?.statusAbsen != "Belum Absen"
                              ? student?.statusAbsen
                              : null,
                          items: const [
                            DropdownMenuItem(
                              value: "hadir",
                              child: Text('Hadir'),
                            ),
                            DropdownMenuItem(
                              value: "izin",
                              child: Text('Izin'),
                            ),
                            DropdownMenuItem(
                              value: "sakit",
                              child: Text('Sakit'),
                            ),
                            DropdownMenuItem(
                              value: "alfa",
                              child: Text('Alfa'),
                            ),
                          ],
                          onChanged: (value) {
                            _addStudentPresence(
                              context,
                              ref,
                              key,
                              '${student?.nis}',
                              '$value',
                            );
                          },
                          isDense: true,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: FilledButton(
          onPressed: () {
            context.goNamed(
              AppRoute.journalClass.name,
              extra: schedule,
            );
          },
          child: const Text(
            'Jurnal Kelas',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addTeacherPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
  ) async {
    final dialogResult = await showOkCancelAlertDialog(
        context: context,
        title: 'Info',
        message: 'Anda Sudah hadir dikelas untuk memulai KBM?',
        okLabel: 'SUDAH',
        cancelLabel: 'BELUM');
    if (dialogResult == OkCancelResult.cancel) return;

    final result = await ref
        .read(teachingControllerProvider.notifier)
        .addTeacherPresence(
            key: key,
            classroomId: '${schedule.id_kelas}',
            subjectId: '${schedule.id_mapel}',
            timetableId: '${schedule.id_timetable}');
    if (result == null || !context.mounted) {
      return;
    }
    ref.invalidate(
      fetchStudentClassroomProvider(
        key: key,
        classId: '${schedule.id_kelas}',
        subjectId: '${schedule.id_mapel}',
        timetableId: '${schedule.id_timetable}',
      ),
    );
  }

  Future<void> _addStudentPresence(
    BuildContext context,
    WidgetRef ref,
    String key,
    String studentId,
    String status,
  ) async {
    final result =
        await ref.read(teachingControllerProvider.notifier).addStudentPresence(
              key: key,
              studentId: studentId,
              classroomId: '${schedule.id_kelas}',
              subjectId: '${schedule.id_mapel}',
              status: status,
            );
    if (result == null || !context.mounted) {
      return;
    }
  }
}
