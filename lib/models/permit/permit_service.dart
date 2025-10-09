import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/permit/permit.dart';
import 'package:retrofit/retrofit.dart';

part 'permit_service.g.dart';

@RestApi(baseUrl: 'permit/')
abstract class PermitRestInterface {
  factory PermitRestInterface(Dio dio, {String baseUrl}) = _PermitRestInterface;

  @GET('list.php')
  Future<List<Permit>> get(
    @Query('key') String key,
    @Query('page') int page,
  );

  @GET('listpermit.php')
  Future<List<Permit>> getPermitdate(
    @Query('key') String key,
    @Query('awal') String awal,
    @Query('akhir') String akhir,
    @Query('page') int? page,
    @Query('grup') String grup,
  );

  @GET('detail.php')
  Future<List<Permit>> getPermit(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('detailsantri.php')
  Future<List<Permit>> getPermitSantri(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('confirm.php')
  Future<Message> aprovePermit(
    @Query('key') String key,
    @Query('id_permit') String id,
    @Query('value') String data,
    @Query('alasan') String alasan,
  );

  @GET('confirmsantri.php')
  Future<Message> aprovePermitSantri(
    @Query('key') String key,
    @Query('id_permit') String id,
    @Query('value') String data,
    @Query('alasan') String alasan,
  );

  @GET('listsantri.php')
  Future<List<Permit>> getSantri(
    @Query('key') String key,
    @Query('page') int? page,
  );

  @GET('type.php')
  Future<List<Permit>> type(
    @Query('key') String key,
    @Query('type') String type,
  );

  @POST('insert.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'name_permit') String permitName,
    @Part(name: 'date') String date,
    @Part(name: 'day') String day,
    @Part(name: 'detail') String detail, {
    @Part(name: 'img') File? img,
  });

  @POST('insertsantri.php')
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
