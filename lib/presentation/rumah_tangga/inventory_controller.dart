import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/place/inventaris.dart';
import '../../models/service_injection.dart';

part 'inventory_controller.g.dart';

@riverpod
class InventoryController extends _$InventoryController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addInventory({
    required String key,
    required String placeId,
    required String name,
    required String unit,
    required String code,
    required String goodCondition,
    required String mediumCondition,
    required String badCondition,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(placeServiceProvider).addInventaris(
            key,
            placeId,
            name,
            unit,
            code,
            goodCondition,
            mediumCondition,
            badCondition,
            img: image,
          ),
    );
    state = result;

    return result.valueOrNull;
  }

  Future<Message?> updateInventory({
    required String key,
    required String id,
    required String name,
    required String unit,
    required String code,
    required String goodCondition,
    required String mediumCondition,
    required String badCondition,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(placeServiceProvider).updateInventaris(
            key,
            id,
            name,
            unit,
            code,
            goodCondition,
            mediumCondition,
            badCondition,
            img: image,
          ),
    );
    state = result;

    return result.valueOrNull;
  }
}

@riverpod
Future<List<Inventaris>> fetchAllInventory(
  FetchAllInventoryRef ref, {
  required String key,
  required String placeId,
}) async {
  final result = ref.watch(placeServiceProvider).getInventaris(key, placeId);
  return result;
}
