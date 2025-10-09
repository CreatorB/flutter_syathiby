import 'package:dio/dio.dart';
import 'package:syathiby/models/rpp/rpp.dart';
import 'package:retrofit/retrofit.dart';

part 'rpp_service.g.dart';

@RestApi(baseUrl: 'rpp/')
abstract class RppRestInterface {
  factory RppRestInterface(Dio dio, {String baseUrl}) = _RppRestInterface;

  @GET('list.php')
  Future<List<Rpp>> getRpp(@Query('key') String key);
}
