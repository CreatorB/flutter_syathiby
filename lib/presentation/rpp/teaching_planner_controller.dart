import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/rpp/rpp.dart';

part 'teaching_planner_controller.g.dart';

@riverpod
class TeachingPlannerController extends _$TeachingPlannerController {
  @override
  FutureOr<void> build() async {
    return;
  }
}

@riverpod
Future<List<Rpp>> fetchAllTeachingPlanner(
  FetchAllTeachingPlannerRef ref, {
  required String key,
}) async {
  final result = ref.watch(teachingPlannerServiceProvider).getRpp(key);
  return result;
}
