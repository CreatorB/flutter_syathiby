import 'package:freezed_annotation/freezed_annotation.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
class Report with _$Report {
  const factory Report({
    @JsonKey(name: 'id_attendance') String? idAttendance,
    String? key,
    String? email,
    @JsonKey(name: 'full_name') String? fullName,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    String? address,
    String? period,
    String? part,
    @JsonKey(name: 'id_store') String? idStore,
    @JsonKey(name: 'name_store') String? nameStore,
    String? ontime,
    String? late,
    @JsonKey(name: 'notpresent') String? notPresent,
    String? overtime,
    String? permit,
    int? assign,
    int? proses,
    int? finish,
    String? presence,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}
