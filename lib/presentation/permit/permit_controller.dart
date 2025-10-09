import 'dart:io';

import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'permit_controller.g.dart';

@riverpod
class PermitController extends _$PermitController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addPermit({
    required String key,
    required String permitName,
    required String date,
    required String day,
    required String detail,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(permitServiceProvider)
          .add(key, permitName, date, day, detail),
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
          .aprovePermit(key, permitId, value, reason),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Permit>> fetchPermitType(
  FetchPermitTypeRef ref, {
  required String key,
  required String type,
}) async {
  final result = await ref.watch(permitServiceProvider).type(key, type);
  return result;
}

@riverpod
Future<List<Permit>> fetchPermitList(
  FetchPermitListRef ref, {
  required String key,
  required int page,
}) async {
  final result = await ref.watch(permitServiceProvider).get(key, page);
  return result;
}

@riverpod
Future<List<Permit>> fetchPermitDetail(
  FetchPermitDetailRef ref, {
  required String key,
  required String id,
}) async {
  final result = await ref.watch(permitServiceProvider).getPermit(key, id);
  return result;
}
