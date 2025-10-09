import 'package:dio/dio.dart';
import 'package:syathiby/models/raw_material/raw_material.dart';
import 'package:retrofit/retrofit.dart';

part 'cart_raw_service.g.dart';

@RestApi(baseUrl: 'sales')
abstract class CartRawRestInterface {
  factory CartRawRestInterface(Dio dio, {String baseUrl}) =
      _CartRawRestInterface;

  @FormUrlEncoded()
  @POST('insert.php')
  Future<List<RawMaterial>> add(
    @Field('key') String key,
    @Field('name_product') String nama,
    @Field('purchase_price') String hargabeli,
    @Field('selling_price') String hargajual,
  );

  @FormUrlEncoded()
  @POST('insert.php')
  Future<List<RawMaterial>> addWithBarcode(
    @Field('key') String key,
    @Field('name_product') String nama,
    @Field('codeproduct') String kodebarang,
    @Field('purchase_price') String hargabeli,
    @Field('selling_price') String hargajual,
  );

  @FormUrlEncoded()
  @POST('update.php')
  Future<List<RawMaterial>> update(
    @Field('key') String key,
    @Field('id_name_product') String id,
    @Field('name_product') String nama,
    @Field('codeproduct') String kodebarang,
    @Field('purchase_price') String hargabeli,
    @Field('selling_price') String hargajual,
    @Field('stock') String stok,
  );
}
