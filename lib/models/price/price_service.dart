import 'package:dio/dio.dart';
import 'package:syathiby/models/price/price.dart';
import 'package:retrofit/retrofit.dart';

part 'price_service.g.dart';

@RestApi(baseUrl: "/price")
abstract class PriceRestInterface {
  factory PriceRestInterface(Dio dio, {String baseUrl}) = _PriceRestInterface;

  @GET("list.php")
  Future<List<Price>> gets(
    @Query("key") String key,
    @Query("nominal") double nominal,
  );

  @GET("emoji.php")
  Future<List<Price>> getEmoji(
    @Query("key") String key,
  );

  @GET("fast.php")
  Future<List<Price>> getChat(
    @Query("key") String key,
  );
}
