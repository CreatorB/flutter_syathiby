import 'package:dio/dio.dart';
import 'package:syathiby/models/category_expense/category_expense.dart';
import 'package:syathiby/models/message.dart';
import 'package:retrofit/retrofit.dart';

part 'category_expense_service.g.dart';

@RestApi(baseUrl: 'categoryextend/')
abstract class CategoryExpenseRestInterface {
  factory CategoryExpenseRestInterface(Dio dio, {String baseUrl}) =
      _CategoryExpenseRestInterface;

  @GET('list.php')
  Future<List<CategoryExpense>> getCategories(
    @Query('key') String key,
  );

  @FormUrlEncoded()
  @POST('insert.php')
  Future<Message> addCategory(
    @Field('key') String key,
    @Field('expense_category') String kategori,
  );

  @FormUrlEncoded()
  @POST('update.php')
  Future<Message> updateCategory(
    @Field('key') String key,
    @Field('id') String id,
    @Field('expense_category') String kategori,
  );

  @GET('delete.php')
  Future<Message> deleteCategory(
    @Query('key') String key,
    @Query('id') String id,
  );

  @GET('search.php')
  Future<List<CategoryExpense>> searchCategory(
    @Query('key') String key,
    @Query('search') String id,
  );
}
