import 'package:dio/dio.dart';
import 'package:syathiby/models/addon/add_on.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'add_on_service.g.dart';

@RestApi(baseUrl: 'addon')
abstract class AddOnRestInterface {
  factory AddOnRestInterface(Dio dio, {String baseUrl}) = _AddOnRestInterface;

  @GET('list.php')
  Future<List<AddOn>> gets(
    @Query('key') String key,
    @Query('id_produk') String idProduk,
    @Query('position') int position,
  );

  @GET('insertdata.php')
  Future<List<AddOn>> insert(
    @Query('key') String key,
    @Query('id_addon') String idAddon,
  );

  @POST('insert.php')
  Future<Message> add(
    @Field('key') String key,
    @Field('name_addon') String name,
    @Field('nominal') String nominal,
    @Field('id_product') String idProduct,
  );

  @POST('update.php')
  Future<Message> update(
    @Field('key') String key,
    @Field('id') String id,
    @Field('name_addon') String nama,
    @Field('nominal') String nominal,
  );

  @GET('delete.php')
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );
}
