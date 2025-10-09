import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/report_card/rapor.dart';
import '../../models/student/siswa.dart';

part 'homeroom_teacher_controller.g.dart';

@riverpod
class HomeroomTeacherController extends _$HomeroomTeacherController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> updateReport({
    required String key,
    required String classId,
    required String rankNumber,
    required String description,
    required String studentId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(reportCardServiceProvider)
          .updateReport(key, classId, rankNumber, description, studentId),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Siswa>> fetchHomeroomTeacher(
  FetchHomeroomTeacherRef ref, {
  required String key,
}) async {
  final result = ref.watch(studentServiceProvider).getKelas(key);
  return result;
}

@riverpod
Future<List<Rapor>> fetchHomeroomTeacherClass(
  FetchHomeroomTeacherClassRef ref, {
  required String key,
  required String classId,
  required String studentId,
}) async {
  final result = ref.watch(studentServiceProvider).getSiswaKelas(
        key,
        classId,
        studentId,
      );
  return result;
}
