import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/store/point.dart';
import 'package:syathiby/models/store/store.dart';
import 'package:retrofit/retrofit.dart';

part 'store_service.g.dart';

@RestApi(baseUrl: 'settings/')
abstract class StoreRestInterface {
  factory StoreRestInterface(Dio dio, {String baseUrl}) = _StoreRestInterface;

  @GET('detailstore.php')
  Future<List<Store>> getStore(@Query('key') String key);

  @GET('datachat.php')
  Future<List<Store>> getChat(@Query('key') String key);

  @GET('location.php')
  Future<List<Point>> getLocation(
    @Query('key') String key,
    @Query('location') String location,
    @Query('latitude') String latitude,
    @Query('longitude') String longitude,
  );

  @POST('updatestore.php')
  @MultiPart()
  Future<Message> updateStore(
    @Part(name: 'key') String key,
    @Part(name: 'id') String id,
    @Part(name: 'name_store') String nama,
    @Part(name: 'email') String email,
    @Part(name: 'nohp') String hp,
    @Part(name: 'address') String alamat, {
    @Part(name: 'img') File? img,
  });

  @GET('liststore.php')
  Future<List<Store>> gets(@Query('key') String key);

  @GET('datagrup.php')
  Future<List<Store>> getsGrup(@Query('key') String key);

  @GET('deletestore.php')
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );

  @POST('addstore.php')
  @FormUrlEncoded()
  Future<Message> add(
    @Field('key') String key,
    @Field('name_store') String nama,
    @Field('email') String email,
    @Field('nohp') String hp,
    @Field('address') String alamat,
  );
}
