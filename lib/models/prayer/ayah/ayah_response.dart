import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah_response.freezed.dart';
part 'ayah_response.g.dart';

@freezed
class AyahResponse with _$AyahResponse {
  const factory AyahResponse({
    required List<Ayah> result,
  }) = _AyahResponse;

  factory AyahResponse.fromJson(Map<String, dynamic> json) =>
      _$AyahResponseFromJson(json);
}

@freezed
class Ayah with _$Ayah {
  const factory Ayah({
    required String id,
    required String sura,
    required String aya,
    @JsonKey(name: 'arabic_text') required String arabicText,
    required String translation,
    required String footnotes,
  }) = _Ayah;

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
}
