import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/price_variant/price_variant.dart';
import 'package:retrofit/retrofit.dart';

part 'price_variant_service.g.dart';

@RestApi(baseUrl: "/pricevariant")
abstract class PriceVariantRestInterface {
  factory PriceVariantRestInterface(Dio dio, {String baseUrl}) =
      _PriceVariantRestInterface;

  @GET("list.php")
  Future<List<PriceVariant>> gets(
    @Query("key") String key,
    @Query("id_produk") String idProduk,
  );

  @POST("insert.php")
  @FormUrlEncoded()
  Future<Message> add(
    @Field("key") String key,
    @Field("minimal") String minimal,
    @Field("price") String price,
    @Field("id_product") String idProduct,
  );

  @POST("update.php")
  @FormUrlEncoded()
  Future<Message> update(
    @Field("key") String key,
    @Field("id") String id,
    @Field("minimal") String minimal,
    @Field("nominal") String nominal,
  );

  @GET("delete.php")
  Future<Message> delete(
    @Query("key") String key,
    @Query("id") String id,
  );
}
