import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:syathiby/models/wordpress/wp_post.dart';
import 'package:syathiby/utils/extension/color.dart';
import 'package:intl/intl.dart';

class WpPostListItem extends HookConsumerWidget {
  final WpPost? post;

  const WpPostListItem({super.key, this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show skeleton during loading
    if (post == null) {
      return _buildSkeleton(context);
    }

    final imageUrl = post!.featuredImageUrl;
    final formattedDate = _formatDate(post!.date ?? '');

    // Debug: print comprehensive post info
    debugPrint('═══════════════════════════════════════════');
    debugPrint('Post ID: ${post!.id}');
    debugPrint('Post Title: ${post!.plainTitle}');
    debugPrint('yoast_head_json: ${post!.yoastHeadJson}');
    debugPrint('og_image data: ${post!.yoastHeadJson?.ogImage}');
    debugPrint('embedded media: ${post!.embedded?.featuredMediaList?.firstOrNull?.sourceUrl}');
    debugPrint('Final imageUrl: $imageUrl');
    debugPrint('═══════════════════════════════════════════');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Featured Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl != null && imageUrl.isNotEmpty
              ? SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: context.colorOnSurface.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('❌ Image load error for ${post!.id}: $error');
                      debugPrint('Stack: $stackTrace');
                      return Container(
                        height: 200,
                        color: context.colorOnSurface.withOpacity(0.1),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.image_outlined,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Error: $error',
                                style: const TextStyle(fontSize: 10, color: Colors.red),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: context.colorOnSurface.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.article_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          post!.plainTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),

        // Date
        Text(
          formattedDate,
          style: TextStyle(
            fontSize: 12,
            color: context.colorOnSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 10),

        // Excerpt
        Text(
          post!.plainExcerpt,
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

  Widget _buildSkeleton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image skeleton
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        // Title skeleton
        Container(
          width: double.infinity,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        // Date skeleton
        Container(
          width: 150,
          height: 14,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 10),
        // Excerpt skeleton
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes} menit yang lalu';
        }
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return DateFormat('d MMMM yyyy', 'id_ID').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }
}
