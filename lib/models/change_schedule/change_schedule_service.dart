import 'package:dio/dio.dart';
import 'package:syathiby/models/change_schedule/change_schedule.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'change_schedule_service.g.dart';

@RestApi()
abstract class ChangeScheduleService {
  factory ChangeScheduleService(Dio dio, {String baseUrl}) =
      _ChangeScheduleService;

  @GET('attendance/listubahjadwaladmin.php')
  Future<List<ChangeSchedule>> getChangeSchedule(
    @Query('key') String key,
    @Query('page') int? page,
  );

  @GET('attendance/listubahjadwal.php')
  Future<List<ChangeSchedule>> getAllChangeSchedule(
    @Query('key') String key,
    @Query('status') String status,
    @Query('page') int? page,
  );

  @GET('attendance/detailubahjadwal.php')
  Future<List<ChangeSchedule>> getDetailChangeSchedule(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('attendance/confirmubahjadwal.php')
  Future<Message> approveChangeSchedule(
    @Query('key') String key,
    @Query('id_ubah_jadwal') String id,
    @Query('value') String data,
    @Query('alasan') String alasan,
  );

  @MultiPart()
  @POST('attendance/ubahjadwal.php')
  Future<Message> addChangeSchedule(
    @Part(name: 'key') String key,
    @Part(name: 'date') String date,
    @Part(name: 'staff') String staff,
    @Part(name: 'detail') String detail,
  );
}
