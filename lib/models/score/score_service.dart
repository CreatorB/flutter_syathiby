import 'package:dio/dio.dart';
import 'package:syathiby/models/score/score.dart';
import 'package:syathiby/models/score/score_type.dart';
import 'package:retrofit/retrofit.dart';

import '../message.dart';

part 'score_service.g.dart';

@RestApi(baseUrl: 'siswa/')
abstract class NilaiRestInterface {
  factory NilaiRestInterface(Dio dio, {String baseUrl}) = _NilaiRestInterface;

  @GET('nilai.php')
  Future<List<Nilai>> getNilai(
    @Query('key') String key,
    @Query('id_kelas') String idKelas,
    @Query('id_mapel') String idMapel,
    @Query('id_jenis_penilaian') String idJenisPenilaian,
  );

  @GET('typenilai.php')
  Future<List<TypeNilai>> getTypeNilai(
    @Query('key') String key,
    @Query('type') String type,
  );

  @GET('nilaisantri.php')
  Future<List<Nilai>> getNilaiSantri(
    @Query('key') String key,
    @Query('id_kelas') String idKelas,
    @Query('id_mapel') String idMapel,
    @Query('nis') String nis,
    @Query('id_jenis_penilaian') String idJenisPenilaian,
  );

  @GET('detailnilaisantri.php')
  Future<List<Nilai>> getDetailNilaiSantri(
    @Query('key') String key,
    @Query('id_kelas') String idKelas,
    @Query('id_mapel') String idMapel,
    @Query('nis') String nis,
    @Query('id_jenis_penilaian') String idJenisPenilaian,
  );

  @FormUrlEncoded()
  @POST('updatenilai.php')
  Future<Message> addNilai(
    @Field('key') String key,
    @Field('id_kelas') String idKelas,
    @Field('id_mapel') String idMapel,
    @Field('nilai') String nilai,
    @Field('date') String date,
    @Field('nis') String nis,
    @Field('note') String note,
    @Field('id_jenis_penilaian') String idJenisPenilaian,
  );
}
