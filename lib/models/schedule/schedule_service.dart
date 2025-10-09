import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/schedule/schedule.dart';
import 'package:retrofit/retrofit.dart';

part 'schedule_service.g.dart';

@RestApi(baseUrl: 'jadwal/')
abstract class JadwalRestInterface {
  factory JadwalRestInterface(Dio dio, {String baseUrl}) = _JadwalRestInterface;

  @GET('list.php')
  Future<List<Jadwal>> get(@Query('key') String key);

  @GET('listmapel.php')
  Future<List<Jadwal>> getMapel(
      @Query('key') String key, @Query('id') String id);

  @GET('laporanabsensi.php')
  Future<List<Jadwal>> getLaporanAbsensi(
      @Query('key') String key,
      @Query('tgl_awal') String tglAwal,
      @Query('tgl_akhir') String tglAkhir,
      @Query('id_kelas') String idKelas);

  @GET('rekapabsensi.php')
  Future<List<Jadwal>> getJadwal(
      @Query('key') String key,
      @Query('id_kelas') String idKelas,
      @Query('id_mapel') String idMapel,
      @Query('id_timetable') String idTimetable);

  @FormUrlEncoded()
  @POST('jurnal.php')
  Future<Message> addJurnal(
    @Field('key') String key,
    @Field('id_kelas') String idKelas,
    @Field('id_mapel') String idMapel,
    @Field('bab') String bab,
    @Field('detail') String detail,
    @Field('id_timetable') String idTimetable,
  );

  @GET('type.php')
  Future<List<Jadwal>> type(@Query('key') String key);

  @POST('insert.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'nama_Jadwal') String namaJadwal,
    @Part(name: 'date') String date,
    @Part(name: 'hour') String hour,
    @Part(name: 'location') String location,
    @Part(name: 'nama_siswa') String namaSiswa,
    @Part(name: 'detail') String detail, {
    @Part(name: 'img') File? img,
  });
}
