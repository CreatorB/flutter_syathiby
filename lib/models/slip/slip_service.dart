import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/slip/absent.dart';
import 'package:syathiby/models/slip/report.dart';
import 'package:syathiby/models/slip/slip.dart';
import 'package:retrofit/retrofit.dart';

part 'slip_service.g.dart';

@RestApi()
abstract class SlipRestInterface {
  factory SlipRestInterface(Dio dio, {String baseUrl}) = _SlipRestInterface;

  @GET('report/salary_slip.php')
  Future<List<Slip>> getPaySlip(
    @Query('key') String key,
    @Query('start_date') String awal,
    @Query('finish_date') String akhir,
  );

  @GET('report/report.php')
  Future<List<Report>> getPayReport(
    @Query('key') String key,
    @Query('start_date') String awal,
    @Query('finish_date') String akhir,
  );

  @GET('attendance/listrekap.php')
  Future<List<Absent>> getRekapAbsent(
    @Query('key') String key,
    @Query('start_date') String awal,
    @Query('finish_date') String akhir,
    @Query('status') String status,
    @Query('grup') String grup,
  );

  @GET('attendance/notpresent.php')
  Future<List<Absent>> getRekapNoAbsent(
    @Query('key') String key,
    @Query('start_date') String awal,
    @Query('finish_date') String akhir,
    @Query('type') String type,
    @Query('grup') String grup,
  );

  @GET('attendance/detail.php')
  Future<List<Absent>> getAbsent(
    @Query('key') String key,
    @Query('start_date') String awal,
    @Query('finish_date') String akhir,
  );

  @GET('attendance/tracking.php')
  Future<List<Absent>> getTracking(@Query('key') String key);

  @GET('attendance/reject.php')
  Future<Message> rejectJob(
    @Query('key') String key,
    @Query('id') String id,
  );
}
