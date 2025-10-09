import 'package:freezed_annotation/freezed_annotation.dart';

part 'surah.freezed.dart';
part 'surah.g.dart';

@freezed
class Surah with _$Surah {
  factory Surah({
    @JsonKey(name: 'id_surah') int? idSurah,
    @JsonKey(name: 'id_ayah') int? idAyah,
    @JsonKey(name: 'arabic') String? arabic,
    @JsonKey(name: 'textarab') String? textArab,
    @JsonKey(name: 'indonesia') String? indonesia,
    @JsonKey(name: 'ayah') String? ayah,
    @JsonKey(name: 'bismillah') String? bismillah,
    @JsonKey(name: 'desc') String? desc,
    @JsonKey(name: 'sound') String? sound,
  }) = _Surah;

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
}
