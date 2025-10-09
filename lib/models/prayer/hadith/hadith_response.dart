import 'package:freezed_annotation/freezed_annotation.dart';

part 'hadith_response.freezed.dart';
part 'hadith_response.g.dart';

@freezed
class HadithResponse with _$HadithResponse {
  const factory HadithResponse({
    required int code,
    required String message,
    required HadithData data,
    required bool error,
  }) = _HadithResponse;

  factory HadithResponse.fromJson(Map<String, dynamic> json) =>
      _$HadithResponseFromJson(json);
}

@freezed
class HadithData with _$HadithData {
  const factory HadithData({
    required String name,
    required String id,
    required int available,
    required int requested,
    required List<Hadith> hadiths,
  }) = _HadithData;

  factory HadithData.fromJson(Map<String, dynamic> json) =>
      _$HadithDataFromJson(json);
}

@freezed
class Hadith with _$Hadith {
  const factory Hadith({
    required int number,
    required String arab,
    required String id,
  }) = _Hadith;

  factory Hadith.fromJson(Map<String, dynamic> json) => _$HadithFromJson(json);
}
