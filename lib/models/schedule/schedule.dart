import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Jadwal with _$Jadwal {
  const factory Jadwal({
    String? key,
    String? id_kelas,
    String? nama_kelas,
    String? id_mapel,
    String? id_timetable,
    String? mata_pelajaran,
    String? id_jenis_penilaian,
    String? hari,
    String? jam,
    String? staff,
    String? jurnal,
    String? date,
    String? jumlah,
    String? hadir,
    String? sakit,
    String? izin,
    String? alfa,
    String? bab,
    String? detail,
    String? jumlahabsen,
    String? today,
    String? absense,
    String? name_hour,
    String? finish_hour,
    String? tingkat,
  }) = _Jadwal;

  factory Jadwal.fromJson(Map<String, dynamic> json) => _$JadwalFromJson(json);
}
