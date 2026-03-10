import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/news/news.dart';

class DetailNewsScreen extends HookConsumerWidget {
  final News news;

  const DetailNewsScreen({
    super.key,
    required this.news,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For web, use flutter_html widget (better web support)
    if (kIsWeb) {
      return _buildWebView(context);
    }

    // For mobile, use InAppWebView for better rendering
    return _buildMobileView(context);
  }

  // Web version using flutter_html
  Widget _buildWebView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${news.title}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (news.img != null && news.img!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: news.img!,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Text(
            news.title ?? '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Html(
            data: news.detail ?? '',
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.6),
              ),
              "p": Style(
                margin: Margins.only(bottom: 16),
              ),
              "img": Style(
                width: Width(100, Unit.percent),
                margin: Margins.symmetric(vertical: 16),
              ),
              "iframe": Style(
                width: Width(100, Unit.percent),
                height: Height(315),
                margin: Margins.symmetric(vertical: 16),
              ),
              "h2, h3, h4": Style(
                margin: Margins.only(top: 24, bottom: 12),
                fontWeight: FontWeight.w600,
              ),
            },
          ),
        ],
      ),
    );
  }

  // Mobile version using InAppWebView
  Widget _buildMobileView(BuildContext context) {
    final isLoading = useState(true);
    final progress = useState(0.0);
    final htmlContent = _buildHtmlContent();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${news.title}',
        ),
        actions: [
          if (isLoading.value)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: htmlContent,
              baseUrl: WebUri('https://syathiby.id'),
            ),
            initialSettings: InAppWebViewSettings(
              supportZoom: false,
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              allowsInlineMediaPlayback: true,
              useHybridComposition: true,
            ),
            onLoadStart: (controller, url) {
              isLoading.value = true;
            },
            onLoadStop: (controller, url) {
              isLoading.value = false;
            },
            onProgressChanged: (controller, progressValue) {
              progress.value = progressValue / 100;
            },
            onConsoleMessage: (controller, consoleMessage) {
              // Handle console messages for debugging
            },
          ),
          if (isLoading.value && progress.value > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: progress.value,
              ),
            ),
        ],
      ),
    );
  }

  String _buildHtmlContent() {
    final title = news.title ?? '';
    final content = news.detail ?? '';
    final imageUrl = news.img ?? '';

    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            line-height: 1.6;
            color: #333;
            padding: 16px;
            background-color: #fff;
        }
        .featured-image {
            width: 100%;
            height: auto;
            border-radius: 8px;
            margin-bottom: 16px;
        }
        h1 {
            font-size: 24px;
            font-weight: bold;
            margin-bottom: 16px;
            line-height: 1.3;
        }
        .content {
            font-size: 16px;
            line-height: 1.8;
        }
        .content p {
            margin-bottom: 16px;
        }
        .content img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 16px 0;
        }
        .content iframe,
        .content video,
        .content embed {
            max-width: 100%;
            height: 315px;
            width: 100%;
            border-radius: 8px;
            margin: 16px 0;
        }
        .content blockquote {
            border-left: 4px solid #ddd;
            padding-left: 16px;
            margin: 16px 0;
            color: #666;
            font-style: italic;
        }
        .content ul, .content ol {
            margin: 16px 0;
            padding-left: 24px;
        }
        .content li {
            margin-bottom: 8px;
        }
        .content a {
            color: #007AFF;
            text-decoration: none;
        }
        .content a:hover {
            text-decoration: underline;
        }
        .content h2, .content h3, .content h4 {
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: 600;
        }
        .content table {
            width: 100%;
            border-collapse: collapse;
            margin: 16px 0;
        }
        .content table td, .content table th {
            border: 1px solid #ddd;
            padding: 8px;
        }
        .content table th {
            background-color: #f5f5f5;
            font-weight: 600;
        }
    </style>
</head>
<body>
    ${imageUrl.isNotEmpty ? '<img src="$imageUrl" class="featured-image" alt="Featured Image">' : ''}
    <h1>$title</h1>
    <div class="content">
        $content
    </div>
</body>
</html>
''';
  }
}
