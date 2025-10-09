import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/di/providers.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'item_news_list.dart';
import 'news_controller.dart';

class NewsScreen extends HookConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(getCurrentUserProvider);
    final key = '${currentUser?.key}';
    final fetchNews = ref.watch(fetchNewsProvider(key: key));
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Berita',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(fetchNewsProvider(key: key)),
        child: Skeletonizer(
          enabled: fetchNews.isLoading,
          child: ListView.builder(
            itemCount: fetchNews.valueOrNull?.length ?? 10, // Example count
            itemBuilder: (context, index) {
              final news = fetchNews.valueOrNull?.elementAtOrNull(index);
              return ListTile(
                title: ItemNewsList(news: news),
                onTap: () {
                  context.goNamed(AppRoute.detailNews.name, extra: news);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
