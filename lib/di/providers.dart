import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:syathiby/models/user/login.dart';
import 'package:syathiby/res/environment_config.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/configurable_log_interceptor.dart';
import 'package:syathiby/utils/response_interceptor.dart';
import 'package:syathiby/utils/shared_preferences_helper.dart';
import 'package:syathiby/utils/web_location_stub.dart'
    if (dart.library.js_interop) 'package:syathiby/utils/web_location_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Logger logger(LoggerRef ref) {
  return Logger();
}

@Riverpod(keepAlive: true)
ConfigurableLogInterceptor loggingInterceptor(LoggingInterceptorRef ref) {
  return ConfigurableLogInterceptor();
}

@riverpod
Login? getCurrentUser(GetCurrentUserRef ref) {
  final json = ref
      .watch(sharedPreferencesHelperProvider)
      .getObject<Map<String, dynamic>>(AppConstant.keyLoginSession);
  if (json == null) return null;
  final currentUser = Login.fromJson(json);
  return currentUser;
}

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio();

  dio.interceptors.add(ResponseInterceptor());

  // Gunakan ConfigurableLogInterceptor yang bisa di-toggle
  // Setting ada di ApiLogConfig:
  //   - ApiLogConfig.enableGlobalLog = true/false (default: true di debug)
  //   - ApiLogConfig.addLogPath('/api/login') untuk log spesifik API
  dio.interceptors.add(ref.watch(loggingInterceptorProvider));

  dio.options.headers['content-Type'] = 'application/json';
  dio.options.baseUrl = EnvironmentConfig.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 60);
  dio.options.receiveTimeout = const Duration(seconds: 60);

  return dio;
}

@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(FirebaseMessagingRef ref) {
  final fcm = FirebaseMessaging.instance;
  // Non-blocking setup for notifications; avoid Android startup crashes on some devices.
  Future.microtask(() async {
    try {
      // On Android this request can fail early (activity/context not ready),
      // and Android < 13 does not require runtime notification permission.
      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
        await fcm.requestPermission().timeout(
          const Duration(seconds: 5),
          onTimeout: () async {
            debugPrint("FCM permission request timeout");
            return fcm.getNotificationSettings();
          },
        );
      }

      await fcm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint("FCM permission request error: $e");
    }
  });
  return fcm;
}

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  // throw UnimplementedError();
  throw UnsupportedError('sharedPreferencesProvider must be overridden');
}

@Riverpod(keepAlive: true)
SharedPreferencesHelper sharedPreferencesHelper(
  SharedPreferencesHelperRef ref,
) {
  return SharedPreferencesHelper(ref.watch(sharedPreferencesProvider));
}

@Riverpod(keepAlive: true)
AudioPlayer audioPlayer(AudioPlayerRef ref) {
  return AudioPlayer();
}

@riverpod
DateTime? parseDateTime(ParseDateTimeRef ref, String dateString) {
  return DateFormat('yyyy-MM-dd').tryParse(dateString);
}

@riverpod
String? formatTime(FormatTimeRef ref, String? timeString, {String? format}) {
  if (timeString == null) {
    return null;
  }
  try {
    final dateTime = DateFormat('HH:mm:ss').parse(timeString).toLocal();
    return DateFormat(format ?? 'HH:mm').format(dateTime);
  } catch (e) {
    return null;
  }
}

@riverpod
String formatCurrency(FormatCurrencyRef ref, dynamic number) {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  final parseNominal = double.tryParse('$number') ?? 0;
  final nominal = currencyFormat.format(parseNominal);
  return nominal;
}

@riverpod
String? formatDate(FormatDateRef ref, String dateString, {String? format}) {
  final date = ref.watch(parseDateTimeProvider(dateString));
  if (date == null) return null;
  return DateFormat(format ?? 'dd MMM yyyy').format(date);
}

@riverpod
String? formatTimeFromDate(FormatTimeFromDateRef ref, String? dateString) {
  if (dateString == null) {
    return null;
  }
  final dateTime = DateTime.tryParse(dateString)?.toLocal();
  if (dateTime == null) {
    return null;
  }
  return DateFormat('HH:mm').format(dateTime);
}

@riverpod
Future<Position> getCurrentLocation(GetCurrentLocationRef ref) async {
  // Di web (terutama Safari iOS), skip permission check karena bisa menyebabkan error.
  // Langsung panggil getCurrentPosition agar browser menampilkan popup permission.
  if (kIsWeb) {
    return _getPositionForWeb();
  }

  // Untuk native app (Android/iOS), gunakan flow normal
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Akses Lokasi GPS mati, Silahkan nyalakan GPS.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error(
          'Izin Akses Lokasi GPS ditolak, silahkan beri izin di pengaturan aplikasi');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Izin lokasi ditolak secara permanen. Mohon buka pengaturan untuk mengaktifkan izin lokasi.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 30),
      ),
    );
  } catch (e) {
    final errorMsg = e.toString().toLowerCase();

    // Deteksi berbagai jenis error permission dari Safari iOS dan browser lain
    final isPermissionDenied = errorMsg.contains('denied') ||
        errorMsg.contains('permission') ||
        errorMsg.contains('not allowed') ||
        errorMsg.contains('notallowederror') ||
        errorMsg.contains('user denied') ||
        errorMsg.contains('geolocation');

    // Deteksi error "origin doesn't have permission" - ini berarti akses via HTTP
    final isOriginError = errorMsg.contains('origin') &&
        (errorMsg.contains('permission') || errorMsg.contains('geolocation'));

    final isSecureContextError = errorMsg.contains('secure') ||
        errorMsg.contains('https') ||
        isOriginError;

    final isTimeoutError = errorMsg.contains('timeout') ||
        errorMsg.contains('timed out');

    final isUnavailableError = errorMsg.contains('unavailable') ||
        errorMsg.contains('position unavailable');

    if (isSecureContextError) {
      return Future.error(
        'Akses lokasi ditolak oleh browser.\n\n'
        'PENYEBAB UTAMA:\n'
        'Website harus diakses via HTTPS (bukan HTTP).\n'
        'Safari/Chrome menolak akses lokasi di website HTTP.\n\n'
        'SOLUSI:\n'
        '• Pastikan URL dimulai dengan https:// (bukan http://)\n'
        '• Hubungi admin jika website belum HTTPS\n\n'
        'Jika sudah HTTPS tapi masih error:\n'
        '1. Buka Pengaturan iPhone > Privasi & Keamanan > Layanan Lokasi\n'
        '2. Pastikan Layanan Lokasi: AKTIF\n'
        '3. Scroll ke Safari > Pilih "Saat Menggunakan Aplikasi"\n'
        '4. Kembali ke Safari, muat ulang halaman',
      );
    }

    if (isPermissionDenied) {
      return Future.error(
        'Izin lokasi ditolak oleh browser.\n\n'
        'Untuk iPhone/Safari:\n'
        '1. Buka Pengaturan iPhone > Privasi & Keamanan > Layanan Lokasi\n'
        '2. Pastikan "Layanan Lokasi" dalam keadaan AKTIF (hijau)\n'
        '3. Scroll ke bawah, cari dan tap "Safari"\n'
        '4. Pilih "Saat Menggunakan Aplikasi"\n'
        '5. Kembali ke Safari, muat ulang halaman, dan izinkan akses lokasi\n\n'
        'Untuk Chrome/Browser lain:\n'
        '- Tap ikon gembok/info di address bar\n'
        '- Pilih "Izin Situs" > Lokasi > Izinkan\n'
        '\nError: $e',
      );
    }

    if (isTimeoutError) {
      return Future.error(
        'Gagal mendapatkan lokasi (Timeout).\n\n'
        'Kemungkinan penyebab:\n'
        '1. Sinyal GPS lemah - coba pindah ke area terbuka\n'
        '2. Koneksi internet lambat\n'
        '3. Layanan lokasi sedang sibuk\n\n'
        'Solusi: Muat ulang halaman dan coba lagi.',
      );
    }

    if (isUnavailableError) {
      return Future.error(
        'Lokasi tidak tersedia.\n\n'
        'Kemungkinan penyebab:\n'
        '1. GPS tidak mendapat sinyal\n'
        '2. Perangkat dalam mode pesawat\n'
        '3. Layanan lokasi dinonaktifkan\n\n'
        'Solusi:\n'
        '- Pastikan GPS/Layanan Lokasi aktif\n'
        '- Pindah ke area dengan sinyal lebih baik\n'
        '- Coba muat ulang halaman',
      );
    }

    return Future.error(
      'Gagal mendapatkan lokasi.\n\n'
      'Jika masalah berlanjut, coba:\n'
      '1. Muat ulang halaman\n'
      '2. Periksa pengaturan lokasi di browser/perangkat\n'
      '3. Pastikan mengakses via HTTPS\n'
      '\nError: $e',
    );
  }
}

/// Fungsi khusus untuk mendapatkan lokasi di Web.
/// Menggunakan JavaScript Geolocation API langsung untuk bypass masalah
/// Geolocator plugin di Safari iOS.
Future<Position> _getPositionForWeb() async {
  try {
    // Gunakan WebLocationHelper yang memanggil JavaScript API langsung.
    // Ini bypass Geolocator plugin yang bermasalah di Safari iOS.
    return await WebLocationHelper.getCurrentPosition(
      timeout: const Duration(seconds: 30),
    );
  } catch (e) {
    // Error sudah di-handle di WebLocationHelper dengan pesan yang jelas.
    // Re-throw langsung.
    return Future.error(e.toString());
  }
}
