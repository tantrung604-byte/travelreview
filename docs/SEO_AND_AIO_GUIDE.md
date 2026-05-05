# 🚀 SEO & AIO Guide untuk TravelReview Web

## 1. Web Server Files

### robots.txt
```
User-agent: *
Allow: /
Disallow: /admin
Disallow: /api
Disallow: /*.json
Disallow: /search?

Sitemap: https://travelreview.vn/sitemap.xml
Sitemap: https://travelreview.vn/sitemap-tours.xml
```

### sitemap.xml (Thay đổi định kỳ)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://travelreview.vn/</loc>
    <lastmod>2026-05-05</lastmod>
    <changefreq>weekly</changefreq>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>https://travelreview.vn/tours</loc>
    <lastmod>2026-05-05</lastmod>
    <changefreq>daily</changefreq>
    <priority>0.9</priority>
  </url>
  <!-- Dynamic tours URLs -->
  <url>
    <loc>https://travelreview.vn/tour/da-nang-ba-na-hills</loc>
    <lastmod>2026-05-05</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
```

### sitemap-tours.xml (Dynamic, generated)
```xml
<!-- Generated from database, 1 entry/tour -->
```

---

## 2. Web HTML Meta Tags & Open Graph

```html
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  
  <!-- Core SEO -->
  <title>TravelReview - Đánh giá du lịch từ người Việt chân thực</title>
  <meta name="description" content="Khám phá 8500+ tour, đọc 125k+ review thực từ người Việt. Đặt tour an toàn với TravelReview.">
  <meta name="keywords" content="du lịch Việt, tour, booking, đánh giá, travel review">
  <link rel="canonical" href="https://travelreview.vn/">
  
  <!-- Open Graph (Facebook, etc) -->
  <meta property="og:title" content="TravelReview - Nền tảng Review Du Lịch #1 Việt Nam">
  <meta property="og:description" content="Khám phá, so sánh, đặt tour an toàn với review từ người thực.">
  <meta property="og:type" content="website">
  <meta property="og:url" content="https://travelreview.vn/">
  <meta property="og:image" content="https://travelreview.vn/og-hero.jpg">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  
  <!-- Twitter Card -->
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="TravelReview - Review Du Lịch Chân Thực">
  <meta name="twitter:description" content="125k+ review, 8500+ tour, operator đã xác minh">
  <meta name="twitter:image" content="https://travelreview.vn/og-hero.jpg">
  
  <!-- App Links (Deep Linking) -->
  <meta name="apple-itunes-app" content="app-id=123456789">
  <meta name="google-play-app" content="app-id=com.travelreview.app">
  
  <!-- Robots & Crawling -->
  <meta name="robots" content="index,follow">
  <meta name="googlebot" content="index,follow">
  <meta name="revisit-after" content="7 days">
  <meta name="author" content="TravelReview">
  <meta name="copyright" content="© 2026 TravelReview. All rights reserved.">
  <meta name="language" content="vi-VN">
  
  <!-- Structured Data (JSON-LD) -->
  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "TravelReview",
  "url": "https://travelreview.vn",
  "logo": "https://travelreview.vn/logo.png",
  "description": "Nền tảng review du lịch chân thực từ người Việt",
  "sameAs": [
    "https://facebook.com/travelreview",
    "https://instagram.com/travelreview",
    "https://twitter.com/travelreview"
  ],
  "contactPoint": {
    "@type": "ContactPoint",
    "contactType": "Customer Service",
    "email": "support@travelreview.vn",
    "telephone": "+84-123-456-789"
  }
}
  </script>
  
  <!-- Homepage Schema -->
  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "TravelReview",
  "url": "https://travelreview.vn",
  "description": "Khát phá, so sánh, đặt tour du lịch với review từ người thực",
  "potentialAction": {
    "@type": "SearchAction",
    "target": {
      "@type": "EntryPoint",
      "urlTemplate": "https://travelreview.vn/search?q={search_term_string}"
    },
    "query-input": "required name=search_term_string"
  }
}
  </script>
</head>
<body>
  <!-- H1: Một tiêu đề chính duy nhất -->
  <h1>TravelReview - Nền tảng Review Du Lịch #1 Việt Nam</h1>
  
  <!-- H2: Các phần nội dung chính -->
  <h2>Khám Phá 8500+ Tours Du Lịch</h2>
  <p>...</p>
  
  <h2>125k+ Review từ Người Việt Chân Thực</h2>
  <p>...</p>
  
  <h2>Đặt Tour An Toàn Với Operator Đã Xác Minh</h2>
  <p>...</p>
  
  <!-- Product Schema cho Travel Package -->
  <script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "TouristTrip",
  "name": "Đà Nẵng - Bà Nà Hills 3N2Đ",
  "description": "Tour 3 ngày 2 đêm khám phá Đà Nẵng, cáp treo Bà Nà Hills",
  "image": "https://travelreview.vn/tours/da-nang-ba-na.jpg",
  "url": "https://travelreview.vn/tour/da-nang-ba-na-hills",
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.9",
    "ratingCount": 2341,
    "bestRating": "5",
    "worstRating": "1"
  },
  "offers": {
    "@type": "PriceSpecification",
    "priceCurrency": "VND",
    "price": "1290000"
  },
  "organizer": {
    "@type": "Organization",
    "name": "Vietravel",
    "url": "https://travelreview.vn/operator/vietravel"
  },
  "itinerary": [
    {
      "@type": "Place",
      "name": "Đà Nẵng"
    },
    {
      "@type": "Place",
      "name": "Bà Nà Hills"
    }
  ]
}
  </script>
</body>
</html>
```

---

## 3. Flutter App Deep Linking & App Indexing

### iOS Info.plist
```xml
<dict>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>travelreview</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>travelreview</string>
            </array>
        </dict>
    </array>
</dict>
```

### Android AndroidManifest.xml
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="https" android:host="travelreview.vn" />
    <data android:pathPrefix="/tour/" />
    <data android:pathPrefix="/operator/" />
</intent-filter>
```

### Flutter go_router Deep Links
```dart
GoRoute(
  path: '/tour/:tourId',
  builder: (context, state) => TourDetailScreen(
    tourId: state.pathParameters['tourId']!,
  ),
  // App Indexing metadata
  metadata: {
    'title': 'Tour Detail',
    'description': 'Chi tiết tour du lịch',
  },
),
```

---

## 4. Admin SEO Manager Tool Features

✅ **H1/H2 Manager**: Xây dựng cấu trúc heading đúng chuẩn  
✅ **Meta Tags Editor**: Title, Description, Keywords, OpenGraph  
✅ **Canonical URL**: Tránh duplicate content  
✅ **JSON-LD Schema**: Tạo structured data tự động  
✅ **SEO Score**: Tính điểm 0-100 (dưới 60 = cảnh báo)  
✅ **Preview**: Xem preview Google Search Result  
✅ **Robots.txt Manager**: Quản lý robots directives  
✅ **Sitemap Generator**: Auto-generate từ database  

---

## 5. Best Practices - "AIO" (All-In-One SEO)

| Tính năng | Mục đích | Priority |
|----------|---------|----------|
| **H1 Unique** | 1 title/page, khác title tag | 🔴 Critical |
| **H2/H3 Hierarchy** | Cấu trúc logic nội dung | 🔴 Critical |
| **Meta Description** | 120-160 ký tự, CTA | 🔴 Critical |
| **Canonical URL** | Avoid duplicate (www vs non-www) | 🟠 High |
| **Schema.org JSON-LD** | Rich snippets trên Google | 🟠 High |
| **OpenGraph Meta** | Better share (Facebook, etc) | 🟡 Medium |
| **Mobile Responsive** | CLS, LCP, FID scores | 🔴 Critical |
| **Page Speed** | Lighthouse > 80 | 🔴 Critical |
| **Internal Linking** | Đầu tiên link H1/H2 keywords | 🟠 High |
| **Alt Text** | Tất cả <img> phải có alt="" | 🟠 High |
| **Sitemaps** | XML + HTML sitemap | 🟡 Medium |
| **Robots.txt** | Disallow admin, /api, etc | 🟡 Medium |

---

## 6. Monitoring & Testing

### Tools
- **Google Search Console** (https://search.google.com/search-console)
- **Google PageSpeed Insights** (https://pagespeed.web.dev)
- **Lighthouse CLI** (npm install -g lighthouse)
- **SEMrush / Ahrefs** (Competitor analysis)

### Commands
```bash
# Lighthouse audit
lighthouse https://travelreview.vn --view

# Validate Schema at scale
for tour_id in {1..100}; do
  curl -s "https://travelreview.vn/tour/$tour_id" | grep 'schema.org' | wc -l
done

# Sitemap test
curl -s https://travelreview.vn/sitemap.xml | grep '<url>' | wc -l
```

---

## 7. Frontend Checklist

- [ ] Meta header tags render on server (SSR/SSG)
- [ ] OG images 1200x630px, < 1MB
- [ ] Canonical URLs absolute (not relative)
- [ ] No JavaScript errors blocking crawlers
- [ ] H1/H2 in proper hierarchy (no gaps)
- [ ] Internal links to related tours/operators
- [ ] 404 pages have proper meta redirect
- [ ] Breadcrumb structured data
- [ ] Image lazy-loading with alt text
- [ ] Mobile viewport meta tag

---

## 8. next-seo / flutter_seo Integration

Thêm vào `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_seo: ^1.0.0  # Auto-generate meta tags từ Flutter
```

Hoặc dùng `web_server` tách biệt (Next.js / Express):
```javascript
// Express server làm SSR cho meta tags
app.get('/tour/:id', async (req, res) => {
  const tour = await getTourFromDB(req.params.id);
  const html = renderMetaTags({
    title: tour.name,
    description: tour.description,
    image: tour.heroImage,
    url: `https://travelreview.vn/tour/${tour.id}`,
  });
  res.send(html);
});
```

---

Hãy dùng Admin SEO Manager để:
1. Tối ưu từng trang (title, H1, description)
2. Tạo JSON-LD schema tự động
3. Kiểm tra SEO score

Kết hợp web robots.txt + sitemap → **AIO SEO Mastery** 🚀

