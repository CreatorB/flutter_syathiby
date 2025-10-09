import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/tahfidz/tahfidz.dart';

part 'tahfidz_controller.g.dart';

@riverpod
class TahfidzController extends _$TahfidzController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> editTahfidzStudent({
    required String key,
    required String tahfidzId,
    required String tahfidzType,
    required String? memorizeTime,
    required String page,
    required String pageEnd,
    required String? detail,
    required String total,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).editSantri(
            key,
            tahfidzId,
            tahfidzType,
            memorizeTime,
            page,
            pageEnd,
            detail,
            total,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> insertTahfidzStudent({
    required String key,
    required String tahfidzType,
    required String? memorizeTime,
    required String page,
    required String pageEnd,
    required String studentId,
    required String classId,
    required String? detail,
    required String total,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).addSantri(
            key,
            tahfidzType,
            memorizeTime,
            page,
            pageEnd,
            studentId,
            classId,
            detail,
            total,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<List<Tahfidz>?> deleteTahfidzStudent({
    required String key,
    required String dateStart,
    required String dateEnd,
    required String tahfidzId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(tahfidzServiceProvider)
          .getRekapTahfidzDelete(key, dateStart, dateEnd, tahfidzId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> insertGradeTahfidz({
    required String key,
    required String gradeTypeId,
    required String grade,
    required String studentId,
    required String classId,
    String? detail,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).addPenilaianSantri(
            key,
            gradeTypeId,
            grade,
            studentId,
            classId,
            detail,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> editTahfidzGradeStudent({
    required String key,
    required String tahfidzId,
    required String gradeTypeId,
    required String grade,
    String? detail,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(tahfidzServiceProvider).editPenilaianSantri(
            key,
            tahfidzId,
            gradeTypeId,
            grade,
            detail,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<List<Tahfidz>?> deleteTahfidzGradeStudent({
    required String key,
    required String dateStart,
    required String dateEnd,
    required String tahfidzId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(tahfidzServiceProvider)
          .getPenilaianTahfidzDelete(key, dateStart, dateEnd, tahfidzId),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Tahfidz>> fetchAllTahfidz(
  FetchAllTahfidzRef ref, {
  required String key,
  required String dateStart,
  required String dateEnd,
}) async {
  final result = await ref
      .watch(tahfidzServiceProvider)
      .getTahfidzdate(key, dateStart, dateEnd);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchDetailTahfidz(
  FetchDetailTahfidzRef ref, {
  required String key,
  required String tahfidzId,
}) async {
  final result =
      await ref.watch(tahfidzServiceProvider).getTahfidzSantri(key, tahfidzId);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchDetailTahfidzGrade(
  FetchDetailTahfidzGradeRef ref, {
  required String key,
  required String tahfidzId,
}) async {
  final result = await ref
      .watch(tahfidzServiceProvider)
      .getTahfidzPenilianSantri(key, tahfidzId);
  return result;
}

@riverpod
Future<List<Siswa>> fetchStudentTahfidzFilter(
  FetchStudentTahfidzFilterRef ref, {
  required String key,
  required int page,
}) async {
  final result =
      await ref.watch(studentServiceProvider).getSiswaFilter(key, page);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchAllTahfidzGrade(
  FetchAllTahfidzGradeRef ref, {
  required String key,
  required String dateStart,
  required String dateEnd,
}) async {
  final result = await ref.watch(tahfidzServiceProvider).getTahfidzPenilaian(
        key,
        dateStart,
        dateEnd,
      );
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchTahfidzType(
  FetchTahfidzTypeRef ref, {
  required String key,
}) async {
  final result = await ref.watch(tahfidzServiceProvider).jenis(key);
  return result;
}

@riverpod
Future<List<Tahfidz>> fetchTahfidzGradeType(
  FetchTahfidzGradeTypeRef ref, {
  required String key,
  required String type,
}) async {
  final result = await ref.watch(tahfidzServiceProvider).typeNilai(key, type);
  return result;
}
