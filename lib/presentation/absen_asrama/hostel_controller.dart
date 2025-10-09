import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/hostel/hostel.dart';
import '../../models/message.dart';

part 'hostel_controller.g.dart';

@riverpod
class HostelController extends _$HostelController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addStudentPresence({
    required String key,
    required String studentId,
    required String hostelId,
    required String status,
  }) async {
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getAbsenAsrama(key, studentId, hostelId, status),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addHostelAttendance({
    required String key,
    required String hostelId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(studentServiceProvider).getAbsenKeamanan(key, hostelId),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Asrama>> fetchAllHostelAttendance(
  FetchAllHostelAttendanceRef ref, {
  required String key,
}) async {
  final result = ref.watch(hostelServiceProvider).getGedungAsrama(key);
  return result;
}

@riverpod
Future<List<Siswa>> fetchStudentHostelAttendance(
  FetchStudentHostelAttendanceRef ref, {
  required String key,
  required String hostelId,
}) async {
  final result = ref.watch(studentServiceProvider).getAsrama(key, hostelId);
  return result;
}

@riverpod
Future<List<Asrama>> fetchAllHostelRoom(
  FetchAllHostelRoomRef ref, {
  required String key,
  required String hostelId,
}) async {
  final result = ref.watch(hostelServiceProvider).get(key, hostelId);
  return result;
}
