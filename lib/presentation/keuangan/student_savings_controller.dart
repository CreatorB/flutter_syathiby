import 'dart:io';

import 'package:syathiby/models/category_expense/category_expense.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/transaction/request_spending.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/student/siswa.dart';
import '../../models/transaction/detail_spend.dart';
import '../../models/transaction/history_transaction.dart';
import '../../models/transaction/order.dart';

part 'student_savings_controller.g.dart';

@riverpod
class StudentSavingsController extends _$StudentSavingsController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> addStudentTransaction({
    required String key,
    required String studentId,
    required String type,
    required String nominal,
    required String notes,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() => ref
        .watch(studentServiceProvider)
        .getTransaksiSantri(key, studentId, type, nominal, notes));
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> deleteSpending({
    required String key,
    required String invoiceId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(transactionServiceProvider).deleteDetailSpend(
            key,
            invoiceId,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Order?> addSpending({
    required RequestSpending requestSpending,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(transactionServiceProvider).add(
            '${requestSpending.key}',
            '${requestSpending.date}',
            requestSpending.amount!,
            requestSpending.toJson(),
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Siswa>> fetchStudentSavings(
  FetchStudentSavingsRef ref, {
  required String key,
  required String type,
}) async {
  final result = ref.watch(studentServiceProvider).getDataKeuangan(key, type);
  return result;
}

@riverpod
Future<List<Siswa>> searchStudentTransaction(
  SearchStudentTransactionRef ref, {
  required String key,
  required String query,
  required String type,
}) async {
  final result = ref
      .watch(studentServiceProvider)
      .getSantriTransaksiSearch(key, query, type);
  return result;
}

@riverpod
Future<List<HistoryTransaction>> fetchAllSpending(
  FetchAllSpendingRef ref, {
  required String key,
  required String startDate,
  required String endDate,
}) async {
  final result = ref.watch(transactionServiceProvider).historySpend(
        key,
        startDate,
        endDate,
      );
  return result;
}

@riverpod
Future<DetailSpend> fetchDetailSpending(
  FetchDetailSpendingRef ref, {
  required String key,
  required String invoiceId,
}) async {
  final result =
      ref.watch(transactionServiceProvider).getDetailSpend(key, invoiceId);
  return result;
}

@riverpod
Future<List<CategoryExpense>> fetchAllCategoryExpanse(
  FetchAllCategoryExpanseRef ref, {
  required String key,
}) async {
  final result = ref.watch(expanseServiceProvider).getCategories(key);
  return result;
}
