import 'package:dio/dio.dart';
import 'package:syathiby/models/surah/surah.dart';
import 'package:retrofit/retrofit.dart';

part 'surah_service.g.dart';

@RestApi()
abstract class SurahRestInterface {
  factory SurahRestInterface(Dio dio, {String baseUrl}) = _SurahRestInterface;

  @GET('quran/surah.php')
  Future<List<Surah>> getSurah(
      @Query('key') String key, @Query('page') int? page);

  @GET('dzikir/hisnulmuslim.php')
  Future<List<Surah>> getHisnul(
      @Query('key') String key, @Query('page') int? page);

  @GET('quran/carisurah.php')
  Future<List<Surah>> searchSurah(
      @Query('key') String key, @Query('search') String? search);

  @GET('dzikir/caridoa.php')
  Future<List<Surah>> searchDoa(
      @Query('key') String key, @Query('search') String? search);

  @GET('quran/ayah.php')
  Future<List<Surah>> getAyah(@Query('key') String key,
      @Query('id_surah') int? id, @Query('page') int? page);

  @GET('dzikir/detailhisnul.php')
  Future<List<Surah>> getDetail(@Query('key') String key,
      @Query('id_surah') int? id, @Query('page') int? page);

  @GET('quran/cariayah.php')
  Future<List<Surah>> searchAyah(@Query('key') String key,
      @Query('id_surah') int? id, @Query('search') String? search);

  @GET('dzikir/list.php')
  Future<List<Surah>> getDzikir(@Query('key') String key,
      @Query('waktu') String? waktu, @Query('page') int? page);

  @GET('hadist/kitab.php')
  Future<List<Surah>> getHadist(@Query('key') String key,
      @Query('kitab') String kitab, @Query('page') int? page);

  @GET('hadist/carihadist.php')
  Future<List<Surah>> searchHadist(@Query('key') String key,
      @Query('kitab') String kitab, @Query('search') String? search);
}
