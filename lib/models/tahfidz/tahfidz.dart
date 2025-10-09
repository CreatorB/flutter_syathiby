import 'package:freezed_annotation/freezed_annotation.dart';

part 'tahfidz.freezed.dart';
part 'tahfidz.g.dart';

@freezed
class Tahfidz with _$Tahfidz {
  @JsonSerializable(explicitToJson: true)
  const factory Tahfidz({
    String? key,
    String? id_tahfidz,
    String? jenis_tahfidz,
    String? waktu_tahfidz,
    String? halaman,
    String? halaman_end,
    String? detail,
    String? date,
    String? hour,
    String? status,
    String? staff,
    String? nama_siswa,
    String? nis,
    String? kelas,
    String? img,
    String? nilai,
    String? jumlah,
  }) = _Tahfidz;

  factory Tahfidz.fromJson(Map<String, dynamic> json) =>
      _$TahfidzFromJson(json);
}
