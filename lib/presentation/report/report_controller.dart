import 'package:syathiby/models/slip/report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/fasting/fasting.dart';
import '../../models/message.dart';
import '../../models/service_injection.dart';
import '../../models/slip/absent.dart';

part 'report_controller.g.dart';

@riverpod
class ReportController extends _$ReportController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> rejectAttendance({
    required String key,
    required String attendanceId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(slipServiceProvider)
          .rejectJob(key, attendanceId.toString()),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Absent>> fetchDetailPresenceReport(
  FetchDetailPresenceReportRef ref, {
  required String key,
  required String startDate,
  required String endDate,
}) async {
  final result = await ref.watch(slipServiceProvider).getAbsent(
        key,
        startDate,
        endDate,
      );
  return result;
}

@riverpod
Future<List<Report>> fetchAttendanceRecap(
  FetchAttendanceRecapRef ref, {
  required String key,
  required String startDate,
  required String endDate,
}) async {
  final result = await ref.watch(slipServiceProvider).getPayReport(
        key,
        startDate,
        endDate,
      );
  return result;
}

@riverpod
Future<List<Puasa>> fetchReportStudentFasting(
  FetchReportStudentFastingRef ref, {
  required String key,
  required String startDate,
  required String endDate,
}) async {
  final result = await ref.watch(fastingServiceProvider).getLaporanListPuasa(
        key,
        startDate,
        endDate,
      );
  return result;
}
