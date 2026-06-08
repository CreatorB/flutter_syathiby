import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:syathiby/models/wordpress/wp_post.dart';

class WpPostDetailScreen extends HookConsumerWidget {
  final WpPost post;

  const WpPostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(true);
    final progress = useState(0.0);
    final articleUrl = post.link?.trim();
    final articleUri =
        (articleUrl != null && articleUrl.isNotEmpty) ? Uri.tryParse(articleUrl) : null;
    final shouldLoadUrlOnWeb = kIsWeb && articleUri != null;

    // Fallback content if URL is missing/invalid.
    final htmlContent = _buildHtmlContent();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
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
            initialUrlRequest: shouldLoadUrlOnWeb
                ? URLRequest(url: WebUri.uri(articleUri))
                : null,
            // Mobile/iOS/Android: always use legacy HTML rendering.
            // Web: use HTML only as fallback when article URL is missing/invalid.
            initialData: !shouldLoadUrlOnWeb
                ? InAppWebViewInitialData(
                    data: htmlContent,
                    baseUrl: WebUri('https://syathiby.id'),
                  )
                : null,
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
    final title = post.title?.rendered ?? '';
    final content = post.content?.rendered ?? '';
    final imageUrl = post.featuredImageUrl ?? '';
    final date = _formatDate(post.date ?? '');

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
        .meta {
            color: #666;
            font-size: 12px;
            margin-bottom: 8px;
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
    <div class="meta">$date</div>
    <h1>$title</h1>
    <div class="content">
        $content
    </div>
</body>
</html>
''';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final days = [
        'Minggu',
        'Senin',
        'Selasa',
        'Rabu',
        'Kamis',
        'Jumat',
        'Sabtu'
      ];
      return '${days[date.weekday % 7]}, ${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
