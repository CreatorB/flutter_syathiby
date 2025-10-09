import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_type.freezed.dart';
part 'score_type.g.dart';

@freezed
abstract class TypeNilai with _$TypeNilai {
  const factory TypeNilai({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_jenis_penilaian') String? idJenisPenilaian,
    @JsonKey(name: 'name_jenis_penilaian') String? nameJenisPenilaian,
    @JsonKey(name: 'kode') String? kode,
  }) = _TypeNilai;

  factory TypeNilai.fromJson(Map<String, dynamic> json) =>
      _$TypeNilaiFromJson(json);
}
