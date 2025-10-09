import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/meeting/meeting.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'meeting_service.g.dart';

@RestApi(baseUrl: 'meeting/')
abstract class RapatRestInterface {
  factory RapatRestInterface(Dio dio, {String baseUrl}) = _RapatRestInterface;

  @GET('list.php')
  Future<List<Rapat>> gets(@Query('key') String key);

  @GET('detail.php')
  Future<List<Rapat>> detail(@Query('key') String key, @Query('id') String id);

  @FormUrlEncoded()
  @POST('presensi.php')
  Future<Message> presensi(
      @Field('key') String key,
      @Field('id_meeting') String idMeeting,
      @Field('lokasi') String lokasi,
      @Field('palsu') String meetingFor);

  @FormUrlEncoded()
  @POST('komentar.php')
  Future<Message> komentar(
    @Field('key') String key,
    @Field('id_meeting') String idMeeting,
    @Field('text') String text,
  );

  @POST('uploadphoto.php')
  @MultiPart()
  Future<Message> uploadFoto(
    @Part(name: 'key') String key,
    @Part(name: 'id_meeting') String idMeeting, {
    @Part(name: 'img') File? img,
  });

  @FormUrlEncoded()
  @POST('insertnotulen.php')
  Future<Message> notulen(
    @Field('key') String key,
    @Field('id_meeting') String idMeeting,
    @Field('text') String text,
  );

  @FormUrlEncoded()
  @POST('updatenotulen.php')
  Future<Message> updateNotulen(
    @Field('key') String key,
    @Field('id_meeting') String idMeeting,
    @Field('text') String text,
  );

  @FormUrlEncoded()
  @POST('addpeserta.php')
  Future<Message> addPeserta(
      @Field('key') String key,
      @Field('id_meeting') String idMeeting,
      @Field('phone_number') String phoneNumber);

  @GET('peserta.php')
  Future<List<Rapat>> peserta(@Query('key') String key, @Query('id') String id);

  @GET('hasil.php')
  Future<List<Rapat>> hasil(@Query('key') String key, @Query('id') String id);

  @GET('photomeeting.php')
  Future<List<Rapat>> photo(@Query('key') String key, @Query('id') String id);

  @GET('hapuspeserta.php')
  Future<Message> hapusPeserta(@Query('key') String key, @Query('id') String id,
      @Query('phone_number') String phoneNumber);

  @GET('absenpeserta.php')
  Future<Message> absenPeserta(
      @Query('key') String key,
      @Query('id') String id,
      @Query('phone_number') String phoneNumber,
      @Query('status') String status);

  @GET('listdivisi.php')
  Future<List<Rapat>> getDivisi(@Query('key') String key);

  @FormUrlEncoded()
  @POST('insert.php')
  Future<Message> add(
    @Field('key') String key,
    @Field('name_meeting') String nameMeeting,
    @Field('deskripsi') String deskripsi,
    @Field('meeting_for') String meetingFor,
    @Field('date') String date,
    @Field('hour_start') String hourStart,
    @Field('finish') String finish,
    @Field('lokasi') String lokasi,
  );

  @FormUrlEncoded()
  @POST('update.php')
  Future<Message> update(
      @Field('key') String key,
      @Field('id') String id,
      @Field('name_meeting') String nameMeeting,
      @Field('deskripsi') String deskripsi,
      @Field('meeting_for') String meetingFor,
      @Field('date') String date,
      @Field('hour_start') String hourStart);

  @GET('delete.php')
  Future<Message> delete(@Query('key') String key, @Query('id') String id);

  @GET('deletenotulen.php')
  Future<Message> deleteNotulen(
    @Query('key') String key,
    @Query('id') String id,
  );
}
