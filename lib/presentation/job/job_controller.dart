import 'package:syathiby/models/job/job.dart';
import 'package:syathiby/models/job/job_detail.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'job_controller.g.dart';

@riverpod
class JobController extends _$JobController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> comment({
    required String key,
    required String id,
    required String data,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(jobServiceProvider).comment(key, id, data),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> processDetailJob({
    required String key,
    required String id,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(jobServiceProvider).proccesDetailJob(key, id),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> finishDetailJob({
    required String key,
    required String id,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(jobServiceProvider).finishDetailJob(key, id),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Job>> fetchJobs(
  FetchJobsRef ref, {
  required String key,
  required String status,
}) async {
  final result = await ref.watch(jobServiceProvider).gets(key, status);
  return result;
}

@riverpod
Future<DetailsJob> fetchJobDetail(
  FetchJobDetailRef ref, {
  required String key,
  required String jobId,
}) async {
  final result = await ref.watch(jobServiceProvider).getDetailJob(key, jobId);
  return result;
}
