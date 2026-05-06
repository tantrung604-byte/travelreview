import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/account/account_screen.dart';
import '../../features/admin/admin_providers.dart';
import '../../features/admin/admin_shell.dart';
import '../../features/admin/seo_manager_screen.dart';
import '../../features/admin/image_upload_manager_screen.dart';
import '../../features/auth/auth_providers.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/checkout/checkout_success_screen.dart';
import '../../features/checkout/payment_service.dart';
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
  static const auth = 'auth';
  static const account = 'account';
  static const cart = 'cart';
  static const checkout = 'checkout';
  static const checkoutSuccess = 'checkoutSuccess';
  static const admin = 'admin';
  static const adminSeo = 'adminSeo';
  static const adminImages = 'adminImages';
  static const legal = 'legal';
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Routes yêu cầu user đăng nhập (kể cả anonymous).
const _authRequiredPrefixes = ['/account', '/checkout'];

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAdmin = ref.watch(isAdminProvider);
  final isSignedIn = ref.watch(isSignedInProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final loc = state.uri.path;
      if (loc.startsWith('/admin') && !isAdmin) {
        return '/';
      }
      final needsAuth = _authRequiredPrefixes.any(loc.startsWith);
      if (needsAuth && !isSignedIn) {
        final next = Uri.encodeComponent(state.uri.toString());
        return '/auth?next=$next';
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
        path: '/auth',
        name: AppRouteNames.auth,
        builder: (context, state) => AuthScreen(
          redirect: state.uri.queryParameters['next'],
        ),
      ),
      GoRoute(
        path: '/account',
        name: AppRouteNames.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: AppRouteNames.cart,
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        name: AppRouteNames.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/checkout/success/:bookingId',
        name: AppRouteNames.checkoutSuccess,
        builder: (context, state) => CheckoutSuccessScreen(
          bookingId: state.pathParameters['bookingId'] ?? '',
          result: state.extra is PaymentResult ? state.extra as PaymentResult : null,
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

