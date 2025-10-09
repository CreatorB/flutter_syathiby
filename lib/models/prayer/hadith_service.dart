import 'package:dio/dio.dart';
import 'package:syathiby/models/prayer/hadith/book_nawawi_response.dart';
import 'package:syathiby/models/prayer/hadith/hadith_detail_response.dart';
import 'package:retrofit/retrofit.dart';

import 'hadith/book_response.dart';
import 'hadith/hadith_response.dart';

part 'hadith_service.g.dart';

@RestApi()
abstract class HadithService {
  factory HadithService(Dio dio, {String baseUrl}) = _HadithService;

  @GET('https://api.hadith.gading.dev/books/')
  Future<BookResponse> getBooks();

  @GET('https://api.hadith.gading.dev/books/{book}')
  Future<HadithResponse> getHadith({
    @Path('book') required String bookId,
    @Query('range') required String range,
  });

  @GET('https://api.hadith.gading.dev/books/{book}/{number}')
  Future<HadithDetailResponse> getHadithDetail({
    @Path('book') required String bookId,
    @Path('number') required int number,
  });

  @GET('https://api.dikiotang.com/hadits')
  Future<BookNawawiResponse> getArbainNawawi();
}
