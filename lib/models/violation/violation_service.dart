import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/violation/violation.dart';
import 'package:retrofit/retrofit.dart';

part 'violation_service.g.dart';

@RestApi(baseUrl: 'pelanggaran/')
abstract class PelanggaranRestInterface {
  factory PelanggaranRestInterface(Dio dio, {String baseUrl}) =
      _PelanggaranRestInterface;

  @GET('list.php')
  Future<List<Pelanggaran>> get(
    @Query('key') String key,
    @Query('type') String type,
    @Query('page') int? page,
  );

  @GET('detailsantri.php')
  Future<List<Pelanggaran>> getLaporanSantri(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('confirm.php')
  Future<Message> aproveLaporanSantri(
    @Query('key') String key,
    @Query('id_pelanggaran') String id,
    @Query('value') String message,
    @Query('alasan') String alasan,
  );

  @GET('updatedate.php')
  Future<Message> updateDatePelanggaran(
    @Query('key') String key,
    @Query('id_pelanggaran') String id,
    @Query('date') String date,
  );

  @GET('rewardlist.php')
  Future<List<Pelanggaran>> getReward(
    @Query('key') String key,
  );

  @GET('type.php')
  Future<List<Pelanggaran>> type(
    @Query('key') String key,
    @Query('type') String type,
  );

  @GET('typereward.php')
  Future<List<Pelanggaran>> typeReward(
    @Query('key') String key,
  );

  @POST('insert.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'nama_pelanggaran') String namaPelanggaran,
    @Part(name: 'date') String date,
    @Part(name: 'hour') String hour,
    @Part(name: 'location') String location,
    @Part(name: 'nama_siswa') String namaSiswa,
    @Part(name: 'detail') String detail,
    @Part(name: 'type') String type, {
    @Part(name: 'img') File? img,
  });

  @POST('insertreward.php')
  @MultiPart()
  Future<Message> addReward(
    @Part(name: 'key') String key,
    @Part(name: 'nama_reward') String namaReward,
    @Part(name: 'date') String date,
    @Part(name: 'hour') String hour,
    @Part(name: 'location') String location,
    @Part(name: 'nama_siswa') String namaSiswa,
    @Part(name: 'detail') String detail, {
    @Part(name: 'img') File? img,
  });
}
