import 'package:freezed_annotation/freezed_annotation.dart';

part 'tempat.freezed.dart';
part 'tempat.g.dart';

@freezed
class Tempat with _$Tempat {
  const factory Tempat({
    String? key,
    String? id_tempat,
    String? nama_tempat,
    int? jumlah_barang,
    String? lokasi,
    String? date,
    String? status,
    dynamic bagus,
    dynamic cukupbaik,
    dynamic rusak,
  }) = _Tempat;

  factory Tempat.fromJson(Map<String, dynamic> json) => _$TempatFromJson(json);
}
