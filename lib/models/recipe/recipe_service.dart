import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/recipe/recipe.dart';
import 'package:retrofit/retrofit.dart';

part 'recipe_service.g.dart';

@RestApi(baseUrl: 'recipe/')
abstract class RecipeRestInterface {
  factory RecipeRestInterface(Dio dio, {String baseUrl}) = _RecipeRestInterface;

  @GET('list.php')
  Future<List<Recipe>> gets(
    @Query('key') String key,
    @Query('id_produk') String idProduk,
  );

  @POST('insert.php')
  Future<Message> add(
    @Field('key') String key,
    @Field('stock') String stock,
    @Field('id_raw_material') String idRawMaterial,
    @Field('id_product') String idProduct,
  );

  @POST('update.php')
  Future<Message> update(
    @Field('key') String key,
    @Field('id') String id,
    @Field('stock') String stock,
  );

  @GET('delete.php')
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );
}
