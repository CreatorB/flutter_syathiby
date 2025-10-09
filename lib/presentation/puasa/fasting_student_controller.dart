import 'package:syathiby/models/fasting/fasting.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';

part 'fasting_student_controller.g.dart';

@riverpod
class FastingStudentController extends _$FastingStudentController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addFastingStudent({
    required String key,
    required String typeId,
    required String studentId,
    required String classId,
    required String hostelId,
    required String date,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(fastingServiceProvider).addPuasa(
            key,
            typeId,
            studentId,
            classId,
            hostelId,
            date,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Puasa>> fetchAllFastingStudent(
  FetchAllFastingStudentRef ref, {
  required String key,
  required String dateStart,
  required String dateEnd,
}) async {
  final result =
      ref.watch(fastingServiceProvider).getListPuasa(key, dateStart, dateEnd);
  return result;
}

@riverpod
Future<List<Puasa>> fetchAllFastingType(
  FetchAllFastingTypeRef ref, {
  required String key,
}) async {
  final result = ref.watch(fastingServiceProvider).jenisPuasa(key);
  return result;
}
