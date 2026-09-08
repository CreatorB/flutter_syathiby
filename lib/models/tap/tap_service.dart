import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'tap_service.g.dart';

@RestApi(baseUrl: 'tap/')
abstract class TapRestInterface {
  factory TapRestInterface(Dio dio, {String baseUrl}) = _TapRestInterface;

  @POST('insert_izin_tap.php')
  @MultiPart()
  Future<Message> addTapIzin(
    @Part(name: 'key') String key,
    @Part(name: 'name_permit') String name,
    @Part(name: 'date') String date,
    @Part(name: 'end_date') String endDate,
    @Part(name: 'jam_izin_from') String jamIzinFrom,
    @Part(name: 'jam_izin_until') String jamIzinUntil,
    @Part(name: 'detail') String detail,
    @Part(name: 'student_ids') String studentIds, {
    // Opsional. Dikirim sejak 7 Sep 2026 supaya backend bisa memberlakukan
    // batas `permit_type.max_hari` -- dulu batas itu hanya dicek di jalur
    // "Ajukan Izin" (permit/insertsantri.php), sehingga jalur tap bisa
    // menembus kebijakan pondok.
    @Part(name: 'id_izin') String? idIzin,
  });
}
