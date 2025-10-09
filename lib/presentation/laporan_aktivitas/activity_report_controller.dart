import 'dart:io';

import 'package:syathiby/models/event/event.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/slip/absent.dart';

part 'activity_report_controller.g.dart';

@riverpod
class ActivityReportController extends _$ActivityReportController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addActivityReport({
    required String key,
    required String activityName,
    required String description,
    required String type,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(jobServiceProvider).addLaporanAktivitas(
            key,
            description,
            activityName,
            type,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Absent>> fetchAllActivityReport(
  FetchAllActivityReportRef ref, {
  required String key,
  required String dateStart,
  required String dateEnd,
  required String type,
}) async {
  final result = ref.watch(staffServiceProvider).getLaporanAktivitas(
        key,
        dateStart,
        dateEnd,
        type,
      );
  return result;
}

@riverpod
Future<List<Event>> fetchAllActivityName(
  FetchAllActivityNameRef ref, {
  required String key,
  required String type,
}) async {
  final result = ref.watch(eventServiceProvider).getsAktivitas(
        key,
        type,
      );
  return result;
}
