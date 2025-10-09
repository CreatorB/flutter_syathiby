import 'package:freezed_annotation/freezed_annotation.dart';

part 'rpp.freezed.dart';
part 'rpp.g.dart';

@freezed
class Rpp with _$Rpp {
  const factory Rpp({
    @JsonKey(name: 'id_rpp') String? idRpp,
    @JsonKey(name: 'staff') String? staff,
    @JsonKey(name: 'jenjang') String? jenjang,
    @JsonKey(name: 'mapel') String? mapel,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'semester') String? semester,
    @JsonKey(name: 'pertemuan_ke') String? pertemuanKe,
    @JsonKey(name: 'alokasi_waktu') String? alokasiWaktu,
    @JsonKey(name: 'standar_kompetensi') String? standarKompetensi,
    @JsonKey(name: 'kompetensi_dasar') String? kompetensiDasar,
    @JsonKey(name: 'indikator') String? indikator,
    @JsonKey(name: 'tujuan_pembelajaran') String? tujuanPembelajaran,
    @JsonKey(name: 'materi_ajar') String? materiAjar,
    @JsonKey(name: 'metode_pembelajaran') String? metodePembelajaran,
    @JsonKey(name: 'langkah_pembelajaran') String? langkahPembelajaran,
    @JsonKey(name: 'alat_sumber_belajar') String? alatSumberBelajar,
    @JsonKey(name: 'penilaian') String? penilaian,
    @JsonKey(name: 'tahun_ajaran') String? tahunAjaran,
  }) = _Rpp;

  factory Rpp.fromJson(Map<String, dynamic> json) => _$RppFromJson(json);
}
