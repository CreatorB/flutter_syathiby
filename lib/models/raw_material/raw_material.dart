import 'package:freezed_annotation/freezed_annotation.dart';

part 'raw_material.freezed.dart';
part 'raw_material.g.dart';

@freezed
class RawMaterial with _$RawMaterial {
  factory RawMaterial({
    @JsonKey(name: 'id_raw_material') String? idRawMaterial,
    String? name,
    String? unit,
    String? img,
    bool? active,
    dynamic price,
    String? stock,
    double? amount,
    String? description,
    bool? posisi,
  }) = _RawMaterial;

  factory RawMaterial.fromJson(Map<String, dynamic> json) =>
      _$RawMaterialFromJson(json);
}
