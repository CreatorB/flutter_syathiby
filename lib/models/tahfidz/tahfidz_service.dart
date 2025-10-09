import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/tahfidz/tahfidz.dart';
import 'package:retrofit/retrofit.dart';

part 'tahfidz_service.g.dart';

@RestApi(baseUrl: 'tahfidz/')
abstract class TahfidzRestInterface {
  factory TahfidzRestInterface(Dio dio, {String baseUrl}) =
      _TahfidzRestInterface;

  @GET("list.php")
  Future<List<Tahfidz>> get(
    @Query("key") String key,
    @Query("page") int? page,
  );

  @GET("listpenilaiantahfidz.php")
  Future<List<Tahfidz>> getTahfidzPenilaian(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
  );

  @GET("listpenilaiankepengasuhan.php")
  Future<List<Tahfidz>> getKepengasuhanPenilaian(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
  );

  @GET("deletepenilaiantahfidz.php")
  Future<List<Tahfidz>> getPenilaianTahfidzDelete(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
    @Query("id") String id,
  );

  @GET("deletepenilaiankepengasuhan.php")
  Future<Message> getPenilaianKepengasuhanDelete(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
    @Query("id") String id,
  );

  @GET("listtahfidz.php")
  Future<List<Tahfidz>> getTahfidzdate(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
  );

  @GET("deletelisttahfidz.php")
  Future<List<Tahfidz>> getRekapTahfidzDelete(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
    @Query("id") String id,
  );

  @GET("listabsensi.php")
  Future<List<Tahfidz>> getAbsensidate(
    @Query("key") String key,
    @Query("awal") String awal,
    @Query("akhir") String akhir,
  );

  @GET("detail.php")
  Future<List<Tahfidz>> getTahfidz(
    @Query("key") String key,
    @Query("id") String id,
  );

  @GET("detailsantri.php")
  Future<List<Tahfidz>> getTahfidzSantri(
    @Query("key") String key,
    @Query("id") String id,
  );

  @GET("detailpenilaiansantri.php")
  Future<List<Tahfidz>> getTahfidzPenilianSantri(
    @Query("key") String key,
    @Query("id") String id,
  );

  @GET("detailpenilaiankepengasuhan.php")
  Future<List<Tahfidz>> getKepengasuhanPenilianSantri(
    @Query("key") String key,
    @Query("id") String id,
  );

  @GET("confirm.php")
  Future<Message> aproveTahfidz(
    @Query("key") String key,
    @Query("id_permit") String id,
    @Query("value") String data,
    @Query("alasan") String alasan,
  );

  @GET("confirmsantri.php")
  Future<Message> aproveTahfidzSantri(
    @Query("key") String key,
    @Query("id_permit") String id,
    @Query("value") String data,
    @Query("alasan") String alasan,
  );

  @GET("listhafalan.php")
  Future<List<Tahfidz>> getSantri(
    @Query("key") String key,
    @Query("page") int? page,
  );

  @GET("jenis.php")
  Future<List<Tahfidz>> jenis(
    @Query("key") String key,
  );

  @GET("type.php")
  Future<List<Tahfidz>> type(
    @Query("key") String key,
    @Query("type") String type,
  );

  @GET("kegiatan.php")
  Future<List<Tahfidz>> kegiatan(
    @Query("key") String key,
  );

  @GET("datenow.php")
  Future<List<Tahfidz>> tahfidzNow(
    @Query("key") String key,
  );

  @GET("typepenilaian.php")
  Future<List<Tahfidz>> typeNilai(
    @Query("key") String key,
    @Query("type") String type,
  );

  @GET("typepenilaiankepengasuhan.php")
  Future<List<Tahfidz>> typePenilaian(
    @Query("key") String key,
    @Query("type") String type,
  );

  @POST("insert.php")
  @MultiPart()
  Future<Message> add(
    @Part(name: "key") String key,
    @Part(name: "name_permit") String name,
    @Part(name: "date") String date,
    @Part(name: "day") String day,
    @Part(name: "detail") String detail, {
    @Part(name: "img") File? img,
  });

  @POST("insertsantri.php")
  @MultiPart()
  Future<Message> addSantri(
    @Part(name: "key") String key,
    @Part(name: "id_jenis") String idJenis,
    @Part(name: "waktu_hafalan") String? waktuHafalan,
    @Part(name: "halaman") String halaman,
    @Part(name: "halaman_end") String halamanEnd,
    @Part(name: "nis") String nis,
    @Part(name: "id_kelas") String idKelas,
    @Part(name: "detail") String? detail,
    @Part(name: "jumlah") String jumlah,
  );

  @POST("editsantri.php")
  @MultiPart()
  Future<Message> editSantri(
    @Part(name: "key") String key,
    @Part(name: "id") String id,
    @Part(name: "id_jenis") String idJenis,
    @Part(name: "waktu_hafalan") String? waktuHafalan,
    @Part(name: "halaman") String halaman,
    @Part(name: "halaman_end") String halamanEnd,
    @Part(name: "detail") String? detail,
    @Part(name: "jumlah") String jumlah,
  );

  @POST("insertpenilaiansantri.php")
  @MultiPart()
  Future<Message> addPenilaianSantri(
    @Part(name: "key") String key,
    @Part(name: "id_jenis") String idJenis,
    @Part(name: "nilai") String nilai,
    @Part(name: "nis") String nis,
    @Part(name: "id_kelas") String idKelas,
    @Part(name: "detail") String? detail,
  );

  @POST("insertpenilaiankepengasuhan.php")
  @MultiPart()
  Future<Message> addPenilaianKepengasuhan(
    @Part(name: "key") String key,
    @Part(name: "id_jenis") String idJenis,
    @Part(name: "nilai") String nilai,
    @Part(name: "nis") String nis,
    @Part(name: "id_kelas") String idKelas,
    @Part(name: "detail") String? detail,
  );

  @POST("editpenilaiansantri.php")
  @MultiPart()
  Future<Message> editPenilaianSantri(
    @Part(name: "key") String key,
    @Part(name: "id") String id,
    @Part(name: "id_jenis") String idJenis,
    @Part(name: "nilai") String nilai,
    @Part(name: "detail") String? detail,
  );

  @POST("editpenilaiankepengasuhan.php")
  @MultiPart()
  Future<Message> editPenilaianKepengasuhan(
    @Part(name: "key") String key,
    @Part(name: "id") String id,
    @Part(name: "id_jenis") String idJenis,
    @Part(name: "nilai") String nilai,
    @Part(name: "detail") String? detail,
  );

  @GET("absensisantri.php")
  Future<Message> searchByBarcode(
    @Query("key") String key,
    @Query("search") String search,
    @Query("id") String id,
  );
}
