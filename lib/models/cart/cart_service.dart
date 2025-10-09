import 'dart:io';

import 'package:dio/dio.dart';
import 'package:syathiby/models/product/product.dart';
import 'package:retrofit/retrofit.dart';

part 'cart_service.g.dart';

@RestApi()
abstract class CartRestInterface {
  factory CartRestInterface(Dio dio, {String baseUrl}) = _CartRestInterface;

  @FormUrlEncoded()
  @POST('sales/insert.php')
  Future<List<Product>> add(
    @Field('key') String key,
    @Field('name_product') String nama,
    @Field('unit') String unit,
    @Field('selling_price') String hargajual,
    @Field('have_stock') String haveSTok,
    @Field('stok') String stok,
    @Field('alertstock') String alertstock,
    @Field('barcode') String barcode,
  );

  @MultiPart()
  @POST('pengadaan/addproduct.php')
  Future<List<Product>> addProduct(
    @Part(name: 'key') String key,
    @Part(name: 'name_product') String nameProduct,
    @Part(name: 'unit') String unit,
    @Part(name: 'selling_price') String hargajual,
    @Part(name: 'have_stock') String haveSTok,
    @Part(name: 'stok') String stok,
    @Part(name: 'alertstock') String alertstock,
    @Part(name: 'barcode') String barcode, {
    @Part(name: 'img') File? img,
  });

  @FormUrlEncoded()
  @POST('sales/insert.php')
  Future<List<Product>> addWithBarcode(
    @Field('key') String key,
    @Field('name_product') String nama,
    @Field('codeproduct') String kodebarang,
    @Field('purchase_price') String hargabeli,
    @Field('selling_price') String hargajual,
  );

  @FormUrlEncoded()
  @POST('sales/update.php')
  Future<List<Product>> update(
    @Field('key') String key,
    @Field('id_name_product') String id,
    @Field('name_product') String nama,
    @Field('codeproduct') String kodebarang,
    @Field('purchase_price') String hargabeli,
    @Field('selling_price') String hargajual,
    @Field('stock') String stok,
  );
}
