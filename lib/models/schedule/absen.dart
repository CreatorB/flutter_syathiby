import 'package:freezed_annotation/freezed_annotation.dart';

part 'absen.freezed.dart';
part 'absen.g.dart';

@freezed
class Absen with _$Absen {
  const factory Absen({
    String? status,
  }) = _Absen;

  factory Absen.fromJson(Map<String, dynamic> json) => _$AbsenFromJson(json);
}
