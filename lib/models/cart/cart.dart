import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/addon/add_on.dart';
import 'package:syathiby/models/product/product.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

@freezed
class Cart with _$Cart {
  const factory Cart({
    @JsonKey(name: 'position') int? position,
    @JsonKey(name: 'count') double? count,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'new_price', defaultValue: '0') String? newPrice,
    @JsonKey(name: 'nominal_addon', defaultValue: '0') String? nominalAddon,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'product') Product? product,
    @JsonKey(name: 'addon') AddOn? addon,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);
}
