import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/prayer/ayah/ayah_response.dart';
import 'package:syathiby/models/prayer/surah/surah.dart';

part 'quran.freezed.dart';
part 'quran.g.dart';

@freezed
class Quran with _$Quran {
  const factory Quran({
    required Surah surah,
    required Ayah ayah,
  }) = _Quran;

  factory Quran.fromJson(Map<String, dynamic> json) => _$QuranFromJson(json);
}
