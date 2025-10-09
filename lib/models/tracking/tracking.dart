import 'package:freezed_annotation/freezed_annotation.dart';

part 'tracking.freezed.dart';
part 'tracking.g.dart';

@freezed
class Tracking with _$Tracking {
  const factory Tracking({
    String? full_name,
    String? phone_number,
    String? img,
    String? date_update,
    String? latlong,
    String? latitude,
    String? longitude,
  }) = _Tracking;

  factory Tracking.fromJson(Map<String, dynamic> json) =>
      _$TrackingFromJson(json);
}
