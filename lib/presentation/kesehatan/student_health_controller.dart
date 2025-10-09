import 'dart:io';

import 'package:syathiby/models/health/diagnose.dart';
import 'package:syathiby/models/health/health.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'student_health_controller.g.dart';

@riverpod
class StudentHealthController extends _$StudentHealthController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addStudentHealth({
    required String key,
    required String diagnose,
    required String complaint,
    required String date,
    required String hour,
    required String handling,
    required String studentName,
    required String classId,
    required String pickedUp,
    required String tellParent,
    required String rest,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(healthServiceProvider).add(
            key,
            diagnose,
            complaint,
            date,
            hour,
            handling,
            studentName,
            classId,
            pickedUp,
            tellParent,
            rest,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> approveStudentHealth({
    required String key,
    required String studentHealthId,
    required String value,
    required String reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .read(healthServiceProvider)
          .aproveLaporanSantri(key, studentHealthId, value, reason),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Kesehatan>> fetchStudentHealth(
  FetchStudentHealthRef ref, {
  required String key,
  required int page,
}) async {
  final result = await ref.watch(healthServiceProvider).get(key, page);
  return result;
}

@riverpod
Future<List<Diagnosa>> fetchHealthType(
  FetchHealthTypeRef ref, {
  required String key,
}) async {
  final result = await ref.watch(healthServiceProvider).getDiagnosa();
  return result;
}

@riverpod
Future<List<Kesehatan>> fetchDetailStudentHealth(
  FetchDetailStudentHealthRef ref, {
  required String key,
  required String studentHealthId,
}) async {
  final result = await ref
      .watch(healthServiceProvider)
      .getLaporanSantri(key, studentHealthId);
  return result;
}
