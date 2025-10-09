import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:retrofit/retrofit.dart';

part 'raw_material_service.g.dart';

@RestApi(baseUrl: 'rawmaterial/')
abstract class RawMaterialRestInterface {
  factory RawMaterialRestInterface(Dio dio, {String baseUrl}) =
      _RawMaterialRestInterface;

  @GET('list.php')
  Future<List<RawMaterial>> gets(@Query('key') String key);

  @GET('liststock.php')
  Future<List<RawMaterial>> getsStock(@Query('key') String key);

  @GET('list.php')
  Future<List<RawMaterial>> choose(
      @Query('key') String key, @Query('have_stock') String check);

  @POST('add.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'name') String nama,
    @Part(name: 'unit') String unit,
    @Part(name: 'price') double jual,
    @Part(name: 'stock') double stok,
    @Part(name: 'description') String deskripsi,
  );

  @POST('update.php')
  @MultiPart()
  Future<Message> update(
    @Part(name: 'key') String key,
    @Part(name: 'id_raw_material') String id,
    @Part(name: 'name') String nama,
    @Part(name: 'unit') String unit,
    @Part(name: 'price') double jual,
    @Part(name: 'stock') double stok,
    @Part(name: 'description') String deskripsi,
  );

  @POST('updatestock.php')
  @MultiPart()
  Future<Message> updateStock(
    @Part(name: 'key') String key,
    @Part(name: 'id_raw_material') String id,
    @Part(name: 'stock') String stok,
  );

  @GET('delete.php')
  Future<Message> delete(@Query('key') String key, @Query('id') String id);

  @GET('search.php')
  Future<List<RawMaterial>> search(
      @Query('key') String key, @Query('search') String id);

  @GET('searchstock.php')
  Future<List<RawMaterial>> searchStock(
      @Query('key') String key, @Query('search') String id);

  @GET('search.php')
  Future<List<RawMaterial>> chooseSearch(@Query('key') String key,
      @Query('search') String id, @Query('have_stock') String check);
}
