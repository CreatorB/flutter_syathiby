import 'dart:io';

import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/violation/violation.dart';

part 'reward_controller.g.dart';

@riverpod
class RewardController extends _$RewardController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addReward({
    required String key,
    required String rewardName,
    required String date,
    required String hour,
    required String location,
    required String studentName,
    required String detail,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(violationServiceProvider).addReward(
            key,
            rewardName,
            date,
            hour,
            location,
            studentName,
            detail,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Pelanggaran>> fetchAllReward(
  FetchAllRewardRef ref, {
  required String key,
}) async {
  final result = ref.watch(violationServiceProvider).getReward(key);
  return result;
}

@riverpod
Future<List<Pelanggaran>> fetchAllTypeReward(
  FetchAllTypeRewardRef ref, {
  required String key,
}) async {
  final result = ref.watch(violationServiceProvider).typeReward(key);
  return result;
}
