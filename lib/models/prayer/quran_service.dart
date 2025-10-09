import 'package:dio/dio.dart';
import 'package:syathiby/models/prayer/ayah/ayah_response.dart';
import 'package:retrofit/retrofit.dart';

part 'quran_service.g.dart';

@RestApi()
abstract class QuranService {
  factory QuranService(Dio dio, {String baseUrl}) = _QuranService;

  @GET(
      'https://raw.githubusercontent.com/rabbaaniiislamicschool/public-api/main/surah.json')
  Future<String> getSurahList();

  @GET(
    'https://quranenc.com/api/v1/translation/sura/indonesian_complex/{surah_number}',
  )
  Future<AyahResponse> getAyahList(
    @Path('surah_number') int surahNumber,
  );
}
