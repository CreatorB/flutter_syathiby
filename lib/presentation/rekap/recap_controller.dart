import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/slip/absent.dart';
import 'package:syathiby/models/store/store.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/hostel/hostel.dart';
import '../../models/message.dart';
import '../../models/recap/recap.dart';
import '../../models/staff/kinerja.dart';

part 'recap_controller.g.dart';

@riverpod
class RecapController extends _$RecapController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> finishAttendance({
    required String key,
    required String staffId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(staffServiceProvider).finishVisiting(key, staffId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addManualAttendance({
    required String key,
    required String date,
    required String hour,
    required String status,
    required String staffId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(jobServiceProvider)
          .addAbsence(key, date, hour, status, staffId),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Recap>> fetchAllRecapPresence(
  FetchAllRecapPresenceRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String groupId,
}) async {
  final result = ref.watch(recapServiceProvider).get(
        key,
        startDate,
        endDate,
        groupId,
      );
  return result;
}

@riverpod
Future<List<Store>> fetchAllGroup(
  FetchAllGroupRef ref, {
  required String key,
}) async {
  final result = ref.watch(storeServiceProvider).getsGrup(key);
  return result;
}

@riverpod
Future<List<Absent>> fetchFilterRecapPresence(
  FetchFilterRecapPresenceRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String status,
  required String groupId,
  bool isNotPresence = false,
}) async {
  if (isNotPresence) {
    return ref
        .watch(slipServiceProvider)
        .getRekapNoAbsent(key, startDate, endDate, status, groupId);
  }
  final result = ref
      .watch(slipServiceProvider)
      .getRekapAbsent(key, startDate, endDate, status, groupId);
  return result;
}

@riverpod
Future<List<Permit>> fetchAllRecapPermit(
  FetchAllRecapPermitRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required int page,
  required String groupId,
}) async {
  final result = ref
      .watch(permitServiceProvider)
      .getPermitdate(key, startDate, endDate, page, groupId);
  return result;
}

@riverpod
Future<List<Absent>> fetchAllManualAttendance(
  FetchAllManualAttendanceRef ref, {
  required String key,
}) async {
  final result = ref.watch(staffServiceProvider).getAttandance(key);
  return result;
}

@riverpod
Future<List<Asrama>> fetchAllDataPresence(
  FetchAllDataPresenceRef ref, {
  required String key,
  required String dateStart,
  required String dateEnd,
  required String division,
}) async {
  final result = ref.watch(hostelServiceProvider).getDataPresenceList(
        key,
        dateStart,
        dateEnd,
        division,
      );
  return result;
}

@riverpod
Future<List<Kinerja>> fetchPresenceGroup(
  FetchPresenceGroupRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String id,
}) async {
  final result = ref.watch(hostelServiceProvider).getPresenceGroup(
        key,
        startDate,
        endDate,
        id,
      );
  return result;
}

@riverpod
Future<List<Kinerja>> fetchPresenceFilter(
  FetchPresenceFilterRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String id,
  required String value,
}) async {
  final result = ref.watch(hostelServiceProvider).getPresenceFilter(
        key,
        startDate,
        endDate,
        id,
        value,
      );
  return result;
}

@riverpod
Future<List<Kinerja>> fetchPermitAttendance(
  FetchPermitAttendanceRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String id,
}) async {
  final result = ref.watch(hostelServiceProvider).getPermitAttendance(
        key,
        startDate,
        endDate,
        id,
      );
  return result;
}
