import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Metadata SEO cho từng trang/route — manage H1, H2, meta description, keywords, schema.
class SeoMetadata {
  const SeoMetadata({
    this.title = '',
    this.description = '',
    this.keywords = '',
    this.h1 = '',
    this.h2List = const [],
    this.canonicalUrl = '',
    this.ogImage = '',
    this.ogType = 'website',
    this.schemaJson = '',
    this.noindex = false,
  });

  final String title;                    // <title>
  final String description;             // meta name="description"
  final String keywords;                // meta name="keywords"
  final String h1;                      // Heading 1 (page title)
  final List<String> h2List;            // Heading 2s (sections)
  final String canonicalUrl;            // Prevent duplicate content
  final String ogImage;                 // Open Graph image
  final String ogType;                  // og:type (website, article, etc)
  final String schemaJson;              // JSON-LD structured data
  final bool noindex;                   // robots:noindex

  SeoMetadata copyWith({
    String? title,
    String? description,
    String? keywords,
    String? h1,
    List<String>? h2List,
    String? canonicalUrl,
    String? ogImage,
    String? ogType,
    String? schemaJson,
    bool? noindex,
  }) =>
      SeoMetadata(
        title: title ?? this.title,
        description: description ?? this.description,
        keywords: keywords ?? this.keywords,
        h1: h1 ?? this.h1,
        h2List: h2List ?? this.h2List,
        canonicalUrl: canonicalUrl ?? this.canonicalUrl,
        ogImage: ogImage ?? this.ogImage,
        ogType: ogType ?? this.ogType,
        schemaJson: schemaJson ?? this.schemaJson,
        noindex: noindex ?? this.noindex,
      );

  /// Generate HTML meta tags (for web)
  String generateMetaTags() {
    final buf = StringBuffer();
    buf.writeln('<meta name="description" content="$description">');
    buf.writeln('<meta name="keywords" content="$keywords">');
    if (canonicalUrl.isNotEmpty) {
      buf.writeln('<link rel="canonical" href="$canonicalUrl">');
    }
    buf.writeln('<meta property="og:title" content="$title">');
    buf.writeln('<meta property="og:description" content="$description">');
    if (ogImage.isNotEmpty) {
      buf.writeln('<meta property="og:image" content="$ogImage">');
    }
    buf.writeln('<meta property="og:type" content="$ogType">');
    if (noindex) {
      buf.writeln('<meta name="robots" content="noindex,nofollow">');
    }
    if (schemaJson.isNotEmpty) {
      buf.writeln('<script type="application/ld+json">$schemaJson</script>');
    }
    return buf.toString();
  }

  /// Health check SEO score (0-100)
  int calculateSeoScore() {
    int score = 0;
    if (title.length >= 30 && title.length <= 60) score += 20;
    if (description.length >= 120 && description.length <= 160) score += 20;
    if (h1.isNotEmpty) score += 15;
    if (h2List.isNotEmpty) score += 15;
    if (keywords.isNotEmpty && keywords.split(',').length >= 3) score += 10;
    if (canonicalUrl.isNotEmpty) score += 10;
    if (schemaJson.isNotEmpty) score += 10;
    return score;
  }
}

/// SEO Controller — manage metadata cho tất cả routes
class SeoController extends Notifier<Map<String, SeoMetadata>> {
  @override
  Map<String, SeoMetadata> build() {
    return {
      '/': _defaultHomeSeo(),
      '/tour': _defaultTourSeo(),
      '/admin': _defaultAdminSeo(),
    };
  }

  void setPageSeo(String route, SeoMetadata metadata) {
    state = {...state, route: metadata};
  }

  SeoMetadata? getPageSeo(String route) => state[route];

  static SeoMetadata _defaultHomeSeo() => SeoMetadata(
    title: 'TravelReview - Đánh giá du lịch từ những người Việt chân thực',
    description: 'Khám phá 8500+ tour, đọc 125k+ review thực từ người Việt. Đặt tour an toàn với TravelReview.',
    keywords: 'du lịch Việt, tour, booking, đánh giá du lịch, travel review, Hà Nội, Đà Nẵng, Sapa',
    h1: 'TravelReview - Nền tảng Review Du Lịch #1 Việt Nam',
    h2List: ['Khám phá 8500+ Tour', 'Đọc Review từ Người Thực', 'Đặt Ngay an Toàn'],
    canonicalUrl: 'https://travelreview.vn/',
    ogImage: 'https://travelreview.vn/og-image-hero.jpg',
    ogType: 'website',
    schemaJson: '''
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "TravelReview",
  "url": "https://travelreview.vn",
  "description": "Nền tảng review du lịch chân thực từ người Việt",
  "potentialAction": {
    "@type": "SearchAction",
    "target": "https://travelreview.vn/search?q={search_term_string}",
    "query-input": "required name=search_term_string"
  }
}
    ''',
  );

  static SeoMetadata _defaultTourSeo() => SeoMetadata(
    title: 'Tours Du Lịch - Đặt Ngay | TravelReview',
    description: 'Tìm kiếm tour du lịch Việt Nam. So sánh giá, đọc review, đặt ngay với các operator đã xác minh.',
    keywords: 'tour du lịch, đặt tour, tour Hà Nội, tour Đà Nẵng, giá tour rẻ',
    h1: 'Tours Du Lịch Chất Lượng - Đặt Ngay',
    h2List: ['Lọc theo Điểm Đến', 'So Sánh Giá', 'Đọc Review Thực'],
    canonicalUrl: 'https://travelreview.vn/tours',
  );

  static SeoMetadata _defaultAdminSeo() => SeoMetadata(
    title: 'Admin Portal - TravelReview',
    noindex: true, // Admin không cần index
  );
}

final seoControllerProvider =
    NotifierProvider<SeoController, Map<String, SeoMetadata>>(
  SeoController.new,
);

