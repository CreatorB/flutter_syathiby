import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/student/siswa.dart';
import '../../models/tahfidz/tahfidz.dart';

part 'parenting_score_controller.g.dart';

@riverpod
class ParentingScoreController extends _$ParentingScoreController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> deleteScoreParenting({
    required String key,
    required String dateStart,
    required String dateEnd,
    required String tahfidzId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).getPenilaianKepengasuhanDelete(
            key,
            dateStart,
            dateEnd,
            tahfidzId,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addScoreParenting({
    required String key,
    required String typeId,
    required String score,
    required String studentId,
    required String classId,
    String? detail,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).addPenilaianKepengasuhan(
            key,
            typeId,
            score,
            studentId,
            classId,
            detail,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> updateScoreParenting({
    required String key,
    required String tahfidzId,
    required String typeId,
    required String score,
    String? detail,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).editPenilaianKepengasuhan(
            key,
            tahfidzId,
            typeId,
            score,
            detail,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Tahfidz>> fetchAllScoreParenting(
  FetchAllScoreParentingRef ref, {
  required String key,
  required String dateStart,
  required String dateEnd,
}) async {
  final result = ref
      .watch(tahfidzServiceProvider)
      .getKepengasuhanPenilaian(key, dateStart, dateEnd);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchAllParentingType(
  FetchAllParentingTypeRef ref, {
  required String key,
  required String type,
}) async {
  final result = ref.watch(tahfidzServiceProvider).typePenilaian(key, type);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchDetailScoreParenting(
  FetchDetailScoreParentingRef ref, {
  required String key,
  required String tahfidzId,
}) async {
  final result = ref
      .watch(tahfidzServiceProvider)
      .getKepengasuhanPenilianSantri(key, tahfidzId);
  return result;
}

@riverpod
Future<List<Siswa>> fetchAllStudent(
  FetchAllStudentRef ref, {
  required String key,
  required int page,
}) async {
  final result = await ref.watch(studentServiceProvider).getSiswa(key, page);
  return result;
}
