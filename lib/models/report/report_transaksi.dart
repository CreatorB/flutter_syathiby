import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_transaksi.freezed.dart';
part 'report_transaksi.g.dart';

@freezed
abstract class ReportTransaksi with _$ReportTransaksi {
  const factory ReportTransaksi({
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'name_product') String? nameProduct,
    @JsonKey(name: 'first_date') String? firstDate,
    @JsonKey(name: 'finish_date') String? finishDate,
    @JsonKey(name: 'totalorder') String? totalOrder,
    String? sales,
    @JsonKey(name: 'last_stock') String? lastStock,
    @JsonKey(name: 'purchase_price') String? purchasePrice,
    @JsonKey(name: 'selling_price') String? sellingPrice,
    @JsonKey(name: 'laba_rugi') String? labaRugi,
    @JsonKey(name: 'have_stock') String? haveStock,
    String? unit,
  }) = _ReportTransaksi;

  factory ReportTransaksi.fromJson(Map<String, dynamic> json) =>
      _$ReportTransaksiFromJson(json);
}
