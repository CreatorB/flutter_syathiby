import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/news/news.dart';
import 'package:syathiby/utils/extension/typography.dart';

class DetailNewsScreen extends HookConsumerWidget {
  final News news;

  const DetailNewsScreen({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${news.title}',
        ),
      ),
      body: ListView(
        children: [
          CachedNetworkImage(
            imageUrl: '${news.img}',
            width: double.infinity,
            height: 280,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _parseHtmlString('${news.detail}'),
              style: context.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    final htmlDocument = HtmlParser.parseHTML(htmlString);
    return htmlDocument.text;
  }
}
