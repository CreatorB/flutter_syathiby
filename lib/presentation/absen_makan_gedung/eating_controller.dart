import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/hostel/food.dart';
import '../../models/message.dart';
import '../../models/student/siswa.dart';

part 'eating_controller.g.dart';

@riverpod
class EatingController extends _$EatingController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addStudentEating({
    required String key,
    required String studentId,
    required String type,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getSantriMakan(key, studentId, type),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addStudentEatingSearch({
    required String key,
    required String search,
    required String type,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getSantriMakanSearch(key, search, type),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Siswa>> fetchAllStudentEating(
  FetchAllStudentEatingRef ref, {
  required String key,
  required String date,
  required String time,
}) async {
  final result =
      ref.watch(studentServiceProvider).getJadwalMakan(key, date, time);
  return result;
}

@riverpod
Future<List<Makan>> fetchEatingReport(
  FetchEatingReportRef ref, {
  required String key,
  required String start,
  required String end,
}) async {
  final result =
      ref.watch(hostelServiceProvider).getGedungMakan(key, start, end);
  return result;
}
