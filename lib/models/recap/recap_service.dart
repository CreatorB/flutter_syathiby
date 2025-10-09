import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/recap/recap.dart';
import 'package:retrofit/retrofit.dart';

part 'recap_service.g.dart';

@RestApi()
abstract class RecapRestInterface {
  factory RecapRestInterface(Dio dio, {String baseUrl}) = _RecapRestInterface;

  @GET('attendance/rekap.php')
  Future<List<Recap>> get(
    @Query('key') String key,
    @Query('awal') String awal,
    @Query('akhir') String akhir,
    @Query('grup') String grup,
  );

  @GET('permit/detail.php')
  Future<List<Recap>> getPermit(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('permit/detailsantri.php')
  Future<List<Recap>> getPermitSantri(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('permit/confirm.php')
  Future<Message> aprovePermit(
    @Query('key') String key,
    @Query('id_permit') String id,
    @Query('value') String data,
    @Query('alasan') String alasan,
  );

  @GET('permit/confirmsantri.php')
  Future<Message> aprovePermitSantri(
    @Query('key') String key,
    @Query('id_permit') String id,
    @Query('value') String data,
    @Query('alasan') String alasan,
  );

  @GET('permit/listsantri.php')
  Future<List<Recap>> getSantri(
    @Query('key') String key,
    @Query('page') int? page,
  );

  @GET('permit/type.php')
  Future<List<Recap>> type(
    @Query('key') String key,
    @Query('type') String type,
  );

  @POST('permit/insert.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'name_permit') String name,
    @Part(name: 'date') String date,
    @Part(name: 'day') String day,
    @Part(name: 'detail') String detail, {
    @Part(name: 'img') File? img,
  });

  @POST('permit/insertsantri.php')
  @MultiPart()
  Future<Message> addSantri(
    @Part(name: 'key') String key,
    @Part(name: 'id_izin') String idIzin,
    @Part(name: 'name_permit') String name,
    @Part(name: 'date') String date,
    @Part(name: 'day') String day,
    @Part(name: 'nis') String nis,
    @Part(name: 'id_kelas') String idKelas,
    @Part(name: 'detail') String detail,
  );
}
