import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_providers.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/seo_manager_screen.dart';
import '../../features/admin/image_upload_manager_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/discover/discover_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/legal/legal_hub_screen.dart';
import '../../features/routing/not_found_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/tour/tour_detail_screen.dart';

/// Route names used across the app.
class AppRouteNames {
  AppRouteNames._();

  static const home = 'home';
  static const discover = 'discover';
  static const search = 'search';
  static const tourDetail = 'tourDetail';
  static const booking = 'booking';
  static const admin = 'admin';
  static const adminSeo = 'adminSeo';
  static const adminImages = 'adminImages';
  static const legal = 'legal';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAdmin = ref.watch(isAdminProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isGoingToAdmin = state.uri.path.startsWith('/admin');
      if (isGoingToAdmin && !isAdmin) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/discover',
        name: AppRouteNames.discover,
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/search',
        name: AppRouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/tour/:tourId',
        name: AppRouteNames.tourDetail,
        builder: (context, state) => TourDetailScreen(
          tourId: state.pathParameters['tourId'] ?? 'unknown',
        ),
      ),
      GoRoute(
        path: '/booking/:tourId',
        name: AppRouteNames.booking,
        builder: (context, state) => BookingScreen(
          tourId: state.pathParameters['tourId'] ?? 'unknown',
        ),
      ),
      GoRoute(
        path: '/legal',
        name: AppRouteNames.legal,
        builder: (context, state) => const LegalHubScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: AppRouteNames.admin,
        builder: (context, state) => const AdminShell(initialIndex: 0),
        redirect: (context, state) {
          if (!isAdmin) return '/';
          return null;
        },
        routes: [
          GoRoute(
            path: 'seo',
            name: AppRouteNames.adminSeo,
            builder: (context, state) => const SeoManagerScreen(routeKey: '/'),
          ),
          GoRoute(
            path: 'images',
            name: AppRouteNames.adminImages,
            builder: (context, state) => const ImageUploadManagerScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => NotFoundScreen(
      location: state.uri.toString(),
    ),
  );
});

