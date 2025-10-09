import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_transfer.freezed.dart';
part 'detail_transfer.g.dart';

@freezed
class DetailTransfer with _$DetailTransfer {
  const factory DetailTransfer({
    Struk? struk,
    List<Data>? data,
  }) = _DetailTransfer;

  factory DetailTransfer.fromJson(Map<String, dynamic> json) =>
      _$DetailTransferFromJson(json);
}

@freezed
class Struk with _$Struk {
  const factory Struk({
    String? nameStore,
    String? email,
    String? nohp,
    String? address,
    String? noInvoice,
    String? operator,
    String? date,
    String? payment,
    String? totalorder,
    String? totalpay,
    String? totallast,
    String? changepay,
    String? status,
    String? note,
    String? img,
    String? storeDestination,
    int? paper,
  }) = _Struk;

  factory Struk.fromJson(Map<String, dynamic> json) => _$StrukFromJson(json);
}

@freezed
class Data with _$Data {
  const factory Data({
    String? codeproduct,
    String? nameProduct,
    String? noInvoice,
    String? idProduct,
    String? date,
    String? amount,
    String? price,
    String? totalprice,
    String? status,
    String? haveStock,
    String? stock,
    String? img,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
