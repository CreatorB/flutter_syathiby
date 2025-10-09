import 'package:dio/dio.dart';
import 'package:syathiby/models/allocation/allocation.dart';
import 'package:retrofit/retrofit.dart';

part 'allocation_service.g.dart';

@RestApi()
abstract class AlokasiRestInterface {
  factory AlokasiRestInterface(Dio dio, {String baseUrl}) =
      _AlokasiRestInterface;

  @GET('alokasi/list.php')
  Future<List<Allocation>> get(
    @Query('key') String key,
  );

  @GET('pengadaan/jenis.php')
  Future<List<Allocation>> getType(
    @Query('key') String key,
  );

  @GET('alokasi/jenis.php')
  Future<List<Allocation>> getJenis(
    @Query('key') String key,
  );

  @GET('masak/waktu.php')
  Future<List<Allocation>> getWaktu(
    @Query('key') String key,
  );

  @GET('alokasi/search.php')
  Future<List<Allocation>> search(
    @Query('key') String key,
    @Query('search') String id,
  );
}
