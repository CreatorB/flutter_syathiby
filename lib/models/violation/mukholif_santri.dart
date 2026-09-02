import 'package:freezed_annotation/freezed_annotation.dart';

part 'mukholif_santri.freezed.dart';
part 'mukholif_santri.g.dart';

@freezed
class MukholifSantri with _$MukholifSantri {
  const factory MukholifSantri({
    @JsonKey(name: 'santri_id') int? santrialId,
    @JsonKey(name: 'nama') String? nama,
    @JsonKey(name: 'nis') String? nis,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'kamar') String? kamar,
    @JsonKey(name: 'poin_aktif') int? poinAktif,
  }) = _MukholifSantri;

  factory MukholifSantri.fromJson(Map<String, dynamic> json) =>
      _$MukholifSantriFromJson(json);
}

@freezed
class MukholifPelanggaran with _$MukholifPelanggaran {
  const factory MukholifPelanggaran({
    @JsonKey(name: 'tanggal') String? tanggal,
    @JsonKey(name: 'nama_pelanggaran') String? namaPelanggaran,
    @JsonKey(name: 'kategori') String? kategori,
    @JsonKey(name: 'poin') int? poin,
    @JsonKey(name: 'bagian') String? bagian,
  }) = _MukholifPelanggaran;

  factory MukholifPelanggaran.fromJson(Map<String, dynamic> json) =>
      _$MukholifPelanggaranFromJson(json);
}

@freezed
class MukholifSantriInfo with _$MukholifSantriInfo {
  const factory MukholifSantriInfo({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'nama') String? nama,
    @JsonKey(name: 'kelas') String? kelas,
    @JsonKey(name: 'kamar') String? kamar,
    @JsonKey(name: 'poin_aktif') int? poinAktif,
  }) = _MukholifSantriInfo;

  factory MukholifSantriInfo.fromJson(Map<String, dynamic> json) =>
      _$MukholifSantriInfoFromJson(json);
}

@freezed
class MukholifSummary with _$MukholifSummary {
  const factory MukholifSummary({
    @JsonKey(name: 'total_pelanggaran') int? totalPelanggaran,
    @JsonKey(name: 'total_poin') int? totalPoin,
    @JsonKey(name: 'total_poin_aktif') int? totalPoinAktif,
  }) = _MukholifSummary;

  factory MukholifSummary.fromJson(Map<String, dynamic> json) =>
      _$MukholifSummaryFromJson(json);
}

@freezed
class MukholifFilters with _$MukholifFilters {
  const factory MukholifFilters({
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'bagian') String? bagian,
    @JsonKey(name: 'kategori') String? kategori,
  }) = _MukholifFilters;

  factory MukholifFilters.fromJson(Map<String, dynamic> json) =>
      _$MukholifFiltersFromJson(json);
}

@freezed
class MukholifDetailData with _$MukholifDetailData {
  const factory MukholifDetailData({
    @JsonKey(name: 'santri') MukholifSantriInfo? siswa,
    @JsonKey(name: 'summary') MukholifSummary? summary,
    @JsonKey(name: 'filters') MukholifFilters? filters,
    @JsonKey(name: 'pelanggaran') List<MukholifPelanggaran>? pelanggaran,
  }) = _MukholifDetailData;

  factory MukholifDetailData.fromJson(Map<String, dynamic> json) =>
      _$MukholifDetailDataFromJson(json);
}

@freezed
class MukholifSearchResponse with _$MukholifSearchResponse {
  const factory MukholifSearchResponse({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'errCode') String? errCode,
    @JsonKey(name: 'msg') String? msg,
    @JsonKey(name: 'warning') String? warning,
    @JsonKey(name: 'warning_message') String? warningMessage,
    @JsonKey(name: 'data') List<MukholifSantri>? data,
  }) = _MukholifSearchResponse;

  factory MukholifSearchResponse.fromJson(Map<String, dynamic> json) =>
      _$MukholifSearchResponseFromJson(json);
}

@freezed
class MukholifDetailResponse with _$MukholifDetailResponse {
  const factory MukholifDetailResponse({
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'errCode') String? errCode,
    @JsonKey(name: 'msg') String? msg,
    @JsonKey(name: 'data') MukholifDetailData? data,
  }) = _MukholifDetailResponse;

  factory MukholifDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$MukholifDetailResponseFromJson(json);
}
