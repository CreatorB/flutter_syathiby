import 'package:freezed_annotation/freezed_annotation.dart';

part 'wp_post.freezed.dart';
part 'wp_post.g.dart';

/// WordPress Post model for WP REST API v2
/// Reference: https://developer.wordpress.org/rest-api/reference/posts/
@freezed
class WpPost with _$WpPost {
  const factory WpPost({
    int? id,
    String? date,
    String? slug,
    String? link,
    WpRenderedContent? title,
    WpRenderedContent? content,
    WpRenderedContent? excerpt,
    @JsonKey(name: 'featured_media') int? featuredMedia,
    @JsonKey(name: '_embedded') WpEmbedded? embedded,
    @JsonKey(name: 'yoast_head_json') YoastHeadJson? yoastHeadJson,
  }) = _WpPost;

  factory WpPost.fromJson(Map<String, dynamic> json) => _$WpPostFromJson(json);
}

@freezed
class WpRenderedContent with _$WpRenderedContent {
  const factory WpRenderedContent({
    String? rendered,
  }) = _WpRenderedContent;

  factory WpRenderedContent.fromJson(Map<String, dynamic> json) =>
      _$WpRenderedContentFromJson(json);
}

@freezed
class WpEmbedded with _$WpEmbedded {
  const factory WpEmbedded({
    @JsonKey(name: 'wp:featuredmedia') List<WpFeaturedMedia>? featuredMediaList,
  }) = _WpEmbedded;

  factory WpEmbedded.fromJson(Map<String, dynamic> json) =>
      _$WpEmbeddedFromJson(json);
}

@freezed
class WpFeaturedMedia with _$WpFeaturedMedia {
  const factory WpFeaturedMedia({
    @JsonKey(name: 'source_url') String? sourceUrl,
    @JsonKey(name: 'media_details') WpMediaDetails? mediaDetails,
  }) = _WpFeaturedMedia;

  factory WpFeaturedMedia.fromJson(Map<String, dynamic> json) =>
      _$WpFeaturedMediaFromJson(json);
}

@freezed
class WpMediaDetails with _$WpMediaDetails {
  const factory WpMediaDetails({
    Map<String, WpImageSize>? sizes,
  }) = _WpMediaDetails;

  factory WpMediaDetails.fromJson(Map<String, dynamic> json) =>
      _$WpMediaDetailsFromJson(json);
}

@freezed
class WpImageSize with _$WpImageSize {
  const factory WpImageSize({
    @JsonKey(name: 'source_url') String? sourceUrl,
    int? width,
    int? height,
  }) = _WpImageSize;

  factory WpImageSize.fromJson(Map<String, dynamic> json) =>
      _$WpImageSizeFromJson(json);
}

/// WordPress Yoast SEO Head JSON metadata
@freezed
class YoastHeadJson with _$YoastHeadJson {
  const factory YoastHeadJson({
    @JsonKey(name: 'og_image') List<OgImage>? ogImage,
  }) = _YoastHeadJson;

  factory YoastHeadJson.fromJson(Map<String, dynamic> json) =>
      _$YoastHeadJsonFromJson(json);
}

/// WordPress OG Image model (from Yoast SEO)
@freezed
class OgImage with _$OgImage {
  const factory OgImage({
    int? width,
    int? height,
    String? url,
    String? type,
  }) = _OgImage;

  factory OgImage.fromJson(Map<String, dynamic> json) =>
      _$OgImageFromJson(json);
}

/// Extension to get featured image URL from WpPost
extension WpPostExtension on WpPost {
  String? get featuredImageUrl {
    // 1. Try og_image first (from Yoast SEO, optimized)
    final ogImageUrl = yoastHeadJson?.ogImage?.firstOrNull?.url;
    if (ogImageUrl != null && ogImageUrl.isNotEmpty) {
      return ogImageUrl;
    }
    
    // 2. Fallback to embedded media
    return embedded?.featuredMediaList?.firstOrNull?.sourceUrl;
  }

  String get plainTitle {
    final text = title?.rendered ?? '';
    return _decodeHtml(text);
  }

  String get plainExcerpt {
    final text = excerpt?.rendered ?? '';
    return _decodeHtml(text).replaceAll('[&hellip;]', '...').replaceAll('[…]', '...');
  }

  String get plainContent {
    final text = content?.rendered ?? '';
    return _decodeHtml(text);
  }

  /// Decode HTML entities and strip tags
  String _decodeHtml(String text) {
    return text
        // Strip HTML tags
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Common HTML entities
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8216;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '...')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&laquo;', '«')
        .replaceAll('&raquo;', '»')
        // Decode numeric entities
        .replaceAllMapped(
          RegExp(r'&#(\d+);'),
          (match) {
            final code = int.tryParse(match.group(1)!);
            return code != null ? String.fromCharCode(code) : match.group(0)!;
          },
        )
        .trim();
  }
}
