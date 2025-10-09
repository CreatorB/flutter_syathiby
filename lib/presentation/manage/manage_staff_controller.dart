import 'dart:io';

import 'package:syathiby/models/staff/staff.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/message.dart';
import '../../models/service_injection.dart';
import '../../models/store/store.dart';

part 'manage_staff_controller.g.dart';

@riverpod
class ManageStaffController extends _$ManageStaffController {
  @override
  FutureOr<void> build() async {
    return;
  }

  Future<Message?> deleteStaff({
    required String key,
    required String staffId,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(staffServiceProvider).delete(
            key,
            staffId,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> updateStaff({
    required String key,
    required String staffId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String salary,
    required String overtime,
    required String comission,
    required String allowance,
    required String salaryCuts,
    required String store,
    required String level,
    required String type,
    required String position,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(staffServiceProvider).update(
            key,
            staffId,
            name,
            email,
            phone,
            address,
            salary,
            overtime,
            comission,
            allowance,
            salaryCuts,
            store,
            level,
            type,
            position,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> addStaff({
    required String key,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String salary,
    required String overtime,
    required String comission,
    required String allowance,
    required String salaryCuts,
    required String store,
    required String level,
    required String type,
    required String position,
    File? image,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(staffServiceProvider).add(
            key,
            name,
            email,
            phone,
            address,
            salary,
            overtime,
            comission,
            allowance,
            salaryCuts,
            store,
            level,
            type,
            position,
            img: image,
          ),
    );
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<List<Store>> fetchAllStore(
  FetchAllStoreRef ref, {
  required String key,
}) async {
  final result = ref.watch(storeServiceProvider).gets(key);
  return result;
}

@riverpod
Future<List<Staff>> searchStaff(
  SearchStaffRef ref, {
  required String key,
  required String query,
}) async {
  final result = ref.watch(staffServiceProvider).search(key, query);
  return result;
}
