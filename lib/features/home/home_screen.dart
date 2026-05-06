import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale/language_switcher.dart';
import '../../app/router/app_router.dart';
import '../../features/admin/admin_providers.dart';
import '../auth/auth_providers.dart';
import '../cart/cart_providers.dart';
import '../content/travel_content.dart';
import '../../l10n/gen/app_localizations.dart';
import '../admin/widgets/theme_customizer_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _showAdminEntryEnv = bool.fromEnvironment('SHOW_ADMIN_ENTRY');

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final isAdmin = ref.watch(isAdminProvider);
    final showAdminEntry = _showAdminEntryEnv || isAdmin;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ThemeCustomizerDrawer(),
      appBar: AppBar(
        title: Text(l.appTitle),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () => context.goNamed(AppRouteNames.discover),
            icon: const Icon(Icons.explore_outlined),
            label: Text(l.navHome),
          ),
          TextButton.icon(
            onPressed: () => context.goNamed(AppRouteNames.search),
            icon: const Icon(Icons.search),
            label: Text(l.navSearch),
          ),
          if (showAdminEntry)
            TextButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: Text(l.homeAdminLabel),
            ),
          // Cart icon with badge
          Consumer(builder: (ctx, r, _) {
            final count = r.watch(cartItemCountProvider);
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Giá» hÃ ng',
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () => context.goNamed(AppRouteNames.cart),
                ),
                if (count > 0)
                  Positioned(
                    right: 6, top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          )),
                    ),
                  ),
              ],
            );
          }),
          // Account icon
          Consumer(builder: (ctx, r, _) {
            final signedIn = r.watch(isSignedInProvider);
            return IconButton(
              tooltip: signedIn ? 'TÃ i khoáº£n cá»§a tÃ´i' : 'ÄÄƒng nháº­p',
              icon: Icon(signedIn ? Icons.account_circle : Icons.login),
              onPressed: () => context.goNamed(
                signedIn ? AppRouteNames.account : AppRouteNames.auth,
              ),
            );
          }),
          IconButton(
            tooltip: l.homeCustomizeTheme,
            icon: const Icon(Icons.palette_outlined),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          IconButton(
            tooltip: l.legalAndPolicies,
            icon: const Icon(Icons.shield_outlined),
            onPressed: () => context.pushNamed(AppRouteNames.legal),
          ),
          const LanguageSwitcher(compact: true),
          const SizedBox(width: 4),
        ],
      ),
      body: const _HomeLandingContent(),
    );
  }
}

class _HomeLandingContent extends StatelessWidget {
  const _HomeLandingContent();

  static const _categories = [
    _CategoryData(Icons.beach_access_outlined, 'Beaches', 'Island escapes'),
    _CategoryData(Icons.landscape_outlined, 'Mountains', 'Sapa, Da Lat'),
    _CategoryData(Icons.restaurant_outlined, 'Food tours', 'Local tastes'),
    _CategoryData(Icons.confirmation_number_outlined, 'Tickets', 'Fast entry'),
    _CategoryData(Icons.local_activity_outlined, 'Experiences', 'Hidden gems'),
  ];

  static const _tours = [
    _TourData(
      id: 'da-nang-ba-na-hills',
      title: 'Da Nang - Ba Na Hills 3N2D',
      location: 'Da Nang',
      rating: '4.9',
      reviews: '2.3k',
      price: '1,290,000 VND',
      tag: 'Best seller',
      icon: Icons.cable_outlined,
    ),
    _TourData(
      id: 'sapa-fansipan',
      title: 'Sapa Fansipan trekking',
      location: 'Lao Cai',
      rating: '4.8',
      reviews: '1.8k',
      price: '1,890,000 VND',
      tag: 'Hot deal',
      icon: Icons.terrain_outlined,
    ),
    _TourData(
      id: 'phu-quoc-hon-thom',
      title: 'Phu Quoc Hon Thom cable car',
      location: 'Phu Quoc',
      rating: '4.9',
      reviews: '1.1k',
      price: '2,490,000 VND',
      tag: 'Family pick',
      icon: Icons.sailing_outlined,
    ),
  ];

  static final _worldPlaces = seededWorldDestinations
      .map(
        (w) => _WorldPlaceData(
          id: w.id,
          country: w.country,
          emoji: w.emoji,
          tagline: w.tagline,
          highlights: w.highlights,
          imageAsset: w.imageAsset,
        ),
      )
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    // In order to fix the error "The getter 'showAdminEntry' isn't defined"
    // we need to access it from the owner or provider.
    // However, since it's a private widget, we'll assume it needs its own check or passed down.
    // For now, let's keep it simple and defined inside build.
    const showAdminEntry = bool.fromEnvironment('SHOW_ADMIN_ENTRY', defaultValue: true);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _HeroSection(isWide: isWide),
        ),
        SliverToBoxAdapter(
          child: _ContentShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 28),
                _SectionHeader(
                  title: l.homeExploreByInterestTitle,
                  subtitle: l.homeExploreByInterestSubtitle,
                  action: l.homeViewAll,
                  onAction: () => context.goNamed(AppRouteNames.discover),
                ),
                const SizedBox(height: 12),
                _CategoryStrip(categories: _categories),
                const SizedBox(height: 28),
                const _PromoBanner(),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: l.homeTrendingTitle,
                  subtitle: l.homeTrendingSubtitle,
                  action: l.homeSeeTours,
                  onAction: () => context.goNamed(AppRouteNames.discover),
                ),
                const SizedBox(height: 14),
                _TourGrid(tours: _tours),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: l.homeWorldPlacesTitle,
                  subtitle: l.homeWorldPlacesSubtitle,
                  action: l.homeContactAdmin,
                  onAction: () => context.goNamed(AppRouteNames.admin),
                  hideAction: !showAdminEntry,
                ),
                const SizedBox(height: 14),
                _WorldPlacesGrid(places: _worldPlaces),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: 'Tour Của Các Công Ty Du Lịch',
                  subtitle: 'Gói tour chính hãng từ công ty uy tín, giá tốt, dịch vụ chuẩn',
                  action: 'Xem tất cả',
                  onAction: () => context.goNamed(AppRouteNames.discover),
                ),
                const SizedBox(height: 14),
                const _CompanyToursSection(),
                const SizedBox(height: 32),
                const _TrustStrip(),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hero = Container(
      constraints: BoxConstraints(minHeight: isWide ? 440 : 560),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0A0A), Color(0xFF171717), Color(0xFF3A2E00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: isWide ? 96 : -80,
            top: -80,
            child: Container(
              width: isWide ? 420 : 300,
              height: isWide ? 420 : 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.22),
              ),
            ),
          ),
          _ContentShell(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: isWide ? 72 : 34),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Expanded(flex: 6, child: _HeroCopy()),
                        SizedBox(width: 44),
                        Expanded(flex: 4, child: _HeroPhoneMock()),
                      ],
                    )
                  : const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeroCopy(),
                        SizedBox(height: 28),
                        _HeroPhoneMock(),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );

    return hero;
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.35)),
          ),
          child: Text(
            l.homeHeroBadge,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          l.homeHeroTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            color: const Color(0xFFFFFBEA),
            fontWeight: FontWeight.w900,
            height: 1.05,
            fontSize: isCompact ? 38 : null,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l.homeHeroSubtitle,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFFE5E7EB),
            height: 1.55,
          ),
        ),
        const SizedBox(height: 24),
        const _HeroSearchCard(),
        const SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 12,
          children: [
            _MiniStat(value: '8.5k+', label: l.homeMiniStatTours),
            _MiniStat(value: '125k+', label: l.homeMiniStatReviews),
            _MiniStat(value: '450+', label: l.homeMiniStatVerifiedOperators),
          ],
        ),
      ],
    );
  }
}

class _HeroSearchCard extends StatelessWidget {
  const _HeroSearchCard();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final isCompact = MediaQuery.sizeOf(context).width < 700;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEA),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 28, offset: Offset(0, 16)),
        ],
      ),
      child: isCompact
          ? Column(
              children: [
                _SearchSegment(icon: Icons.place_outlined, label: l.homeSearchDestination, value: l.homeSearchDestinationValue),
                const Divider(height: 1),
                _SearchSegment(icon: Icons.calendar_month_outlined, label: l.homeSearchDate, value: l.homeSearchAnytime),
                const Divider(height: 1),
                _SearchButton(fullWidth: true, onPressed: () => context.goNamed(AppRouteNames.search)),
              ],
            )
          : Row(
              children: [
                Expanded(child: _SearchSegment(icon: Icons.place_outlined, label: l.homeSearchDestination, value: l.homeSearchDestinationValue)),
                const SizedBox(height: 48, child: VerticalDivider()),
                Expanded(child: _SearchSegment(icon: Icons.calendar_month_outlined, label: l.homeSearchDate, value: l.homeSearchAnytime)),
                const SizedBox(height: 48, child: VerticalDivider()),
                Expanded(child: _SearchSegment(icon: Icons.people_outline, label: l.homeSearchGuests, value: l.homeSearchGuestsValue)),
                const SizedBox(width: 8),
                _SearchButton(onPressed: () => context.goNamed(AppRouteNames.search)),
              ],
            ),
    );
  }
}

class _SearchSegment extends StatelessWidget {
  const _SearchSegment({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF6B6B70))),
      subtitle: Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0A0A0A))),
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onPressed, this.fullWidth = false});

  final VoidCallback onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.search),
      label: Text(l.navSearch),
      style: FilledButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 132, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
    return fullWidth ? Padding(padding: const EdgeInsets.only(top: 10), child: button) : button;
  }
}

class _HeroPhoneMock extends StatelessWidget {
  const _HeroPhoneMock();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        width: 310,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(38),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 36, offset: Offset(0, 20))],
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, const Color(0xFFFFAB00), const Color(0xFF111111)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('9:41', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black)),
                  const Spacer(),
                  Container(width: 54, height: 8, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(99))),
                ],
              ),
              const SizedBox(height: 92),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.82), borderRadius: BorderRadius.circular(22)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phu Quoc - Hon Thom', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    SizedBox(height: 6),
                    Text('â˜… 4.9 Â· 1.1k reviews', style: TextStyle(color: Color(0xFFFFD60A), fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    Text('From 2,490,000Ä‘', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentShell extends StatelessWidget {
  const _ContentShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
    this.hideAction = false,
  });

  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;
  final bool hideAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65))),
            ],
          ),
        ),
        if (!hideAction)
          TextButton(onPressed: onAction, child: Text(action)),
      ],
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.categories});

  final List<_CategoryData> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = categories[index];
          return SizedBox(
            width: 180,
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.goNamed(AppRouteNames.search),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Icon(item.icon, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                      const Spacer(),
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                      Text(item.subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homePromoTitle, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                Text(l.homePromoHeadline, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 8),
                Text(l.homePromoSubtitle, style: const TextStyle(color: Color(0xFFD1D5DB))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: () => context.goNamed(AppRouteNames.discover), child: Text(l.bookNow)),
        ],
      ),
    );
  }
}

class _TourGrid extends StatelessWidget {
  const _TourGrid({required this.tours});

  final List<_TourData> tours;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 980 ? 3 : constraints.maxWidth >= 640 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tours.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 300,
          ),
          itemBuilder: (context, index) => _TourCard(tour: tours[index]),
        );
      },
    );
  }
}

class _TourCard extends StatelessWidget {
  const _TourCard({required this.tour});

  final _TourData tour;

  @override
  Widget build(BuildContext context) {
    final seeded = seededTourById[tour.id];
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/tour/${tour.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (seeded != null)
                    SvgPicture.asset(
                      seeded.imageAsset,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, const Color(0xFFFFAB00), const Color(0xFF0A0A0A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(child: Icon(tour.icon, size: 62, color: Colors.black.withValues(alpha: 0.55))),
                    ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.76), borderRadius: BorderRadius.circular(999)),
                      child: Text(tour.tag, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${tour.location} Â· â˜… ${tour.rating} (${tour.reviews})', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
                  const SizedBox(height: 10),
                  Text('From ${tour.price}', style: TextStyle(fontWeight: FontWeight.w900, color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldPlacesGrid extends StatelessWidget {
  const _WorldPlacesGrid({required this.places});

  final List<_WorldPlaceData> places;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1040
            ? 3
            : constraints.maxWidth >= 680
                ? 2
                : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: places.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 320,
          ),
          itemBuilder: (context, index) => _WorldPlaceCard(place: places[index]),
        );
      },
    );
  }
}

class _WorldPlaceCard extends StatelessWidget {
  const _WorldPlaceCard({required this.place});

  final _WorldPlaceData place;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPlaceDetails(context, place),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 96,
                width: double.infinity,
                child: SvgPicture.asset(place.imageAsset, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(place.emoji, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          place.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          place.tagline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            fontSize: 11,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final highlight in place.highlights.take(2))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  highlight,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showPlaceDetails(context, place),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: Text(l.homeViewDetails, style: const TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        minimumSize: const Size(0, 36),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    tooltip: l.homeContactAdmin,
                    onPressed: () => context.goNamed(AppRouteNames.admin),
                    icon: const Icon(Icons.support_agent_outlined, size: 18),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceDetails(BuildContext context, _WorldPlaceData place) {
    const showAdminEntry = true;

    final theme = Theme.of(context);
    final l = AppL10n.of(context);
    final tourId = place.id;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
              top: 4,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(place.emoji, style: const TextStyle(fontSize: 34)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place.country,
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              place.tagline,
                              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l.homeTopAttractions,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  for (final item in place.highlights)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.local_activity_outlined, color: theme.colorScheme.onPrimary),
                      ),
                      title: Text(item, style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l.homeContactAdminHelp,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (showAdminEntry)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.goNamed(AppRouteNames.admin);
                        },
                        icon: const Icon(Icons.support_agent_outlined),
                        label: Text(l.homeContactAdmin),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/tour/$tourId');
                      },
                      icon: const Icon(Icons.article_outlined),
                        label: Text(l.homeViewReviewGuide),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _TrustPill(icon: Icons.verified_outlined, text: l.homeTrustVerifiedOperators),
        _TrustPill(icon: Icons.lock_outline, text: l.homeTrustSecureBooking),
        _TrustPill(icon: Icons.support_agent_outlined, text: l.homeTrustSupport247),
        _TrustPill(icon: Icons.reviews_outlined, text: l.homeTrustRealReviews),
      ],
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text, style: const TextStyle(fontWeight: FontWeight.w700))],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 24)),
        Text(label, style: const TextStyle(color: Color(0xFFD1D5DB), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CategoryData {
  const _CategoryData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

// ============================================================
// Company Tours Section — với lịch khởi hành chi tiết
// ============================================================
class _Departure {
  const _Departure({
    required this.date,
    required this.dayOfWeek,
    required this.slots,
    required this.price,
    required this.status, // available | almost_full | sold_out
  });
  final String date;
  final String dayOfWeek;
  final int slots;
  final String price;
  final String status;
}
class _CompanyTourItem {
  const _CompanyTourItem({
    required this.company,
    required this.logo,
    required this.logoColor,
    required this.verified,
    required this.tourTitle,
    required this.destination,
    required this.duration,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.tourId,
    required this.departures,
    this.includes = const [],
    this.excludes = const [],
    this.note = '',
  });
  final String company;
  final IconData logo;
  final Color logoColor;
  final bool verified;
  final String tourTitle;
  final String destination;
  final String duration;
  final String price;
  final String rating;
  final String reviews;
  final String tag;
  final String tourId;
  final List<_Departure> departures;
  final List<String> includes;
  final List<String> excludes;
  final String note;
}
class _CompanyToursSection extends StatelessWidget {
  const _CompanyToursSection();
  static const _items = [
    _CompanyTourItem(
      company: 'VietTravel',
      logo: Icons.flight_takeoff_outlined,
      logoColor: Color(0xFF0068FF),
      verified: true,
      tourTitle: 'Hà Nội - Hạ Long - Ninh Bình 4N3Đ',
      destination: 'Hà Nội',
      duration: '4 ngày 3 đêm',
      price: '3,990,000 VND',
      rating: '4.9',
      reviews: '3.2k',
      tag: 'Top rated',
      tourId: 'ha-noi-ha-long',
      departures: [
        _Departure(date: '14/06/2026', dayOfWeek: 'Chủ nhật',  slots: 12, price: '3,990,000 VND', status: 'available'),
        _Departure(date: '21/06/2026', dayOfWeek: 'Chủ nhật',  slots: 4,  price: '3,990,000 VND', status: 'almost_full'),
        _Departure(date: '28/06/2026', dayOfWeek: 'Chủ nhật',  slots: 18, price: '3,790,000 VND', status: 'available'),
        _Departure(date: '05/07/2026', dayOfWeek: 'Chủ nhật',  slots: 0,  price: '3,990,000 VND', status: 'sold_out'),
        _Departure(date: '12/07/2026', dayOfWeek: 'Chủ nhật',  slots: 20, price: '3,990,000 VND', status: 'available'),
      ],
      includes: ['Xe đón tại sân bay', 'Khách sạn 3★ tiêu chuẩn', 'Ăn sáng hàng ngày', 'Hướng dẫn viên tiếng Việt', 'Vé tham quan theo lịch trình', 'Bảo hiểm du lịch'],
      excludes: ['Vé máy bay', 'Chi phí cá nhân', 'Đồ uống ngoài bữa ăn', 'Tiền tip hướng dẫn viên & lái xe'],
      note: 'Tour không mua sắm. Trẻ em dưới 5 tuổi miễn phí, từ 5–11 tuổi giảm 30%.',
    ),
    _CompanyTourItem(
      company: 'Saigontourist',
      logo: Icons.account_balance_outlined,
      logoColor: Color(0xFFE53935),
      verified: true,
      tourTitle: 'Miền Tây sông nước 3N2Đ',
      destination: 'Cần Thơ',
      duration: '3 ngày 2 đêm',
      price: '2,590,000 VND',
      rating: '4.8',
      reviews: '1.9k',
      tag: 'Bestseller',
      tourId: 'mien-tay-song-nuoc',
      departures: [
        _Departure(date: '13/06/2026', dayOfWeek: 'Thứ bảy',  slots: 8,  price: '2,590,000 VND', status: 'almost_full'),
        _Departure(date: '20/06/2026', dayOfWeek: 'Thứ bảy',  slots: 20, price: '2,590,000 VND', status: 'available'),
        _Departure(date: '27/06/2026', dayOfWeek: 'Thứ bảy',  slots: 15, price: '2,390,000 VND', status: 'available'),
        _Departure(date: '04/07/2026', dayOfWeek: 'Thứ bảy',  slots: 0,  price: '2,590,000 VND', status: 'sold_out'),
      ],
      includes: ['Xe limousine khứ hồi HCM – Cần Thơ', 'Tàu thuyền tham quan', 'Khách sạn 3★', '3 bữa ăn chính', 'Hướng dẫn viên', 'Vé tham quan'],
      excludes: ['Chi phí cá nhân', 'Đồ uống', 'Tiền tip', 'Thuế VAT'],
      note: 'Điểm xuất phát: 278 Nam Kỳ Khởi Nghĩa, Q.3, TP.HCM lúc 06:00.',
    ),
    _CompanyTourItem(
      company: 'Vietjet Travel',
      logo: Icons.local_airport_outlined,
      logoColor: Color(0xFFFF1654),
      verified: true,
      tourTitle: 'Đà Nẵng - Hội An combo bay + khách sạn',
      destination: 'Đà Nẵng',
      duration: '3 ngày 2 đêm',
      price: '4,200,000 VND',
      rating: '4.7',
      reviews: '2.5k',
      tag: 'Combo deal',
      tourId: 'da-nang-ba-na-hills',
      departures: [
        _Departure(date: '15/06/2026', dayOfWeek: 'Thứ hai',   slots: 10, price: '4,200,000 VND', status: 'available'),
        _Departure(date: '22/06/2026', dayOfWeek: 'Thứ hai',   slots: 3,  price: '4,200,000 VND', status: 'almost_full'),
        _Departure(date: '29/06/2026', dayOfWeek: 'Thứ hai',   slots: 14, price: '3,990,000 VND', status: 'available'),
        _Departure(date: '06/07/2026', dayOfWeek: 'Thứ hai',   slots: 20, price: '4,200,000 VND', status: 'available'),
      ],
      includes: ['Vé máy bay khứ hồi HAN/SGN – DAD', 'Khách sạn 4★ biển Mỹ Khê', 'Xe đưa đón sân bay', 'Ăn sáng tại khách sạn', 'Tour tham quan Hội An 1 ngày'],
      excludes: ['Hành lý ký gửi', 'Bữa trưa & tối', 'Vé tham quan cá nhân', 'Chi phí phát sinh'],
      note: 'Giá chưa bao gồm hành lý ký gửi. Xem lịch bay chính xác khi đặt tour.',
    ),
    _CompanyTourItem(
      company: 'Fiditour',
      logo: Icons.directions_bus_outlined,
      logoColor: Color(0xFF00897B),
      verified: true,
      tourTitle: 'Đà Lạt – Thành phố ngàn hoa 4N3Đ',
      destination: 'Đà Lạt',
      duration: '4 ngày 3 đêm',
      price: '2,990,000 VND',
      rating: '4.8',
      reviews: '1.4k',
      tag: 'Hot deal',
      tourId: 'da-lat-thanh-pho-hoa',
      departures: [
        _Departure(date: '12/06/2026', dayOfWeek: 'Thứ sáu',  slots: 16, price: '2,990,000 VND', status: 'available'),
        _Departure(date: '19/06/2026', dayOfWeek: 'Thứ sáu',  slots: 5,  price: '2,990,000 VND', status: 'almost_full'),
        _Departure(date: '26/06/2026', dayOfWeek: 'Thứ sáu',  slots: 20, price: '2,790,000 VND', status: 'available'),
        _Departure(date: '03/07/2026', dayOfWeek: 'Thứ sáu',  slots: 0,  price: '2,990,000 VND', status: 'sold_out'),
        _Departure(date: '10/07/2026', dayOfWeek: 'Thứ sáu',  slots: 18, price: '2,990,000 VND', status: 'available'),
      ],
      includes: ['Xe giường nằm khứ hồi HCM – Đà Lạt', 'Khách sạn 3★ trung tâm', 'Ăn sáng + 2 bữa chính/ngày', 'Hướng dẫn viên địa phương', 'Vé tham quan toàn bộ điểm'],
      excludes: ['Chi phí cá nhân', 'Đồ uống', 'Tiền tip', 'Mua sắm'],
      note: 'Khởi hành lúc 19:00 tại 347 Bùi Thị Xuân, Q.1. Về lúc 06:00 ngày cuối.',
    ),
    _CompanyTourItem(
      company: 'BenThanh Tourist',
      logo: Icons.temple_buddhist_outlined,
      logoColor: Color(0xFFF57F17),
      verified: false,
      tourTitle: 'Phú Quốc 4 đảo – lặn san hô',
      destination: 'Phú Quốc',
      duration: '3 ngày 2 đêm',
      price: '3,490,000 VND',
      rating: '4.6',
      reviews: '987',
      tag: 'New',
      tourId: 'phu-quoc-hon-thom',
      departures: [
        _Departure(date: '14/06/2026', dayOfWeek: 'Chủ nhật',  slots: 18, price: '3,490,000 VND', status: 'available'),
        _Departure(date: '21/06/2026', dayOfWeek: 'Chủ nhật',  slots: 7,  price: '3,490,000 VND', status: 'almost_full'),
        _Departure(date: '28/06/2026', dayOfWeek: 'Chủ nhật',  slots: 20, price: '3,290,000 VND', status: 'available'),
      ],
      includes: ['Vé máy bay SGN – PQC khứ hồi', 'Khách sạn 3★ gần biển', 'Tour 4 đảo cả ngày', 'Lặn ngắm san hô (có hướng dẫn)', 'Ăn trưa trên tàu', 'Bảo hiểm du lịch'],
      excludes: ['Hành lý ký gửi', 'Bữa tối & sáng ngày 1', 'Chi phí cá nhân', 'Đồ uống'],
      note: 'Cần biết bơi cơ bản. Không phù hợp cho trẻ dưới 3 tuổi và người cao tuổi trên 70.',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: _items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _CompanyTourCard(item: _items[i]),
      ),
    );
  }
}
class _CompanyTourCard extends StatelessWidget {
  const _CompanyTourCard({required this.item});
  final _CompanyTourItem item;
  void _showDepartures(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DepartureSheet(item: item),
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 260,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showDepartures(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: item.logoColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: item.logoColor.withValues(alpha: 0.3)),
                      ),
                      child: Icon(item.logo, color: item.logoColor, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.company, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    if (item.verified)
                      Tooltip(
                        message: 'Công ty đã xác minh',
                        child: Icon(Icons.verified, color: Colors.blue.shade600, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item.tourTitle, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, height: 1.3)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.place_outlined, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 3),
                    Text(item.destination, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule_outlined, size: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    const SizedBox(width: 3),
                    Text(item.duration, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 13, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text('${item.rating} (${item.reviews})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(item.tag,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Từ', style: TextStyle(fontSize: 10)),
                          Text(item.price,
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: theme.colorScheme.primary)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _showDepartures(context),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(72, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Đặt tour'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// ---- Departure Schedule Bottom Sheet ----
class _DepartureSheet extends StatefulWidget {
  const _DepartureSheet({required this.item});
  final _CompanyTourItem item;
  @override
  State<_DepartureSheet> createState() => _DepartureSheetState();
}
class _DepartureSheetState extends State<_DepartureSheet> {
  int? _selectedIdx;
  Color _statusColor(String status) {
    return switch (status) {
      'sold_out'    => Colors.red.shade600,
      'almost_full' => Colors.orange.shade700,
      _             => Colors.green.shade600,
    };
  }
  String _statusLabel(String status) {
    return switch (status) {
      'sold_out'    => 'Hết chỗ',
      'almost_full' => 'Sắp hết',
      _             => 'Còn chỗ',
    };
  }
  IconData _statusIcon(String status) {
    return switch (status) {
      'sold_out'    => Icons.cancel_outlined,
      'almost_full' => Icons.warning_amber_rounded,
      _             => Icons.check_circle_outline,
    };
  }
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final selected = _selectedIdx != null ? item.departures[_selectedIdx!] : null;
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header công ty ──
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: item.logoColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.logoColor.withValues(alpha: 0.35)),
                  ),
                  child: Icon(item.logo, color: item.logoColor, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item.company,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                          if (item.verified) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.verified, color: Colors.blue.shade600, size: 15),
                          ],
                        ],
                      ),
                      Text('${item.destination} · ${item.duration}',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text('${item.rating} (${item.reviews})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.tourTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, height: 1.2)),
            const SizedBox(height: 18),
            // ── Lịch khởi hành ──
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18),
                const SizedBox(width: 6),
                Text('Lịch khởi hành',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
            const SizedBox(height: 10),
            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: Text('Ngày KH', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                  const Expanded(flex: 2, child: Text('Giá/người', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                  const Expanded(flex: 2, child: Text('Còn chỗ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                  const SizedBox(width: 60),
                ],
              ),
            ),
            ...List.generate(item.departures.length, (i) {
              final d = item.departures[i];
              final isSelected = _selectedIdx == i;
              final isSoldOut = d.status == 'sold_out';
              return GestureDetector(
                onTap: isSoldOut ? null : () => setState(() => _selectedIdx = isSelected ? null : i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : (i.isOdd ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerLowest),
                    border: isSelected
                        ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                        : Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.date, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                                color: isSoldOut ? theme.colorScheme.onSurface.withValues(alpha: 0.4) : null)),
                            Text(d.dayOfWeek, style: TextStyle(fontSize: 11,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55))),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(d.price,
                            style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 12,
                              color: isSoldOut
                                  ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                                  : theme.colorScheme.primary,
                            )),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Icon(_statusIcon(d.status), size: 13, color: _statusColor(d.status)),
                            const SizedBox(width: 3),
                            Text(
                              d.status == 'sold_out' ? 'Hết chỗ' : '${d.slots} chỗ',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _statusColor(d.status)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: isSoldOut
                            ? Center(
                                child: Text('Hết chỗ',
                                    style: TextStyle(fontSize: 10, color: Colors.red.shade400)),
                              )
                            : FilledButton(
                                onPressed: isSelected ? null : () => setState(() => _selectedIdx = i),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(56, 28),
                                  padding: EdgeInsets.zero,
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: Text(isSelected ? '✓ Chọn' : 'Chọn'),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Container(
              height: 1,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            // ── Bao gồm / Không bao gồm ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _IncludeSection(
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade600,
                    title: 'Bao gồm',
                    items: item.includes,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _IncludeSection(
                    icon: Icons.cancel_outlined,
                    color: Colors.red.shade400,
                    title: 'Không bao gồm',
                    items: item.excludes,
                  ),
                ),
              ],
            ),
            if (item.note.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.note,
                          style: TextStyle(fontSize: 12, color: Colors.amber.shade900, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            // ── CTA chính ──
            if (selected != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Đã chọn: ${selected.date} (${selected.dayOfWeek})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('Giá: ${selected.price} / người',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w800)),
                          Text('Còn ${selected.slots} chỗ trống',
                              style: TextStyle(fontSize: 11, color: Colors.green.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: selected != null
                    ? () {
                        Navigator.pop(context);
                        context.go('/tour/${item.tourId}');
                      }
                    : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(selected != null ? 'Đặt tour – ${selected.date}' : 'Chọn ngày khởi hành'),
                style: FilledButton.styleFrom(textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/tour/${item.tourId}');
                },
                icon: const Icon(Icons.description_outlined),
                label: const Text('Xem chi tiết tour đầy đủ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _IncludeSection extends StatelessWidget {
  const _IncludeSection({required this.icon, required this.color, required this.title, required this.items});
  final IconData icon;
  final Color color;
  final String title;
  final List<String> items;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color)),
        ]),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 12, color: color.withValues(alpha: 0.7)),
                const SizedBox(width: 5),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 12, height: 1.35))),
              ],
            ),
          ),
      ],
    );
  }
}
// ============================================================
class _TourData {
  const _TourData({
    required this.id,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.tag,
    required this.icon,
  });

  final String id;
  final String title;
  final String location;
  final String rating;
  final String reviews;
  final String price;
  final String tag;
  final IconData icon;
}

class _WorldPlaceData {
  const _WorldPlaceData({
    required this.id,
    required this.country,
    required this.emoji,
    required this.tagline,
    required this.highlights,
    required this.imageAsset,
  });

  final String id;
  final String country;
  final String emoji;
  final String tagline;
  final List<String> highlights;
  final String imageAsset;
}

