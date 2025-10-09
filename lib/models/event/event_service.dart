import 'package:dio/dio.dart';
import 'package:syathiby/models/event/event.dart';
import 'package:retrofit/retrofit.dart';

part 'event_service.g.dart';

@RestApi(baseUrl: 'event/')
abstract class EventRestInterface {
  factory EventRestInterface(Dio dio, {String baseUrl}) = _EventRestInterface;

  @GET('list.php')
  Future<List<Event>> gets(@Query('key') String key, @Query('page') int? page);

  @GET('listactivity.php')
  Future<List<Event>> getListActivity(@Query('key') String key);

  @GET('namaaktivitas.php')
  Future<List<Event>> getsAktivitas(
      @Query('key') String key, @Query('type') String type);

  @GET('searchnamaaktivitas.php')
  Future<List<Event>> searchJob(@Query('key') String key,
      @Query('type') String type, @Query('search') String search);

  @GET('detail.php')
  Future<List<Event>> getEvent(
      @Query('key') String key, @Query('id') String id);
}
