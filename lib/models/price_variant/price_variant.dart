import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_variant.freezed.dart';
part 'price_variant.g.dart';

@freezed
abstract class PriceVariant with _$PriceVariant {
  const factory PriceVariant({
    @JsonKey(name: 'id_pricevariant') String? idPriceVariant,
    @JsonKey(name: 'id_product') String? idProduct,
    String? name,
    String? detail,
    String? minimal,
    String? price,
  }) = _PriceVariant;

  factory PriceVariant.fromJson(Map<String, dynamic> json) =>
      _$PriceVariantFromJson(json);
}
