import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/job/job.dart';
import 'package:syathiby/models/job/job_detail.dart';
import 'package:syathiby/models/job/request_visiting.dart';
import 'package:syathiby/models/job/visiting.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'job_service.g.dart';

@RestApi()
abstract class JobRestInterface {
  factory JobRestInterface(Dio dio, {String baseUrl}) = _JobRestInterface;

  @GET('job/list.php')
  Future<List<Job>> gets(
    @Query('key') String key,
    @Query('status') String status,
  );

  @GET('job/tugaspengabdian.php')
  Future<List<Job>> getTugas(
    @Query('key') String key,
  );

  @POST('job/updatetugas.php')
  @FormUrlEncoded()
  Future<Message> getSendTugas(
    @Field('key') String key,
    @Field('id_tugas') String idTugas,
  );

  @GET('job/listall.php')
  Future<List<Job>> get(
    @Query('key') String key,
  );

  @GET('job/detail.php')
  Future<DetailsJob> getDetailJob(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('pengadaan/timeline.php')
  Future<DetailsJob> getDetailPengadaan(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('permintaan/timeline.php')
  Future<DetailsJob> getDetailPermintaanObat(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('job/proccessjob.php')
  Future<Message> proccesDetailJob(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @GET('job/finishjob.php')
  Future<Message> finishDetailJob(
    @Query('key') String key,
    @Query('no_invoice') String id,
  );

  @POST('job/comment.php')
  @FormUrlEncoded()
  Future<Message> comment(
    @Field('key') String key,
    @Field('id') String id,
    @Field('value') String data,
  );

  @POST('job/insert.php')
  @FormUrlEncoded()
  Future<Message> add(
    @Field('key') String key,
    @Field('note') String note,
    @Field('detail') String detail,
    @Field('operator') String operator,
  );

  @POST('job/insertjob.php')
  @FormUrlEncoded()
  Future<List<Job>> addJob(
    @Field('key') String key,
    @Field('note') String note,
    @Field('detail') String detail,
    @Field('operator') String operator,
  );

  @POST('attendance/manual.php')
  @FormUrlEncoded()
  Future<Message> addAbsence(
    @Field('key') String key,
    @Field('date') String date,
    @Field('hour') String hour,
    @Field('status') String status,
    @Field('operator') String operator,
  );

  @POST('attendance/visiting.php')
  @MultiPart()
  Future<Visiting> addVisiting(
    @Part(name: 'data') RequestVisiting requestVisiting, {
    @Part(name: 'img') File? img,
  });

  @POST('overtime/insert.php')
  @FormUrlEncoded()
  Future<Message> addOvertime(
    @Field('key') String key,
    @Field('date') String date,
    @Field('hour') String hour,
    @Field('jam') String jam,
    @Field('id_event') String idEvent,
    @Field('operator') String operator,
  );

  @POST('attendance/absenlainnya.php')
  @FormUrlEncoded()
  Future<Message> addActivity(
    @Field('key') String key,
    @Field('detail') String detail,
    @Field('id_event') String idEvent,
  );

  @POST('event/insertlaporanaktivitas.php')
  @MultiPart()
  Future<Message> addLaporanAktivitas(
    @Part(name: 'key') String key,
    @Part(name: 'detail') String detail,
    @Part(name: 'nama_aktivitas') String namaAktivitas,
    @Part(name: 'type') String type, {
    @Part(name: 'img') File? img,
  });

  @POST('job/update.php')
  @FormUrlEncoded()
  Future<Message> update(
    @Field('key') String key,
    @Field('id') String id,
    @Field('note') String note,
    @Field('detail') String detail,
    @Field('operator') String operator,
  );

  @GET('job/delete.php')
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('job/search.php')
  Future<List<Job>> search(
    @Query('key') String key,
    @Query('search') String search,
  );
}
