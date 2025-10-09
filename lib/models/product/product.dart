import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:syathiby/models/addon/add_on.dart';
import 'package:syathiby/models/price_variant/price_variant.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'name_product') String? nameProduct,
    String? unit,
    String? img,
    @JsonKey(name: 'codeproduct') String? codeProduct,
    @JsonKey(name: 'id_category') String? idCategory,
    @JsonKey(name: 'name_category') String? nameCategory,
    bool? active,
    @JsonKey(name: 'selling_price') dynamic sellingPrice,
    @JsonKey(name: 'purchase_price') dynamic purchasePrice,
    int? stock,
    double? amount,
    @JsonKey(name: 'minimalstock') String? minimalStock,
    String? description,
    String? discount,
    bool? posisi,
    String? online,
    @JsonKey(name: 'have_stock') dynamic haveStock,
    @JsonKey(name: 'wholesale_price') dynamic wholesalePrice,
    String? tax,
    String? inc,
    @JsonKey(name: 'id_master') String? idMaster,
    @JsonKey(name: 'alertstock') String? alertStock,
    String? packages,
    String? item,
    @JsonKey(name: 'pricevariant') List<PriceVariant>? priceVariant,
    List<AddOn>? addon,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
