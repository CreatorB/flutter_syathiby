import 'package:freezed_annotation/freezed_annotation.dart';

part 'req_trans.freezed.dart';
part 'req_trans.g.dart';

@freezed
class ReqTrans with _$ReqTrans {
  const factory ReqTrans({
    String? key,
    int? paymentType,
    int? paymentAmount,
    int? totalOrder,
    String? idCustomer,
    int? point,
    String? idDiscount,
    String? card,
    String? note,
    String? dueDate,
    List<Barang>? product,
    double? latitude,
    double? longitude,
    String? id,
  }) = _ReqTrans;

  factory ReqTrans.fromJson(Map<String, dynamic> json) =>
      _$ReqTransFromJson(json);
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
