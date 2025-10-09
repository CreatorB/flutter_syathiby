import 'dart:io';

import 'package:syathiby/models/allocation/allocation.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/transaction/detail_history.dart';
import 'package:syathiby/models/transaction/detail_transaction.dart';
import 'package:syathiby/models/transaction/history_transaction.dart';
import 'package:syathiby/models/transaction/request_raw_material.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/product/product.dart';
import '../../models/transaction/order.dart';

part 'kitchen_controller.g.dart';

@riverpod
class KitchenController extends _$KitchenController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addFoodMenu({
    required String key,
    required String name,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(productServiceProvider).addMenu(key, name, img: image),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addRawMaterial({
    required String key,
    required String name,
    required String unit,
    required double sellPrice,
    required double stock,
    required String description,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(rawMaterialServiceProvider).add(
            key,
            name,
            unit,
            sellPrice,
            stock,
            description,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Order?> orderRawMaterial({
    required RequestRawMaterial requestRawMaterial,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(transactionServiceProvider).orderraw(
            requestRawMaterial.toJson(),
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Order?> addReportCooking({
    required RequestTransaction requestTransaction,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(transactionServiceProvider)
          .processMasak(requestTransaction),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> editFoodMenu({
    required String key,
    required String menuId,
    required String name,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(productServiceProvider).updateMenu(
            key,
            menuId,
            name,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> editRawMaterial({
    required String key,
    required String id,
    required String name,
    required String unit,
    required double sellPrice,
    required double stock,
    required String description,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(rawMaterialServiceProvider).update(
            key,
            id,
            name,
            unit,
            sellPrice,
            stock,
            description,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> editRealStock({
    required String key,
    required String id,
    required String stock,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(rawMaterialServiceProvider).updateStock(
            key,
            id,
            stock,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> deleteFoodMenu({
    required String key,
    required String menuId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(productServiceProvider).delete(key, menuId),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> deleteRawMaterial({
    required String key,
    required String id,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(rawMaterialServiceProvider).delete(key, id),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Product>> fetchAllFoodMenu(
  FetchAllFoodMenuRef ref, {
  required String key,
}) async {
  final result = ref.watch(productServiceProvider).getsMenu(key);
  return result;
}

@riverpod
Future<List<RawMaterial>> fetchAllRawMaterial(
  FetchAllRawMaterialRef ref, {
  required String key,
}) async {
  final result = ref.watch(rawMaterialServiceProvider).gets(key);
  return result;
}

@riverpod
Future<List<RawMaterial>> fetchRealStockRawMaterial(
  FetchRealStockRawMaterialRef ref, {
  required String key,
}) async {
  final result = ref.watch(rawMaterialServiceProvider).getsStock(key);
  return result;
}

@riverpod
Future<List<DetailHistory>> fetchHistoryRawMaterial(
  FetchHistoryRawMaterialRef ref, {
  required String key,
  required String productId,
  required String startDate,
  required String endDate,
}) async {
  final result =
      ref.watch(transactionServiceProvider).getHistoryStockRawMaterial(
            key,
            productId,
            startDate,
            endDate,
          );
  return result;
}

@riverpod
Future<List<Product>> fetchDetailFoodMenu(
  FetchDetailFoodMenuRef ref, {
  required String key,
}) async {
  final result = ref.watch(productServiceProvider).getsMenu(key);
  return result;
}

@riverpod
Future<List<HistoryTransaction>> fetchReportCooking(
  FetchReportCookingRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  String? status,
}) async {
  final result = ref.watch(transactionServiceProvider).historyMasak(
        key,
        startDate,
        endDate,
        status,
      );
  return result;
}

@riverpod
Future<DetailTransaction> fetchDetailReportCooking(
  FetchDetailReportCookingRef ref, {
  required String key,
  required String id,
}) async {
  final result = ref.watch(transactionServiceProvider).getDetailMasak(key, id);
  return result;
}

@riverpod
Future<List<Allocation>> fetchCookingTime(
  FetchCookingTimeRef ref, {
  required String key,
}) async {
  final result = ref.watch(allocationServiceProvider).getWaktu(key);
  return result;
}
