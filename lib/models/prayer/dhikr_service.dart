import 'package:flutter/services.dart' show rootBundle;
import 'package:syathiby/models/prayer/dhikr/pray_response.dart';
import 'package:dio/dio.dart';

class DhikrService {
  final Dio _dio;
  DhikrService(this._dio);

  Future<String> getMorningDhikr() async {
    return await rootBundle.loadString('assets/json/morning_dhikr.json');
  }

  Future<String> getEveningDhikr() async {
    return await rootBundle.loadString('assets/json/evening_dhikr.json');
  }

  Future<PrayResponse> getPrayList() async {
    final response = await _dio.get('https://api.dikiotang.com/doa');
    return PrayResponse.fromJson(response.data);
  }
}
