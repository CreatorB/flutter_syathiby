import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

/// Memasang identitas perangkat sebagai HTTP header pada SETIAP request.
///
/// === KENAPA HEADER, BUKAN PARAMETER ===
///
/// Backend butuh tahu perangkat apa yang dipakai saat absen (lihat
/// `apps/aplikasi/geten/fungsi_log_aktivitas.php`). Alternatifnya menambah
/// `@Part` di tiap endpoint, tapi itu berarti:
///   - menyentuh belasan definisi service dan setiap tempat pemanggilnya,
///   - endpoint baru gampang terlupa, dan
///   - `profile/logout.php` yang memakai body JSON tidak bisa dilayani sama
///     sekali karena di sana tidak ada mekanisme multipart.
///
/// Satu interceptor menyelesaikan ketiganya sekaligus, dan endpoint yang
/// ditambahkan nanti otomatis ikut terekam tanpa perubahan apa pun.
///
/// === KENAPA DI-CACHE ===
///
/// `DeviceInfoPlugin` dan `PackageInfo` memanggil platform channel — mahal
/// kalau dilakukan tiap request. Nilainya tidak berubah selama aplikasi hidup,
/// jadi dikumpulkan sekali lalu dipakai ulang.
///
/// === KENAPA TIDAK MEMBLOKIR ===
///
/// Kalau pengumpulan info perangkat gagal atau belum selesai, request TETAP
/// diteruskan tanpa header. Absensi staff jauh lebih penting daripada
/// kelengkapan lognya — prinsip yang sama dipegang di sisi server.
class DeviceInfoInterceptor extends Interceptor {
  DeviceInfoInterceptor();

  static Map<String, String>? _cache;
  static bool _sedangKumpul = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final data = _cache;
    if (data != null) {
      options.headers.addAll(data);
    } else if (!_sedangKumpul) {
      // Kumpulkan di latar belakang untuk request BERIKUTNYA. Sengaja tidak
      // di-await: menahan request pertama demi header log adalah pertukaran
      // yang salah — request pertama biasanya justru login.
      _sedangKumpul = true;
      _kumpulkan().then((hasil) {
        _cache = hasil;
        _sedangKumpul = false;
      }).catchError((_) {
        _sedangKumpul = false;
      });
    }
    handler.next(options);
  }

  /// Kumpulkan sekali, simpan sebagai header siap pakai.
  ///
  /// Nama header mengikuti pola `X-<nama-kolom>` supaya sisi PHP bisa
  /// memetakannya langsung tanpa daftar terjemahan
  /// (`X-DEVICE-MODEL` -> `$_SERVER['HTTP_X_DEVICE_MODEL']` -> kolom
  /// `device_model`).
  static Future<Map<String, String>> _kumpulkan() async {
    final h = <String, String>{};

    try {
      final paket = await PackageInfo.fromPlatform();
      h['X-App-Version'] = paket.version;
      h['X-App-Build'] = paket.buildNumber;
    } catch (_) {
      // biarkan kosong
    }

    try {
      final info = DeviceInfoPlugin();

      if (kIsWeb) {
        final w = await info.webBrowserInfo;
        h['X-Platform'] = 'web';
        h['X-Device-Model'] = _bersih(w.browserName.name);
        h['X-Device-Brand'] = _bersih(w.vendor ?? '');
        h['X-OS-Version'] = _bersih(w.platform ?? '');
      } else if (Platform.isAndroid) {
        final a = await info.androidInfo;
        h['X-Platform'] = 'android';
        h['X-Device-Model'] = _bersih(a.model);
        h['X-Device-Brand'] = _bersih(a.manufacturer);
        // Sertakan SDK level: "13 (SDK 33)" jauh lebih berguna saat men-debug
        // masalah yang khas versi Android tertentu.
        h['X-OS-Version'] = _bersih('Android ${a.version.release} (SDK ${a.version.sdkInt})');
        h['X-Device-Id'] = _bersih(a.id);
        // isPhysicalDevice=false berarti emulator. Ini yang membuat absen dari
        // emulator bisa dikenali di dashboard.
        h['X-Is-Physical'] = a.isPhysicalDevice ? 'true' : 'false';
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        h['X-Platform'] = 'ios';
        h['X-Device-Model'] = _bersih(i.utsname.machine);
        h['X-Device-Brand'] = 'Apple';
        h['X-OS-Version'] = _bersih('${i.systemName} ${i.systemVersion}');
        h['X-Device-Id'] = _bersih(i.identifierForVendor ?? '');
        h['X-Is-Physical'] = i.isPhysicalDevice ? 'true' : 'false';
      }
    } catch (_) {
      // biarkan apa adanya
    }

    return h;
  }

  /// Header HTTP hanya boleh ASCII dan tanpa baris baru.
  ///
  /// Nama perangkat Android bisa memuat karakter non-ASCII (mis. merek Tiongkok
  /// atau HP yang namanya diubah pemiliknya). Dio akan melempar error kalau
  /// nilai header mengandung karakter di luar Latin-1, dan itu berarti SELURUH
  /// request gagal — absensinya ikut gagal hanya gara-gara nama HP.
  static String _bersih(String v) {
    final hasil = v
        .replaceAll(RegExp(r'[\r\n]'), ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        .trim();
    return hasil.length > 80 ? hasil.substring(0, 80) : hasil;
  }
}
