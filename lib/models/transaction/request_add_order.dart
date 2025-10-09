import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_add_order.freezed.dart';
part 'request_add_order.g.dart';

@freezed
class RequestAddOrder with _$RequestAddOrder {
  const factory RequestAddOrder({
    String? key,
    int? totalOrder,
    int? paymentType,
    String? noInvoice,
    List<Barang>? product,
  }) = _RequestAddOrder;

  factory RequestAddOrder.fromJson(Map<String, dynamic> json) =>
      _$RequestAddOrderFromJson(json);
}

@freezed
class Barang with _$Barang {
  const factory Barang({
    String? idProduct,
    int? amountProduct,
    String? notes,
  }) = _Barang;

  factory Barang.fromJson(Map<String, dynamic> json) => _$BarangFromJson(json);
}
