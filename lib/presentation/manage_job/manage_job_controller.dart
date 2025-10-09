import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/job/job.dart';

part 'manage_job_controller.g.dart';

@riverpod
class ManageJobController extends _$ManageJobController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> removeJob({
    required String key,
    required String jobId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(jobServiceProvider).delete(key, jobId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addJob({
    required String key,
    required String note,
    required String detail,
    required String operator,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(jobServiceProvider).add(key, note, detail, operator),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> editJob({
    required String key,
    required String jobId,
    required String note,
    required String detail,
    required String operator,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(jobServiceProvider).update(
            key,
            jobId,
            note,
            detail,
            operator,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Job>> fetchAllJob(
  FetchAllJobRef ref, {
  required String key,
}) async {
  final result = await ref.watch(jobServiceProvider).get(key);
  return result;
}
