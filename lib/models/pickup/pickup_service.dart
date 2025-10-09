import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/pickup/pickup.dart';
import 'package:retrofit/retrofit.dart';

part 'pickup_service.g.dart';

@RestApi(baseUrl: 'penjemputan/')
abstract class PenjemputanRestInterface {
  factory PenjemputanRestInterface(Dio dio, {String baseUrl}) =
      _PenjemputanRestInterface;

  @GET('listsiswa.php')
  Future<List<Penjemputan>> gets(
    @Query('key') String key,
    @Query('id') String id,
    @Query('id_kelas') String idKelas,
    @Query('type') String type,
    @Query('page') int? page,
  );

  @GET('listsiswanegative.php')
  Future<List<Penjemputan>> getsNegative(
    @Query('key') String key,
    @Query('id') String id,
    @Query('id_kelas') String idKelas,
    @Query('type') String type,
    @Query('page') int? page,
  );

  @GET('datasiswa.php')
  Future<List<Penjemputan>> getsdata(
    @Query('key') String key,
    @Query('id') String id,
    @Query('id_event') String idEvent,
  );

  @GET('startdrive.php')
  Future<List<Penjemputan>> startDrive(
    @Query('key') String key,
    @Query('id') String id,
    @Query('latitude') String latitude,
    @Query('longitude') String longitude,
  );

  @GET('finishdrive.php')
  Future<List<Penjemputan>> finishDrive(
    @Query('key') String key,
    @Query('id') String id,
    @Query('latitude') String latitude,
    @Query('longitude') String longitude,
  );

  @POST('insert.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'code') String code,
    @Part(name: 'latitude') String latitude,
    @Part(name: 'longitude') String longitude,
  );

  @POST('prosesjemput.php')
  @MultiPart()
  Future<Message> getJemput(
    @Part(name: 'key') String key,
    @Part(name: 'nis') String nis,
    @Part(name: 'id_event') String idEvent,
    @Part(name: 'id_kelas') String idKelas,
    @Part(name: 'value') String data,
  );

  @POST('prosespengembalian.php')
  @MultiPart()
  Future<Message> getPengembalian(
    @Part(name: 'key') String key,
    @Part(name: 'nis') String nis,
    @Part(name: 'id_event') String idEvent,
    @Part(name: 'id_kelas') String idKelas,
    @Part(name: 'value') String data,
  );

  @GET('getsiswa.php')
  Future<List<Penjemputan>> searchByBarcode(
    @Query('key') String key,
    @Query('code') String id,
    @Query('id_event') String idEvent,
  );
}
