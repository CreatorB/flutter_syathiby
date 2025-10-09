import 'package:freezed_annotation/freezed_annotation.dart';

part 'request_transaction.freezed.dart';
part 'request_transaction.g.dart';

@freezed
class RequestTransaction with _$RequestTransaction {
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory RequestTransaction({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'payment_type') int? paymentType,
    @JsonKey(name: 'payment_amount') int? paymentAmount,
    @JsonKey(name: 'total_order') double? totalOrder,
    @JsonKey(name: 'id_customer') String? idCustomer,
    @JsonKey(name: 'kurir') String? kurir,
    @JsonKey(name: 'name_customer') String? nameCustomer,
    @JsonKey(name: 'name_store') String? nameStore,
    @JsonKey(name: 'email_store') String? emailStore,
    @JsonKey(name: 'nohp_store') String? nohpStore,
    @JsonKey(name: 'footer') String? footer,
    @JsonKey(name: 'address_store') String? addressStore,
    @JsonKey(name: 'id_supplier') String? idSupplier,
    @JsonKey(name: 'name_supplier') String? nameSupplier,
    @JsonKey(name: 'point') String? point,
    @JsonKey(name: 'id_discount') String? idDiscount,
    @JsonKey(name: 'card') String? card,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'waktu') String? waktu,
    @JsonKey(name: 'due_date') String? dueDate,
    @JsonKey(name: 'product') List<Barang>? product,
    @JsonKey(name: 'latitude') double? latitude,
    @JsonKey(name: 'longitude') double? longitude,
    @JsonKey(name: 'id_table') String? idTable,
    @JsonKey(name: 'id') String? id,
    @JsonKey(name: 'complaint') String? complaint,
    @JsonKey(name: 'advice') String? advice,
    @JsonKey(name: 'name_kegiatan') String? nameKegiatan,
    @JsonKey(name: 'name_subkegiatan') String? nameSubkegiatan,
    @JsonKey(name: 'jeniskegiatan') String? jenisKegiatan,
  }) = _RequestTransaction;

  factory RequestTransaction.fromJson(Map<String, dynamic> json) =>
      _$RequestTransactionFromJson(json);
}

@freezed
class Barang with _$Barang {
  @JsonSerializable(explicitToJson: true, includeIfNull: false)
  const factory Barang({
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'amount_product') double? amountProduct,
    @JsonKey(name: 'new_price') String? newPrice,
    @JsonKey(name: 'notes') String? notes,
  }) = _Barang;

  factory Barang.fromJson(Map<String, dynamic> json) => _$BarangFromJson(json);
}
