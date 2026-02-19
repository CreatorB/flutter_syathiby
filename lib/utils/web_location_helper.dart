// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web/web.dart' as web;

/// Helper untuk mendapatkan lokasi di web menggunakan JavaScript API langsung.
/// Ini bypass Geolocator plugin yang bermasalah di beberapa versi Safari iOS.
class WebLocationHelper {
  /// Mendapatkan posisi menggunakan JavaScript Geolocation API langsung.
  static Future<Position> getCurrentPosition({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!kIsWeb) {
      // Fallback ke Geolocator untuk non-web
      return Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: timeout,
        ),
      );
    }

    final completer = Completer<Position>();

    // Buat options untuk geolocation
    final options = web.PositionOptions(
      enableHighAccuracy: true,
      timeout: timeout.inMilliseconds,
      maximumAge: 0,
    );

    // Success callback
    void onSuccess(web.GeolocationPosition pos) {
      if (completer.isCompleted) return;

      final coords = pos.coords;
      final position = Position(
        latitude: coords.latitude.toDouble(),
        longitude: coords.longitude.toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(pos.timestamp.toInt()),
        accuracy: coords.accuracy.toDouble(),
        altitude: coords.altitude?.toDouble() ?? 0.0,
        altitudeAccuracy: coords.altitudeAccuracy?.toDouble() ?? 0.0,
        heading: coords.heading?.toDouble() ?? 0.0,
        headingAccuracy: 0.0,
        speed: coords.speed?.toDouble() ?? 0.0,
        speedAccuracy: 0.0,
      );
      completer.complete(position);
    }

    // Error callback
    void onError(web.GeolocationPositionError error) {
      if (completer.isCompleted) return;

      String message;
      switch (error.code) {
        case 1: // PERMISSION_DENIED
          message = 'Izin lokasi ditolak.\n\n'
              'Untuk iPhone/Safari:\n'
              '1. Pengaturan > Privasi & Keamanan > Layanan Lokasi\n'
              '2. Pastikan Layanan Lokasi: AKTIF\n'
              '3. Safari Websites > "Saat Menggunakan"\n'
              '4. Muat ulang halaman, pilih "Izinkan"';
          break;
        case 2: // POSITION_UNAVAILABLE
          message = 'Lokasi tidak tersedia. Pastikan GPS aktif.';
          break;
        case 3: // TIMEOUT
          message = 'Timeout mendapatkan lokasi. Coba di area terbuka.';
          break;
        default:
          message = 'Gagal mendapatkan lokasi: ${error.message}';
      }
      completer.completeError(message);
    }

    try {
      web.window.navigator.geolocation.getCurrentPosition(
        onSuccess.toJS,
        onError.toJS,
        options,
      );
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError('Geolocation error: $e');
      }
    }

    return completer.future;
  }
}
