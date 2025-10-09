import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_time.freezed.dart';
part 'prayer_time.g.dart';

@freezed
class PrayerTime with _$PrayerTime {
  const factory PrayerTime({
    required String province,
    required String city,
    required String latitude,
    required String longitude,
    required double lat,
    required double lng,
    required List<Time> times,
  }) = _PrayerTime;

  factory PrayerTime.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimeFromJson(json);
}

@freezed
class Time with _$Time {
  const factory Time({
    required String imsak,
    required String fajr,
    required String sunset,
    required String dhuha,
    required String dhuhr,
    required String asr,
    required String maghrib,
    required String isha,
    required String gregorian,
    required String hijri,
    required int timestamp,
  }) = _Time;

  factory Time.fromJson(Map<String, dynamic> json) => _$TimeFromJson(json);
}
