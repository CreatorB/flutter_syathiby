import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/fasting/fasting.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'fasting_service.g.dart';

@RestApi(baseUrl: 'puasa/')
abstract class PuasaService {
  factory PuasaService(Dio dio, {String baseUrl}) = _PuasaService;

  @GET('list.php')
  Future<List<Puasa>> getPuasa(
    @Query('key') String key,
    @Query('page') int? page,
  );

  @GET('listsantripuasa.php')
  Future<List<Puasa>> getListPuasa(
    @Query('key') String key,
    @Query('awal') String awal,
    @Query('akhir') String akhir,
  );

  @GET('datapuasa.php')
  Future<List<Puasa>> getLaporanListPuasa(
    @Query('key') String key,
    @Query('awal') String awal,
    @Query('akhir') String akhir,
  );

  @GET('listtahfidz.php')
  Future<List<Puasa>> getTahfidzdate(
    @Query('key') String key,
    @Query('awal') String awal,
    @Query('akhir') String akhir,
  );

  @GET('listabsensi.php')
  Future<List<Puasa>> getAbsensidate(
    @Query('key') String key,
    @Query('awal') String awal,
    @Query('akhir') String akhir,
  );

  @GET('detail.php')
  Future<List<Puasa>> getTahfidz(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('detailsantri.php')
  Future<List<Puasa>> getTahfidzSantri(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('detailpenilaiansantri.php')
  Future<List<Puasa>> getTahfidzPenilianSantri(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('confirm.php')
  Future<Message> aproveTahfidz(
    @Query('key') String key,
    @Query('id_permit') String id,
    @Query('value') String data,
    @Query('alasan') String alasan,
  );

  @GET('listhafalan.php')
  Future<List<Puasa>> getSantri(
    @Query('key') String key,
    @Query('page') int? page,
  );

  @GET('jenis.php')
  Future<List<Puasa>> jenis(
    @Query('key') String key,
  );

  @GET('type.php')
  Future<List<Puasa>> type(
    @Query('key') String key,
    @Query('type') String type,
  );

  @GET('datenow.php')
  Future<List<Puasa>> tahfidzNow(
    @Query('key') String key,
  );

  @GET('jenispuasa.php')
  Future<List<Puasa>> jenisPuasa(
    @Query('key') String key,
  );

  @POST('insert.php')
  Future<Message> add(
    @Field('key') String key,
    @Field('name_permit') String name,
    @Field('date') String date,
    @Field('day') String day,
    @Field('detail') String detail, {
    @Part(name: 'img') File? img,
  });

  @POST('insertsantri.php')
  Future<Message> addSantri(
    @Field('key') String key,
    @Field('id_jenis') String idJenis,
    @Field('waktu_hafalan') String waktuHafalan,
    @Field('halaman') String halaman,
    @Field('halaman_end') String halamanEnd,
    @Field('nis') String nis,
    @Field('id_kelas') String idKelas,
    @Field('detail') String detail,
  );

  @MultiPart()
  @POST('insert.php')
  Future<Message> addPuasa(
    @Part(name: 'key') String key,
    @Part(name: 'id_jenis') String idJenis,
    @Part(name: 'nis') String nis,
    @Part(name: 'id_kelas') String idKelas,
    @Part(name: 'id_asrama') String idAsrama,
    @Part(name: 'date') String date, {
    @Part(name: 'img') File? image,
  });

  @GET('absensisantri.php')
  Future<Message> searchByBarcode(
    @Query('key') String key,
    @Query('search') String search,
    @Query('id') String id,
  );
}
