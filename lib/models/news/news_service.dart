import 'package:dio/dio.dart';
import 'package:syathiby/models/news/news.dart';
import 'package:retrofit/retrofit.dart';

part 'news_service.g.dart';

@RestApi()
abstract class NewsRestInterface {
  factory NewsRestInterface(Dio dio, {String baseUrl}) = _NewsRestInterface;

  @GET('news/list.php')
  Future<List<News>> getNews(@Query('key') String key);

  @GET('news/tv.php')
  Future<List<News>> getAcaraTv(@Query('key') String key);
}
