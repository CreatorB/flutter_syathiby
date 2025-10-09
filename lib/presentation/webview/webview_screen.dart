import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WebViewScreen extends HookConsumerWidget {
  const WebViewScreen({super.key, this.title, this.url});

  final String? title;
  final String? url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (title == null || url == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Link Website'),
        ),
        body: const Text('Tidak ada link url'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri(url!),
        ),
      ),
    );
  }
}
