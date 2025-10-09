import 'package:freezed_annotation/freezed_annotation.dart';

import 'hadith_response.dart';

part 'hadith_detail_response.freezed.dart';
part 'hadith_detail_response.g.dart';

@freezed
class HadithDetailResponse with _$HadithDetailResponse {
  const factory HadithDetailResponse({
    required int code,
    required String message,
    required HadithDetailResponseData data,
    required bool error,
  }) = _HadithDetailResponse;

  factory HadithDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$HadithDetailResponseFromJson(json);
}

@freezed
class HadithDetailResponseData with _$HadithDetailResponseData {
  const factory HadithDetailResponseData({
    required String name,
    required String id,
    required int available,
    required Hadith contents,
  }) = _HadithDetailResponseData;

  factory HadithDetailResponseData.fromJson(Map<String, dynamic> json) =>
      _$HadithDetailResponseDataFromJson(json);
}
