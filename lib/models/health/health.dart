import 'package:freezed_annotation/freezed_annotation.dart';

part 'health.freezed.dart';
part 'health.g.dart';

@freezed
class Kesehatan with _$Kesehatan {
  const factory Kesehatan({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_kesehatan') String? id_kesehatan,
    @JsonKey(name: 'keluhan') String? keluhan,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'hour') String? hour,
    @JsonKey(name: 'nama_siswa') String? nama_siswa,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'staff') String? staff,
    @JsonKey(name: 'penanganan') String? penanganan,
    @JsonKey(name: 'dijemput') String? dijemput,
    @JsonKey(name: 'diagnosa') String? diagnosa,
    @JsonKey(name: 'istirahat') String? istirahat,
    @JsonKey(name: 'info_ortu') String? info_ortu,
  }) = _Kesehatan;

  factory Kesehatan.fromJson(Map<String, dynamic> json) =>
      _$KesehatanFromJson(json);
}
