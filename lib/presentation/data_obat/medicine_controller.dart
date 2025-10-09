import 'package:syathiby/models/medicine/medicine.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/transaction/detail_transaction.dart';
import 'package:syathiby/models/transaction/history_transaction.dart';
import 'package:syathiby/models/transaction/order.dart';
import 'package:syathiby/models/transaction/request_transaction.dart';
import 'package:syathiby/models/transaction/transaction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/job/job_detail.dart';
import '../../models/message.dart';
import '../../models/unit/unit.dart';

part 'medicine_controller.g.dart';

@riverpod
class MedicineController extends _$MedicineController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> confirmMedicineRequest({
    required String key,
    required String invoiceId,
    required String data,
    String? reason,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(transactionServiceProvider)
          .aprovePermintaanObat(key, invoiceId, data, reason),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Order?> addMedicineRequest({
    required RequestTransaction requestTransaction,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(transactionServiceProvider)
          .processPermintaaanObat(requestTransaction.toJson()),
    );
    state = result;

    return result.valueOrNull;
  }

  Future<Message?> addMedicine({
    required String key,
    required String name,
    required String unit,
    required String stock,
    required String description,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(medicineServiceProvider)
          .add(key, name, unit, stock, description),
    );
    state = result;

    return result.valueOrNull;
  }

  Future<Message?> updateMedicine({
    required String key,
    required String medicineId,
    required String name,
    required String unit,
    required String stock,
    required String description,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref
          .watch(medicineServiceProvider)
          .update(key, medicineId, name, unit, stock, description),
    );
    state = result;

    return result.valueOrNull;
  }

  Future<Message?> removeMedicine({
    required String key,
    required String medicineId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(medicineServiceProvider).delete(key, medicineId),
    );
    state = result;

    return result.valueOrNull;
  }
}

@riverpod
Future<List<Transaction>> searchMedicineRequest(
  SearchMedicineRequestRef ref, {
  required String key,
  required String query,
}) async {
  final result =
      ref.watch(transactionServiceProvider).searchTransactionObat(key, query);
  return result;
}

@riverpod
Future<List<HistoryTransaction>> historyMedicineRequest(
  HistoryMedicineRequestRef ref, {
  required String key,
  required String startDate,
  required String endDate,
  required String status,
}) async {
  final result = ref.watch(transactionServiceProvider).historyPengadaanObat(
        key,
        startDate,
        endDate,
        status,
      );
  return result;
}

@riverpod
Future<DetailTransaction> detailMedicineRequest(
  DetailMedicineRequestRef ref, {
  required String key,
  required String invoiceId,
}) async {
  final result = ref
      .watch(transactionServiceProvider)
      .getDetailPermintaanObat(key, invoiceId);
  return result;
}

@riverpod
Future<DetailsJob> timelineMedicineRequest(
  TimelineMedicineRequestRef ref, {
  required String key,
  required String invoiceId,
}) async {
  final result =
      ref.watch(jobServiceProvider).getDetailPermintaanObat(key, invoiceId);
  return result;
}

@riverpod
Future<List<Product>> fetchAllMedicine(
  FetchAllMedicineRef ref, {
  required String key,
  required String trx,
  required String haveStock,
}) async {
  final result =
      ref.watch(productServiceProvider).chooseObat(key, trx, haveStock);
  return result;
}

@riverpod
Future<List<Unit>> fetchAllUnit(
  FetchAllUnitRef ref, {
  required String key,
}) async {
  final result = ref.watch(unitServiceProvider).getUnit(key);
  return result;
}

@riverpod
Future<List<DataObat>> fetchAllMedicineData(
  FetchAllMedicineDataRef ref, {
  required String key,
}) async {
  final result = ref.watch(medicineServiceProvider).gets(key);
  return result;
}

@riverpod
Future<List<Product>> searchMedicine(
  SearchMedicineRef ref, {
  required String key,
  required String query,
  required String haveStock,
}) async {
  final result =
      ref.watch(productServiceProvider).chooseSearchObat(key, query, haveStock);
  return result;
}
