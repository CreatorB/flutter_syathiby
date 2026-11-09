import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/firebase_options.dart';
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
        // Token browser berasal dari Web App project Firebase
        // `syathiby-1345121` (10 Nov 2026), sama seperti token Android.
        // Keduanya dikirimi server, jadi token browser disimpan terpisah
        // (`platform: web`) supaya tidak saling menimpa.
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
      // Di web, Firebase TIDAK di-init di `main()` (dilewati demi kompatibilitas
      // Safari). Tanpa init, `firebase_options.dart` ter-tree-shake dan browser
      // memakai service worker project yang salah/expired. Jadi init sekarang
      // secara lazy: hanya saat pengguna benar-benar minta izin notifikasi.
      await _ensureFirebaseWeb();
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

  /// Inisialisasi Firebase khusus web (idempotent, aman dipanggil berulang).
  ///
  /// CATATAN penting (akar masalah push web):
  /// - Di `main()`, `await _initFirebase()` hanya dipanggil bila `!kIsWeb`.
  ///   Saat build web, `kIsWeb` = true, sehingga cabang itu dibuang dan
  ///   `DefaultFirebaseOptions` ikut ter-*tree-shake*: `main.dart.js` jadi
  ///   0 string `AIza`/`syathiby-1345121`, dan browser memakai project yang
  ///   salah (dulu `al-ukhuwah`, token-nya ditolak server).
  /// - Solusinya: inisialisasi Firebase dilakukan LAZY di jalur ini, hanya
  ///   saat pengguna benar-benar meminta izin notifikasi browser.
  /// - Guard `if (!kIsWeb) return;` sengaja DIJAGA: saat build web
  ///   `kIsWeb` = true sehingga guard tidak aktif dan seluruh isi fungsi tetap
  ///   hidup (config ikut ke bundle). Saat build Android, guard memangkas
  ///   cabang web agar bundle mobile tidakbringing konfigurasi web.
  Future<void> _ensureFirebaseWeb() async {
    if (!kIsWeb) return;
    if (Firebase.apps.isNotEmpty) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 15));
      debugPrint('Firebase web diinisialisasi (project syathiby-1345121)');
    } catch (e) {
      debugPrint('Inisialisasi Firebase web gagal: $e');
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
