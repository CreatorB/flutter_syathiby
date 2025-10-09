import 'package:dio/dio.dart';
import 'package:syathiby/models/prayer/dhikr/pray_response.dart';
import 'package:retrofit/retrofit.dart';

part 'dhikr_service.g.dart';

@RestApi()
abstract class DhikrService {
  factory DhikrService(Dio dio, {String baseUrl}) = _DhikrService;

  @GET(
    'https://github.com/rabbaaniiislamicschool/public-api/raw/main/morning_dhikr.json',
  )
  Future<String> getMorningDhikr();

  @GET(
    'https://github.com/rabbaaniiislamicschool/public-api/raw/main/evening_dhikr.json',
  )
  Future<String> getEveningDhikr();

  @GET('https://api.dikiotang.com/doa')
  Future<PrayResponse> getPrayList();
}
