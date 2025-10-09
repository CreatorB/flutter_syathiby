import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/schedule/schedule.dart';

part 'report_class_controller.g.dart';

@riverpod
class ReportClassController extends _$ReportClassController {
  @override
  FutureOr<void> build() async {
    return;
  }
}

@riverpod
Future<List<Asrama>> fetchAllHostel(
  FetchAllHostelRef ref, {
  required String key,
}) async {
  final result = ref.watch(hostelServiceProvider).getGedungKelas(key);
  return result;
}

@riverpod
Future<List<Asrama>> fetchAllHostelClassroom(
  FetchAllHostelClassroomRef ref, {
  required String key,
  required String hostelId,
}) async {
  final result = ref.watch(hostelServiceProvider).getDataKelas(key, hostelId);
  return result;
}

@riverpod
Future<List<Jadwal>> fetchClassroomAttendance(
  FetchClassroomAttendanceRef ref, {
  required String key,
  required String date,
  required String classId,
}) async {
  final result = ref.watch(teachingScheduleServiceProvider).getLaporanAbsensi(
        key,
        date,
        date,
        classId,
      );
  return result;
}
