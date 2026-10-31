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
    // Sayap Santri (Ikhwan / Akhwat) yang dihitung server dari gender.
    String? gender,
    String? sayap,
  }) = _Permit;

  factory Permit.fromJson(Map<String, dynamic> json) => _$PermitFromJson(json);
}

/// Ringkasan yang dikirim server bersama daftar izin.
///
/// Dipakai untuk label tab (jumlah izin per status), lingkup sayap yang
/// otomatis dari `employees.gender_lock`, dan penanda apakah chip filter
/// sayap masih boleh dipakai atau terkunci.
@freezed
abstract class PermitMeta with _$PermitMeta {
  const factory PermitMeta({
    @JsonKey(name: 'scope_gender') String? scopeGender,
    @JsonKey(name: 'sayap_terkunci') int? sayapTerkunci,
    String? sayap,
    Map<String, int>? jumlah,
  }) = _PermitMeta;

  factory PermitMeta.fromJson(Map<String, dynamic> json) =>
      _$PermitMetaFromJson(json);
}

/// Bungkus respons `permit/listsantri.php`.
///
/// Server mengembalikan objek `{status, errCode, msg, meta, data}`. Object
/// ini dipakai agar bagian `meta` tidak hilang saat response diproses.
@freezed
abstract class PermitListResponse with _$PermitListResponse {
  const factory PermitListResponse({
    String? status,
    @JsonKey(name: 'errCode') String? errCode,
    String? msg,
    PermitMeta? meta,
    @Default(<Permit>[]) List<Permit> data,
  }) = _PermitListResponse;

  factory PermitListResponse.fromJson(Map<String, dynamic> json) =>
      _$PermitListResponseFromJson(json);
}
