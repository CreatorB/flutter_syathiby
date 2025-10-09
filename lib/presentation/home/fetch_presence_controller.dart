import 'package:syathiby/models/days/days.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/store/store.dart';
import 'package:syathiby/models/user/request_logout.dart';
import 'package:syathiby/models/user/user.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'fetch_presence_controller.g.dart';

@riverpod
Future<Store?> fetchPresence(
  FetchPresenceRef ref, {
  required String key,
}) async {
  final result = await ref.watch(storeServiceProvider).getStore(key);
  return result.firstOrNull;
}

@riverpod
Future<List<Days>> fetchScheduleJob(
  FetchScheduleJobRef ref, {
  required String key,
}) async {
  final result = ref.watch(scheduleServiceProvider).gets(key);
  return result;
}

@riverpod
Future<User> saveTokenToServer(
  SaveTokenToServerRef ref, {
  required String key,
  required String token,
}) async {
  final result = await ref.watch(userServiceProvider).getToken(
        RequestLogout(
          key: key,
          token: token,
        ),
      );
  return result;
}
