import 'dart:io';

import 'package:dio/dio.dart';
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
            return await ref.watch(userServiceProvider).presenceNormal(
                  key,
                  latitude,
                  longitude,
                  mock,
                  locationPresenceName,
                );
          } on DioException catch (e) {
            if (e.error is RestException) {
              final re = e.error as RestException;
              return Absent(errCode: re.errorCode, msg: re.message);
            }
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
    
    // Debug logging
    print('[ATTENDANCE DEBUG] Lat: $latitude, Long: $longitude, Mock: $mock');
    if (result.hasError) {
      print('[ATTENDANCE ERROR] ${result.error}');
      print('[ATTENDANCE ERROR STACK] ${result.stackTrace}');
    } else {
      final absent = result.valueOrNull;
      print('[ATTENDANCE RESPONSE] Status: ${absent?.status}');
      print('[ATTENDANCE RESPONSE] ErrCode: ${absent?.errCode ?? "MISSING"}');
      print('[ATTENDANCE RESPONSE] Msg: ${absent?.msg ?? "MISSING"}');
      print('[ATTENDANCE RESPONSE] Full Object: $absent');
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
