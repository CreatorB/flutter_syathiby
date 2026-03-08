import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:syathiby/models/wordpress/wp_post.dart';

part 'wp_api_service.g.dart';

/// WordPress REST API v2 Service
/// Base URL: https://syathiby.id/wp-json/wp/v2
@RestApi(baseUrl: 'https://syathiby.id/wp-json/wp/v2')
abstract class WpApiService {
  factory WpApiService(Dio dio, {String baseUrl}) = _WpApiService;

  /// Get list of posts
  /// 
  /// @param page - Page number (default: 1)
  /// @param perPage - Posts per page (default: 10, max: 100)
  /// @param embed - Include embedded resources like featured media (default: true)
  /// @param orderBy - Sort by date, relevance, id, etc (default: date)
  /// @param order - asc or desc (default: desc)
  @GET('/posts')
  Future<List<WpPost>> getPosts({
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('_embed') bool? embed,
    @Query('orderby') String? orderBy,
    @Query('order') String? order,
  });

  /// Get single post by ID
  /// 
  /// @param id - Post ID
  /// @param embed - Include embedded resources
  @GET('/posts/{id}')
  Future<WpPost> getPost(
    @Path('id') int id, {
    @Query('_embed') bool? embed,
  });

  /// Search posts
  /// 
  /// @param search - Search query string
  /// @param page - Page number
  /// @param perPage - Posts per page
  @GET('/posts')
  Future<List<WpPost>> searchPosts({
    @Query('search') required String search,
    @Query('page') int? page,
    @Query('per_page') int? perPage,
    @Query('_embed') bool? embed,
  });
}
