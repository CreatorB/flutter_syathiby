import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/prayer/dhikr/pray.dart';

part 'pray_response.freezed.dart';
part 'pray_response.g.dart';

@freezed
class PrayResponse with _$PrayResponse {
  const factory PrayResponse({
    required List<Pray> data,
  }) = _PrayResponse;

  factory PrayResponse.fromJson(Map<String, dynamic> json) =>
      _$PrayResponseFromJson(json);
}
