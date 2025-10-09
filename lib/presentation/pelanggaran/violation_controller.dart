import 'dart:io';

import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/student/siswa.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/violation/violation.dart';

part 'violation_controller.g.dart';

@riverpod
class ViolationController extends _$ViolationController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addViolation({
    required String key,
    required String violationName,
    required String date,
    required String hour,
    required String location,
    required String studentName,
    required String detail,
    required String type,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(violationServiceProvider).add(
            key,
            violationName,
            date,
            hour,
            location,
            studentName,
            detail,
            type,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> approveReportViolation({
    required String key,
    required String violationId,
    required String message,
    required String reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(violationServiceProvider)
          .aproveLaporanSantri(key, violationId, message, reason),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> updateDateViolation({
    required String key,
    required String violationId,
    required String date,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(violationServiceProvider)
          .updateDatePelanggaran(key, violationId, date),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Pelanggaran>> fetchListViolation(
  FetchListViolationRef ref, {
  required String key,
  required String type,
  required int page,
}) async {
  final result = await ref.watch(violationServiceProvider).get(key, type, page);
  return result;
}

@riverpod
Future<List<Pelanggaran>> fetchViolationType(
  FetchViolationTypeRef ref, {
  required String key,
  required String type,
}) async {
  final result = await ref.watch(violationServiceProvider).type(key, type);
  return result;
}

@riverpod
Future<List<Siswa>> fetchSearchStudent(
  FetchSearchStudentRef ref, {
  required String key,
  required String query,
}) async {
  final result =
      await ref.watch(studentServiceProvider).searchSiswa(key, query);
  return result;
}

@riverpod
Future<List<Pelanggaran>> fetchDetailViolation(
  FetchDetailViolationRef ref, {
  required String key,
  required String violationId,
}) async {
  final result = await ref
      .watch(violationServiceProvider)
      .getLaporanSantri(key, violationId);
  return result;
}
