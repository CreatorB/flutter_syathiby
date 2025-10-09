import 'package:freezed_annotation/freezed_annotation.dart';

part 'hostel.freezed.dart';
part 'hostel.g.dart';

@freezed
class Asrama with _$Asrama {
  const factory Asrama({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_asrama') String? idAsrama,
    @JsonKey(name: 'nama_asrama') String? namaAsrama,
    @JsonKey(name: 'jumlah_santri') int? jumlahSantri,
    @JsonKey(name: 'musrif') dynamic musrif,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'dijemput') int? dijemput,
    @JsonKey(name: 'dikembalikan') int? dikembalikan,
    @JsonKey(name: 'belumpulang') int? belumpulang,
    @JsonKey(name: 'belumkembali') dynamic belumkembali,
    @JsonKey(name: 'ontime') int? ontime,
  }) = _Asrama;

  factory Asrama.fromJson(Map<String, dynamic> json) => _$AsramaFromJson(json);
}
