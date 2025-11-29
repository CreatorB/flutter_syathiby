import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/user/login.dart';
import 'package:syathiby/res/strings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:syathiby/utils/rest_exception.dart';

part 'login_controller.g.dart';

@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() async {}

  Future<void> login({
    required String phoneNumber,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final loginResult =
          await ref.read(userServiceProvider).login(phoneNumber, password);

      final loginData = loginResult.firstOrNull;
      if (loginData != null) {
        await _saveSession(loginData);

        state = const AsyncData(null);

        ref.invalidate(goRouterProvider);
      } else {
        throw Exception('Data pengguna tidak ditemukan setelah login.');
      }
    } catch (e, st) {
      if (e is RestException) {
        print("========================================");
        print("🔴 LOGIC ERROR DARI SERVER:");
        print(
            "MSG: ${e.message}"); // atau ${e.message} tergantung isi class RestException
        print("CODE: ${e.errorCode}");
        print("========================================");
      }
      // 2. Cek apakah error dari Jaringan (Dio)
      else if (e is DioException) {
        print("🔴 DIO ERROR: ${e.message}");
        if (e.error is RestException) {
          final restErr = e.error as RestException;
          print("🔴 ISI REST EXCEPTION: ${restErr.message}");
        }
      }
      state = AsyncError(e, st);
    }
  }

  Future<void> _saveSession(Login login) async {
    final pref = ref.read(sharedPreferencesHelperProvider);
    await pref.setObject(AppConstant.keyLoginSession, login.toJson());
    try {
      final token = await ref.read(firebaseMessagingProvider).getToken();
      await pref.setString(AppConstant.keyDeviceToken, token ?? '');
    } catch (e) {
      debugPrint('Gagal mendapatkan Firebase token: $e');
    }
  }
}
