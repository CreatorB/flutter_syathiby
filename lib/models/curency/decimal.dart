import 'package:freezed_annotation/freezed_annotation.dart';

part 'decimal.freezed.dart';
part 'decimal.g.dart';

@freezed
class Decimal with _$Decimal {
  const factory Decimal({
    String? id_decimal,
    String? code_decimal,
  }) = _Decimal;

  factory Decimal.fromJson(Map<String, dynamic> json) =>
      _$DecimalFromJson(json);
}
