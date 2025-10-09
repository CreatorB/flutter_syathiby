import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/staff/kinerja.dart';
import 'package:syathiby/models/staff/staff.dart';
import 'package:retrofit/retrofit.dart';

import '../slip/absent.dart';

part 'staff_service.g.dart';

@RestApi()
abstract class StaffRestInterface {
  factory StaffRestInterface(Dio dio, {String baseUrl}) = _StaffRestInterface;

  @GET('settings/datastaff.php')
  Future<List<Staff>> getStaff(@Query('key') String key);

  @GET('settings/detailstaff.php')
  Future<List<Kinerja>> detailStaff(
    @Query('key') String key,
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @GET('settings/detailkinerja.php')
  Future<List<Kinerja>> detailKinerja(@Query('key') String key);

  @GET('settings/datastaffpos.php')
  Future<List<Staff>> getspos(@Query('key') String key);

  @GET('chat/membergrup.php')
  Future<List<Staff>> getsMember(
    @Query('key') String key,
    @Query('position') String position,
  );

  @GET('attendance/datastaff.php')
  Future<List<Absent>> getAttandance(@Query('key') String key);

  @GET('attendance/datavisiting.php')
  Future<List<Absent>> getAttandanceVisiting(@Query('key') String key);

  @GET('attendance/otherabsence.php')
  Future<List<Absent>> getAttandanceOther(@Query('key') String key,
      @Query('awal') String awal, @Query('akhir') String akhir);

  @GET('attendance/laporanaktivitas.php')
  Future<List<Absent>> getLaporanAktivitas(
      @Query('key') String key,
      @Query('awal') String awal,
      @Query('akhir') String akhir,
      @Query('type') String type);

  @GET('overtime/overtime.php')
  Future<List<Absent>> getOvertime(@Query('key') String key);

  @GET('chat/datachat.php')
  Future<List<Staff>> getsChat(@Query('key') String key);

  @GET('chat/datagrup.php')
  Future<List<Staff>> getsGrup(@Query('key') String key);

  @GET('settings/datastaff.php')
  Future<List<Staff>> getKurir(@Query('key') String key);

  @GET('settings/deletestaff.php')
  Future<Message> delete(
      @Query('key') String key, @Query('phone_number') String id);

  @GET('attendance/finish.php')
  Future<Message> finish(
      @Query('key') String key, @Query('phone_number') String id);

  @GET('attendance/finishvisiting.php')
  Future<Message> finishVisiting(
      @Query('key') String key, @Query('id') String id);

  @GET('attendance/finishabsenlain.php')
  Future<Message> finishAbsen(@Query('key') String key, @Query('id') String id);

  @GET('overtime/finish.php')
  Future<Message> finishOvertime(
      @Query('key') String key, @Query('phone_number') String id);

  @GET('settings/searchstaff.php')
  Future<List<Staff>> search(
      @Query('key') String key, @Query('search') String id);

  @POST('settings/addstaff.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'full_name') String nama,
    @Part(name: 'email') String email,
    @Part(name: 'phone_number') String telpon,
    @Part(name: 'address') String alamat,
    @Part(name: 'salary_fixed') String gaji,
    @Part(name: 'gajilembur') String gajilembur,
    @Part(name: 'commission') String komisi,
    @Part(name: 'allowance') String tunjangan,
    @Part(name: 'piece') String potongan,
    @Part(name: 'id_store') String toko,
    @Part(name: 'level') String level,
    @Part(name: 'pay_per') String type,
    @Part(name: 'position') String position, {
    @Part(name: 'img') File? img,
  });

  @POST('settings/updatestaff.php')
  @MultiPart()
  Future<Message> update(
    @Part(name: 'key') String key,
    @Part(name: 'id') String id,
    @Part(name: 'full_name') String nama,
    @Part(name: 'email') String email,
    @Part(name: 'phone_number') String telpon,
    @Part(name: 'address') String alamat,
    @Part(name: 'salary_fixed') String gaji,
    @Part(name: 'gajilembur') String gajilembur,
    @Part(name: 'commission') String komisi,
    @Part(name: 'allowance') String tunjangan,
    @Part(name: 'piece') String potongan,
    @Part(name: 'id_store') String toko,
    @Part(name: 'level') String level,
    @Part(name: 'pay_per') String type,
    @Part(name: 'position') String position, {
    @Part(name: 'img') File? img,
  });

  @GET('chat/searchchat.php')
  Future<List<Staff>> searchChat(
      @Query('key') String key, @Query('search') String id);

  @GET('chat/scanuser.php')
  Future<List<Staff>> scanUser(
      @Query('key') String key, @Query('scan') String scan);
}
