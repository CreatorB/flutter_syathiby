import 'package:freezed_annotation/freezed_annotation.dart';

part 'job_detail.freezed.dart';
part 'job_detail.g.dart';

@freezed
class DetailsJob with _$DetailsJob {
  const factory DetailsJob({
    Info? info,
    @JsonKey(name: 'data') List<JobData>? data,
  }) = _DetailsJob;

  factory DetailsJob.fromJson(Map<String, dynamic> json) =>
      _$DetailsJobFromJson(json);
}

@freezed
class Info with _$Info {
  const factory Info({
    @JsonKey(name: 'id_history_job') String? id_history_job,
    @JsonKey(name: 'no_invoice') String? no_invoice,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'detail') String? detail,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'name_staff') String? name_staff,
    @JsonKey(name: 'by') String? by,
  }) = _Info;

  factory Info.fromJson(Map<String, dynamic> json) => _$InfoFromJson(json);
}

@freezed
class JobData with _$JobData {
  const factory JobData({
    String? id,
    @JsonKey(name: 'name_staff') String? name_staff,
    String? comment,
    @JsonKey(name: 'no_invoice') String? no_invoice,
    String? date,
    String? status,
    String? img,
    String? note,
  }) = _JobData;

  factory JobData.fromJson(Map<String, dynamic> json) =>
      _$JobDataFromJson(json);
}
