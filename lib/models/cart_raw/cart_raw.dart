import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';

part 'cart_raw.freezed.dart';
part 'cart_raw.g.dart';

@freezed
class CartRaw with _$CartRaw {
  const factory CartRaw({
    @JsonKey(name: 'position') int? position,
    @JsonKey(name: 'count') double? count,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'new_price', defaultValue: '0') String? newPrice,
    @JsonKey(name: 'product') RawMaterial? product,
  }) = _CartRaw;

  factory CartRaw.fromJson(Map<String, dynamic> json) =>
      _$CartRawFromJson(json);
}
