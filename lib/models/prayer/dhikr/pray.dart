import 'package:freezed_annotation/freezed_annotation.dart';

part 'pray.freezed.dart';
part 'pray.g.dart';

@freezed
class Pray with _$Pray {
  const factory Pray({
    required String arab,
    required String indo,
    required String judul,
    required String source,
  }) = _Pray;

  factory Pray.fromJson(Map<String, dynamic> json) => _$PrayFromJson(json);
}
