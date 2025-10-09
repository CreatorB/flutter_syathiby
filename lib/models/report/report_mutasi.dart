import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_mutasi.freezed.dart';
part 'report_mutasi.g.dart';

@freezed
abstract class ReportMutasi with _$ReportMutasi {
  const factory ReportMutasi({
    Info? info,
    List<Transaksi>? transaksi,
  }) = _ReportMutasi;

  factory ReportMutasi.fromJson(Map<String, dynamic> json) =>
      _$ReportMutasiFromJson(json);
}

@freezed
abstract class Info with _$Info {
  const factory Info({
    @JsonKey(name: 'penjualan_bersih') String? penjualanBersih,
    @JsonKey(name: 'jumlah_transaksi') String? jumlahTransaksi,
  }) = _Info;

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

@freezed
abstract class Transaksi with _$Transaksi {
  const factory Transaksi({
    @JsonKey(name: 'no_invoice') String? noInvoice,
    String? tanggal,
    String? omset,
    String? margin,
    List<Barang>? barang,
  }) = _Transaksi;

  factory Transaksi.fromJson(Map<String, dynamic> json) =>
      _$TransaksiFromJson(json);
}

@freezed
abstract class Barang with _$Barang {
  const factory Barang({
    @JsonKey(name: 'id_barang') String? idBarang,
    @JsonKey(name: 'nama_barang') String? namaBarang,
    String? margin,
    String? laba,
    String? qty,
    @JsonKey(name: 'harga_jual') String? hargaJual,
    @JsonKey(name: 'harga_beli') String? hargaBeli,
  }) = _Barang;

  factory Barang.fromJson(Map<String, dynamic> json) => _$BarangFromJson(json);
}
