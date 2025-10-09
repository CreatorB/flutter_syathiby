import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/student/siswa.dart';
import '../../models/tahfidz/tahfidz.dart';

part 'tahfidz_presence_controller.g.dart';

@riverpod
class TahfidzPresenceController extends _$TahfidzPresenceController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> removeStudentTahfidz({
    required String key,
    required String studentId,
    required String classId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getDeleteHalaqah(key, studentId, classId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> teacherPresence({
    required String key,
    required String date,
    required String time,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(studentServiceProvider).getAbsenPengampu(key, date, time),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addStudentPresence({
    required String key,
    required String studentId,
    required String classId,
    required String status,
    required String date,
    required String time,
  }) async {
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getAbsenTahfidz(key, studentId, classId, status, date, time),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addTahfidzTeacherPresence({
    required String key,
    required String id,
    required String status,
    required String date,
    required String time,
  }) async {
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getAbsenPengampuTahfidz(key, id, status, date, time),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addStudentToClass({
    required String key,
    required String studentId,
    required String classId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(studentServiceProvider).getSantriTahfidz(
            key,
            studentId,
            classId,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Tahfidz>> fetchTahfidzDateNow(
  FetchTahfidzDateNowRef ref, {
  required String key,
}) async {
  final result = await ref.watch(tahfidzServiceProvider).tahfidzNow(key);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchScheduleTahfidzTime(
  FetchScheduleTahfidzTimeRef ref, {
  required String key,
  required String type,
}) async {
  final result = await ref.watch(tahfidzServiceProvider).type(key, type);
  return result;
}

@riverpod
Future<List<Siswa>> fetchScheduleTahfidz(
  FetchScheduleTahfidzRef ref, {
  required String key,
  required String date,
  required String time,
}) async {
  final result = await ref.watch(studentServiceProvider).getJadwalTahfidz(
        key,
        date,
        time,
      );
  return result;
}

@riverpod
Future<List<Siswa>> fetchTeacherTahfidzSchedule(
  FetchTeacherTahfidzScheduleRef ref, {
  required String key,
  required String date,
  required String time,
}) async {
  final result = await ref.watch(studentServiceProvider).getJadwalPengampu(
        key,
        date,
        time,
      );
  return result;
}

@riverpod
Future<Message> fetchTeacherPresenceTahfidz(
  FetchTeacherPresenceTahfidzRef ref, {
  required String key,
  required String staff,
  required String status,
  required String date,
  required String time,
}) async {
  final result =
      await ref.watch(studentServiceProvider).getAbsenPengampuTahfidz(
            key,
            staff,
            status,
            date,
            time,
          );
  return result;
}
