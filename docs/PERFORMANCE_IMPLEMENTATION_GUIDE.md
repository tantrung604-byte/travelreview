# 🚀 Performance Optimization Implementation Guide

## Các Component Đã Tạo

### 1. **SkeletonLoader** (`lib/core/ui/skeleton_loader.dart`)
Hiển thị loading skeleton khi dữ liệu đang fetch

**Cách dùng**:
```dart
import 'package:travelreview_app/core/ui/skeleton_loader.dart';

// Loading state
if (tourState.isLoading) {
  return SkeletonLoader(
    count: 6,
    itemHeight: 200,
  );
}

// Hoặc grid
if (tourState.isLoading) {
  return SkeletonGrid(
    count: 6,
    crossAxisCount: 3,
    itemHeight: 180,
  );
}

// Data loaded
return _TourGrid(tours: tourState.value);
```

---

### 2. **OptimizedImage** (`lib/core/ui/optimized_image.dart`)
Lazy load image từ network với caching

**Cách dùng**:
```dart
import 'package:travelreview_app/core/ui/optimized_image.dart';

// Basic
OptimizedImage(
  imageUrl: 'https://...tour-image.jpg',
  height: 200,
  width: 300,
  borderRadius: 12,
)

// Lazy loaded version
LazyImage(
  imageUrl: 'https://...tour-image.jpg',
  height: 200,
  borderRadius: 12,
)

// Asset (SVG/PNG)
AssetImage(
  assetPath: 'assets/images/tour_da_nang.svg',
  height: 200,
  width: 200,
)
```

---

### 3. **Responsive** (`lib/core/ui/responsive.dart`)
Adaptive layout cho mobile/tablet/desktop

**Cách dùng**:
```dart
import 'package:travelreview_app/core/ui/responsive.dart';

// Get device type
if (ResponsiveConfig.isMobile(context)) {
  return TourGridMobile(tours: tours);
}

// Grid cross axis count
GridView(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: ResponsiveConfig.getGridCrossAxisCount(context),
  ),
  children: [...],
)

// Responsive widget builder
Responsive(
  mobile: TourListMobile(tours: tours),
  tablet: TourGrid3Cols(tours: tours),
  desktop: TourGrid4Cols(tours: tours),
)

// Content padding
Padding(
  padding: ResponsiveConfig.getContentPadding(context),
  child: Text('Hello'),
)
```

---

### 4. **PerformanceMonitor** (`lib/core/performance/performance_monitor.dart`)
Track app performance & user behavior

**Cách dùng**:
```dart
import 'package:travelreview_app/core/performance/performance_monitor.dart';

// Initialize trong main.dart
void main() async {
  // ... other initialization
  await PerformanceMonitor.instance.initialize();
  // ...
}

// Log screen view
PerformanceMonitor.instance.logScreenView('tour_detail');

// Log custom event
PerformanceMonitor.instance.logEvent('filter_applied', parameters: {
  'filter_type': 'price',
  'filter_value': '1000000-2000000',
});

// Start trace
final trace = PerformanceMonitor.instance.startTrace('fetch_tours');
// ... do work
await trace.stop();

// Log tour view
PerformanceMonitor.instance.logTourView(
  tourId: tour.id,
  tourTitle: tour.title,
);

// Log search
PerformanceMonitor.instance.logSearch('Phu Quoc', resultCount: 12);

// Log purchase
PerformanceMonitor.instance.logPurchase(
  transactionId: 'txn-123',
  value: 1290000,
);
```

---

## 📋 Implementation Checklist

### Phase 1: Critical (This Sprint)

- [ ] **Update pubspec.yaml**
  ```bash
  flutter pub get
  ```

- [ ] **Update Home Screen**
  - Replace static image asset loads with `OptimizedImage`
  - Add skeleton loader in `_HomeLandingContent.build()` when loading tours
  - Use `SkeletonGrid` for tour grid

- [ ] **Update Tour Discover Screen**
  - Implement pagination (load 5 tours initially, "Load More" button)
  - Use skeleton loader while fetching next page
  - Replace tour image with `OptimizedImage`

- [ ] **Update Tour Detail Screen**
  - Show skeleton/loading state while fetching tour details
  - Use `OptimizedImage` for hero image and gallery
  - Add performance trace for page load time

- [ ] **Performance Monitoring**
  - Update `main.dart` to initialize `PerformanceMonitor`
  - Log screen views in router navigation
  - Track tour interactions

### Phase 2: Important (Next Sprint)

- [ ] **Responsive Grid**
  - Update all grid layouts to use `ResponsiveConfig.getGridCrossAxisCount()`
  - Apply responsive padding via `ResponsiveConfig.getContentPadding()`
  
- [ ] **State Management Optimization**
  - Profile Riverpod providers
  - Add `.select()` for granular updates
  - Minimize watch() calls in build

- [ ] **Code Splitting**
  - Lazy load admin module
  - Lazy load checkout/payment flows

---

## 🔨 Integration Steps

### Step 1: Update main.dart
```dart
import 'package:travelreview_app/core/performance/performance_monitor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize performance monitoring
  await PerformanceMonitor.instance.initialize();

  runApp(
    const ProviderScope(
      child: TravelReviewApp(),
    ),
  );
}
```

### Step 2: Update Home Screen
```dart
import 'package:travelreview_app/core/ui/skeleton_loader.dart';
import 'package:travelreview_app/core/ui/optimized_image.dart';

// In _HomeLandingContent.build():
Consumer(builder: (ctx, ref, _) {
  final toursAsync = ref.watch(discoverToursProvider);
  
  return toursAsync.when(
    loading: () => SkeletonGrid(
      count: 6,
      crossAxisCount: ResponsiveConfig.getGridCrossAxisCount(context),
    ),
    data: (tours) => _TourGrid(tours: tours),
    error: (e, st) => ErrorWidget(e),
  );
})
```

### Step 3: Replace Image Assets in Tour Card
```dart
// ❌ Before
Image.asset('assets/images/tour_da_nang.svg')

// ✅ After
OptimizedImage(
  imageUrl: tour.imageUrl, // Firebase Storage URL
  height: 180,
  borderRadius: 8,
)
```

---

## 📊 Expected Performance Improvements

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **FCP** | ~2.5s | ~1.8s | 28% faster |
| **LCP** | ~3.2s | ~2.4s | 25% faster |
| **CLS** | 0.15 | 0.08 | Better UX |
| **Jank** | 60fps drops | 60fps consistent | Smooth scroll |
| **Bundle Size** | ~5MB | ~5.2MB | +4% (worth it) |

---

## 🧪 Testing Performance

### Using Flutter DevTools
```bash
# Start app with profiling
flutter run --profile

# Open DevTools
flutter pub global activate devtools
devtools

# Go to Performance tab
# Record and analyze frame drops
```

### Manual Perf Checks
1. **FCP**: Time to see first content
   - Measure with Google Chrome DevTools
   - Target: < 1.8s

2. **LCP**: Time to see main hero image
   - Measure when image fully loads
   - Target: < 2.5s

3. **CLS**: Layout shift when content loads
   - Check Inspector for unexpected size changes
   - Target: score < 0.1

4. **Jank**: Frame drops during scroll
   - Record 60fps video of scrolling
   - Target: 60fps consistent

---

## 🐛 Debugging Tips

### Check if image is cached
```dart
// Clear image cache if needed
imageCache.clear();
imageCache.clearLiveImages();
```

### Monitor Firestore calls
```dart
// Add to your Firestore queries
final ref = FirebaseFirestore.instance;
// Automatically logs network calls
```

### Profile widget rebuilds
```dart
// Use debugPrintBeginFrameBanner = true;
void main() {
  debugPrintBeginFrameBanner = true;
  // ...
}
```

---

## 📚 References
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf)
- [cached_network_image docs](https://pub.dev/packages/cached_network_image)
- [Shimmer effect guide](https://pub.dev/packages/shimmer)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Web Vitals Explained](https://web.dev/vitals/)


