import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_stock.freezed.dart';
part 'report_stock.g.dart';

@freezed
abstract class ReportStock with _$ReportStock {
  const factory ReportStock({
    @JsonKey(name: 'id_barang') String? idBarang,
    @JsonKey(name: 'nama_barang') String? namaBarang,
    @JsonKey(name: 'tanggal_awal') String? tanggalAwal,
    @JsonKey(name: 'tanggal_akhir') String? tanggalAkhir,
    String? terjual,
    @JsonKey(name: 'stok_terakhir') String? stokTerakhir,
    @JsonKey(name: 'minimal_stok') String? minimalStok,
    List<Detail>? datastok,
  }) = _ReportStock;

  factory ReportStock.fromJson(Map<String, dynamic> json) =>
      _$ReportStockFromJson(json);
}

@freezed
abstract class Detail with _$Detail {
  const factory Detail({
    @JsonKey(name: 'sisa_stok') String? sisaStok,
    @JsonKey(name: 'minimal_stok') String? minimalStok,
    String? tanggal,
  }) = _Detail;

  factory Detail.fromJson(Map<String, dynamic> json) => _$DetailFromJson(json);
}
