import 'package:freezed_annotation/freezed_annotation.dart';

part 'violation.freezed.dart';
part 'violation.g.dart';

@freezed
abstract class Pelanggaran with _$Pelanggaran {
  const factory Pelanggaran({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_pelanggaran') String? idPelanggaran,
    @JsonKey(name: 'nama_pelanggaran') String? namaPelanggaran,
    @JsonKey(name: 'detail') String? detail,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'hour') String? hour,
    @JsonKey(name: 'location') String? location,
    @JsonKey(name: 'nama_siswa') String? namaSiswa,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'staff') String? staff,
    @JsonKey(name: 'alasan') String? alasan,
    @JsonKey(name: 'penindak') String? penindak,
    @JsonKey(name: 'kabag') String? kabag,
  }) = _Pelanggaran;

  factory Pelanggaran.fromJson(Map<String, dynamic> json) =>
      _$PelanggaranFromJson(json);
}
