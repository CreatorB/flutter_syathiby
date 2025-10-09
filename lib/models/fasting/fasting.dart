import 'package:freezed_annotation/freezed_annotation.dart';

part 'fasting.freezed.dart';
part 'fasting.g.dart';

@freezed
abstract class Puasa with _$Puasa {
  const factory Puasa({
    String? key,
    @JsonKey(name: 'id_puasa') String? idPuasa,
    @JsonKey(name: 'jenis_puasa') String? jenisPuasa,
    String? date,
    String? status,
    String? staff,
    @JsonKey(name: 'nama_siswa') String? namaSiswa,
    String? nis,
    String? kelas,
    String? asrama,
    String? img,
    int? total,
    int? totalma,
    int? totalmsw,
    int? totalpi,
  }) = _Puasa;

  factory Puasa.fromJson(Map<String, dynamic> json) => _$PuasaFromJson(json);
}
