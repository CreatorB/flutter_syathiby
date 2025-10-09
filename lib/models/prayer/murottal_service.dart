import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'murottal_service.g.dart';

@RestApi(
  baseUrl: 'https://github.com/rabbaaniiislamicschool/public-api/raw/main/',
)
abstract class MurottalService {
  factory MurottalService(Dio dio, {String baseUrl}) = _MurottalService;

  @GET('murottal.json')
  Future<String> getMurottalAudio();
}
