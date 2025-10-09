import 'package:freezed_annotation/freezed_annotation.dart';

part 'job.freezed.dart';
part 'job.g.dart';

@freezed
class Job with _$Job {
  const factory Job({
    @JsonKey(name: 'key') String? key,
    @JsonKey(name: 'id_history_job') String? id_history_job,
    @JsonKey(name: 'no_invoice') String? no_invoice,
    @JsonKey(name: 'note') String? note,
    @JsonKey(name: 'detail') String? detail,
    @Default('0') @JsonKey(name: 'date') String date,
    @JsonKey(name: 'status') String? status,
    @JsonKey(name: 'img') String? img,
    @JsonKey(name: 'operator') String? operator,
    @JsonKey(name: 'phone_number') String? phone_number,
    @JsonKey(name: 'hour') String? hour,
    @JsonKey(name: 'id_asrama') String? id_asrama,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}
