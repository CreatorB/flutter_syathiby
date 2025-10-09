import 'package:freezed_annotation/freezed_annotation.dart';

part 'diagnose.freezed.dart';
part 'diagnose.g.dart';

@freezed
class Diagnosa with _$Diagnosa {
  const factory Diagnosa({
    @JsonKey(name: 'id_diagnosa') String? id_diagnosa,
    @JsonKey(name: 'name_diagnosa') String? name_diagnosa,
  }) = _Diagnosa;

  factory Diagnosa.fromJson(Map<String, dynamic> json) =>
      _$DiagnosaFromJson(json);
}
