import 'package:freezed_annotation/freezed_annotation.dart';

part 'meeting.freezed.dart';
part 'meeting.g.dart';

@freezed
abstract class Rapat with _$Rapat {
  const factory Rapat({
    @JsonKey(name: 'id_meeting') String? idMeeting,
    @JsonKey(name: 'name_meeting') String? nameMeeting,
    @JsonKey(name: 'operator') String? operator,
    @JsonKey(name: 'deskripsi') String? deskripsi,
    @JsonKey(name: 'meeting_for') String? meetingFor,
    @JsonKey(name: 'date') String? date,
    @JsonKey(name: 'date_finish') String? dateFinish,
    @JsonKey(name: 'hour_start') String? hourStart,
    @JsonKey(name: 'hour_finish') String? hourFinish,
    @JsonKey(name: 'location') String? location,
    @JsonKey(name: 'admin') String? admin,
    @JsonKey(name: 'linkhost') String? linkHost,
    @JsonKey(name: 'linkpeserta') String? linkPeserta,
    @JsonKey(name: 'status_meeting') dynamic statusMeeting,
  }) = _Rapat;

  factory Rapat.fromJson(Map<String, dynamic> json) => _$RapatFromJson(json);
}
