import 'package:freezed_annotation/freezed_annotation.dart';

part 'absent.freezed.dart';
part 'absent.g.dart';

@freezed
class Absent with _$Absent {
  const factory Absent({
    String? id_attendance,
    String? staff,
    String? date,
    String? hour,
    String? location,
    dynamic device,
    String? status,
    String? img,
    String? name_staff,
    int? attandence,
    int? job,
    String? today,
    String? workhour,
    String? timeattand,
    String? type,
    dynamic during,
    String? late,
    String? done,
    String? locationfinish,
    String? overtime,
    String? overtime2,
    String? latitude,
    String? longitude,
    String? distance,
    String? name_event,
    String? reason,
  }) = _Absent;

  factory Absent.fromJson(Map<String, dynamic> json) => _$AbsentFromJson(json);
}
