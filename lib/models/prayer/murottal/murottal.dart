import 'package:freezed_annotation/freezed_annotation.dart';

part 'murottal.freezed.dart';
part 'murottal.g.dart';

@freezed
class Murottal with _$Murottal {
  const factory Murottal({
    @JsonKey(name: 'base_url') required String baseUrl,
    @Default(3) @JsonKey(name: 'padding_surah_number') int paddingSurahNumber,
    @JsonKey(name: 'padding_ayah_number') int? paddingAyahNumber,
    required String source,
    required String? separator,
    required String type,
    required String extension,
    required List<Reciter> reciters,
  }) = _Murottal;

  factory Murottal.fromJson(Map<String, dynamic> json) =>
      _$MurottalFromJson(json);
}

@freezed
class Reciter with _$Reciter {
  const factory Reciter({
    @JsonKey(name: 'reciter_name') required String reciterName,
    @JsonKey(name: 'end_point') required String endPoint,
    @JsonKey(name: 'photo_url') required String? photoUrl,
    required String? country,
    required String? biography,
  }) = _Reciter;

  factory Reciter.fromJson(Map<String, dynamic> json) =>
      _$ReciterFromJson(json);
}
