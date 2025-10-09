import 'package:freezed_annotation/freezed_annotation.dart';

part 'score.freezed.dart';
part 'score.g.dart';

@freezed
abstract class Nilai with _$Nilai {
  const factory Nilai({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_kelas') String? idKelas,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'nama_lengkap') String? namaLengkap,
    @JsonKey(name: 'nis') String? nis,
    @JsonKey(name: 'id_mapel') String? idMapel,
    @JsonKey(name: 'mapel') String? mapel,
    @JsonKey(name: 'id_jenis_penilaian') String? idJenisPenilaian,
    @JsonKey(name: 'name_jenis_penilaian') String? nameJenisPenilaian,
    @JsonKey(name: 'nilai') int? nilai,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'hari') String? hari,
    @JsonKey(name: 'jam') String? jam,
    @JsonKey(name: 'staff') String? staff,
    @JsonKey(name: 'pr1') String? pr1,
    @JsonKey(name: 'pr2') String? pr2,
    @JsonKey(name: 'pr3') String? pr3,
    @JsonKey(name: 'pr4') String? pr4,
    @JsonKey(name: 'rpr') int? rpr,
    @JsonKey(name: 'ph1') String? ph1,
    @JsonKey(name: 'ph2') String? ph2,
    @JsonKey(name: 'ph3') String? ph3,
    @JsonKey(name: 'ph4') String? ph4,
    @JsonKey(name: 'rph') String? rph,
    @JsonKey(name: 't1') String? t1,
    @JsonKey(name: 't2') String? t2,
    @JsonKey(name: 't3') String? t3,
    @JsonKey(name: 't4') String? t4,
    @JsonKey(name: 'rt') int? rt,
    @JsonKey(name: 'pts') String? pts,
    @JsonKey(name: 'pta') String? pta,
    @JsonKey(name: 'nilai_rapor') String? nilaiRapor,
    @JsonKey(name: 'kkm') String? kkm,
    @JsonKey(name: 'kedisiplinan') String? kedisiplinan,
    @JsonKey(name: 'kerapihan') String? kerapihan,
    @JsonKey(name: 'kebersihan') String? kebersihan,
    @JsonKey(name: 'keterangan') String? keterangan,
    @JsonKey(name: 'img') String? img,
  }) = _Nilai;

  factory Nilai.fromJson(Map<String, dynamic> json) => _$NilaiFromJson(json);
}
