import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_transfer.freezed.dart';
part 'request_transfer.g.dart';

@freezed
class RequestTransfer with _$RequestTransfer {
  const factory RequestTransfer({
    String? key,
    int? paymentType,
    int? totalOrder,
    String? idStore,
    List<Barang>? product,
  }) = _RequestTransfer;

  factory RequestTransfer.fromJson(Map<String, dynamic> json) =>
      _$RequestTransferFromJson(json);
}

@freezed
class Barang with _$Barang {
  const factory Barang({
    String? idProduct,
    int? amountProduct,
  }) = _Barang;

  factory Barang.fromJson(Map<String, dynamic> json) => _$BarangFromJson(json);
}
