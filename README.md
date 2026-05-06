# TravelReview App

[![CI: Deploy to GitHub Pages](https://github.com/tantrung604-byte/travelreview/actions/workflows/deploy_web.yml/badge.svg)](https://github.com/tantrung604-byte/travelreview/actions/workflows/deploy_web.yml)

Ứng dụng Flutter (Android/iOS/Web) sử dụng **Firebase** + **Riverpod 3.x**.

Hiện project đã có:
- Web build với metadata SEO/AIO trong `web/index.html`.
- `web/robots.txt` và `web/sitemap.xml` cho Google Search Console.
- Routing production-ready bằng `go_router`.
- Admin Portal demo có **Theme Customizer** và **SEO Manager** quản lý H1/H2/meta/schema.
- Android APK/AAB release build.

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                       # Entry point + ProviderScope + Firebase init
├── app/
│   ├── app.dart                    # MaterialApp.router + Theme root
│   └── router/
│       └── app_router.dart         # go_router routes
├── core/
│   ├── seo/
│   │   └── seo_config.dart         # SEO metadata + score + JSON-LD helpers
│   └── firebase/
│       └── firebase_providers.dart # Provider cho Auth/Firestore/Storage
└── features/
    ├── admin/                      # Admin Portal + SEO Manager + theme customizer
    ├── legal/                      # Legal hub + privacy/terms renderer
    └── home/
        ├── home_screen.dart
        └── home_providers.dart
```

## 🔥 Cấu hình Firebase (Bắt buộc trước khi chạy)

1. Cài đặt FlutterFire CLI:
   ```powershell
   dart pub global activate flutterfire_cli
   ```
2. Đăng nhập Firebase CLI (nếu chưa):
   ```powershell
   npm install -g firebase-tools
   firebase login
   ```
3. Tạo / chọn project và sinh `firebase_options.dart`:
   ```powershell
   flutterfire configure --project=<your-firebase-project-id>
   ```
4. Mở `lib/main.dart` và uncomment 2 dòng:
   ```dart
   import 'firebase_options.dart';
   ...
   options: DefaultFirebaseOptions.currentPlatform,
   ```

## 🚀 Chạy ứng dụng

```powershell
flutter pub get
flutter run
```

## 🧭 Routing

Routes chính hiện có:

| Route | Màn hình |
|---|---|
| `/` | Home / launcher |
| `/discover` | User Discover |
| `/search` | Search |
| `/tour/:tourId` | Tour Detail |
| `/booking/:tourId` | Booking flow |
| `/legal` | Legal Hub |
| `/admin` | Admin Portal |
| `/admin/seo` | Admin SEO Manager |

## 🏗️ Code generation cho Riverpod (nếu dùng `@riverpod`)

```powershell
dart run build_runner watch -d
```

## 📦 Build Release

```powershell
flutter analyze
flutter test
flutter build web --release --base-href /
flutter build apk --release
flutter build appbundle --release
```

Hoặc chạy script tổng hợp:

```powershell
.\scripts\build_release.ps1
```

Artifacts sau khi build:

| Platform | Output |
|---|---|
| Web | `build/web/` |
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | `build/app/outputs/bundle/release/app-release.aab` |

> Lưu ý: Android release hiện vẫn dùng signing mặc định/debug của Flutter nếu chưa cấu hình keystore production. Trước khi upload Play Console, hãy cấu hình `key.properties` và signing config release.

## 🔎 SEO / AIO Web

Files chính:

- `web/index.html`: meta title/description, Open Graph, Twitter Card, JSON-LD, fallback H1/H2 trong `<noscript>`.
- `web/robots.txt`: rule crawl và sitemap URL.
- `web/sitemap.xml`: sitemap tĩnh ban đầu.
- `docs/SEO_AND_AIO_GUIDE.md`: hướng dẫn mở rộng sitemap động, schema tour, deep link app.

Admin Portal có menu **🔍 SEO Manager** để quản lý:

- H1 duy nhất của trang.
- Danh sách H2 sections.
- Meta title/description/keywords.
- Canonical URL.
- OG image.
- JSON-LD schema.
- Robots noindex.
- SEO score 0–100 và preview kết quả Google.

## 🛠️ Admin Portal

Admin Portal đã được tách khỏi trang user-facing production. Link riêng:

| Môi trường | URL |
|---|---|
| Flutter dev | `http://localhost:<port>/admin` |
| Production domain | `https://<your-domain>/admin` |
| SEO Manager | `/admin/seo` |

> Khi deploy static web hosting, cấu hình rewrite/fallback mọi route như `/admin`, `/discover`, `/tour/...` về `index.html` để `go_router` xử lý client-side route.

Mặc định Home **không hiển thị** nút Admin. Nếu cần bật nút Admin trong dev/test:

```powershell
flutter run -d chrome --dart-define=SHOW_ADMIN_ENTRY=true
```

Hoặc build web nội bộ có nút Admin:

```powershell
flutter build web --release --base-href / --dart-define=SHOW_ADMIN_ENTRY=true
```

Trong Admin:

- **Đổi giao diện**: đổi màu chủ đạo, sáng/tối, cỡ chữ, tương phản, mật độ UI.
- **SEO Manager**: quản trị SEO cho web/app landing pages.
- Dashboard demo: KPI cards, queue duyệt KYC, admin nav.

## 🧰 Dependencies chính

| Package | Vai trò |
|---|---|
| `flutter_riverpod` | State management |
| `riverpod_annotation` + `riverpod_generator` | Codegen Provider |
| `firebase_core` | Khởi tạo Firebase |
| `firebase_auth` | Đăng nhập / xác thực |
| `cloud_firestore` | Database NoSQL |
| `firebase_storage` | Lưu ảnh / file |

## 📝 Package name
- Android/iOS bundle ID: `com.travelreview.travelreview_app`
