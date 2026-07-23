import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/models/hostel/hostel.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/slip/absent.dart';
import 'package:syathiby/models/user/request_logout.dart';
import 'package:syathiby/models/user/user.dart';
import 'package:syathiby/presentation/setting/presence_type.dart';
import 'package:syathiby/utils/rest_exception.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_controller.g.dart';

void _log(String message) {
  if (kDebugMode) {
    print('[AccountController] $message');
  }
}

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
        () async {
          try {
            _log('Calling presenceNormal API...');
            final response = await ref.watch(userServiceProvider).presenceNormal(
                  key,
                  latitude,
                  longitude,
                  mock,
                  locationPresenceName,
                );
            _log('presenceNormal response: $response');
            return response;
          } on DioException catch (e) {
            _log('DioException in presenceNormal: ${e.error}');
            if (e.error is RestException) {
              final re = e.error as RestException;
              _log('RestException: code=${re.errorCode}, message=${re.message}');
              return Absent(errCode: re.errorCode, msg: re.message);
            }
            _log('Re-throwing DioException');
            rethrow;
          }
        },
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

    _log('Final result for presence: hasError=${result.hasError}, valueOrNull=${result.valueOrNull}');
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
  try {
    _log('fetchProfile API call with key: $key');
    final result = await ref.watch(userServiceProvider).getProfile(key);
    _log('fetchProfile result count: ${result.length}');
    if (result.isEmpty) {
      _log('fetchProfile returned empty list');
      throw Exception('Data profil tidak ditemukan');
    }
    return result.first;
  } catch (e) {
    _log('fetchProfile error: $e');
    rethrow;
  }
}

@riverpod
Future<List<Asrama>> fetchPresenceLocation(
  FetchPresenceLocationRef ref, {
  required String key,
}) async {
  final result = await ref.watch(hostelServiceProvider).getGedungPresensi(key);
  return result;
}
