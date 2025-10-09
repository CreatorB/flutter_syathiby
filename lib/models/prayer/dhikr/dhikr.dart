import 'package:freezed_annotation/freezed_annotation.dart';

part 'dhikr.freezed.dart';
part 'dhikr.g.dart';

@freezed
class Dhikr with _$Dhikr {
  const factory Dhikr({
    String? title,
    required String arabic,
    String? transliteration,
    required String translation,
    required String count,
    String? faedah,
    String? reference,
  }) = _Dhikr;

  factory Dhikr.fromJson(Map<String, dynamic> json) => _$DhikrFromJson(json);
}
