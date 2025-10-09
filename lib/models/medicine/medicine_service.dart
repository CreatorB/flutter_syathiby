import 'package:dio/dio.dart';
import 'package:syathiby/models/medicine/medicine.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'medicine_service.g.dart';

@RestApi(baseUrl: 'obat/')
abstract class DataObatRestInterface {
  factory DataObatRestInterface(Dio dio, {String baseUrl}) =
      _DataObatRestInterface;

  @GET('list.php')
  Future<List<DataObat>> gets(
    @Query('key') String key,
  );

  @GET('liststock.php')
  Future<List<DataObat>> getsStock(
    @Query('key') String key,
  );

  @GET('list.php')
  Future<List<DataObat>> choose(
    @Query('key') String key,
    @Query('have_stock') String check,
  );

  @POST('add.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'name') String nama,
    @Part(name: 'unit') String unit,
    @Part(name: 'stock') String stok,
    @Part(name: 'description') String deskripsi,
  );

  @POST('update.php')
  @MultiPart()
  Future<Message> update(
    @Part(name: 'key') String key,
    @Part(name: 'id_obat') String id,
    @Part(name: 'name') String nama,
    @Part(name: 'unit') String unit,
    @Part(name: 'stock') String stok,
    @Part(name: 'description') String deskripsi,
  );

  @POST('updatestock.php')
  @MultiPart()
  Future<Message> updateStock(
    @Part(name: 'key') String key,
    @Part(name: 'id_obat') String id,
    @Part(name: 'stock') String stok,
  );

  @GET('delete.php')
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('search.php')
  Future<List<DataObat>> search(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('searchstock.php')
  Future<List<DataObat>> searchStock(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET('search.php')
  Future<List<DataObat>> chooseSearch(
    @Query('key') String key,
    @Query('search') String id,
    @Query('have_stock') String check,
  );
}
