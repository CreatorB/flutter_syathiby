import 'package:syathiby/models/change_schedule/change_schedule.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/staff/staff.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'change_shift_controller.g.dart';

@riverpod
class ChangeShiftController extends _$ChangeShiftController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> approveChangeShift({
    required String key,
    required String id,
    required String data,
    required String reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(changeScheduleServiceProvider)
          .approveChangeSchedule(key, id, data, reason),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addChangeShift({
    required String key,
    required String date,
    required String staff,
    required String reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(changeScheduleServiceProvider)
          .addChangeSchedule(key, date, staff, reason),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<ChangeSchedule>> fetchAllChangeShiftAdmin(
  FetchAllChangeShiftAdminRef ref, {
  required String key,
  required int page,
}) async {
  final result = ref.watch(changeScheduleServiceProvider).getChangeSchedule(
        key,
        page,
      );
  return result;
}

@riverpod
Future<List<ChangeSchedule>> fetchAllChangeShift(
  FetchAllChangeShiftRef ref, {
  required String key,
  required int page,
  required String status,
}) async {
  final result = ref.watch(changeScheduleServiceProvider).getAllChangeSchedule(
        key,
        status,
        page,
      );
  return result;
}

@riverpod
Future<List<ChangeSchedule>> fetchDetailChangeShift(
  FetchDetailChangeShiftRef ref, {
  required String key,
  required String id,
}) async {
  final result =
      ref.watch(changeScheduleServiceProvider).getDetailChangeSchedule(
            key,
            id,
          );
  return result;
}

@riverpod
Future<List<Staff>> fetchAllStaffReplacement(
  FetchAllStaffReplacementRef ref, {
  required String key,
}) async {
  final result = ref.watch(staffServiceProvider).getspos(key);
  return result;
}
