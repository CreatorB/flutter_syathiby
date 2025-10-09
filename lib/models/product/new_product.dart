import 'package:freezed_annotation/freezed_annotation.dart';

import 'product.dart';

part 'new_product.freezed.dart';
part 'new_product.g.dart';

@freezed
abstract class ProductNew with _$ProductNew {
  const factory ProductNew({
    required String status,
    required String errCode,
    required String msg,
    required List<Product>? data,
  }) = _ProductNew;

  factory ProductNew.fromJson(Map<String, dynamic> json) =>
      _$ProductNewFromJson(json);
}
