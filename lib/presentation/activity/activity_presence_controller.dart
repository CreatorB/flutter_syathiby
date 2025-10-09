import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/tahfidz/tahfidz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/student/siswa.dart';

part 'activity_presence_controller.g.dart';

@riverpod
class ActivityPresenceController extends _$ActivityPresenceController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addStudentActivity({
    required String key,
    required String studentId,
    required String type,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getSantriKegiatan(key, studentId, type),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addStudentActivitySearch({
    required String key,
    required String search,
    required String type,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(studentServiceProvider)
          .getSantriKegiatanSearch(key, search, type),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Tahfidz>> fetchAllActivity(
  FetchAllActivityRef ref, {
  required String key,
}) async {
  final result = ref.watch(tahfidzServiceProvider).kegiatan(key);
  return result;
}

@riverpod
Future<List<Siswa>> fetchDetailActivity(
  FetchDetailActivityRef ref, {
  required String key,
  required String date,
  required String time,
}) async {
  final result =
      ref.watch(studentServiceProvider).getJadwalKegiatan(key, date, time);
  return result;
}
