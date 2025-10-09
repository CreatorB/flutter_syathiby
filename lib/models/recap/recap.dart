import 'package:freezed_annotation/freezed_annotation.dart';

part 'recap.freezed.dart';
part 'recap.g.dart';

@freezed
class Recap with _$Recap {
  factory Recap({
    String? key,
    @JsonKey(name: 'nama_divisi') String? namaDivisi,
    String? date,
    String? day,
    String? period,
    String? jumlah,
    String? hadir,
    String? late,
    @JsonKey(name: 'beforetime') String? beforeTime,
    String? ontime,
    String? ontime2,
    String? alfa,
    String? notpresent2,
    String? izin,
    String? kabag,
  }) = _Recap;

  factory Recap.fromJson(Map<String, dynamic> json) => _$RecapFromJson(json);
}
