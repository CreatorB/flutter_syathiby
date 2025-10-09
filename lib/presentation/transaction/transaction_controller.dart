import 'dart:io';

import 'package:syathiby/models/allocation/allocation.dart';
import 'package:syathiby/models/job/job_detail.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/transaction/detail_transaction.dart';
import 'package:syathiby/models/transaction/order.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/models/transaction/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/transaction/history_transaction.dart';

part 'transaction_controller.g.dart';

@riverpod
class TransactionController extends _$TransactionController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<List<Product>?> addItem({
    required String key,
    required String name,
    required String unit,
    required String sellingPrice,
    required String haveStock,
    required String stock,
    required String alertStock,
    required String barcode,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(cartServiceProvider).addProduct(
            key,
            name,
            unit,
            sellingPrice,
            haveStock,
            stock,
            alertStock,
            barcode,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Order?> addOrderTransaction({
    required RequestTransaction requestTransaction,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(transactionServiceProvider)
          .processPengadaan(requestTransaction.toJson()),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> changePriceItem({
    required String key,
    required String productId,
    required String invoiceId,
    required String newPrice,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(transactionServiceProvider)
          .hargaPengadaan(key, productId, invoiceId, newPrice),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> approveRequestTransaction({
    required String key,
    required String invoiceId,
    required String data,
    String? reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(transactionServiceProvider)
          .aprovePengadaan(key, invoiceId, data, reason),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> deleteItem({
    required String key,
    required String id,
    String? reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(productServiceProvider).delete(key, id),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<HistoryTransaction>> fetchHistoryTransaction(
  FetchHistoryTransactionRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String status,
}) async {
  final result = ref
      .watch(transactionServiceProvider)
      .historyPengadaan(key, startDate, endDate, status);
  return result;
}

@riverpod
Future<List<Transaction>> fetchRequestItems(
  FetchRequestItemsRef ref, {
  required String key,
}) async {
  final result = ref.watch(transactionServiceProvider).dataPengadaan(key);
  return result;
}

@riverpod
Future<DetailTransaction> fetchDetailRequestTransaction(
  FetchDetailRequestTransactionRef ref, {
  required String key,
  required String invoiceId,
}) async {
  final result = ref.watch(transactionServiceProvider).getDetailPengadaan(
        key,
        invoiceId,
      );
  return result;
}

@riverpod
Future<DetailsJob> fetchDetailRequestTransactionTimeline(
  FetchDetailRequestTransactionTimelineRef ref, {
  required String key,
  required String invoiceId,
}) async {
  final result = ref.watch(jobServiceProvider).getDetailPengadaan(
        key,
        invoiceId,
      );
  return result;
}

@riverpod
Future<List<Product>> fetchAllItem(
  FetchAllItemRef ref, {
  required String key,
  required String trx,
  required String haveStock,
  required int page,
}) async {
  final result = ref.watch(productServiceProvider).gets(
        key,
        trx,
        haveStock,
        page,
      );
  return result;
}

@riverpod
Future<List<Allocation>> fetchAllAllocation(
  FetchAllAllocationRef ref, {
  required String key,
}) async {
  final result = ref.watch(allocationServiceProvider).get(key);
  return result;
}

@riverpod
Future<List<Allocation>> fetchAllTransactionType(
  FetchAllTransactionTypeRef ref, {
  required String key,
}) async {
  final result = ref.watch(allocationServiceProvider).getType(key);
  return result;
}
