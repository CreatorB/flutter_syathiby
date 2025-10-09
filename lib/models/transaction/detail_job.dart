import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_job.freezed.dart';
part 'detail_job.g.dart';

@freezed
class DetailJob with _$DetailJob {
  const factory DetailJob({
    String? no_invoice,
    String? note,
    String? date,
    String? status,
    String? operator,
  }) = _DetailJob;

  factory DetailJob.fromJson(Map<String, dynamic> json) =>
      _$DetailJobFromJson(json);
}
