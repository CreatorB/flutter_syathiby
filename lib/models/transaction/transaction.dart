import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart'; // File ini akan dihasilkan otomatis saat menjalankan build runner

@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    @JsonKey(name: 'uuid') String? uuid,
    @JsonKey(name: 'name_product') String? nameProduct,
    @JsonKey(name: 'name_supplier') String? nameSupplier,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'no_invoice') String? noInvoice,
    @JsonKey(name: 'oleh') String? oleh,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'payment') String? payment,
    @JsonKey(name: 'totalorder') String? totalOrder,
    @JsonKey(name: 'totalpay') int? totalPay,
    @JsonKey(name: 'nominal') String? nominal,
    @JsonKey(name: 'by') String? by,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'type') String? type,
    @JsonKey(name: 'name_table') String? nameTable,
  }) = _Transaction;

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}
