import 'package:freezed_annotation/freezed_annotation.dart';

part 'pickup.freezed.dart';
part 'pickup.g.dart';

@freezed
abstract class Penjemputan with _$Penjemputan {
  const factory Penjemputan({
    @JsonKey(name: 'id_event') String? idEvent,
    @JsonKey(name: 'nama_event') String? namaEvent,
    @JsonKey(name: 'nama_lengkap') String? namaLengkap,
    @JsonKey(name: 'nis') String? nis,
    @JsonKey(name: 'id_kelas') String? idKelas,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'asrama') String? asrama,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'tingkat ') String? tingkat,
    @JsonKey(name: 'date_detail') String? dateDetail,
    @JsonKey(name: 'hour') String? hour,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'jml') String? jml,
    @JsonKey(name: 'sekolah') String? sekolah,
    @JsonKey(name: 'penjemput') String? penjemput,
    @JsonKey(name: 'diantar') String? diantar,
    @JsonKey(name: 'pengantar') String? pengantar,
  }) = _Penjemputan;

  factory Penjemputan.fromJson(Map<String, dynamic> json) =>
      _$PenjemputanFromJson(json);
}
