import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_transaction.freezed.dart';
part 'detail_transaction.g.dart';

@freezed
class DetailTransaction with _$DetailTransaction {
  const factory DetailTransaction({
    Struk? struk,
    @JsonKey(name: 'data') List<TransactionData>? data,
  }) = _DetailTransaction;

  factory DetailTransaction.fromJson(Map<String, dynamic> json) =>
      _$DetailTransactionFromJson(json);
}

@freezed
class Struk with _$Struk {
  const factory Struk({
    @JsonKey(name: 'name_store') String? nameStore,
    @JsonKey(name: 'email') String? email,
    @JsonKey(name: 'nohp') String? noHp,
    @JsonKey(name: 'address') String? address,
    @JsonKey(name: 'no_invoice') String? noInvoice,
    @JsonKey(name: 'operator') String? operator,
    @JsonKey(name: 'id_customer') String? idCustomer,
    @JsonKey(name: 'name_customer') String? nameCustomer,
    @JsonKey(name: 'id_table') String? idTable,
    @JsonKey(name: 'name_table') String? nameTable,
    @JsonKey(name: 'id_supplier') String? idSupplier,
    @JsonKey(name: 'name_supplier') String? nameSupplier,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'payment') String? payment,
    @JsonKey(name: 'totalorder') int? totalOrder,
    @JsonKey(name: 'totalpay') int? totalPay,
    @JsonKey(name: 'totallast') int? totalLast,
    @JsonKey(name: 'changepay') String? changePay,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'service_charge') String? serviceCharge,
    @JsonKey(name: 'discount') String? discount,
    @JsonKey(name: 'tax') String? tax,
    @JsonKey(name: 'footer') String? footer,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'paper') int? paper,
    @JsonKey(name: 'link_order') String? linkOrder,
    @JsonKey(name: 'nama_kegiatan') String? namaKegiatan,
    @JsonKey(name: 'subkegiatan') String? subKegiatan,
    @JsonKey(name: 'alokasi') String? alokasi,
    @JsonKey(name: 'jeniskegiatan') String? jenisKegiatan,
    @JsonKey(name: 'keterangan') String? keterangan,
    @JsonKey(name: 'namabidang') String? namaBidang,
    @JsonKey(name: 'level') String? level,
    @JsonKey(name: 'waktu') String? waktu,
  }) = _Struk;

  factory Struk.fromJson(Map<String, dynamic> json) => _$StrukFromJson(json);
}

@freezed
class TransactionData with _$TransactionData {
  const factory TransactionData({
    @JsonKey(name: 'codeproduct') String? codeProduct,
    @JsonKey(name: 'name_product') String? nameProduct,
    @JsonKey(name: 'no_invoice') String? noInvoice,
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'amount') dynamic amount,
    @JsonKey(name: 'price') dynamic price,
    @JsonKey(name: 'totalprice') dynamic totalPrice,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'have_stock') String? haveStock,
    @JsonKey(name: 'stock') String? stock,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'unit') String? unit,
  }) = _TransactionData;

  factory TransactionData.fromJson(Map<String, dynamic> json) =>
      _$TransactionDataFromJson(json);
}
