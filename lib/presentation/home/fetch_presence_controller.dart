import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/models/days/days.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:syathiby/models/store/store.dart';
import 'package:syathiby/models/user/request_logout.dart';
import 'package:syathiby/res/strings.dart';
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

/// Mengirim token FCM ke `profile/gettoken.php` supaya server bisa mengirim
/// notifikasi. Dipanggil setelah login, sekali per app start, dan saat token
/// diganti Firebase. Kegagalan hanya dicatat, tidak pernah memblokir UI.
@Riverpod(keepAlive: true)
class FcmTokenSync extends _$FcmTokenSync {
  StreamSubscription<String>? _refreshSub;
  Future<void>? _running;

  @override
  void build() {
    ref.onDispose(() => _refreshSub?.cancel());
  }

  /// [force] dipakai saat login: key sesi tidak berganti antar login, sedangkan
  /// server memindahkan token ke akun terakhir yang login di perangkat ini.
  Future<void> sync({String? key, bool force = false}) {
    return _running ??= _sync(key, force).whenComplete(() => _running = null);
  }

  Future<void> _sync(String? key, bool force) async {
    try {
      final sessionKey = key ?? ref.read(getCurrentUserProvider)?.key;
      if (sessionKey == null || sessionKey.isEmpty) return;
      if (kIsWeb) {
        // Token browser berasal dari project Firebase `al-ukhuwah`, sedangkan
        // token Android dari `syathiby-1345121`. Keduanya dikirimi server,
        // jadi token browser disimpan terpisah (`platform: web`).
        final tokenWeb = await _fetchWebToken();
        if (tokenWeb == null || tokenWeb.isEmpty) return;
        await _sendWeb(sessionKey, tokenWeb, force: force);
        return;
      }
      _listenTokenRefresh();
      final token = await _fetchToken();
      if (token == null || token.isEmpty) return;
      await _send(sessionKey, token, force: force);
    } catch (e) {
      debugPrint('Sinkronisasi token FCM gagal: $e');
    }
  }

  Future<String?> _fetchToken() {
    return ref
        .read(firebaseMessagingProvider)
        .getToken()
        .timeout(const Duration(seconds: 15));
  }

  /// Token untuk browser. Butuh izin notifikasi + kunci VAPID project web.
  Future<String?> _fetchWebToken() async {
    if (AppConstant.vapidKey.isEmpty) {
      debugPrint(
        'Push web dilewati: kunci VAPID belum diisi '
        '(--dart-define=FCM_VAPID_KEY=...)',
      );
      return null;
    }
    try {
      final messaging = ref.read(firebaseMessagingProvider);
      final izin = await messaging.requestPermission();
      if (izin.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Push web dilewati: izin notifikasi browser ditolak');
        return null;
      }
      return await messaging
          .getToken(vapidKey: AppConstant.vapidKey)
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint('Pengambilan token FCM web gagal: $e');
      return null;
    }
  }

  Future<void> _send(String key, String token, {bool force = false}) async {
    final pref = ref.read(sharedPreferencesHelperProvider);
    await pref.setString(AppConstant.keyDeviceToken, token);
    final syncedKey = '${AppConstant.keyFcmSyncedPrefix}$key';
    if (!force && pref.getString(syncedKey) == token) return;
    await ref
        .read(userServiceProvider)
        .getToken(RequestLogout(key: key, token: token));
    await pref.setString(syncedKey, token);
  }

  /// Kirim token browser ke server (disimpan di `users.token_web`).
  Future<void> _sendWeb(String key, String token, {bool force = false}) async {
    final pref = ref.read(sharedPreferencesHelperProvider);
    final syncedKey = '${AppConstant.keyFcmSyncedPrefix}web_$key';
    if (!force && pref.getString(syncedKey) == token) return;
    await ref
        .read(userServiceProvider)
        .getToken(RequestLogout(key: key, token: token, platform: 'web'));
    await pref.setString(syncedKey, token);
  }

  void _listenTokenRefresh() {
    _refreshSub ??= ref.read(firebaseMessagingProvider).onTokenRefresh.listen(
        (token) async {
      try {
        final key = ref.read(getCurrentUserProvider)?.key;
        if (key == null || key.isEmpty || token.isEmpty) return;
        await _send(key, token);
      } catch (e) {
        debugPrint('Sinkronisasi token FCM (refresh) gagal: $e');
      }
    }, onError: (Object e) => debugPrint('onTokenRefresh error: $e'));
  }
}
