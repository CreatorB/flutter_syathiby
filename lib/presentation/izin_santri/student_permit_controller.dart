import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/permit/permit.dart';
import '../../models/service_injection.dart';

part 'student_permit_controller.g.dart';

@riverpod
class StudentPermitController extends _$StudentPermitController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addPermit({
    required String key,
    required String permitId,
    required String permitName,
    required String date,
    required String day,
    required String studentId,
    required String classId,
    required String detail,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(permitServiceProvider).addSantri(
          key, permitId, permitName, date, day, studentId, classId, detail),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> onApprove({
    required String key,
    required String permitId,
    required String value,
    required String reason,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(permitServiceProvider)
          .aprovePermitSantri(key, permitId, value, reason),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Permit>> fetchStudentPermitList(
  FetchStudentPermitListRef ref, {
  required String key,
  required int page,
}) async {
  final result = await ref.watch(permitServiceProvider).getSantri(key, page);
  return result;
}

@riverpod
Future<List<Permit>> fetchDetailStudentPermit(
  FetchDetailStudentPermitRef ref, {
  required String key,
  required String id,
}) async {
  final result =
      await ref.watch(permitServiceProvider).getPermitSantri(key, id);
  return result;
}
