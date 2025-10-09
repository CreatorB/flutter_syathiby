import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_payment.freezed.dart';
part 'detail_payment.g.dart';

@freezed
class DetailPayment with _$DetailPayment {
  const factory DetailPayment({
    double? totalprice,
    double? totalpay,
    double? discount,
    double? tax,
    double? serviceCharge,
    String? idDiscount,
    String? nameDiscount,
  }) = _DetailPayment;

  factory DetailPayment.fromJson(Map<String, dynamic> json) =>
      _$DetailPaymentFromJson(json);
}
