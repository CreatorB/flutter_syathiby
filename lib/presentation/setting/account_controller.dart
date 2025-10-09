import 'dart:io';

import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/slip/absent.dart';
import 'package:syathiby/models/user/request_logout.dart';
import 'package:syathiby/models/user/user.dart';
import 'package:syathiby/presentation/setting/presence_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

@riverpod
class AccountController extends _$AccountController {
  @override
  FutureOr<void> build() async {}

  Future<Message?> updateProfile({
    required String key,
    required String fullName,
    required String email,
    required String phoneNumber,
    required String address,
    File? file,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(userServiceProvider).updateProfile(
            key,
            fullName,
            email,
            phoneNumber,
            address,
            file: file,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Message?> changePassword({
    required String key,
    required String oldPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(userServiceProvider).changePassword(
            key,
            oldPassword,
            newPassword,
          ),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Absent?> registerPresence({
    required String key,
    required PresenceType presenceType,
    String? token,
    File? image,
  }) async {
    state = const AsyncLoading();
    AsyncValue<Absent> result;
    if (token != null && presenceType == PresenceType.biometric) {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).registerFinger(key, token),
      );
    } else {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).registerPhoto(key, image!),
      );
    }
    state = result;
    return result.valueOrNull;
  }

  Future<Absent?> presence({
    required String key,
    required double latitude,
    required double longitude,
    required bool mock,
    required String locationPresenceName,
    required PresenceType presenceType,
    String? token,
    File? image,
  }) async {
    state = const AsyncLoading();
    AsyncValue<Absent> result;
    if (presenceType == PresenceType.normal) {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).presenceNormal(
              key,
              latitude,
              longitude,
              mock,
              locationPresenceName,
            ),
      );
    } else if (token != null && presenceType == PresenceType.biometric) {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).presenceFinger(
              key,
              latitude,
              longitude,
              mock,
              locationPresenceName,
              token,
            ),
      );
    } else {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).presence(
              key,
              latitude,
              longitude,
              mock,
              locationPresenceName,
              file: image,
            ),
      );
    }
    state = result;
    return result.valueOrNull;
  }

  Future<Absent?> presenceOut(RequestLogout requestLogout) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.watch(userServiceProvider).getLogout(requestLogout),
    );
    state = result;
    return result.valueOrNull;
  }

  Future<Absent?> reasonLate({
    required String key,
    required String reason,
    required bool isClockIn,
  }) async {
    state = const AsyncLoading();
    AsyncValue<Absent> result;
    if (isClockIn) {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).reason(key, reason),
      );
    } else {
      result = await AsyncValue.guard(
        () => ref.watch(userServiceProvider).reasonOut(key, reason),
      );
    }
    state = result;
    return result.valueOrNull;
  }
}

@riverpod
Future<User> fetchProfile(
  FetchProfileRef ref, {
  required String key,
}) async {
  final result = await ref.watch(userServiceProvider).getProfile(key);
  return result.first;
}

@riverpod
Future<List<Asrama>> fetchPresenceLocation(
  FetchPresenceLocationRef ref, {
  required String key,
}) async {
  final result = await ref.watch(hostelServiceProvider).getGedungPresensi(key);
  return result;
}
