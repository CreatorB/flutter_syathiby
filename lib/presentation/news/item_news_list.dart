import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/news/news.dart';
import 'package:syathiby/utils/extension/color.dart';

class ItemNewsList extends HookConsumerWidget {
  final News? news;

  const ItemNewsList({super.key, this.news});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: '${news?.img}',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const Icon(
              Icons.image,
              size: 200,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${news?.title}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 10),
        Text(
          htmlToPlainText('${news?.desc}'),
          style: TextStyle(
            fontSize: 16,
            color: context.colorOnSurface.withOpacity(0.6),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String htmlToPlainText(String htmlString) {
    final htmlDocument = HtmlParser.parseHTML(htmlString);
    return htmlDocument.text;
  }
}
