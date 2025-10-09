import 'package:freezed_annotation/freezed_annotation.dart';

part 'rapor.freezed.dart';
part 'rapor.g.dart';

@freezed
class Rapor with _$Rapor {
  const factory Rapor({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_kelas') String? idKelas,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'semester') String? semester,
    @JsonKey(name: 'nama_lengkap') String? namaLengkap,
    @JsonKey(name: 'nis') String? nis,
    @JsonKey(name: 'staff') String? staff,
    @JsonKey(name: 'kkm') String? kkm,
    @JsonKey(name: 'rangking') String? rangking,
    @JsonKey(name: 'keterangan') String? keterangan,
    @JsonKey(name: 'img') String? img,
  }) = _Rapor;

  factory Rapor.fromJson(Map<String, dynamic> json) => _$RaporFromJson(json);
}
