import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/place/inventaris.dart';
import 'package:syathiby/models/place/tempat.dart';
import 'package:retrofit/retrofit.dart';

part 'place_service.g.dart';

@RestApi(baseUrl: 'sarpras/')
abstract class TempatRestInterface {
  factory TempatRestInterface(Dio dio, {String baseUrl}) = _TempatRestInterface;

  @GET('list.php')
  Future<List<Tempat>> get(@Query('key') String key);

  @GET('inventaris.php')
  Future<List<Inventaris>> getInventaris(
    @Query('key') String key,
    @Query('id_tempat') String idTempat,
  );

  @POST('updateinventaris.php')
  @FormUrlEncoded()
  Future<Message> getUpdateInventaris(
    @Field('key') String key,
    @Field('id_inventaris') String idInventaris,
    @Field('status') String status,
  );

  @POST('addtempat.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'name') String name,
  );

  @POST('updatetempat.php')
  @MultiPart()
  Future<Message> update(
    @Part(name: 'key') String key,
    @Part(name: 'id') String id,
    @Part(name: 'name') String name,
  );

  @POST('updateinventaris.php')
  @MultiPart()
  Future<Message> updateInventaris(
    @Part(name: 'key') String key,
    @Part(name: 'id') String id,
    @Part(name: 'name') String name,
    @Part(name: 'unit') String unit,
    @Part(name: 'code') String code,
    @Part(name: 'baik') String baik,
    @Part(name: 'cukupbaik') String cukupbaik,
    @Part(name: 'rusak') String rusak, {
    @Part(name: 'img') File? img,
  });

  @POST('addinventaris.php')
  @MultiPart()
  Future<Message> addInventaris(
    @Part(name: 'key') String key,
    @Part(name: 'id_tempat') String idTempat,
    @Part(name: 'name') String name,
    @Part(name: 'unit') String unit,
    @Part(name: 'code') String code,
    @Part(name: 'baik') String baik,
    @Part(name: 'cukupbaik') String cukupbaik,
    @Part(name: 'rusak') String rusak, {
    @Part(name: 'img') File? img,
  });

  @GET('listkelas.php')
  Future<List<Tempat>> getKelas(
    @Query('key') String key,
    @Query('id') String id,
    @Query('id_jenis_asrama') String idJenisAsrama,
  );

  @GET('tempat.php')
  Future<List<Tempat>> getGedung(
    @Query('key') String key,
    @Query('id') String id,
  );
}
