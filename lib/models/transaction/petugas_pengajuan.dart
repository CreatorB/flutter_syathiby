// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'petugas_pengajuan.freezed.dart';
part 'petugas_pengajuan.g.dart';

/// Data form pengajuan dari `pengadaan/petugas.php`: atasan pemohon dan
/// daftar tim perbaikan beserta anggotanya.
@freezed
class PetugasPengajuan with _$PetugasPengajuan {
  const factory PetugasPengajuan({
    @JsonKey(name: 'atasan') String? atasan,
    @JsonKey(name: 'atasan_nama') String? atasanNama,
    @JsonKey(name: 'atasan_otomatis') int? atasanOtomatis,
    @JsonKey(name: 'tim') List<TimPerbaikan>? tim,
  }) = _PetugasPengajuan;

  factory PetugasPengajuan.fromJson(Map<String, dynamic> json) =>
      _$PetugasPengajuanFromJson(json);
}

@freezed
class TimPerbaikan with _$TimPerbaikan {
  const factory TimPerbaikan({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'nama') String? nama,
    @JsonKey(name: 'anggota') List<Petugas>? anggota,
  }) = _TimPerbaikan;

  factory TimPerbaikan.fromJson(Map<String, dynamic> json) =>
      _$TimPerbaikanFromJson(json);
}

@freezed
class Petugas with _$Petugas {
  const factory Petugas({
    @JsonKey(name: 'telp') String? telp,
    @JsonKey(name: 'nama') String? nama,
  }) = _Petugas;

  factory Petugas.fromJson(Map<String, dynamic> json) =>
      _$PetugasFromJson(json);
}
