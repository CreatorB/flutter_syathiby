import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

@freezed
class Event with _$Event {
  const factory Event({
    String? id_event,
    String? name_event,
    String? start_date,
    String? finish_date,
    String? detail,
    int? jumlah,
    int? dijemput,
    int? dikembalikan,
    String? location,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}
