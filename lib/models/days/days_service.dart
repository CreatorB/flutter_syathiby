import 'package:dio/dio.dart';
import 'package:syathiby/models/days/days.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'days_service.g.dart';

@RestApi(baseUrl: 'schedule/')
abstract class DaysRestInterface {
  factory DaysRestInterface(Dio dio, {String baseUrl}) = _DaysRestInterface;

  @GET('list.php')
  Future<List<Days>> gets(@Query('key') String key);

  @POST('insert.php')
  @FormUrlEncoded()
  Future<Message> add(
    @Field('key') String key,
    @Field('name_addon') String nama,
    @Field('nominal') String nominal,
  );

  @POST('update.php')
  @FormUrlEncoded()
  Future<Message> update(
    @Field('key') String key,
    @Field('id') String id,
    @Field('name_addon') String nama,
    @Field('nominal') String nominal,
  );

  @GET('delete.php')
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );
}
