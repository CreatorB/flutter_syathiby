import 'package:freezed_annotation/freezed_annotation.dart';

part 'permit.freezed.dart';
part 'permit.g.dart';

@freezed
abstract class Permit with _$Permit {
  const factory Permit({
    @JsonKey(ignore: true) String? key,
    @JsonKey(name: 'id_permit') String? idPermit,
    @JsonKey(name: 'name_permit') String? namePermit,
    String? day,
    String? detail,
    String? date,
    @JsonKey(name: 'lastdate') String? lastDate,
    String? status,
    String? img,
    String? doc,
    String? staff,
    @JsonKey(name: 'nama_siswa') String? namaSiswa,
    String? kelas,
    String? asrama,
    String? kabag,
    String? alasan,
    String? aproval,
  }) = _Permit;

  factory Permit.fromJson(Map<String, dynamic> json) => _$PermitFromJson(json);
}
