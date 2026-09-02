import 'package:freezed_annotation/freezed_annotation.dart';

part 'permit.freezed.dart';
part 'permit.g.dart';

@freezed
abstract class TapHistory with _$TapHistory {
  const factory TapHistory({
    String? id,
    @JsonKey(name: 'tap_keluar') String? tapKeluar,
    @JsonKey(name: 'tap_masuk') String? tapMasuk,
    String? status,
    @JsonKey(name: 'jam_izin_from') String? jamIzinFrom,
    @JsonKey(name: 'jam_izin_until') String? jamIzinUntil,
  }) = _TapHistory;

  factory TapHistory.fromJson(Map<String, dynamic> json) =>
      _$TapHistoryFromJson(json);
}

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
    @JsonKey(name: 'jam_izin_from') String? jamIzinFrom,
    @JsonKey(name: 'jam_izin_until') String? jamIzinUntil,
    @JsonKey(name: 'tap_keluar') String? tapKeluar,
    @JsonKey(name: 'tap_masuk') String? tapMasuk,
    @JsonKey(name: 'tap_status') String? tapStatus,
    @JsonKey(name: 'tap_history') List<TapHistory>? tapHistory,
    @JsonKey(name: 'is_late') String? isLate,
  }) = _Permit;

  factory Permit.fromJson(Map<String, dynamic> json) => _$PermitFromJson(json);
}
