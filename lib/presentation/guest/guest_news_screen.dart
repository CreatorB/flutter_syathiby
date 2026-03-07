import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/routing/app_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syathiby/di/providers.dart';
import '../news/item_news_list.dart';
import '../news/news_controller.dart';

/// Guest mode news screen - shows news without requiring login
class GuestNewsScreen extends HookConsumerWidget {
  const GuestNewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Guest users have an empty/dummy key for fetching public news
    const guestKey = '';
    final fetchNews = ref.watch(fetchNewsProvider(key: guestKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(fetchNewsProvider(key: guestKey)),
        child: Skeletonizer(
          enabled: fetchNews.isLoading,
          child: fetchNews.hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat berita',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            ref.refresh(fetchNewsProvider(key: guestKey)),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: fetchNews.valueOrNull?.length ?? 10,
                  itemBuilder: (context, index) {
                    final news = fetchNews.valueOrNull?.elementAtOrNull(index);
                    return ListTile(
                      title: ItemNewsList(news: news),
                      onTap: () {
                        context.goNamed(
                          AppRoute.guestDetailNews.name,
                          extra: news,
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}
