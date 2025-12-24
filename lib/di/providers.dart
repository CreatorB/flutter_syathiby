import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:syathiby/models/user/login.dart';
import 'package:syathiby/res/env.dart';
import 'package:syathiby/res/strings.dart';
import 'package:syathiby/utils/configurable_log_interceptor.dart';
import 'package:syathiby/utils/response_interceptor.dart';
import 'package:syathiby/utils/shared_preferences_helper.dart';
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
  dio.options.baseUrl = Env.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 60);
  dio.options.receiveTimeout = const Duration(seconds: 60);

  return dio;
}

@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(FirebaseMessagingRef ref) {
  final fcm = FirebaseMessaging.instance;
  // Pindahkan permission request ke non-blocking untuk mencegah hang di splash
  Future.microtask(() async {
    try {
      await fcm.requestPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          debugPrint("FCM permission request timeout");
          return fcm.getNotificationSettings();
        },
      );
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
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Akses Lokasi GPS mati, Silahkan nyalakan GPS.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error(
          'Izin Akses Lokasi GPS ditolak, silahkan beri izin di pengaturan aplikasi');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
