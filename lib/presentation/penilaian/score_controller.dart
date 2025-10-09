import 'package:syathiby/models/score/score.dart';
import 'package:syathiby/models/score/score_type.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/schedule/schedule.dart';

part 'score_controller.g.dart';

@riverpod
class ScoreController extends _$ScoreController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addScore({
    required String key,
    required String classId,
    required String subjectId,
    required String studentId,
    required String scoreTypeId,
    required String score,
    required String date,
    required String note,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(scoreServiceProvider).addNilai(
            key,
            classId,
            subjectId,
            score,
            date,
            studentId,
            note,
            scoreTypeId,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<TypeNilai>> fetchAllScoreType(
  FetchAllScoreTypeRef ref, {
  required String key,
  required String type,
}) async {
  final result = await ref.watch(scoreServiceProvider).getTypeNilai(key, type);
  return result;
}

@riverpod
Future<List<Jadwal>> fetchAllSubject(
  FetchAllSubjectRef ref, {
  required String key,
  String? id,
}) async {
  if (id == null) return [];
  final result =
      await ref.watch(teachingScheduleServiceProvider).getMapel(key, id);
  return result;
}

@riverpod
Future<List<Nilai>> fetchStudentScore(
  FetchStudentScoreRef ref, {
  required String key,
  required String classId,
  required String subjectId,
  required String typeId,
}) async {
  final result = await ref
      .watch(scoreServiceProvider)
      .getNilai(key, classId, subjectId, typeId);
  return result;
}

@riverpod
Future<List<Nilai>> fetchAllScore(
  FetchAllScoreRef ref, {
  required String key,
  required String classId,
  required String subjectId,
  required String studentId,
  required String typeId,
}) async {
  final result = await ref
      .watch(scoreServiceProvider)
      .getDetailNilaiSantri(key, classId, subjectId, studentId, typeId);
  return result;
}
