# Kế hoạch UX/UI & Kiến trúc Code — TravelReview App

> Tài liệu này phân tích tính năng, thiết kế UX/UI và đề xuất kiến trúc code Flutter (Riverpod + Firebase) tối ưu cho **mobile + web**. Trạng thái hiện tại của repo: chỉ có `HomeScreen` mẫu (counter), `firebase_providers.dart` đã wrap Auth/Firestore/Storage, `main.dart` init Firebase trong try/catch — chưa có routing, theme system, model, hay feature module thực.

---

## 1. Phân tích tính năng (Feature Analysis)

### 1.1 Bản đồ tính năng

| Nhóm | Tính năng | Mô tả ngắn | Ưu tiên |
|---|---|---|---|
| Auth | Đăng ký/đăng nhập email, Google, Apple, ẩn danh | Firebase Auth, persistence khác nhau giữa web/mobile | **MVP** |
| Discover | Home feed địa điểm gợi ý (theo vị trí, trending, category) | Firestore query + pagination | **MVP** |
| Search | Tìm kiếm theo tên/category/city + filter (rating, giá, khoảng cách) | Algolia/Typesense hoặc Firestore composite index | **MVP** |
| Place Detail | Ảnh hero, mô tả, rating tổng, danh sách review, mini map | Firestore doc + subcollection reviews | **MVP** |
| Review CRUD | Tạo/sửa/xóa review: rating sao, text, multi-image | Storage upload + Firestore write | **MVP** |
| Map | Bản đồ với marker địa điểm, cluster | google_maps_flutter + web variant | **MVP** |
| Bookmark | Lưu địa điểm yêu thích | Subcollection `users/{uid}/bookmarks` | **MVP** |
| Profile | Thông tin user, review của tôi, bookmark | | **MVP** |
| Notifications | Push (like, comment, follow) | FCM + APNs/Web Push | Phase 2 |
| Social | Follow user, like/comment review | Subcollections + counters | Phase 2 |
| Trip Planner | Tạo lịch trình nhiều điểm | Có thể tái dùng bookmark | Phase 3 |
| AI Recommend | Gợi ý dựa trên lịch sử | Cloud Functions + embeddings | Phase 3 |
| i18n | vi / en | flutter_localizations | **MVP** |
| Offline | Cache list/detail | Firestore persistence + Hive | Phase 2 |

### 1.2 Personas chính
- **Khách du lịch (reader):** lướt feed, xem review, bookmark.
- **Reviewer tích cực:** đăng nhiều bài, theo dõi, được follow.
- **Khách vãng lai web:** vào từ Google Search → cần SEO + URL đẹp + không bắt login.

---

## 2. Thiết kế UX/UI

### 2.1 Information Architecture

```
Root
├── /onboarding            (lần đầu mở app)
├── /auth (login/register/forgot)
├── /  (Shell với bottom nav / nav rail)
│   ├── /home              tab Discover
│   ├── /search            tab Search + Map toggle
│   ├── /create-review     FAB ở giữa (mobile) / nút trên rail (web)
│   ├── /bookmarks         tab Saved
│   └── /profile           tab Me
├── /place/:id             detail (deep-linkable)
├── /review/:id            detail review
├── /user/:uid             profile public
└── /settings
```

### 2.2 User flow chính

1. **Onboarding → Home:** 3 slide intro → hỏi quyền vị trí → vào Home (cho phép browse trước khi login).
2. **Discover → Place Detail → Write Review:** tap card → xem detail → nút "Viết review" → form (rating, text, ảnh) → submit → quay về detail với review mới ở top.
3. **Search & Map:** nhập keyword → list/map toggle → tap marker → bottom sheet preview → mở detail.
4. **Bookmark:** tap icon trái tim trên card hoặc detail → toggle, animation, lưu Firestore.

### 2.3 Wireframe (mô tả layout)

**Home (mobile):**
```
┌─────────────────────────────┐
│ AppBar: Logo  🔔  👤        │
├─────────────────────────────┤
│ 🔍 Search bar (giả)         │
│ ─ Categories chips ─────────│
│ [Beach][Food][Hotel][Cafe]…│
│                             │
│ "Trending gần bạn"          │
│ ┌──────┐ ┌──────┐ ┌──────┐ │
│ │ card │ │ card │ │ card │ │  ← horizontal list
│ └──────┘ └──────┘ └──────┘ │
│ "Mới review"                │
│ ┌─────────────────────────┐ │
│ │ vertical place card     │ │  ← ListView.builder
│ └─────────────────────────┘ │
│ … pagination …              │
├─────────────────────────────┤
│ 🏠   🔍   ➕   ❤   👤       │  Bottom nav
└─────────────────────────────┘
```

**Home (web/desktop ≥1024):**
```
┌─────────────────────────────────────────────────────┐
│ TopBar: Logo  Search──────────  Login | Avatar      │
├──┬──────────────────────────────────────────────────┤
│🏠│  Hero banner / category grid                     │
│🔍│ ┌────┬────┬────┬────┐                            │
│➕│ │card│card│card│card│  ← GridView 4 cột          │
│❤ │ └────┴────┴────┴────┘                            │
│👤│ "Trending"                                        │
│  │ …                                                │
└──┴──────────────────────────────────────────────────┘
   NavigationRail extended    Content max-width 1200
```

**Place Detail:**
- `SliverAppBar` với hero image (mobile) / two-column (web: ảnh trái, info phải sticky).
- Section: tiêu đề + rating + địa chỉ + nút (Bookmark, Share, Direction).
- Mini map (height 180).
- Tabs: Tổng quan | Reviews | Ảnh.
- Bottom action bar mobile: "Viết review" sticky.

**Write Review:**
- Stepper 2 bước (Rating + Text → Ảnh) trên mobile; single page form trên web.
- Multi-image picker với reorder, crop.

### 2.4 Design System

**Color (theme du lịch — biển/rừng):**

| Token | Light | Dark |
|---|---|---|
| seed | `#0E7C66` (teal) | giữ nguyên |
| primary | M3 generated | M3 generated |
| secondary accent | `#F2A65A` (sandy orange) | `#FFB877` |
| surface | `#FAFAF7` | `#121514` |
| error | `#B3261E` | `#F2B8B5` |

Dùng `ColorScheme.fromSeed(seedColor: ..., brightness: ...)` cho cả light/dark.

**Typography:** `GoogleFonts.plusJakartaSans` (display) + `inter` (body), scale Material 3 (`displayLarge`…`labelSmall`). Title địa điểm: `headlineSmall` bold.

**Spacing scale:** 4 / 8 / 12 / 16 / 24 / 32 / 48 (token `AppSpacing`).

**Component library (shared/widgets):**
- `PlaceCard` (variant: horizontal, vertical, grid)
- `RatingStars` (read + interactive)
- `ReviewTile`
- `AppSearchBar`
- `CategoryChipBar`
- `ResponsiveScaffold` (xem §3)
- `LoadingShimmer`, `EmptyState`, `ErrorState`

### 2.5 Responsive breakpoints

| Tên | Width | Layout |
|---|---|---|
| compact (mobile) | < 600 | BottomNav, 1 cột, FAB |
| medium (tablet) | 600–1024 | NavigationRail (collapsed), 2 cột |
| expanded (web) | 1024–1440 | NavigationRail extended, 3–4 cột grid |
| large | ≥1440 | Center content max-width 1280, 4 cột |

Sử dụng `flutter_adaptive_scaffold` hoặc tự build `LayoutBuilder` (xem snippet §6.1).

### 2.6 Dark mode & Accessibility
- `ThemeMode.system` + toggle trong Settings, lưu vào `SharedPreferences`.
- Tương phản WCAG AA (≥4.5:1 cho text).
- `Semantics` label cho icon-only buttons; `MergeSemantics` cho card.
- Min tap target 48×48; focus traversal cho web (keyboard nav, `Shortcuts`/`Actions`).
- Hỗ trợ `MediaQuery.textScaler` (không hardcode font size theo px).

---

## 3. Kiến trúc code & tối ưu mobile + web

### 3.1 Cấu trúc thư mục đề xuất (feature-first)

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── app.dart
│   ├── router.dart                 (go_router)
│   └── theme/
│       ├── app_theme.dart
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       └── app_typography.dart
├── core/
│   ├── firebase/firebase_providers.dart
│   ├── network/                    (dio / retry interceptors nếu cần API ngoài)
│   ├── storage/                    (hive boxes, prefs)
│   ├── platform/                   (kIsWeb helpers, image_picker_web stub)
│   ├── utils/                      (formatters, validators, geo)
│   └── errors/                     (Failure, exceptions)
├── shared/
│   ├── widgets/                    (PlaceCard, RatingStars…)
│   └── layout/                     (ResponsiveScaffold)
├── l10n/
│   ├── app_en.arb
│   └── app_vi.arb
└── features/
    ├── auth/
    │   ├── data/    (auth_repository.dart)
    │   ├── domain/  (app_user.dart - freezed)
    │   ├── application/ (auth_controller.dart - AsyncNotifier)
    │   └── presentation/ (login_screen.dart, register_screen.dart)
    ├── home/
    ├── place/
    │   ├── data/place_repository.dart
    │   ├── domain/place.dart
    │   ├── application/places_controller.dart
    │   └── presentation/{place_detail_screen,widgets}
    ├── review/
    ├── search/
    ├── map/
    ├── bookmark/
    ├── profile/
    └── notifications/
```

Mỗi feature theo lớp **data / domain / application / presentation** (clean-lite).

### 3.2 State management — Riverpod 2.x/3.x

- Dùng `Notifier` / `AsyncNotifier` thay cho `StateNotifier`.
- Dùng `riverpod_annotation` + codegen (`@riverpod`) để giảm boilerplate.
- `family` cho provider phụ thuộc tham số (placeId, userId).
- `autoDispose` cho màn hình tạm thời (detail, form).
- `ref.watch(provider.select((s) => s.field))` để giảm rebuild.

### 3.3 Firestore data model

```
users/{uid}
  displayName, avatarUrl, bio, followersCount, followingCount, createdAt

places/{placeId}
  name, slug, description, category, geo (GeoPoint), city, country,
  ratingAvg, ratingCount, coverImage, photos[], createdBy, createdAt

places/{placeId}/reviews/{reviewId}
  authorId, rating, text, photos[], likeCount, createdAt, updatedAt

users/{uid}/bookmarks/{placeId}
  placeId, addedAt, snapshot { name, cover, rating } // denormalize

users/{uid}/notifications/{nid}
  type, fromUid, payload, read, createdAt

follows/{followerUid_followingUid}  // composite ID

likes/{reviewId}_{uid}
```

**Index:** composite `places (category ASC, ratingAvg DESC)`, `(city ASC, ratingAvg DESC)`, geohash field cho near-by query.

**Security rules tóm tắt:** chỉ chủ sở hữu mới sửa review/bookmark; place chỉ admin tạo (hoặc verified user); read public.

### 3.4 Routing — go_router với ShellRoute

- `StatefulShellRoute.indexedStack` bao 5 tab chính, giữ state.
- Deep link: `/place/:id` mở app từ web URL hoặc dynamic links.
- Redirect dựa vào `authStateProvider` để chặn trang yêu cầu login.
- Trên web: bật `usePathUrlStrategy()` để URL không có `#`.

### 3.5 Khác biệt mobile vs web

| Vấn đề | Mobile | Web |
|---|---|---|
| Image picker | `image_picker` | `image_picker` (hỗ trợ web) hoặc `file_picker` |
| File upload | `File` (`dart:io`) | `XFile.readAsBytes()` → `putData` |
| Persistence Auth | mặc định | `Persistence.LOCAL` cần set rõ |
| Maps | `google_maps_flutter` | `google_maps_flutter_web` + JS API key trong `index.html` |
| Push | FCM native | FCM web (service worker) |
| Camera | có | thường không, fallback chọn ảnh |
| Routing URL | không quan trọng | path strategy + SEO meta |
| Renderer | Skia | CanvasKit / WASM |

**Conditional import:**
```dart
import 'image_picker_stub.dart'
  if (dart.library.io) 'image_picker_io.dart'
  if (dart.library.html) 'image_picker_web.dart';
```

### 3.6 Tối ưu hiệu năng

- `const` constructor mọi widget tĩnh.
- `ListView.builder` + `itemExtent` khi biết chiều cao → scroll mượt.
- `CachedNetworkImage` + `memCacheWidth` để giảm RAM.
- Compress ảnh trước upload (`flutter_image_compress` mobile, canvas resize web).
- **Pagination** Firestore: `limit(20).startAfterDocument(lastDoc)`.
- Bật Firestore offline persistence (mobile mặc định; web cần IndexedDB).
- Riverpod `select` + `family.autoDispose` để giải phóng memory khi rời màn hình.
- **Web-only:** deferred loading cho feature ít dùng:
  ```dart
  import 'features/map/map_screen.dart' deferred as map_feat;
  await map_feat.loadLibrary();
  ```
  giảm initial JS bundle đáng kể.
- Tree-shake icons: dùng `Icons.*` của Material, tránh import package icon lớn không cần.
- Build web: `flutter build web --wasm` (Flutter ≥3.22) cho hiệu năng cao; CanvasKit cho UI giàu hình ảnh.
- Code-split routes với `go_router` + deferred imports cho từng route nặng.

### 3.7 Offline & cache
- Firestore offline persistence (mobile mặc định, web qua IndexedDB).
- `Hive` lưu: bookmarks, last viewed places, draft review.
- Optimistic UI: cập nhật state trước, sync sau, rollback nếu lỗi.

### 3.8 i18n
- `flutter_localizations` + `intl` + `gen_l10n`.
- `app_en.arb`, `app_vi.arb` trong `lib/l10n/`.
- `MaterialApp.router(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: [...])`.

### 3.9 Testing
- **Unit:** test Notifier với `ProviderContainer` + override repository (mock).
- **Widget:** golden test cho `PlaceCard` ở 3 breakpoint.
- **Integration:** `firebase_auth_mocks`, `fake_cloud_firestore`.
- CI: GitHub Actions chạy `flutter analyze`, `flutter test`, build web preview.

---

## 4. Packages đề xuất

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  hooks_riverpod: ^2.5.1
  flutter_hooks: ^0.20.5
  riverpod_annotation: ^2.3.5

  go_router: ^14.0.0

  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_messaging: ^15.0.0
  firebase_analytics: ^11.0.0

  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0

  cached_network_image: ^3.3.1
  image_picker: ^1.1.0
  image_cropper: ^7.0.0
  flutter_image_compress: ^2.3.0

  google_maps_flutter: ^2.6.0
  google_maps_flutter_web: ^0.5.7

  flutter_adaptive_scaffold: ^0.3.0   # hoặc responsive_framework: ^1.4.0
  google_fonts: ^6.2.1
  shimmer: ^3.0.0
  intl: ^0.19.0
  shared_preferences: ^2.2.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  url_launcher: ^6.2.6
  share_plus: ^9.0.0

dev_dependencies:
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.10
  fake_cloud_firestore: ^3.0.0
  firebase_auth_mocks: ^0.14.0

flutter:
  generate: true   # cho gen_l10n
```

---

## 5. Roadmap theo Sprint (mỗi sprint ~2 tuần)

| Sprint | Mục tiêu | Deliverable |
|---|---|---|
| **0 – Setup** | flutterfire configure, theme, router shell, l10n, CI | App chạy trên Android/iOS/Web với 5 tab rỗng + dark mode |
| **1 – Auth + Profile** | Email/Google sign-in, profile screen, route guard | Login/Logout hoạt động, persistence cả web |
| **2 – Places & Home feed** | Place model, repository, pagination, PlaceCard, Discover | Home + Detail có data thật từ Firestore |
| **3 – Reviews + Bookmark** | CRUD review, upload ảnh (mobile+web), bookmark | User có thể đăng review, lưu địa điểm |
| **4 – Search + Map** | Search filter, GoogleMap mobile/web, marker cluster | Tab Search + bản đồ |
| **5 – Notifications + Social** | FCM, follow, like/comment | Push hoạt động đa nền tảng |
| **6 – Polish & Launch** | Performance audit, golden tests, SEO web, analytics, store release | Build production cho 3 nền tảng |

---

## 6. Code snippet mẫu

### 6.1 ResponsiveScaffold (BottomNav ↔ NavigationRail)

```dart
class ResponsiveScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavDestination> destinations;
  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        if (w < 600) {
          return Scaffold(
            body: child,
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(icon: Icon(d.icon), label: d.label),
              ],
            ),
          );
        }
        final extended = w >= 1024;
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                extended: extended,
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                destinations: [
                  for (final d in destinations)
                    NavigationRailDestination(
                      icon: Icon(d.icon),
                      label: Text(d.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### 6.2 AsyncNotifier có pagination cho Places

```dart
@immutable
class PlacesState {
  final List<Place> items;
  final bool hasMore;
  final DocumentSnapshot? cursor;
  const PlacesState({this.items = const [], this.hasMore = true, this.cursor});

  PlacesState copyWith({List<Place>? items, bool? hasMore, DocumentSnapshot? cursor}) =>
      PlacesState(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        cursor: cursor ?? this.cursor,
      );
}

class PlacesController extends AsyncNotifier<PlacesState> {
  static const _pageSize = 20;

  @override
  Future<PlacesState> build() => _fetch(const PlacesState());

  Future<PlacesState> _fetch(PlacesState prev) async {
    final db = ref.read(firestoreProvider);
    var q = db.collection('places')
        .orderBy('ratingAvg', descending: true)
        .limit(_pageSize);
    if (prev.cursor != null) q = q.startAfterDocument(prev.cursor!);
    final snap = await q.get();
    final newItems = snap.docs.map((d) => Place.fromDoc(d)).toList();
    return prev.copyWith(
      items: [...prev.items, ...newItems],
      cursor: snap.docs.isNotEmpty ? snap.docs.last : prev.cursor,
      hasMore: snap.docs.length == _pageSize,
    );
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || !cur.hasMore || state.isLoading) return;
    state = const AsyncLoading<PlacesState>().copyWithPrevious(state);
    state = await AsyncValue.guard(() => _fetch(cur));
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(const PlacesState()));
  }
}

final placesControllerProvider =
    AsyncNotifierProvider<PlacesController, PlacesState>(PlacesController.new);
```

### 6.3 GoRouter shell route cơ bản

```dart
final goRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(
      ref.read(firebaseAuthProvider).authStateChanges(),
    ),
    redirect: (ctx, state) {
      final loggedIn = auth.value != null;
      final goingAuth = state.matchedLocation.startsWith('/auth');
      if (!loggedIn && _needsAuth(state.matchedLocation)) return '/auth/login';
      if (loggedIn && goingAuth) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/place/:id',
        builder: (_, s) => PlaceDetailScreen(id: s.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/search', builder: (_, __) => const SearchScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/create', builder: (_, __) => const CreateReviewScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/bookmarks', builder: (_, __) => const BookmarksScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
        ],
      ),
    ],
  );
});

bool _needsAuth(String path) =>
    path.startsWith('/create') || path.startsWith('/bookmarks') || path.startsWith('/profile');
```

Trong `main.dart` thêm: `usePathUrlStrategy();` (từ `package:flutter_web_plugins/url_strategy.dart`) khi `kIsWeb`.

---

## 7. Lưu ý thêm (Further Considerations)

1. **Search backend:** Firestore filter hạn chế (không full-text). Khuyến nghị **Algolia** hoặc **Typesense** cho search nâng cao; MVP có thể dùng prefix query trên `nameLowercase`.
2. **Maps cost:** Google Maps tính phí. Cân nhắc **Mapbox** hoặc **MapLibre + OSM** cho web để giảm chi phí.
3. **Codegen vs viết tay:** dùng `riverpod_annotation` + `freezed` tiết kiệm code nhưng tốn build time; team nhỏ nên cân nhắc viết tay cho provider đơn giản.
4. **Renderer web:** Flutter đang chuẩn hóa CanvasKit/WASM; nên test sớm với `--wasm` để tránh refactor sau.
5. **SEO web:** Flutter Web khó SEO. Nếu landing/place detail cần index Google → cân nhắc tách trang đó sang Next.js hoặc dùng SSR proxy + dynamic meta.

---

# 📦 PHẦN MỞ RỘNG — Hướng Thương mại điện tử (Bán Tour) + Tích hợp AI

> Mở rộng app từ "review địa điểm" thành **marketplace bán tour du lịch** với nhiều **nhà cung cấp (Tour Operator)**, kết hợp review của người dùng (UGC) làm bằng chứng xã hội (social proof) và **AI** làm trợ lý cá nhân hóa, tìm kiếm, hỗ trợ khách hàng.

---

## 8. Mô hình kinh doanh & vai trò người dùng

### 8.1 Mô hình
- **Marketplace 2 mặt (two-sided):** Khách hàng (Traveler) ↔ Công ty du lịch (Tour Operator / Supplier).
- **Doanh thu:**
  - Hoa hồng (commission) trên mỗi booking thành công (gợi ý 8–15%).
  - Gói nâng cấp hiển thị (featured listing, top search).
  - Quảng cáo ngữ cảnh (sponsored tour trong AI chat).
  - Phí dịch vụ thanh toán (1–2%).
- **Trust layer:** review từ khách đã book (verified review) + rating Operator → KPI quyết định ranking.

### 8.2 Roles (RBAC)

| Role | Quyền chính |
|---|---|
| `guest` | Browse tour, đọc review, chat AI giới hạn |
| `traveler` | Book, thanh toán, viết review verified, wishlist, chat với operator |
| `operator_staff` | Tạo/sửa tour của công ty, quản lý booking, trả lời review/chat |
| `operator_admin` | + quản lý nhân viên, payout, analytics công ty |
| `platform_admin` | Duyệt operator, dispute, payout, kiểm duyệt nội dung |
| `ai_agent` (system) | Tự động trả lời, đề xuất, nhưng có guardrail |

---

## 9. Tính năng e-commerce bổ sung

### 9.1 Bảng tính năng

| Nhóm | Tính năng | Ưu tiên |
|---|---|---|
| **Catalog tour** | Tour listing với giá, lịch khởi hành, số chỗ còn | **MVP-EC** |
| | Variants (option ngày, hạng phòng, có/không vé máy bay) | MVP-EC |
| | Rich content: itinerary từng ngày, ảnh, video, bản đồ tuyến | MVP-EC |
| | Inclusions/Exclusions, chính sách hủy, điều kiện sức khỏe | MVP-EC |
| **Operator portal** | Onboarding KYC công ty (giấy phép lữ hành) | MVP-EC |
| | Dashboard: tour, booking, doanh thu, review | MVP-EC |
| | Quản lý lịch khởi hành (departure inventory) | MVP-EC |
| **Booking flow** | Chọn ngày → số khách (adult/child/infant) → option → thông tin hành khách → thanh toán | MVP-EC |
| | Hold chỗ tạm thời (15 phút) khi checkout | MVP-EC |
| | E-voucher PDF + QR check-in | MVP-EC |
| **Payment** | Thẻ (Stripe/2C2P), VNPay, MoMo, ZaloPay, Apple/Google Pay | MVP-EC |
| | Đặt cọc 30% / Trả góp (BNPL) | Phase 2 |
| | Đa tiền tệ (VND/USD), tỷ giá realtime | Phase 2 |
| **Cart & Wishlist** | Giỏ hàng đa tour, wishlist | MVP-EC |
| **Review verified** | Chỉ user đã hoàn tất tour mới review được | **MVP-EC** |
| | Operator reply, helpful vote, report abuse | MVP-EC |
| **Promo & Loyalty** | Coupon, flash sale, referral, point đổi voucher | Phase 2 |
| **Hỗ trợ khách hàng** | Chat traveler ↔ operator, AI 1st-line | MVP-EC |
| | Hủy/đổi tour, refund flow, dispute | MVP-EC |
| **Notifications** | Booking confirmed, payment, reminder T-3 ngày, review request | MVP-EC |
| **Analytics** | Operator: views, conversion, AOV; Platform: GMV, take rate | MVP-EC |
| **Compliance** | GDPR/PDPL, hóa đơn VAT, lưu hợp đồng điện tử | MVP-EC |

### 9.2 Funnel chính (e-commerce)

```
Discover → Tour Detail → Select date/option → Cart/Checkout
   → Payment → Confirmation → Pre-trip reminder → Post-trip Review
```

### 9.3 KPI cần đo
- **Conversion rate** (Detail → Book), **AOV**, **GMV**, **Take rate**, **Refund rate**.
- **NPS**, **Repeat booking rate**, **Operator response time**.
- **AI:** chat→book rate, suggest CTR, search zero-result rate.

---

## 10. Kiến trúc dữ liệu mở rộng (Firestore)

```
operators/{operatorId}
  legalName, brand, logo, licenseNo, kycStatus, ratingAvg, ratingCount,
  payoutAccount(stripeAccountId), createdAt, status

operators/{operatorId}/staff/{uid}
  role, email, addedAt

tours/{tourId}
  operatorId, title, slug, summary, description (rich),
  category[], destinations[], durationDays, durationNights,
  basePrice, currency, taxIncluded,
  images[], videoUrl, mapPolyline,
  inclusions[], exclusions[], itinerary [{day, title, desc, places[]}],
  cancellationPolicyId, healthRequirements,
  ratingAvg, ratingCount, soldCount, viewCount,
  status (draft|published|paused), featured, createdAt, updatedAt,
  searchKeywords[],            // for prefix search
  embedding (vector 1536)      // for AI semantic search

tours/{tourId}/departures/{departureId}
  startDate, endDate, priceAdult, priceChild, priceInfant,
  capacity, sold, available,   // inventory
  cutoffHours, status

tours/{tourId}/options/{optionId}
  name (vd "Phòng đơn", "Có vé máy bay"), priceDelta

tours/{tourId}/reviews/{reviewId}
  bookingId,                   // bắt buộc → verified
  authorId, rating, text, photos[], helpfulCount,
  operatorReply { text, at }, createdAt

bookings/{bookingId}
  travelerId, tourId, operatorId, departureId,
  passengers [{fullName, dob, passport, type}],
  options[], priceBreakdown {base, options, tax, discount, total},
  currency, paymentStatus (pending|paid|refunded|failed),
  bookingStatus (hold|confirmed|cancelled|completed),
  paymentIntentId, voucherCode, qr, holdExpiresAt,
  createdAt, updatedAt, timeline[]

payments/{paymentId}
  bookingId, gateway, amount, fee, netToOperator, platformCommission,
  status, raw, createdAt

carts/{uid}
  items [{tourId, departureId, options[], pax}], updatedAt

coupons/{code}
  type (percent|fixed), value, minOrder, maxDiscount,
  validFrom, validTo, perUserLimit, totalLimit, usedCount,
  appliesTo {tourIds?, operatorIds?, categories?}

conversations/{conversationId}        // chat traveler ↔ operator / AI
  participants[], lastMessage, updatedAt, type (support|sales|ai)

conversations/{cid}/messages/{mid}
  senderId, role (user|operator|ai|system),
  text, attachments[], toolCalls?, createdAt

aiSessions/{sessionId}                 // log AI cho audit + cải thiện
  uid, intent, messages[], suggestedTours[], tokensUsed, model, createdAt

audit_logs/{id} ...
```

**Index quan trọng:**
- `tours (status ASC, ratingAvg DESC)`, `(category ARRAY, ratingAvg DESC)`, `(destinations ARRAY, basePrice ASC)`.
- `departures (startDate ASC, available DESC)`.
- `bookings (travelerId, createdAt DESC)`, `(operatorId, bookingStatus, createdAt DESC)`.
- **Vector index** cho `tours.embedding` (Firestore Vector Search hoặc Pinecone/Qdrant ngoài).

**Security rules nguyên tắc:**
- `bookings`: traveler chỉ đọc của mình; operator chỉ đọc booking thuộc tour của mình.
- `tours` write: chỉ `operator_staff` của `operatorId` đó.
- `reviews` create: chỉ khi tồn tại `bookings` với `bookingStatus = completed` của user.
- Mọi mutation tiền (payment, refund, payout) **bắt buộc qua Cloud Functions** (server-authoritative), không cho client write trực tiếp.

---

## 11. Backend & dịch vụ mở rộng

Flutter + Firestore không đủ cho e-commerce nghiêm túc. Bổ sung:

| Thành phần | Công nghệ đề xuất |
|---|---|
| Serverless logic | **Cloud Functions for Firebase** (Node/TS) hoặc **Cloud Run** |
| Thanh toán | **Stripe Connect** (Standard/Express) cho marketplace + payout operator; tích hợp **VNPay/MoMo/ZaloPay** qua Cloud Functions |
| Search | **Algolia** hoặc **Typesense** (sync từ Firestore) — hỗ trợ filter, facet, geosearch |
| Vector / RAG | **Vertex AI Vector Search**, **Pinecone**, hoặc **Qdrant** |
| AI / LLM | **Gemini 1.5/2.x** (Vertex AI), **Azure OpenAI (GPT-4o/o-series)**, fallback **OpenAI** |
| Email/SMS | **SendGrid / Resend**, **Twilio** |
| File / ảnh | Firebase Storage + **Cloudflare Images** hoặc Imgix (resize on-the-fly) |
| Realtime | Firestore listeners + **Firebase Realtime DB** cho presence chat |
| Job queue | **Cloud Tasks** (release hold sau 15', gửi reminder) |
| Observability | Firebase Crashlytics + **Sentry** + GA4 + BigQuery export |
| Hợp đồng/PDF | Cloud Function dùng `pdfkit` / `puppeteer` |

**Sơ đồ booking (server-authoritative):**

```
Client → CF createBooking(hold) → Firestore (status=hold, holdExpiresAt=+15m)
       → CF createPaymentIntent(Stripe/VNPay) → return clientSecret/redirect
Client → Pay
Webhook (Stripe/VNPay) → CF onPaymentSucceeded
       → tx: bookings.status=confirmed, departures.sold+=N, available-=N
       → tạo voucher PDF, gửi email, push, queue reminder T-3
```

---

## 12. Tích hợp AI

### 12.1 Use case AI trọng tâm

| # | Use case | Mô tả | Mô hình / kỹ thuật |
|---|---|---|---|
| 1 | **AI Travel Concierge (chatbot)** | "Tôi có 5 ngày & 15 triệu, thích biển, đi tháng 7" → đề xuất tour, đặt giùm | LLM + **Function calling** + RAG trên catalog |
| 2 | **Semantic search** | Tìm "tour nghỉ dưỡng yên tĩnh cho gia đình có trẻ nhỏ" | Embedding + Vector Search + rerank |
| 3 | **Personalized recommendation** | Home feed cá nhân hóa | Two-tower / collaborative filtering + LLM rerank |
| 4 | **Dynamic itinerary planner** | Sinh lịch trình tự túc theo ngân sách | LLM + tool: distance matrix, weather, opening hours |
| 5 | **Review summarization** | "Tóm tắt 200 review của tour này" + sentiment + pros/cons | LLM tóm tắt định kỳ, cache vào doc |
| 6 | **Auto-translate review** | vi↔en↔ja↔ko realtime | Gemini/Azure Translator |
| 7 | **Image moderation & enhancement** | Lọc ảnh không hợp lệ, auto-tag | Vision API + safety filter |
| 8 | **Tour content generator** (operator) | Operator nhập bullet → AI viết mô tả SEO + itinerary | LLM với prompt template |
| 9 | **Pricing assistant** (operator) | Đề xuất giá theo demand + đối thủ | ML model + LLM giải thích |
| 10 | **Fraud / abuse detection** | Phát hiện review giả, booking gian lận | Embedding similarity + rule + LLM judge |
| 11 | **Voice search & STT** (mobile) | "Tìm tour Đà Nẵng dưới 5 triệu" | Speech-to-Text + intent → search |
| 12 | **AI Support agent** | Trả lời FAQ, escalate sang người thật | RAG trên policy + Function call hủy/đổi |

### 12.2 Kiến trúc AI (RAG + Tool calling)

```
┌────────────┐    intent + history     ┌──────────────────┐
│ Flutter UI │ ───────────────────────►│  Cloud Function  │
│ (chat,     │                         │  /aiChat (BFF)    │
│  search)   │◄──────── stream ────────│                  │
└────────────┘                         │  - Auth check     │
                                       │  - Rate limit     │
                                       │  - Build context  │
                                       └────────┬─────────┘
                                                │
                            ┌───────────────────┼───────────────────┐
                            ▼                   ▼                   ▼
                  ┌───────────────┐   ┌────────────────┐   ┌─────────────────┐
                  │ Vector Search │   │  LLM (Gemini/  │   │ Tools (functions)│
                  │ tours/embedding│   │  GPT-4o) stream│   │ - searchTours    │
                  └───────────────┘   └────────────────┘   │ - getDepartures  │
                            ▲                   ▲          │ - createBooking  │
                            │                   │          │ - getWeather     │
                            └─── retrieved docs ┘          │ - applyCoupon    │
                                                           └─────────────────┘
```

Pipeline:
1. Người dùng gửi câu hỏi (kèm filter UI: ngân sách, ngày).
2. CF `aiChat` xác thực user, áp **rate limit** (vd 30 msg / giờ với guest, 200 với traveler).
3. Sinh embedding query → **Vector Search top-K** trong `tours.embedding` → kèm metadata.
4. Build prompt: `system + user profile + retrieved tours + tools schema`.
5. LLM stream về client (SSE / Firestore listener trên `messages`).
6. Khi LLM gọi tool (vd `createBooking`), CF thực thi → trả kết quả vào hội thoại.
7. Lưu hội thoại + `aiSessions` để audit + fine-tune sau.

### 12.3 Sinh & cập nhật embedding cho tour

- Trigger Cloud Function `onWrite` của `tours/{id}` → khi `title/description/itinerary` đổi → gọi embedding API → ghi `tours.embedding`.
- Dùng model embedding 1024–1536 chiều (Gemini `text-embedding-004` / OpenAI `text-embedding-3-small`).
- Nightly job: re-embed tour có review mới >10 (vì semantic thay đổi).

### 12.4 Guardrails & Trust

- **Không cho AI tự ý thanh toán** — luôn yêu cầu user confirm UI cuối cùng.
- **Disclosure:** badge "Trả lời bởi AI" trong chat.
- **PII redaction** trước khi gửi LLM (passport, CCCD, số thẻ).
- **Output filtering:** safety filter của Gemini/OpenAI + blocklist nội dung nhạy cảm.
- **Cite sources:** mỗi đề xuất tour kèm link tour & review trích dẫn.
- **Hallucination control:** nếu vector retrieval score thấp → trả lời "không có tour phù hợp" thay vì bịa.
- **Cost control:** cache câu hỏi giống nhau (semantic cache), cap tokens/user/ngày.
- **A/B test:** so sánh AI rec vs popularity-based bằng feature flag.

### 12.5 Frontend AI UX

- **Floating AI button** (mobile: FAB phụ, web: góc dưới phải).
- **Chat full-screen** với:
  - Input đa phương thức: text, voice (mic), upload ảnh ("tour giống ảnh này").
  - **Tool result cards** inline: tour card có thể tap "Xem chi tiết" hoặc "Đặt ngay".
  - Quick chips: "Tour cuối tuần", "Dưới 5tr", "Cho gia đình".
- **AI Search bar** trên Discover: gõ tự nhiên thay vì keyword.
- **AI summary panel** trên Tour Detail: "Khách nói gì? — 4.6★ • Ưu: hướng dẫn viên thân thiện • Nhược: bữa trưa đơn giản".
- **AI itinerary builder**: timeline kéo-thả, AI gợi ý chèn điểm.

### 12.6 Code snippet — Cloud Function `aiChat` (Node/TS rút gọn)

```ts
// functions/src/aiChat.ts
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { GoogleGenerativeAI } from '@google/generative-ai';

const genAI = new GoogleGenerativeAI(process.env.GEMINI_KEY!);

export const aiChat = onCall({ cors: true, maxInstances: 20 }, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Login required');

  const { message, conversationId, filters } = req.data;
  await checkRateLimit(uid);

  // 1. Embed + retrieve
  const embed = await embedText(message);
  const tours = await vectorSearch('tours', embed, { topK: 6, filters });

  // 2. Build prompt
  const model = genAI.getGenerativeModel({
    model: 'gemini-1.5-pro',
    tools: [{ functionDeclarations: TOOLS_SCHEMA }],
    systemInstruction: SYSTEM_PROMPT, // bao gồm policy, tone, disclosure
  });

  const chat = model.startChat({ history: await loadHistory(conversationId) });
  const ctx = `Context tours:\n${tours.map(formatTour).join('\n---\n')}\n\nUser: ${message}`;

  const result = await chat.sendMessageStream(ctx);
  // 3. Stream về Firestore (client listen messages subcollection)
  for await (const chunk of result.stream) {
    await appendChunk(conversationId, chunk.text());
    const calls = chunk.functionCalls();
    if (calls?.length) await handleToolCalls(uid, conversationId, calls);
  }

  await logAiSession(uid, conversationId, tours);
  return { ok: true };
});
```

### 12.7 Code snippet — Flutter side gọi AI chat (Riverpod)

```dart
final aiChatControllerProvider =
    AsyncNotifierProvider.family<AiChatController, void, String>(
  AiChatController.new,
);

class AiChatController extends FamilyAsyncNotifier<void, String> {
  late final String conversationId;

  @override
  Future<void> build(String arg) async {
    conversationId = arg;
  }

  Future<void> send(String text, {Map<String, dynamic>? filters}) async {
    final fn = FirebaseFunctions.instance.httpsCallable('aiChat');
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await fn.call({
        'message': text,
        'conversationId': conversationId,
        'filters': filters,
      });
    });
  }
}

// Stream messages từ Firestore để render UI
final messagesProvider = StreamProvider.family<List<Message>, String>((ref, cid) {
  final db = ref.watch(firestoreProvider);
  return db
      .collection('conversations').doc(cid).collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) => s.docs.map((d) => Message.fromDoc(d)).toList());
});
```

---

## 13. Booking flow chi tiết (UX)

**Mobile (compact):**
1. Tour Detail → nút sticky "Chọn ngày & đặt".
2. Bottom sheet chọn `Departure` (calendar đánh dấu ngày còn chỗ + giá).
3. Stepper số khách (adult/child/infant) + options.
4. Màn Checkout (full-screen): thông tin hành khách (auto-fill từ profile), coupon, tóm tắt giá.
5. Chọn payment method → redirect/web view → callback.
6. Màn Success: voucher QR + nút "Thêm vào lịch".

**Web (expanded):**
- Layout 2 cột: trái (form), phải (sticky Order Summary luôn hiện).
- Hỗ trợ Apple Pay / Google Pay / saved cards.
- Guest checkout (không bắt buộc login, nhưng tạo account "magic link" sau khi book).

**Hold inventory:** khi vào checkout → CF tạo booking `status=hold`, `holdExpiresAt = now + 15m`. Cloud Task release nếu hết hạn.

---

## 14. Operator Portal (web-first)

- **Tách app/route riêng** `/operator/*` (cùng codebase, route guard role).
- Layout desktop với NavigationRail + DataTable (`data_table_2`).
- Trang chính: **Dashboard** (GMV, conversion), **Tours** (CRUD + AI generator), **Departures** (calendar inventory), **Bookings** (Kanban: hold/confirmed/completed), **Reviews** (reply), **Payouts** (Stripe Connect dashboard embed), **Team**, **Settings**.
- Tối ưu mobile-tablet cho operator dùng iPad đứng quầy.

---

## 15. Bảo mật, pháp lý & tuân thủ

- **PCI-DSS:** không lưu số thẻ — dùng tokenization của Stripe/VNPay.
- **KYC operator:** upload giấy phép lữ hành → admin duyệt → mới được publish tour.
- **Hợp đồng điện tử** PDF có hash SHA-256 lưu trên Storage; tùy chọn ký số (VNPT-CA).
- **GDPR/PDPL VN 13/2023:** consent banner, data export/delete, DPA với operator.
- **Hóa đơn điện tử VAT:** tích hợp VNPT/Misa eInvoice qua webhook payment.
- **Anti-fraud:** velocity check, geo-IP mismatch, 3DS bắt buộc giao dịch >5tr.
- **Insurance hợp tác:** Bảo Việt / PVI bán kèm bảo hiểm du lịch (upsell, AI gợi ý).

---

## 16. Packages bổ sung (e-commerce + AI)

```yaml
dependencies:
  # ...existing packages...

  # E-commerce
  cloud_functions: ^5.0.0
  flutter_stripe: ^11.0.0          # Stripe (mobile + web)
  pay: ^2.0.0                      # Apple/Google Pay
  webview_flutter: ^4.7.0          # VNPay/MoMo redirect
  flutter_inappwebview: ^6.1.0
  qr_flutter: ^4.1.0               # E-voucher QR
  pdfx: ^2.6.0                     # Xem voucher
  table_calendar: ^3.1.2           # Departure calendar
  data_table_2: ^2.5.15            # Operator dashboard
  fl_chart: ^0.68.0                # Analytics chart
  intl_phone_field: ^3.2.0         # Phone input passenger
  country_picker: ^2.0.26

  # Search & AI
  algolia_helper_flutter: ^1.0.0   # hoặc typesense: ^0.6.0
  speech_to_text: ^7.0.0           # Voice search
  flutter_tts: ^4.0.0
  flutter_markdown: ^0.7.1         # Render AI message

dev_dependencies:
  # ...existing dev packages...
```

---

## 17. Roadmap mở rộng (sau MVP review)

| Sprint | Mục tiêu | Deliverable |
|---|---|---|
| **EC-1** | Tour catalog + Departure inventory + Operator portal MVP | Operator tạo tour, traveler xem |
| **EC-2** | Booking flow + Stripe + VNPay + voucher | Đặt tour thành công end-to-end |
| **EC-3** | Verified review + chat operator + reminder | Vòng đời 1 booking hoàn chỉnh |
| **AI-1** | Embedding + semantic search + AI summary review | Search tự nhiên + tóm tắt review |
| **AI-2** | AI Concierge chat + tool calling (search, getDepartures) | Chatbot gợi ý + dẫn đến đặt |
| **AI-3** | Personalized home feed + voice + image search | Cá nhân hóa & đa phương thức |
| **EC-4** | Coupon, loyalty, đa tiền tệ, BNPL | Tăng conversion |
| **OPS** | Anti-fraud, KYC, eInvoice, insurance upsell | Production-grade |

---

## 18. Lưu ý khi triển khai AI cho thị trường VN

- **Ngôn ngữ:** ưu tiên model hỗ trợ tiếng Việt tốt — Gemini 1.5/2.x và GPT-4o đều ổn; tránh model nhỏ kém tiếng Việt.
- **Region/Latency:** deploy CF ở `asia-southeast1` (Singapore) hoặc `asia-east2` (HK); LLM endpoint chọn region gần nhất.
- **Chi phí:** ước lượng 1 phiên chat ~1.5k–3k tokens; với 10k MAU chat 5 lần/tháng → cần budget LLM ~ vài trăm USD/tháng (Gemini Flash rẻ hơn nhiều cho task nhẹ → dùng **Flash** cho summary/translate, **Pro** cho concierge).
- **Fallback offline:** khi mất mạng, chat hiển thị queued + retry; không block UI.
- **Đo lường AI ROI:** track event `ai_suggested_tour_clicked`, `ai_assisted_booking_completed` → so sánh với cohort không dùng AI.

---

# ⚡ PHẦN 19 — Hệ thống Real-time đồng bộ Web ↔ Mobile, tối ưu thiết bị user

> Mục tiêu: **mọi thay đổi (booking, chat, inventory tour, notification, AI message, review) đẩy tới tất cả thiết bị của cùng user trong < 1 giây**, tiết kiệm pin/data trên mobile, mượt trên web, an toàn khi mất mạng.

---

## 19.1 Bản đồ luồng real-time cần đồng bộ

| # | Sự kiện | Nguồn ghi | Đích lắng nghe | Latency mục tiêu | Kênh |
|---|---|---|---|---|---|
| 1 | Booking trạng thái (hold→paid→confirmed→cancelled) | Cloud Function (webhook payment) | Traveler (mọi device) + Operator dashboard | < 1s | Firestore listener |
| 2 | Inventory `departures.available` | CF transaction | Tour Detail của mọi viewer | < 2s | Firestore listener |
| 3 | Chat message (traveler ↔ operator ↔ AI) | Client/CF | 2 phía + AI streaming | < 500ms | Firestore + presence RTDB |
| 4 | AI streaming token | CF (LLM stream) | Người gửi (mọi device đang mở chat) | từng chunk 100ms | Firestore append doc / SSE |
| 5 | Notification (booking confirmed, reminder, like) | CF | Tất cả device user | < 3s | **FCM** push + in-app stream |
| 6 | Cart đa thiết bị | Client write `carts/{uid}` | Mọi device đăng nhập cùng uid | < 1s | Firestore listener |
| 7 | Wishlist / bookmark | Client | Mọi device | < 1s | Firestore listener |
| 8 | Review mới đăng | Client | Tour Detail viewer | < 2s | Firestore listener |
| 9 | Operator: booking mới đến | CF | Web dashboard + mobile operator app | < 1s | Firestore + FCM |
| 10 | Presence (online / typing) | Client heartbeat | Đối phương chat | < 500ms | **Realtime DB** (`onDisconnect`) |
| 11 | Flash sale countdown | Server time | Mọi viewer | sync time | Server timestamp + local tick |

---

## 19.2 Lựa chọn công nghệ realtime (vì sao kết hợp)

| Công cụ | Dùng cho | Lý do |
|---|---|---|
| **Cloud Firestore** listeners (`snapshots()`) | Dữ liệu truy vấn theo doc/query: booking, tour, chat, cart | Đồng bộ tự động, **offline persistence** sẵn cả mobile + web (IndexedDB) |
| **Firebase Realtime Database** | Presence (online/typing), counter cao tần | Latency cực thấp, hỗ trợ `onDisconnect()` |
| **FCM (Firebase Cloud Messaging)** | Push khi app **đóng/background** trên mobile + Web Push | Đẩy thông báo qua APNs/FCM/Web Push, đánh thức app |
| **Cloud Functions Streaming / SSE** | AI token streaming tới client | Stream từng chunk LLM, thay vì chờ trả full |
| **WebSocket (tùy chọn)** | Nếu cần backend tự host (vd Cloud Run + ws) | Khi Firestore không đủ (vd chat tần suất cực cao, game-like) |

> ✅ **Khuyến nghị:** Mặc định dùng **Firestore listener cho 90% case** + **RTDB cho presence** + **FCM cho push background** + **AI stream qua Firestore append** (đơn giản, không cần tự host WebSocket).

---

## 19.3 Mô hình "Single Source of Truth" + đồng bộ đa thiết bị

```
┌────────────┐  ┌────────────┐  ┌────────────┐
│ Mobile A   │  │ Mobile B   │  │ Web (PC)   │   ← cùng 1 user (uid=X)
└─────┬──────┘  └─────┬──────┘  └─────┬──────┘
      │ snapshots()    │ snapshots()  │ snapshots()
      └──────┬─────────┴──────────────┘
             ▼
   ┌────────────────────────┐
   │  Firestore (truth)     │  ←── Cloud Functions ghi (server-authoritative)
   │  + RTDB (presence)     │  ←── Webhook payment / AI / Operator
   └────────────────────────┘
             ▲
             │ FCM khi app đóng
   ┌────────────────────────┐
   │  FCM (multi-device)    │  → đẩy vào tất cả device tokens của uid=X
   └────────────────────────┘
```

**Nguyên tắc:**
1. Client **không bao giờ** là nguồn sự thật cho dữ liệu nhạy cảm (booking, payment, inventory) → luôn ghi qua Cloud Function.
2. Mỗi user có **device registry**: `users/{uid}/devices/{deviceId}` chứa `fcmToken`, `platform`, `lastActive`, `appVersion`. CF lặp gửi FCM tới mọi token còn active.
3. Khi app foreground → ưu tiên **Firestore listener** (đẹp, mượt, không cần permission).
4. Khi app background/đóng → **FCM** gọi user, mở app lại → listener auto-resync.
5. Optimistic UI: ghi local ngay, Firestore sẽ sync; nếu fail → rollback.

---

## 19.4 Tối ưu thiết bị user (battery, data, RAM, latency)

### 19.4.1 Mobile (Android/iOS)

| Vấn đề | Giải pháp |
|---|---|
| Pin do listener chạy nền | **Hủy listener khi rời màn hình** — dùng `autoDispose` Riverpod; không bao giờ giữ global stream cả app trừ `authStateProvider` và `unreadNotificationsCount` (nhẹ) |
| Data 4G | `Settings(persistenceEnabled: true, cacheSizeBytes: 100 * 1024 * 1024)` để cache 100MB; query có `limit()`; tránh `.snapshots()` trên collection lớn không có filter |
| Background sync | Dùng **FCM data message** + `WorkManager`/`BGTaskScheduler` thay vì giữ socket |
| Push khi app đóng | FCM với `priority: high` cho booking/payment; `normal` cho reminder |
| Cold start | Lazy-init Firebase modules; chỉ `initializeApp` ở `main`; init Messaging/Analytics sau khi UI render frame đầu (`addPostFrameCallback`) |
| Image bandwidth | `CachedNetworkImage` + `memCacheWidth = devicePixelRatio * widget.width`; CDN trả ảnh `webp/avif` theo `Accept` header |
| Mất mạng | Firestore offline queue tự retry; hiện banner "Đang offline" dựa `connectivity_plus` |
| Đồng bộ giữa 2 máy của cùng user | Listener Firestore đã tự đồng bộ; thêm `cart/wishlist/draft review` lưu Firestore (không chỉ local) |

### 19.4.2 Web (PWA)

| Vấn đề | Giải pháp |
|---|---|
| Tab background bị throttle | Pause heavy listener khi `document.visibilityState === 'hidden'`, resume khi visible |
| Web Push | FCM Web (cần `firebase-messaging-sw.js` ở `web/`); xin permission có chiến lược (sau action, không spam ngay) |
| Persistence | `enableMultiTabIndexedDbPersistence()` để chia sẻ cache giữa nhiều tab |
| Bundle size | Code-split route + deferred AI/map; dùng `flutter build web --wasm`; tree-shake icons |
| Initial paint | Loading skeleton trong `index.html` trước khi Flutter bootstrap; preconnect Firestore/Storage origins |
| SEO landing tour | Dùng prerendering (Rendertron) hoặc tách trang public sang Next.js cho SEO |

### 19.4.3 Đồng bộ trạng thái ngang hàng (multi-device cùng uid)

- **Auth multi-device:** Firebase Auth tự đồng bộ session; thêm `forceLogout` doc `users/{uid}/security/forceLogoutAt` → mọi device listen, tự sign-out khi đổi mật khẩu hoặc nghi ngờ.
- **Read state:** notification "đã đọc" lưu Firestore → web đọc → mobile cũng mất badge.
- **Resume position** (read continuation): lưu `users/{uid}/state/lastTourViewed` → mở web thấy "Tiếp tục xem tour X" giống Netflix.

---

## 19.5 Chiến lược offline-first

```
UI layer ──► Riverpod Notifier ──► Repository
                                       │
                ┌──────────────────────┼─────────────────────┐
                ▼                      ▼                     ▼
         Local cache (Hive)    Firestore offline cache   Remote Firestore
                                                           ▲
                                              Background sync khi online
```

- **Mutation queue:** khi offline, ghi vào Hive `outbox` + Firestore offline write (Firestore tự queue) → khi online tự flush.
- **Conflict resolution:** dùng **server timestamp** + **Last-Write-Wins** cho dữ liệu user-owned; với inventory/booking → **transaction trên server** (CF) là người quyết định.
- **Optimistic UI:** badge "Đang gửi…" trên review/chat khi chưa sync.
- Hiển thị icon **đám mây ☁️ / ☁️↻ / ⚠️** cho từng item.

---

## 19.6 Push notification đa nền tảng (FCM)

### 19.6.1 Đăng ký token đa thiết bị

```dart
// core/notifications/notifications_service.dart
class NotificationsService {
  final FirebaseMessaging _fm;
  final FirebaseFirestore _db;
  NotificationsService(this._fm, this._db);

  Future<void> registerDevice(String uid) async {
    if (kIsWeb) {
      await _fm.requestPermission();
      final token = await _fm.getToken(
        vapidKey: const String.fromEnvironment('FCM_VAPID_KEY'),
      );
      await _saveToken(uid, token, 'web');
    } else {
      await _fm.requestPermission(alert: true, badge: true, sound: true);
      final token = await _fm.getToken();
      await _saveToken(uid, token, defaultTargetPlatform.name);
      await FirebaseMessaging.instance.subscribeToTopic('user_$uid');
    }
    _fm.onTokenRefresh.listen((t) => _saveToken(uid, t, _platform()));
  }

  Future<void> _saveToken(String uid, String? token, String platform) async {
    if (token == null) return;
    final id = _stableDeviceId(); // package_info + platform device_info
    await _db.doc('users/$uid/devices/$id').set({
      'token': token,
      'platform': platform,
      'lastActive': FieldValue.serverTimestamp(),
      'appVersion': await _appVersion(),
    }, SetOptions(merge: true));
  }
}
```

### 19.6.2 Cloud Function fan-out tới mọi device

```ts
// functions/src/notify.ts
export async function notifyUser(uid: string, payload: admin.messaging.MessagingPayload) {
  const snap = await db.collection(`users/${uid}/devices`).get();
  const tokens = snap.docs.map(d => d.data().token).filter(Boolean);
  if (!tokens.length) return;
  const res = await admin.messaging().sendEachForMulticast({
    tokens,
    notification: payload.notification,
    data: payload.data,
    android: { priority: 'high' },
    apns: { headers: { 'apns-priority': '10' }, payload: { aps: { sound: 'default' } } },
    webpush: { fcmOptions: { link: payload.data?.url ?? '/' } },
  });
  // Dọn token chết
  res.responses.forEach((r, i) => {
    if (!r.success && /registration-token-not-registered/.test(r.error?.code ?? '')) {
      snap.docs[i].ref.delete();
    }
  });
}
```

### 19.6.3 Web service worker

`web/firebase-messaging-sw.js`:
```js
importScripts('https://www.gstatic.com/firebasejs/10.x.x/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.x.x/firebase-messaging-compat.js');
firebase.initializeApp({ /* same config */ });
firebase.messaging().onBackgroundMessage((m) => {
  self.registration.showNotification(m.notification.title, {
    body: m.notification.body,
    icon: '/icons/Icon-192.png',
    data: m.data,
  });
});
```

---

## 19.7 Presence & typing (Realtime DB)

```dart
final presenceProvider = Provider<PresenceService>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  return PresenceService(FirebaseDatabase.instance, uid);
});

class PresenceService {
  PresenceService(this._db, this._uid) {
    if (_uid == null) return;
    final ref = _db.ref('presence/$_uid');
    ref.onDisconnect().set({'online': false, 'at': ServerValue.timestamp});
    ref.set({'online': true, 'at': ServerValue.timestamp});
  }
  final FirebaseDatabase _db;
  final String? _uid;

  Future<void> setTyping(String conversationId, bool typing) =>
      _db.ref('typing/$conversationId/$_uid').set(typing);
}
```

→ Web đóng tab cũng tự `online: false` nhờ `onDisconnect()`.

---

## 19.8 AI streaming realtime trên cả mobile + web

**Cách đơn giản (khuyến nghị):** CF ghi từng chunk vào `conversations/{cid}/messages/{aiMsgId}` (field `text` được `update` liên tục). Client dùng `.snapshots()` → UI tự cập nhật từng từ.

```ts
// CF — append từng chunk
const msgRef = db.doc(`conversations/${cid}/messages/${aiMsgId}`);
await msgRef.set({ role: 'ai', text: '', streaming: true, createdAt: FieldValue.serverTimestamp() });
let acc = '';
for await (const chunk of llmStream) {
  acc += chunk.text();
  await msgRef.update({ text: acc });
}
await msgRef.update({ streaming: false });
```

```dart
// Flutter — render mượt
ref.watch(messagesProvider(cid)).whenData((msgs) {
  // msgs[last].text tự update từng từ → typewriter effect
});
```

> Lưu ý: Firestore tính write theo lần update → để tiết kiệm, **debounce 80–120ms** giữa các update (vd buffer 20–40 token mới flush). Cân bằng giữa "mượt" và chi phí.

---

## 19.9 Realtime trên Operator Portal (web)

- Dashboard có **counter live** (booking hôm nay, doanh thu): listen aggregate doc `operators/{id}/stats/today` được CF cập nhật khi có booking confirmed.
- Bảng booking dùng `snapshots(includeMetadataChanges: true)` để hiển thị badge "đang đồng bộ".
- Toast + chuông khi có **booking mới** (FCM web + sound) → operator phản hồi nhanh, tăng conversion.

---

## 19.10 Quan trắc & SLO realtime

| Metric | Mục tiêu |
|---|---|
| End-to-end latency (write → listener nhận) | p95 < 1.2s |
| FCM delivery time | p95 < 5s |
| AI first token | < 1.5s |
| Listener reconnect sau mất mạng | < 3s |
| Battery drain mobile (idle 1h, app open) | < 3% |
| Data 4G (1h browse) | < 20MB |

Đo bằng: Firebase Performance Monitoring, custom trace, Sentry breadcrumb, GA4 event `realtime_latency_ms`.

---

## 19.11 Code snippet — `RealtimeSyncService` thống nhất

```dart
// core/realtime/realtime_sync_service.dart
class RealtimeSyncService {
  RealtimeSyncService(this._ref);
  final Ref _ref;
  final List<StreamSubscription> _subs = [];

  void start(String uid) {
    final db = _ref.read(firestoreProvider);

    // 1. Bookings của tôi
    _subs.add(db.collection('bookings')
        .where('travelerId', isEqualTo: uid)
        .orderBy('updatedAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((s) => _ref.read(myBookingsProvider.notifier).update(s)));

    // 2. Notifications chưa đọc (badge)
    _subs.add(db.collection('users/$uid/notifications')
        .where('read', isEqualTo: false)
        .snapshots(includeMetadataChanges: false)
        .listen((s) => _ref.read(unreadCountProvider.notifier).set(s.size)));

    // 3. Cart đồng bộ đa thiết bị
    _subs.add(db.doc('carts/$uid').snapshots()
        .listen((d) => _ref.read(cartProvider.notifier).fromDoc(d)));

    // 4. Force logout signal
    _subs.add(db.doc('users/$uid/security/state').snapshots().listen((d) {
      final t = d.data()?['forceLogoutAt'];
      if (t != null) _ref.read(authControllerProvider.notifier).signOut();
    }));
  }

  Future<void> stop() async {
    for (final s in _subs) { await s.cancel(); }
    _subs.clear();
  }
}

final realtimeSyncProvider = Provider<RealtimeSyncService>((ref) {
  final svc = RealtimeSyncService(ref);
  ref.listen(authStateProvider, (_, next) {
    final uid = next.value?.uid;
    if (uid != null) svc.start(uid); else svc.stop();
  }, fireImmediately: true);
  ref.onDispose(svc.stop);
  return svc;
});
```

Khởi tạo 1 lần ở root: `ref.read(realtimeSyncProvider);`.

---

## 19.12 Tối ưu lifecycle & visibility

```dart
class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver(this.onChange);
  final ValueChanged<AppLifecycleState> onChange;
  @override
  void didChangeAppLifecycleState(AppLifecycleState s) => onChange(s);
}

// Trong app.dart
useEffect(() {
  final obs = AppLifecycleObserver((state) {
    final notif = ref.read(notificationsServiceProvider);
    if (state == AppLifecycleState.resumed) {
      notif.touchLastActive();           // cập nhật devices/{id}.lastActive
      ref.invalidate(myBookingsProvider); // refresh nếu cần
    } else if (state == AppLifecycleState.paused) {
      ref.read(presenceProvider).setOffline();
    }
  });
  WidgetsBinding.instance.addObserver(obs);
  return () => WidgetsBinding.instance.removeObserver(obs);
}, const []);
```

Web: thêm listener `document.visibilityState` qua `dart:html` (conditional import) cùng mục đích.

---

## 19.13 Bảo mật realtime

- **Security Rules** Firestore + RTDB chặt: user chỉ subscribe được dữ liệu của mình hoặc public; rule cho `conversations` kiểm tra `uid in resource.data.participants`.
- **App Check** (Play Integrity / DeviceCheck / reCAPTCHA Enterprise) bật cho Firestore + RTDB + Functions → chống abuse listener.
- **Rate limit** trên Cloud Function (số message/giờ).
- **Encryption in transit** mặc định (TLS); dữ liệu nhạy cảm (passport) **mã hóa field-level** trước khi ghi (`encrypt` package + KMS).

---

## 19.14 Roadmap thêm cho mảng realtime

| Sprint | Việc | Output |
|---|---|---|
| **RT-1** | Device registry + FCM (mobile + web SW) + notification fan-out CF | Push hoạt động đa thiết bị |
| **RT-2** | `RealtimeSyncService` + cart/notification/booking sync | Mở app trên web đã thấy giỏ hàng từ mobile |
| **RT-3** | Presence + typing (RTDB) cho chat operator | Chat real-time có "đang gõ…" |
| **RT-4** | AI streaming qua Firestore append + debounce | Typewriter effect mượt, chi phí kiểm soát |
| **RT-5** | App Check + Force logout + Resume position | Bảo mật + UX cross-device chuẩn Netflix |
| **RT-6** | Performance Monitoring + SLO dashboard | Đo và alert latency vượt ngưỡng |

---

✅ **Tóm tắt §19:** Real-time = **Firestore listeners** (chính) + **RTDB presence** + **FCM push đa thiết bị** + **AI streaming qua Firestore append**. Tối ưu thiết bị bằng **autoDispose listener**, **offline persistence + outbox**, **lifecycle-aware pause/resume**, **debounce write**, **App Check**, và **device registry** để 1 user trên nhiều máy luôn thấy cùng trạng thái trong < 1 giây.

---

# 🌐 PHẦN 20 — Hệ thống Song ngữ (Vietnamese ↔ English)

> Mục tiêu: app hoạt động hoàn chỉnh **2 ngôn ngữ vi/en** (mở rộng được sang ja/ko), người dùng đổi ngôn ngữ tức thì không cần restart, đồng bộ lựa chọn giữa các thiết bị, đồng thời nội dung động (tour, review) được dịch tự động bằng AI khi cần.

---

## 20.1 Phân loại nội dung cần dịch

| Loại | Nguồn | Cách dịch |
|---|---|---|
| **UI tĩnh** (label, button, message) | code | ARB files + `gen_l10n` |
| **Validation / error message** | code + server | ARB + Cloud Function trả `errorCode` → client map sang chuỗi |
| **Nội dung động — tour, review, mô tả operator** | Firestore | Lưu **multi-locale field** + AI auto-translate |
| **Email / SMS / Push notification** | Cloud Function | Template theo locale từ `users/{uid}.locale` |
| **PDF voucher, hóa đơn** | Cloud Function | Template multi-locale |
| **Currency, date, number** | runtime | `intl` formatter theo locale |
| **Hình ảnh có chữ** (banner, infographic) | CMS | Upload bản theo locale, đặt tên `_vi`, `_en` |

---

## 20.2 Chiến lược lưu nội dung động đa ngôn ngữ (Firestore)

**Pattern 1 — Field map** (khuyến nghị, ít doc, query đơn giản):
```
tours/{tourId}
  title:        { vi: "Tour Đà Lạt 3N2Đ", en: "Dalat 3D2N Tour" }
  summary:      { vi: "...", en: "..." }
  description:  { vi: "...", en: "..." }
  itinerary: [
    { day: 1, title: { vi: "...", en: "..." }, desc: { vi: "...", en: "..." } }
  ]
  defaultLocale: "vi"
  availableLocales: ["vi", "en"]
  searchKeywords_vi: [...], searchKeywords_en: [...]
  embedding_vi: [...], embedding_en: [...]   // search semantic theo từng locale
```

Helper Dart:
```dart
String tr(Map? m, BuildContext ctx, {String fallback = 'vi'}) {
  if (m == null) return '';
  final code = Localizations.localeOf(ctx).languageCode;
  return (m[code] ?? m[fallback] ?? m.values.first).toString();
}
```

**Pattern 2 — Subcollection** (khi nội dung rất dài, vd blog):
```
tours/{tourId}/i18n/{localeCode}  → { title, description, ... }
```

> ✅ Mặc định dùng **Pattern 1**; chuyển sang Pattern 2 chỉ khi description > 50KB.

---

## 20.3 Auto-translate bằng AI (Cloud Function)

```ts
// functions/src/translateTour.ts — trigger khi operator publish
export const onTourPublished = onDocumentWritten('tours/{tourId}', async (e) => {
  const after = e.data?.after.data();
  if (!after || after.status !== 'published') return;

  const src = after.defaultLocale ?? 'vi';
  const targets = ['en']; // có thể mở rộng ['en','ja','ko']
  const updates: Record<string, any> = {};

  for (const f of ['title', 'summary', 'description']) {
    const value = after[f];
    if (value && typeof value === 'object' && !value[targets[0]]) {
      for (const lang of targets) {
        updates[`${f}.${lang}`] = await translate(value[src], src, lang);
      }
    }
  }
  if (Object.keys(updates).length) {
    await e.data!.after.ref.update({ ...updates, autoTranslatedAt: FieldValue.serverTimestamp() });
  }
});
```

- Dùng **Gemini Flash** hoặc **Azure Translator** (rẻ, nhanh).
- Đánh dấu `autoTranslated: true` để UI hiển thị badge "🌐 Bản dịch tự động — đề xuất chỉnh sửa".
- Operator có thể override bản dịch trong portal.
- Re-translate khi nội dung gốc đổi (so sánh hash).

**User-generated content (review):**
- Hiển thị nguyên gốc + nút **"Dịch sang tiếng Việt"** (lazy) → call CF `translateText` → cache vào `reviews/{id}/translations/{lang}`.
- Tránh dịch toàn bộ review trước (tốn tiền).

---

## 20.4 UI strings — gen_l10n flow

**1. `pubspec.yaml`:**
```yaml
flutter:
  generate: true   # bật gen_l10n

dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
```

**2. `l10n.yaml` (root):**
```yaml
arb-dir: lib/l10n
template-arb-file: app_vi.arb
output-localization-file: app_localizations.dart
output-class: AppL10n
nullable-getter: false
synthetic-package: false
output-dir: lib/l10n/gen
```

**3. `lib/l10n/app_vi.arb`:**
```json
{
  "@@locale": "vi",
  "appTitle": "TravelReview",
  "navHome": "Khám phá",
  "navSearch": "Tìm kiếm",
  "navBookings": "Đơn của tôi",
  "navProfile": "Cá nhân",
  "bookNow": "Đặt ngay",
  "priceFromVnd": "Từ {price}",
  "@priceFromVnd": {
    "placeholders": { "price": { "type": "int", "format": "compactCurrency" } }
  },
  "reviewsCount": "{count, plural, =0{Chưa có đánh giá} =1{1 đánh giá} other{{count} đánh giá}}",
  "@reviewsCount": { "placeholders": { "count": { "type": "int" } } }
}
```

**4. `lib/l10n/app_en.arb`:**
```json
{
  "@@locale": "en",
  "appTitle": "TravelReview",
  "navHome": "Discover",
  "navSearch": "Search",
  "navBookings": "My Bookings",
  "navProfile": "Profile",
  "bookNow": "Book now",
  "priceFromVnd": "From {price}",
  "reviewsCount": "{count, plural, =0{No reviews} =1{1 review} other{{count} reviews}}"
}
```

**5. Sử dụng:**
```dart
final l = AppL10n.of(context);
Text(l.bookNow);
Text(l.reviewsCount(count));
```

---

## 20.5 Locale state + persistence + đồng bộ thiết bị

```dart
// app/locale/locale_controller.dart
class LocaleController extends Notifier<Locale?> {
  static const _key = 'app_locale';

  @override
  Locale? build() {
    _load();
    return null; // null = follow system
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final code = p.getString(_key);
    if (code != null) state = Locale(code);
  }

  Future<void> setLocale(Locale? loc) async {
    state = loc;
    final p = await SharedPreferences.getInstance();
    if (loc == null) {
      await p.remove(_key);
    } else {
      await p.setString(_key, loc.languageCode);
    }
    // Đồng bộ lên Firestore để mọi device cùng user dùng chung
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid != null) {
      await ref.read(firestoreProvider).doc('users/$uid').set(
        {'locale': loc?.languageCode ?? 'system'},
        SetOptions(merge: true),
      );
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
```

Khi user mở app trên thiết bị mới:
- Listener `users/{uid}` đọc `locale` → `LocaleController.setLocale(...)` (không ghi ngược lại).

**MaterialApp:**
```dart
final locale = ref.watch(localeControllerProvider);
return MaterialApp.router(
  locale: locale,
  supportedLocales: AppL10n.supportedLocales,
  localizationsDelegates: AppL10n.localizationsDelegates,
  localeResolutionCallback: (device, supported) {
    if (locale != null) return locale;
    return supported.firstWhere(
      (l) => l.languageCode == device?.languageCode,
      orElse: () => const Locale('vi'),
    );
  },
  // ...
);
```

---

## 20.6 Language Switcher UI

- **Settings → Ngôn ngữ**: 3 lựa chọn `Theo hệ thống / Tiếng Việt / English` (radio).
- **Topbar web** (góc phải): dropdown 🌐 vi | en (giống Booking.com).
- **Onboarding lần đầu**: hỏi ngôn ngữ ngay sau splash (auto-detect từ `Platform.localeName` làm default).
- **Deep link / URL web**: hỗ trợ `?lang=en` để share link sang đối tượng nước ngoài → override locale phiên đó.

---

## 20.7 Định dạng số, ngày, tiền tệ

```dart
// core/utils/formatters.dart
String formatPrice(int vnd, BuildContext ctx) {
  final code = Localizations.localeOf(ctx).languageCode;
  if (code == 'vi') {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0).format(vnd);
  }
  // Tự đổi ra USD theo tỷ giá đã cache
  final usd = vnd / ref.read(fxRateProvider).vndToUsd;
  return NumberFormat.currency(locale: 'en_US', symbol: '\$', decimalDigits: 2).format(usd);
}

String formatDate(DateTime d, BuildContext ctx) =>
    DateFormat.yMMMd(Localizations.localeOf(ctx).toString()).format(d);
```

- Hỗ trợ **đa tiền tệ**: lưu `currencyPreference` (VND/USD) song song với `locale`.
- Ngày: tiếng Việt "20 thg 7, 2026" / tiếng Anh "Jul 20, 2026".
- Số: dấu thập phân `,` (vi) vs `.` (en) — `intl` xử lý tự động.

---

## 20.8 Push notification song ngữ

Cloud Function dựa vào `users/{uid}.locale`:
```ts
const locale = (await db.doc(`users/${uid}`).get()).data()?.locale ?? 'vi';
const t = NOTIF_TEMPLATES[locale] ?? NOTIF_TEMPLATES.vi;
await notifyUser(uid, {
  notification: {
    title: t.bookingConfirmed.title,
    body: t.bookingConfirmed.body({ tourName, date }),
  },
});
```

`NOTIF_TEMPLATES` là object `{ vi: {...}, en: {...} }` checked-in trong code. Nếu thêm locale mới → chỉ cần thêm 1 key.

---

## 20.9 Email & PDF voucher song ngữ

- Template MJML/Handlebars `voucher.{locale}.hbs`; CF chọn theo `locale`.
- PDF: thư viện `pdfkit` với font Unicode hỗ trợ tiếng Việt (vd **Be Vietnam Pro**, **Inter**) — phải embed font, tránh `?` ô vuông.
- Số liệu (giá, ngày) dùng `Intl` server-side (`@formatjs/intl`).

---

## 20.10 SEO web đa ngôn ngữ

- URL pattern: `/vi/tour/dalat-3n2d` và `/en/tour/dalat-3d2n`.
- `<link rel="alternate" hreflang="vi" href="...">` và ngược lại trong `index.html` injected dynamic theo route.
- Sitemap `sitemap-vi.xml` + `sitemap-en.xml`.
- `lang` attribute trên `<html>` đổi theo locale (`document.documentElement.lang`).
- Open Graph meta dịch theo locale (cần SSR/prerender, xem §7).

---

## 20.11 RTL & mở rộng locale

- Dù vi/en đều LTR, code nên dùng `EdgeInsetsDirectional`, `Alignment.startCenter`, `TextDirection`-aware → dễ thêm **ar/he** sau.
- `MaterialApp` tự xử lý direction theo locale.
- Tránh hardcode `Row` thứ tự widget cứng nhắc; ưu tiên `Wrap`/Flex direction-aware.

---

## 20.12 Quản trị & quy trình dịch

| Bước | Công cụ |
|---|---|
| Quản lý chuỗi | **Crowdin / Lokalise / Phrase** (sync với GitHub `lib/l10n/*.arb`) |
| Quy ước key | `feature_screen_element` (vd `home_search_placeholder`) |
| Pseudo-locale | `flutter run --locale=zz` để test UI dài/ngắn |
| Fallback | Thiếu key locale → tự fallback `vi`; CI fail nếu thiếu key trong `app_en.arb` |
| Lint | `custom_lint` rule chặn string literal trong widget Text (bắt buộc qua AppL10n) |
| Coverage | Script đếm % key đã dịch, comment lên PR |

---

## 20.13 Test song ngữ

```dart
testWidgets('home shows VI label', (t) async {
  await t.pumpWidget(ProviderScope(
    overrides: [localeControllerProvider.overrideWith(() => _Fixed(const Locale('vi')))],
    child: const TravelReviewApp(),
  ));
  expect(find.text('Khám phá'), findsOneWidget);
});

testWidgets('home shows EN label', (t) async {
  await t.pumpWidget(ProviderScope(
    overrides: [localeControllerProvider.overrideWith(() => _Fixed(const Locale('en')))],
    child: const TravelReviewApp(),
  ));
  expect(find.text('Discover'), findsOneWidget);
});
```

Golden test cho `PlaceCard` ở 2 locale × 3 breakpoint = 6 ảnh tham chiếu.

---

## 20.14 Roadmap thêm cho song ngữ

| Sprint | Việc | Output |
|---|---|---|
| **L10N-1** | Setup gen_l10n + ARB vi/en + LocaleController + Switcher | App đổi ngôn ngữ tức thì |
| **L10N-2** | Multi-locale field cho tour + helper `tr()` + Operator portal nhập song ngữ | Operator quản lý 2 bản nội dung |
| **L10N-3** | Auto-translate AI (CF `onTourPublished`) + badge "bản dịch máy" | Tour có sẵn EN ngay khi publish |
| **L10N-4** | Locale sync Firestore + push/email/PDF theo locale + đa tiền tệ | Trải nghiệm song ngữ end-to-end |
| **L10N-5** | SEO hreflang + sitemap đa ngôn ngữ + URL `/vi/`, `/en/` | Web index Google đúng theo ngôn ngữ |
| **L10N-6** | Crowdin sync + CI check coverage + pseudo-locale | Quy trình dịch chuyên nghiệp |

---

✅ **Tóm tắt §20:** Bilingual = **gen_l10n + ARB** cho UI + **multi-locale field map** cho dữ liệu Firestore + **AI auto-translate** cho operator content + **lazy translate** cho review + **locale sync Firestore** đa thiết bị + **template push/email/PDF theo locale** + **URL `/vi/ /en/` + hreflang** cho SEO. Code đã chuẩn bị sẵn `EdgeInsetsDirectional` để mở rộng RTL sau.

---

# 🎨 PHẦN 21 — UX/UI Admin Portal & User-facing (hiện đại, đồng nhất)

> Mục tiêu: 2 sản phẩm UI riêng cùng codebase Flutter:
> - **User App** (mobile + web): đẹp, hiện đại, mượt, hướng cảm xúc du lịch.
> - **Admin/Operator Portal** (web-first, có mobile companion): dày data, năng suất cao, dạng "cockpit".
>
> Cả hai chia sẻ **Design System chung** nhưng có **tone, density, navigation pattern** khác biệt.

---

## 21.1 Phân định 3 lớp người dùng & 3 sản phẩm UI

| Sản phẩm | Đối tượng | Nền tảng chính | Tinh thần thiết kế |
|---|---|---|---|
| **User App** | Traveler (khách) | Mobile + Web responsive | Cảm xúc, hình ảnh lớn, motion mượt, story-driven |
| **Operator Portal** | Tour operator (B2B) | **Web** desktop + tablet | Data-dense, productivity, keyboard-first, table/kanban |
| **Platform Admin** | Nhân viên platform | **Web** desktop only | Quyền lực, audit-driven, bảng + biểu đồ + filter mạnh |

Cùng **`lib/`**, tách module:
```
lib/
├── apps/
│   ├── user/          (entry: TravelReviewApp)
│   ├── operator/      (entry: OperatorApp – flavor riêng / route /operator)
│   └── admin/         (entry: AdminApp – build target riêng / route /admin)
├── shared/
│   ├── design_system/ (tokens, themes, components dùng chung)
│   └── ...
```

> Có thể build **3 entrypoint** (`main_user.dart`, `main_operator.dart`, `main_admin.dart`) để app store chỉ chứa User App; Operator/Admin chỉ deploy web (giảm bundle size mobile).

---

## 21.2 Design System chung — Foundation tokens

### 21.2.1 Color tokens (Material 3 + custom)

```
seed.primary    = #0E7C66   (Teal — du lịch biển/rừng)
seed.secondary  = #F2A65A   (Sandy orange — accent)
seed.tertiary   = #6C63FF   (Indigo — admin/data)

semantic:
  success = #16A34A   warning = #F59E0B
  danger  = #DC2626   info    = #2563EB

neutral (Slate):
  0 #FFFFFF / 50 #F8FAFC / 100 #F1F5F9 / 200 #E2E8F0 / 300 #CBD5E1
  500 #64748B / 700 #334155 / 900 #0F172A / 950 #020617
```

- **User**: dùng `seed.primary` làm chủ đạo, `secondary` accent CTA.
- **Operator/Admin**: thêm `seed.tertiary` (indigo) để phân biệt môi trường — tránh nhầm với app khách hàng.
- Sinh `ColorScheme.fromSeed(...)` cho cả 2 brightness.

### 21.2.2 Typography
- **User**: `Plus Jakarta Sans` (display, friendly) + `Inter` (body).
- **Admin**: `Inter` toàn bộ (đọc bảng tốt) + `JetBrains Mono` cho ID/JSON.
- Scale Material 3: `displayL/M/S → headlineL/M/S → titleL/M/S → bodyL/M/S → labelL/M/S`.

### 21.2.3 Spacing & Radius
```
spacing: 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64
radius:  xs 4, sm 8, md 12, lg 16, xl 24, full 999
elevation (M3 tonal): 0, 1, 2, 3, 4, 5
density: User=standard, Admin=compact (-2)
```

### 21.2.4 Motion
- **Curve mặc định:** `Curves.easeOutCubic`, duration 200ms (micro), 350ms (page).
- **Hero animation** ảnh tour User App.
- **Reduced motion:** đọc `MediaQuery.disableAnimations` → tắt parallax/hero.
- **Staggered list** (`flutter_staggered_animations`) cho card xuất hiện dần.

### 21.2.5 Component map (shared)

| Component | User | Admin | Ghi chú |
|---|---|---|---|
| Button (Primary/Secondary/Ghost/Danger) | ✅ | ✅ | Icon + label, size sm/md/lg |
| Input / Select / DatePicker / TimePicker | ✅ | ✅ | M3 OutlinedInputBorder |
| Card (image-rich vs data-dense variant) | ✅ | ✅ | |
| Chip (filter, status) | ✅ | ✅ | |
| Tabs / Segmented | ✅ | ✅ | |
| Toast / SnackBar / Banner | ✅ | ✅ | |
| Dialog / BottomSheet / Drawer | ✅ | ✅ | |
| Empty / Error / Loading state (skeleton) | ✅ | ✅ | shimmer |
| **Data Table** (sort/filter/paginate/inline edit) | ❌ | ✅ | `data_table_2` |
| **Kanban Board** | ❌ | ✅ | `appflowy_board` |
| **Calendar inventory** | ❌ | ✅ | `table_calendar` |
| **Charts** (line, bar, donut, heatmap) | tối thiểu | ✅ | `fl_chart` / `syncfusion_flutter_charts` |
| **Command palette** ⌘K | ❌ | ✅ | tự build với `RawKeyboardListener` |
| **Image gallery / hero** | ✅ | ❌ | |
| **Map (mini + full)** | ✅ | ✅ | |

---

## 21.3 USER APP — UX/UI hiện đại

### 21.3.1 Tinh thần
- **"Travel as a feeling"** — ảnh full-bleed, gradient overlay, micro-interaction.
- Lấy cảm hứng: **Airbnb** (search), **Booking.com** (price clarity), **Hopper** (price prediction), **Wanderlog** (itinerary), **Klook** (tour catalog).
- **Mobile-first**, web là phiên bản "premium" với hero rộng, hover state.

### 21.3.2 Wireframe nâng cấp các màn chính

**Discover (Home) — Mobile:**
```
┌─────────────────────────────────────┐
│ Status bar (transparent)            │
│                                     │
│   "Xin chào, Ân 👋"                  │
│   "Bạn muốn đi đâu hôm nay?"          │
│                                     │
│ ┌───────────────────────────────┐   │
│ │ 🔍 Tìm tour, điểm đến, công ty │  │ ← AI-search bar
│ └───────────────────────────────┘   │
│                                     │
│ [ 🌊 Biển ][ 🏔 Núi ][ 🏛 Văn hóa ]│  Pill chips horizontal scroll
│                                     │
│ ╭──────────────╮  ╭──────────────╮  │
│ │ Hero image   │  │ Hero image   │  │ ← Trending tours
│ │ ⭐ 4.8 · 2k  │  │ ⭐ 4.7 · 1k  │  │   PageView snap, parallax
│ │ Đà Lạt 3N2Đ │  │ Phú Quốc 4N3Đ│  │
│ │ Từ 2.490.000 │  │ Từ 5.990.000 │  │
│ ╰──────────────╯  ╰──────────────╯  │
│                                     │
│ "Gợi ý cho bạn" 🤖                   │ ← AI recommendation
│ [Personalized horizontal cards]     │
│                                     │
│ "Khám phá theo điểm đến"            │
│ ▢ Đà Nẵng    ▢ Hội An               │ ← Grid 2 cột, ảnh + tên
│ ▢ Sapa       ▢ Hạ Long              │
│                                     │
│ "Flash sale ⏰ kết thúc trong 02:14:33"│  Sticky banner gradient
│ ─────────────────────────────────── │
│ Bottom nav: 🏠 🔍 🤖 ❤ 👤            │
└─────────────────────────────────────┘
```

**Tour Detail — Mobile (Sliver):**
```
SliverAppBar (expandedHeight: 320) — ảnh hero PageView
  ↓ thu lại còn 56px khi scroll, blur background
─── Tiêu đề lớn + ⭐ rating + giá ───
─── Pills: 3N2Đ · 8 chỗ còn · ✓ Hủy free 24h ───
─── Highlights (3 icon nhỏ với gradient bg) ───
─── Tabs sticky: Tổng quan | Lịch trình | Đánh giá | Bản đồ ───
─── Lịch trình: Stepper dọc đẹp, mỗi day có ảnh thumbnail ───
─── AI Summary review (§12.5) — card teal nhạt ───
─── Reviews: shimmer khi load, hiển thị 3 + "Xem tất cả" ───
─── Mini map sticky bottom ───
─── BottomBar persistent: giá lớn + "Chọn ngày & đặt" ─── (CTA gradient)
```

**Booking Sheet (modal bottom sheet) — Mobile:**
- Bo góc 24px trên, có handle bar.
- Step indicator 1/3 — 2/3 — 3/3 (animated dots).
- Calendar `table_calendar` với badge giá nhỏ ở mỗi ngày khả dụng.
- Số khách: NumberSpinner ± với haptic feedback.
- Live total ở dưới, đổi animated khi user chỉnh.

**Web Discover (≥1200):**
```
┌──────────────────────────────────────────────────────────┐
│ TopBar:  Logo  [Khám phá] [Cảm hứng] [Hỗ trợ]   🌐 ❤ 👤 │
├──────────────────────────────────────────────────────────┤
│       ╭──────────── Hero video/image (60vh) ───────────╮ │
│       │  "Khám phá Việt Nam theo cách của bạn"        │ │
│       │  [ AI search bar lớn, glassmorphism ]         │ │
│       ╰────────────────────────────────────────────────╯ │
│                                                          │
│  Categories grid (8 ô vuông gradient + icon)             │
│                                                          │
│  "Thịnh hành"                              [ Xem tất cả →]│
│  ┌────┬────┬────┬────┐                                   │
│  │card│card│card│card│  ← 4 cột, hover scale 1.02 + shadow│
│  └────┴────┴────┴────┘                                   │
│                                                          │
│  "Theo cảm hứng"                                          │
│  ┌──────────────┬──────────────┐                         │
│  │ Editorial    │ Editorial    │  Bento grid 2 cột       │
│  │ "Cuối tuần"  │ "Trăng mật"  │  ảnh lớn + tagline       │
│  └──────────────┴──────────────┘                         │
└──────────────────────────────────────────────────────────┘
```

### 21.3.3 Patterns hiện đại bắt buộc

- **Skeleton shimmer** thay spinner.
- **Optimistic UI** (bookmark, like) ngay lập tức.
- **Pull-to-refresh** + spring animation.
- **Haptic feedback** cho các action quan trọng (mobile).
- **Empty state minh họa** (illustration SVG, tone teal nhạt).
- **Glassmorphism**: AppBar, search bar floating khi scroll (`BackdropFilter`).
- **Gradient button CTA** (teal → indigo) thay flat.
- **Image lazy-load + blurhash placeholder** (`flutter_blurhash`).
- **Confetti** sau khi book thành công (`confetti` package).
- **Bottom sheet draggable** với scrim mờ + spring.
- **Onboarding 3 slide** dùng `concentric_transition`.
- **Dark mode hoàn chỉnh** + auto-switch theo giờ địa phương (option).

### 21.3.4 Micro-interactions checklist

| Tương tác | Hiệu ứng |
|---|---|
| Tap card | scale 0.97 + ripple |
| Like | heart scale 1.2 + particle bay lên |
| Bookmark | bookmark fill animation |
| Loading button | spinner thay icon, button width giữ nguyên |
| Pull refresh | logo xoay theo |
| Page transition | shared axis (M3) hoặc fade-through |
| Booking success | confetti + checkmark scale-in + sound subtle |

---

## 21.4 OPERATOR PORTAL — UX/UI productivity

### 21.4.1 Tinh thần
- **Cockpit của doanh nghiệp**: thấy mọi thứ trong 1 màn (Dashboard).
- Lấy cảm hứng: **Linear**, **Vercel Dashboard**, **Stripe Dashboard**, **Notion**, **Airtable**.
- **Density cao**, ít padding hơn user app, **keyboard-first**.

### 21.4.2 Layout chuẩn

```
┌─────────────────────────────────────────────────────────────────┐
│ TopBar: ☰ Logo · OperatorName ▾   ⌘K Search   🔔 12   👤 Avatar │
├──────┬──────────────────────────────────────────────────────────┤
│ NAV  │ Breadcrumb: Dashboard › Tours › Edit                     │
│      │                                                          │
│ 📊 Dashboard                                                    │
│ 🧭 Tours       │  ┌── Page header ──────────────────────────┐  │
│ 📅 Departures  │  │ Title + status pill + actions (right)   │  │
│ 🛒 Bookings    │  └─────────────────────────────────────────┘  │
│ 💬 Messages    │                                                │
│ ⭐ Reviews     │  ┌── KPI strip (4 cards) ───────────────────┐ │
│ 💰 Payouts     │  │ GMV  │ AOV │ Conv │ Rating │ ↑ trend     │ │
│ 👥 Team        │  └─────────────────────────────────────────┘  │
│ ⚙ Settings     │                                                │
│      │  ┌── Main content (DataTable / Kanban / Charts) ─────┐  │
│      │  │                                                    │  │
│      │  └────────────────────────────────────────────────────┘  │
└──────┴──────────────────────────────────────────────────────────┘
   NavRail extended      Content max-width 1440 (centered)
```

### 21.4.3 Trang chính & component đặc trưng

**Dashboard:**
- Hàng KPI 4 card: số lớn + delta % + sparkline.
- Biểu đồ doanh thu 30 ngày (`fl_chart` line + area gradient).
- Donut "Booking theo trạng thái".
- Heatmap calendar "Lượt đặt theo ngày" (giống GitHub contribution).
- Activity feed bên phải (booking mới, review mới).

**Tours (DataTable):**
- `data_table_2` với:
  - Sort, filter (chip multi-select), search, **inline edit** field giá.
  - Bulk action toolbar xuất hiện khi chọn nhiều dòng.
  - Cột status có pill màu.
  - Cột thumbnail tour (40×40 rounded).
  - Pagination dưới + total count.
- Nút "+ Tour mới" → drawer slide từ phải, không rời trang.
- **AI Generate** trong form: paste bullet → AI điền title/description/itinerary.

**Departures (Calendar):**
- `table_calendar` view tháng + tuần switch.
- Mỗi ô ngày hiển thị **số chỗ còn** (badge) + giá (số nhỏ).
- Click ngày → drawer phải: chỉnh capacity/price/status.
- Drag-to-copy: kéo 1 ngày sang ngày khác để clone.

**Bookings (Kanban):**
- 4 cột: `Hold` → `Confirmed` → `Completed` → `Cancelled`.
- Card kéo thả (giới hạn rule: chỉ admin được force chuyển Confirmed).
- Filter bar: theo tour, ngày, khách, payment status.
- Click card → side panel chi tiết + timeline.

**Messages:**
- Layout 3 panel (Linear style): conversation list | thread | customer info panel.
- Phím tắt `J/K` chuyển conversation, `R` reply, `E` resolve.
- AI suggested reply ở dưới input (3 chip "Cảm ơn", "Xin lỗi", "Đề xuất tour khác").

**Reviews:**
- List + filter rating + flag.
- AI moderation badge (suspicious/clean).
- 1-click reply với template multi-locale.

**Payouts:**
- Embed Stripe Connect dashboard (iframe) hoặc list payments với status.
- Export CSV/Excel cho kế toán.

### 21.4.4 Productivity patterns

- **Command palette ⌘K** (Cmd/Ctrl + K):
  - Tìm tour, booking, customer; thực hiện action ("Tạo tour mới", "Đăng xuất").
- **Phím tắt toàn cục**: `g d` Dashboard, `g t` Tours, `g b` Bookings (Linear style).
- **Multi-tab tabs trong app** (Notion-like): mở nhiều tour đồng thời.
- **Inline edit + auto-save** + indicator "✓ Đã lưu" / "↻ Đang lưu" góc phải dưới.
- **Undo toast 5s** sau mỗi delete.
- **Bulk action** với multi-select checkbox.
- **Resizable side panel** (drag để mở rộng).
- **Saved views** (filter combo): "Booking hôm nay chưa xử lý", "Tour < 4★".

### 21.4.5 Operator mobile companion (compact)

- Chỉ 4 tab: Dashboard | Bookings | Messages | Profile.
- Push noti booking mới với action "Confirm" / "Decline" ngay từ notification.
- Tối ưu cho iPad ngang (NavRail) — đại lý dùng ở quầy.

---

## 21.5 PLATFORM ADMIN — UX/UI quản trị

### 21.5.1 Tinh thần
- **God-mode dashboard**: số liệu toàn nền tảng, can thiệp mọi entity.
- Phong cách: **Vercel Admin**, **Retool**, **Supabase Studio**.
- Web-only, density cực cao, dark mode mặc định.

### 21.5.2 Trang chính

| Trang | Nội dung |
|---|---|
| **Overview** | GMV/MAU/Take-rate realtime, top operator, top tour, alert chuông |
| **Operators** | Danh sách + KYC pending → duyệt/từ chối + xem giấy phép upload |
| **Users** | Search/filter, ban/unban, xem hoạt động, force logout |
| **Tours moderation** | Queue tour cần duyệt (AI flag) |
| **Bookings (all)** | Toàn nền tảng, filter mạnh, export |
| **Disputes** | Khiếu nại refund, thread chat traveler ↔ operator + admin can thiệp |
| **Payouts** | Lịch payout, hold/release, audit |
| **Coupons** | CRUD coupon nền tảng (cross-operator) |
| **AI Console** | Logs aiSessions, semantic cache, model A/B, cost dashboard |
| **Feature flags** | Bật/tắt feature theo cohort (sau §12.4) |
| **Audit log** | Mọi hành động admin lưu lại, search/filter |
| **System health** | Firestore quota, Functions p95 latency, FCM delivery rate |

### 21.5.3 Patterns đặc trưng

- **Đăng nhập bắt buộc 2FA** (TOTP / Passkey).
- **Impersonate user** (xem app dưới góc nhìn user — có badge cảnh báo).
- **Diff viewer** cho thay đổi cấu hình (giống GitHub PR).
- **Bulk SQL-like query** trên Firestore qua Cloud Function (filter/export).
- **Audit banner màu đỏ** cho hành động phá hủy ("Xóa operator" → typing tên để xác nhận).
- **Activity timeline** cho mỗi entity (audit trail).

---

## 21.6 Responsive matrix (cả 3 sản phẩm)

| Width | User | Operator | Admin |
|---|---|---|---|
| < 600 | BottomNav, 1 cột, FAB AI | 4-tab compact | (chặn, redirect "Vui lòng dùng desktop") |
| 600–1024 | NavRail collapsed, 2 cột | NavRail collapsed + DataTable scroll | (cảnh báo) |
| 1024–1440 | NavRail extended, grid 3-4 | NavRail extended, full layout | NavRail extended, 2 panel |
| ≥ 1440 | Center max-width 1280 | max-width 1440 | full-bleed, multi-panel |

---

## 21.7 Auth, role guard & route topology

```
go_router structure:

/                           → User shell (5 tab)
/operator                   → Operator shell (NavRail) — guard: role ∈ {operator_*}
/admin                      → Admin shell — guard: role = platform_admin + 2FA verified
/auth/login
/auth/operator-login        → riêng, theme khác để brand operator
/auth/admin-login           → SSO + 2FA
```

- 1 codebase, 3 entrypoint optional:
  - `flutter run -t lib/main_user.dart` (mobile + web)
  - `flutter build web -t lib/main_operator.dart --base-href /operator/`
  - `flutter build web -t lib/main_admin.dart --base-href /admin/`
- Hoặc cùng 1 entrypoint, route-based theme switch.

Theme override theo entrypoint:
```dart
final isOperator = environment.entrypoint == 'operator';
final scheme = ColorScheme.fromSeed(
  seedColor: isOperator ? const Color(0xFF6C63FF) : const Color(0xFF0E7C66),
  brightness: Brightness.light,
);
```

---

## 21.8 Code snippet — `AppDesignTokens` chia sẻ

```dart
// lib/shared/design_system/app_tokens.dart
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  final double s2, s4, s8, s12, s16, s24, s32, s48;
  final double rSm, rMd, rLg, rXl;
  final Color success, warning, danger, info;
  final BorderRadius brSm, brMd, brLg, brXl;

  const AppTokens({
    this.s2 = 2, this.s4 = 4, this.s8 = 8, this.s12 = 12,
    this.s16 = 16, this.s24 = 24, this.s32 = 32, this.s48 = 48,
    this.rSm = 8, this.rMd = 12, this.rLg = 16, this.rXl = 24,
    this.success = const Color(0xFF16A34A),
    this.warning = const Color(0xFFF59E0B),
    this.danger  = const Color(0xFFDC2626),
    this.info    = const Color(0xFF2563EB),
    this.brSm = const BorderRadius.all(Radius.circular(8)),
    this.brMd = const BorderRadius.all(Radius.circular(12)),
    this.brLg = const BorderRadius.all(Radius.circular(16)),
    this.brXl = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  AppTokens copyWith({/* ... */}) => this;
  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) => this;
}

extension AppTokensX on BuildContext {
  AppTokens get t => Theme.of(this).extension<AppTokens>()!;
}

// Sử dụng:
Padding(padding: EdgeInsets.all(context.t.s16), child: ...)
```

---

## 21.9 Code snippet — `KpiCard` (dùng cho Operator/Admin)

```dart
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final double deltaPct;        // -0.05 = -5%
  final List<double>? sparkline;
  const KpiCard({super.key, required this.label, required this.value, required this.deltaPct, this.sparkline});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final up = deltaPct >= 0;
    final color = up ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(up ? Icons.trending_up : Icons.trending_down, size: 16, color: color),
              const SizedBox(width: 4),
              Text('${(deltaPct * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(width: 6),
              Text('vs 30d trước', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              const Spacer(),
              if (sparkline != null) SizedBox(width: 80, height: 28, child: _Sparkline(sparkline!, color)),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 21.10 Code snippet — `CommandPalette` ⌘K (Operator/Admin)

```dart
class CommandPalette extends StatefulWidget {
  final List<CommandItem> items;
  const CommandPalette({super.key, required this.items});
  // items: {icon, title, shortcut, action}

  static Future<void> show(BuildContext ctx, List<CommandItem> items) =>
      showGeneralDialog(
        context: ctx,
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => CommandPalette(items: items),
        transitionBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(a), child: child)),
      );
  // ... search field + list filter, Enter để chạy action
}

// Bind shortcut toàn cục:
CallbackShortcuts(
  bindings: {
    const SingleActivator(LogicalKeyboardKey.keyK, meta: true, control: true):
        () => CommandPalette.show(context, _commands),
  },
  child: child,
)
```

---

## 21.11 Accessibility & Performance (cả 3 app)

- **A11y:** Semantics labels, focus order, contrast AA, motion-reduce, screen reader test với TalkBack/VoiceOver.
- **Performance:** `const` widget, `RepaintBoundary` cho card list, `addPostFrameCallback` cho heavy init, image `memCacheWidth`.
- **Web SEO** chỉ cho User App (Operator/Admin không cần).
- **Bundle split**: Operator/Admin build web riêng → user mobile không tải code admin.

---

## 21.12 Test UI

- **Golden test**: mỗi component ở light/dark × vi/en × 3 breakpoint = up to 12 ảnh.
- **Storybook-like**: dùng `widgetbook` để demo design system, share với team design.
- **Visual regression CI**: chạy golden trong GitHub Actions.

---

## 21.13 Roadmap UX/UI

| Sprint | Việc | Output |
|---|---|---|
| **UI-1** | Design tokens + theme (light/dark) + 2 brand (User/Admin) | `AppTokens`, theme switcher |
| **UI-2** | Component library shared (Button/Card/Input/Empty/...) + Widgetbook | Catalog component đầy đủ |
| **UI-3** | User App: Discover + TourDetail + BookingSheet với polish (skeleton, hero, glassmorphism) | Mobile + web đẹp như Klook/Airbnb |
| **UI-4** | Operator: NavRail + Dashboard KPI + Tours DataTable + Departures calendar | MVP portal làm việc được |
| **UI-5** | Operator: Bookings Kanban + Messages 3-panel + Command Palette ⌘K | Productivity boost |
| **UI-6** | Admin: Overview + Operator KYC + Disputes + Audit log | Đủ vận hành nền tảng |
| **UI-7** | Micro-interactions (haptic, confetti, hero), motion polish, accessibility audit | Cảm xúc + a11y AA |
| **UI-8** | Golden tests + Widgetbook deploy + design review | QA UI + handoff design |

---

## 21.14 Inspiration references

- **User App**: Airbnb (search/hero), Booking.com (price + filter), Klook (catalog + voucher), Hopper (price prediction), Wanderlog (itinerary timeline).
- **Operator**: Linear (palette/keyboard), Vercel Dashboard (KPI), Stripe Dashboard (data table + chart), Notion (multi-tab inline edit).
- **Admin**: Retool, Supabase Studio, Vercel Admin, Sentry (audit/dispute).
- **Motion/Components**: Material 3, Apple HIG, Vercel Geist.

---

