import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/message.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:retrofit/retrofit.dart';

part 'product_service.g.dart';

@RestApi(baseUrl: 'product/')
abstract class ProductRestInterface {
  factory ProductRestInterface(Dio dio, {String baseUrl}) =
      _ProductRestInterface;

  @GET('list.php')
  Future<List<Product>> gets(
    @Query('key') String key,
    @Query('trx') String trx,
    @Query('have_stock') String haveStock,
    @Query('page') int page,
  );

  @GET('listmenu.php')
  Future<List<Product>> getsMenu(@Query('key') String key);

  @GET('liststock.php')
  Future<List<Product>> getsStock(@Query('key') String key);

  @GET('listvariable.php')
  Future<List<Product>> getsVariant(
      @Query('key') String key, @Query('id_product') String idProduct);

  @GET('list.php')
  Future<List<Product>> choose(@Query('key') String key,
      @Query('trx') String trx, @Query('have_stock') String check,
      {@Query('page') int? page});

  @GET('listobat.php')
  Future<List<Product>> chooseObat(
    @Query('key') String key,
    @Query('trx') String trx,
    @Query('have_stock') String haveStock,
  );

  @GET('listmenu.php')
  Future<List<Product>> chooseMenu(@Query('key') String key,
      @Query('trx') String trx, @Query('have_stock') String check);

  @GET('searchsubcategory.php')
  Future<List<Product>> chooseCat(
      @Query('key') String key,
      @Query('trx') String trx,
      @Query('have_stock') String check,
      @Query('id_subcategory') String id);

  @GET('listvariable.php')
  Future<List<Product>> chooseVariable(@Query('key') String key,
      @Query('id_product') String idProduct, @Query('have_stock') String check);

  @POST('insert.php')
  @MultiPart()
  Future<Message> add(
    @Part(name: 'key') String key,
    @Part(name: 'name_product') String nama,
    @Part(name: 'unit') String unit,
    @Part(name: 'codeproduct') String kode,
    @Part(name: 'id_category') String idkategori,
    @Part(name: 'purchase_price') String beli,
    @Part(name: 'selling_price') String jual,
    @Part(name: 'stock') String stok,
    @Part(name: 'minimalstock') String minstok,
    @Part(name: 'description') String deskripsi,
    @Part(name: 'online') String online,
    @Part(name: 'have_stock') String havestok,
    @Part(name: 'wholesale_price') String grosir,
    @Part(name: 'tax') String tax,
    @Part(name: 'alertstock') String alertstock, {
    @Part(name: 'img') File? img,
  });

  @POST('insertmenu.php')
  @MultiPart()
  Future<Message> addMenu(
    @Part(name: 'key') String key,
    @Part(name: 'name_menu') String nama, {
    @Part(name: 'img') File? img,
  });

  @POST('insertvariant.php')
  @MultiPart()
  Future<Message> addVariant(
    @Part(name: 'key') String key,
    @Part(name: 'name_product') String nama,
    @Part(name: 'codeproduct') String kode,
    @Part(name: 'id_master') String idProduct,
    @Part(name: 'purchase_price') String beli,
    @Part(name: 'selling_price') String jual,
    @Part(name: 'stock') String stok,
    @Part(name: 'minimalstock') String minstok,
    @Part(name: 'description') String deskripsi,
    @Part(name: 'online') String online,
    @Part(name: 'have_stock') String havestok,
    @Part(name: 'wholesale_price') String grosir,
    @Part(name: 'tax') String tax,
    @Part(name: 'alertstock') String alertstock, {
    @Part(name: 'img') File? img,
  });

  @POST('update.php')
  @MultiPart()
  Future<Message> update(
    @Part(name: 'key') String key,
    @Part(name: 'id_product') String id,
    @Part(name: 'name_product') String nama,
    @Part(name: 'unit') String unit,
    @Part(name: 'codeproduct') String kode,
    @Part(name: 'id_category') String idkategori,
    @Part(name: 'purchase_price') String beli,
    @Part(name: 'selling_price') String jual,
    @Part(name: 'stock') String stok,
    @Part(name: 'minimalstock') String minstok,
    @Part(name: 'description') String deskripsi,
    @Part(name: 'online') String online,
    @Part(name: 'have_stock') String havestok,
    @Part(name: 'wholesale_price') String grosir,
    @Part(name: 'tax') String tax,
    @Part(name: 'alertstock') String alertstock, {
    @Part(name: 'img') File? img,
  });

  @POST("updatemenu.php")
  Future<Message> updateMenu(
    @Part(name: 'key') String key,
    @Part(name: 'id_product') String id,
    @Part(name: 'name_menu') String nama, {
    @Part(name: 'img') File? img,
  });

  @POST("updatestock.php")
  Future<Message> updateStock(
    @Part(name: 'key') String key,
    @Part(name: 'id_product') String id,
    @Part(name: 'stock') String stok,
    @Part(name: 'reason') String reason,
  );

  @GET("delete.php")
  Future<Message> delete(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET("search.php")
  Future<List<Product>> search(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET("searchstock.php")
  Future<List<Product>> searchStock(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET("searchvariant.php")
  Future<List<Product>> searchVariant(
    @Query('key') String key,
    @Query('search') String id,
  );

  @GET("search.php")
  Future<List<Product>> chooseSearch(
    @Query('key') String key,
    @Query('search') String query,
    @Query('have_stock') String haveStock,
  );

  @GET("searchobat.php")
  Future<List<Product>> chooseSearchObat(
    @Query('key') String key,
    @Query('search') String query,
    @Query('have_stock') String haveStock,
  );

  @GET("inventorysearchbarcode.php")
  Future<List<Product>> searchByBarcode(
    @Query('key') String key,
    @Query('codeproduct') String id,
  );

  @GET("inventorysort.php")
  Future<List<Product>> sort(
    @Query('key') String key,
  );
}
