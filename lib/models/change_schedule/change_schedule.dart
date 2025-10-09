import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_schedule.freezed.dart';
part 'change_schedule.g.dart';

@freezed
class ChangeSchedule with _$ChangeSchedule {
  const factory ChangeSchedule({
    String? id_ubah_jadwal,
    String? date,
    String? detail,
    String? staff,
    String? staff2,
    String? status,
    String? position,
    String? pengganti,
    String? kabag,
    String? aproval,
    String? alasan,
  }) = _ChangeSchedule;

  factory ChangeSchedule.fromJson(Map<String, dynamic> json) =>
      _$ChangeScheduleFromJson(json);
}
