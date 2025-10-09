import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_penjualan.freezed.dart';
part 'report_penjualan.g.dart';

@freezed
abstract class ReportPenjualan with _$ReportPenjualan {
  const factory ReportPenjualan({
    Info? info,
    List<Penjualan>? salesReport,
  }) = _ReportPenjualan;

  factory ReportPenjualan.fromJson(Map<String, dynamic> json) =>
      _$ReportPenjualanFromJson(json);
}

@freezed
abstract class Info with _$Info {
  const factory Info({
    @JsonKey(name: 'total_sales') String? totalSales,
    String? average,
    @JsonKey(name: 'number_transaction') String? numberTransaction,
    String? date,
    String? operator,
    @JsonKey(name: 'name_store') String? nameStore,
  }) = _Info;

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

@freezed
abstract class Penjualan with _$Penjualan {
  const factory Penjualan({
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'name_product') String? nameProduct,
    String? amount,
    String? totalprice,
    @JsonKey(name: 'selling_price') String? sellingPrice,
    String? unit,
  }) = _Penjualan;

  factory Penjualan.fromJson(Map<String, dynamic> json) =>
      _$PenjualanFromJson(json);
}
