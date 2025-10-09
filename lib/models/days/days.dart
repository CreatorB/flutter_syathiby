import 'package:freezed_annotation/freezed_annotation.dart';

part 'days.freezed.dart';
part 'days.g.dart';

@freezed
class Days with _$Days {
  const factory Days({
    dynamic id_days,
    String? name_days,
    String? start_working,
    String? finish_working,
    String? dates,
    String? today,
  }) = _Days;

  factory Days.fromJson(Map<String, dynamic> json) => _$DaysFromJson(json);
}
