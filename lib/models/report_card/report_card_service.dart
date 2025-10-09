import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../message.dart';

part 'report_card_service.g.dart';

@RestApi(baseUrl: 'siswa/')
abstract class ReportCardRestInterface {
  factory ReportCardRestInterface(Dio dio, {String baseUrl}) =
      _ReportCardRestInterface;

  @FormUrlEncoded()
  @POST('updaterapor.php')
  Future<Message> updateReport(
    @Field('key') String key,
    @Field('id_kelas') String classId,
    @Field('rangking') String rankNumber,
    @Field('keterangan') String description,
    @Field('nis') String studentId,
  );
}
