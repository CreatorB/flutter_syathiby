import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_laba_rugi.freezed.dart';
part 'report_laba_rugi.g.dart';

@freezed
abstract class ReportLabaRugi with _$ReportLabaRugi {
  const factory ReportLabaRugi({
    Info? info,
    Keuangan? financialStatements,
    List<Penjualan>? salesReport,
  }) = _ReportLabaRugi;

  factory ReportLabaRugi.fromJson(Map<String, dynamic> json) =>
      _$ReportLabaRugiFromJson(json);
}

@freezed
abstract class Info with _$Info {
  const factory Info({
    @JsonKey(name: 'net_sales') String? netSales,
    String? average,
    @JsonKey(name: 'amount_transaction') String? amountTransaction,
  }) = _Info;

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

@freezed
abstract class Penjualan with _$Penjualan {
  const factory Penjualan({
    @JsonKey(name: 'id_product') String? idProduct,
    @JsonKey(name: 'name_product') String? nameProduct,
    String? amount,
    @JsonKey(name: 'totalprice') String? totalPrice,
    @JsonKey(name: 'selling_price') String? sellingPrice,
  }) = _Penjualan;

  factory Penjualan.fromJson(Map<String, dynamic> json) =>
      _$PenjualanFromJson(json);
}

@freezed
abstract class Keuangan with _$Keuangan {
  const factory Keuangan({
    @JsonKey(name: 'gross_sales') String? grossSales,
    String? discount,
    String? cancellation,
    @JsonKey(name: 'net_sales') String? netSales,
    String? tax,
    String? admin,
    @JsonKey(name: 'total_income') String? totalIncome,
    @JsonKey(name: 'harga_pokok_penjualan') String? hargaPokokPenjualan,
    @JsonKey(name: 'gross_profit') String? grossProfit,
    String? expenses,
  }) = _Keuangan;

  factory Keuangan.fromJson(Map<String, dynamic> json) =>
      _$KeuanganFromJson(json);
}
