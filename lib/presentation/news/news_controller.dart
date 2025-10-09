import 'package:syathiby/models/news/news.dart';
import 'package:syathiby/models/service_injection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'news_controller.g.dart';

@riverpod
Future<List<News>> fetchNews(
  FetchNewsRef ref, {
  required String key,
}) async {
  return await ref.watch(newsServiceProvider).getNews(key);
}
