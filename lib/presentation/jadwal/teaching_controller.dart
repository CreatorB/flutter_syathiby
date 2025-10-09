import 'package:syathiby/models/schedule/schedule.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/student/siswa.dart';

part 'teaching_controller.g.dart';

@riverpod
class TeachingController extends _$TeachingController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addStudentPresence({
    required String key,
    required String studentId,
    required String classroomId,
    required String subjectId,
    required String status,
  }) async {
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getAbsen(key, studentId, classroomId, subjectId, status),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addTeacherPresence({
    required String key,
    required String classroomId,
    required String subjectId,
    required String timetableId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getAbsenGuru(key, classroomId, subjectId, timetableId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addJournalClass({
    required String key,
    required String classroomId,
    required String subjectId,
    required String chapter,
    required String description,
    required String timetableId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(teachingScheduleServiceProvider).addJurnal(
            key,
            classroomId,
            subjectId,
            chapter,
            description,
            timetableId,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<Jadwal?> fetchDetailTeachingSchedule(
  FetchDetailTeachingScheduleRef ref, {
  required String key,
  required String classroomId,
  required String subjectId,
  required String timetableId,
}) async {
  final result = await ref.watch(teachingScheduleServiceProvider).getJadwal(
        key,
        classroomId,
        subjectId,
        timetableId,
      );
  return result.firstOrNull;
}

@riverpod
Future<List<Jadwal>> fetchTeachingSchedule(
  FetchTeachingScheduleRef ref, {
  required String key,
}) async {
  final result = await ref.watch(teachingScheduleServiceProvider).get(key);
  return result;
}

@riverpod
Future<List<Siswa>> fetchStudentClassroom(
  FetchStudentClassroomRef ref, {
  required String key,
  required String classId,
  required String subjectId,
  required String timetableId,
}) async {
  final result = await ref.watch(studentServiceProvider).getJadwal(
        key,
        classId,
        subjectId,
        timetableId,
      );
  return result;
}
