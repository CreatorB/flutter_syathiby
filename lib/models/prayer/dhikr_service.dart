import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:syathiby/models/prayer/dhikr/pray_response.dart';
import 'package:dio/dio.dart';

const _dzikirBaseUrl = 'https://aplikasi.syathiby.id/dzikir';

class DhikrService {
  final Dio _dio;
  DhikrService(this._dio);

  Future<String> _muat(String nama) async {
    try {
      final r = await _dio.get<String>(
        '$_dzikirBaseUrl/${nama == 'morning_dhikr.json' ? 'pagi.php' : 'petang.php'}',
        options: Options(
          responseType: ResponseType.plain,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      final data = r.data;
      if (data != null && (jsonDecode(data) as List).isNotEmpty) return data;
    } catch (_) {}
    return rootBundle.loadString('assets/json/$nama');
  }

  Future<String> getMorningDhikr() => _muat('morning_dhikr.json');

  Future<String> getEveningDhikr() => _muat('evening_dhikr.json');

  Future<PrayResponse> getPrayList() async {
    final response = await _dio.get('https://api.dikiotang.com/doa');
    return PrayResponse.fromJson(response.data);
  }
}
