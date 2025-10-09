import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_raw_material.freezed.dart';
part 'request_raw_material.g.dart';

@freezed
class RequestRawMaterial with _$RequestRawMaterial {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory RequestRawMaterial({
    String? key,
    @JsonKey(name: 'payment_type') int? paymentType,
    @JsonKey(name: 'total_order') int? totalOrder,
    List<BarangRaw>? product,
  }) = _RequestRawMaterial;

  factory RequestRawMaterial.fromJson(Map<String, dynamic> json) =>
      _$RequestRawMaterialFromJson(json);
}

@freezed
class BarangRaw with _$BarangRaw {
  @JsonSerializable(includeIfNull: false, explicitToJson: true)
  const factory BarangRaw({
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'amount_product') double? amountProduct,
  }) = _BarangRaw;

  factory BarangRaw.fromJson(Map<String, dynamic> json) =>
      _$BarangRawFromJson(json);
}
