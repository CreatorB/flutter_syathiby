import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/staff/kinerja.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'performance_controller.g.dart';

@riverpod
Future<List<Kinerja>> fetchStaffPerformance(
  FetchStaffPerformanceRef ref, {
  required String key,
  required int page,
  required int limit,
}) async {
  return await ref.watch(staffServiceProvider).detailStaff(key, page, limit);
}

@riverpod
Future<List<Kinerja>> fetchPerformanceDetail(
  FetchPerformanceDetailRef ref, {
  required String key,
}) async {
  return await ref.watch(staffServiceProvider).detailKinerja(key);
}
