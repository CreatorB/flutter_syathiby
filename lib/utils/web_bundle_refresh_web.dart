import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;

/// Self-heal bundle web: kalau server sudah punya build lebih baru, browser
/// otomatis mengambilnya.
///
/// Kenapa perlu: Flutter web mendaftarkan **service worker** yang menyimpan
/// `main.dart.js` di Cache Storage. Setelah deploy, browser yang pernah
/// membuka aplikasi masih menjalankan bundle LAMA -- tampilan lama tetap
/// terlihat (mis. kartu penjelasan alur yang sudah dihapus), walaupun file
/// di server sudah diperbarui. Reload biasa belum tentu cukup karena service
/// worker masih melayani file lama dari cache.
///
/// Cara kerja:
/// 1. `assets/version.json` berisi salinan `web/version.json` saat build --
///    jadi ia merepresentasikan bundle yang SEDANG BERJALAN.
/// 2. `version.json` di server berisi build terbaru (dibaca tanpa cache).
/// 3. Kalau `buildStamp`-nya beda, cache service worker dibersihkan, service
///    worker di-unregister, entri cache HTTP berkas entry point ditulis ulang
///    dari jaringan, lalu halaman di-reload satu kali. Setelah reload,
///    bundle baru yang jalan dan stamp-nya sudah sama, jadi tidak ada reload
///    beruntun.
///
/// Catatan: file `assets/version.json` dibuat otomatis saat build (salinan
/// dari `web/version.json`), jadi tidak boleh diedit manual.
class WebBundleRefresh {
  static const _stampKey = 'web_bundle_running_stamp';

  /// Path aset berisi versi bundle yang sedang berjalan.
  static const _bundledVersionPath = 'assets/version.json';

  /// Path file versi yang dilayani server.
  static const _servedVersionPath = 'version.json';

  /// Aman dipanggil berkali-kali; hanya reload bila memang versinya beda.
  static Future<void> ensureFreshBundle() async {
    if (!kIsWeb) return;
    try {
      final running = await _runningStamp();
      if (running.isEmpty) return;

      final served = await _servedStamp();
      if (served.isEmpty || served == running) return;

      final prefs = await SharedPreferences.getInstance();
      // Jangan reload berulang untuk stamp yang sama (mis. aset versi tidak
      // ikut ter-deploy) -> satu kali saja.
      if (prefs.getString(_stampKey) == served) {
        debugPrint(
          '[WebBundleRefresh] bundle di server ($served) beda, tapi sudah '
          'percobaan reload untuk versi itu -- lewati.',
        );
        return;
      }
      await prefs.setString(_stampKey, served);

      debugPrint(
        '[WebBundleRefresh] bundle di server ($served) beda dari yang jalan '
        '($running) -> bersihkan cache lalu reload.',
      );
      await _clearServiceWorker();
      await _refreshBundleFiles();
      web.window.location.reload();
    } catch (e) {
      debugPrint('[WebBundleRefresh] gagal: $e');
    }
  }

  /// Stamp bundle yang sedang berjalan (dari aset yang di-build).
  static Future<String> _runningStamp() async {
    try {
      final raw = await rootBundle.loadString(_bundledVersionPath);
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) {
        return (data['buildStamp'] ?? '').toString();
      }
    } catch (_) {
      // Aset versi tidak ada (build lama) -> deteksi tidak mungkin.
    }
    return '';
  }

  /// Stamp bundle yang dilayani server (selalu tanpa cache).
  static Future<String> _servedStamp() async {
    try {
      final url =
          '$_servedVersionPath?cb=${DateTime.now().millisecondsSinceEpoch}';
      final response = await web.window.fetch(url.toJS).toDart;
      if (response.status != 200) return '';
      final data = await response.json().toDart;
      if (data is! JSObject) return '';
      final raw = data.getProperty<JSAny?>('buildStamp'.toJS);
      return raw is JSString ? raw.toDart : '';
    } catch (_) {
      return '';
    }
  }

  /// Paksa browser mengambil ulang berkas entry point dari jaringan dan
  /// memperbarui entri cache HTTP-nya.
  ///
  /// Tanpa langkah ini, browser yang sudah menyimpan `main.dart.js` dengan
  /// `max-age` panjang (dulu 10 tahun dari `expires max` nginx) tetap memakai
  /// berkas lama walaupun Cache Storage sudah dibersihkan -- browser tidak
  /// pernah menanyakan ke server. Mode cache `reload` memaksa permintaan ke
  /// jaringan dan mengganti entri cache lama dengan berkas terbaru.
  static Future<void> _refreshBundleFiles() async {
    for (final path in const [
      'main.dart.js',
      'flutter_bootstrap.js',
      'flutter_service_worker.js',
    ]) {
      try {
        await web.window
            .fetch(path.toJS, web.RequestInit(cache: 'reload'))
            .toDart;
      } catch (_) {}
    }
  }

  /// Hapus Cache Storage + unregister service worker supaya aset diambil dari
  /// jaringan, bukan dari cache lama.
  static Future<void> _clearServiceWorker() async {    try {
      final keys = (await web.window.caches.keys().toDart).toDart;
      for (final key in keys) {
        await web.window.caches.delete(key.toDart).toDart;
      }
    } catch (_) {}
    try {
      final regs = (await web.window.navigator
              .serviceWorker
              .getRegistrations()
              .toDart)
          .toDart;
      for (final reg in regs) {
        await reg.unregister().toDart;
      }
    } catch (_) {}
  }
}
