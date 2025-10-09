import 'package:dio/dio.dart';
import 'package:syathiby/models/prayer/time/prayer_time.dart';
import 'package:retrofit/retrofit.dart';

part 'prayer_time_service.g.dart';

@RestApi(baseUrl: 'https://prayer-times-xi.vercel.app/api/prayer/')
abstract class PrayerTimeService {
  factory PrayerTimeService(Dio dio, {String baseUrl}) = _PrayerTimeService;

  @GET('day')
  Future<PrayerTime> getPrayerTime(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );

  @GET('week')
  Future<PrayerTime> getPrayerTimeWeek(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );

  @GET('month')
  Future<PrayerTime> getPrayerTimeMonth(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );

  @GET('year')
  Future<PrayerTime> getPrayerTimeYear(
    @Query('latitude') double latitude,
    @Query('longitude') double longitude,
  );
}
