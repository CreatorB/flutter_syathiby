import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventaris.freezed.dart';
part 'inventaris.g.dart';

@freezed
class Inventaris with _$Inventaris {
  const factory Inventaris({
    String? key,
    String? id_tempat,
    String? id_inventaris,
    String? nama_tempat,
    String? nama_inventaris,
    String? code,
    String? jumlah_barang,
    String? cek_terakhir,
    String? date,
    String? kondisi,
    String? bagus,
    String? cukupbaik,
    String? rusak,
    String? img,
    String? unit,
  }) = _Inventaris;

  factory Inventaris.fromJson(Map<String, dynamic> json) =>
      _$InventarisFromJson(json);
}
