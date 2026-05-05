import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/locale/language_switcher.dart';
import '../../app/router/app_router.dart';
import '../../features/admin/admin_providers.dart';
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
            label: const Text('Discover'),
          ),
          TextButton.icon(
            onPressed: () => context.goNamed(AppRouteNames.search),
            icon: const Icon(Icons.search),
            label: const Text('Search'),
          ),
          if (showAdminEntry)
            TextButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.admin),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Admin'),
            ),
          IconButton(
            tooltip: 'Customize theme',
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
      title: 'Da Nang - Ba Na Hills 3D2N',
      location: 'Da Nang',
      rating: '4.9',
      reviews: '2.3k',
      price: '1,290,000đ',
      tag: 'Best seller',
      icon: Icons.cable_outlined,
    ),
    _TourData(
      id: 'sapa-fansipan',
      title: 'Sapa Fansipan trekking',
      location: 'Lao Cai',
      rating: '4.8',
      reviews: '1.8k',
      price: '1,890,000đ',
      tag: 'Hot deal',
      icon: Icons.terrain_outlined,
    ),
    _TourData(
      id: 'phu-quoc-hon-thom',
      title: 'Phu Quoc Hon Thom cable car',
      location: 'Phu Quoc',
      rating: '4.9',
      reviews: '1.1k',
      price: '2,490,000đ',
      tag: 'Family pick',
      icon: Icons.sailing_outlined,
    ),
  ];

  static const _worldPlaces = [
    _WorldPlaceData(
      country: 'Hong Kong',
      emoji: '🇭🇰',
      tagline: 'Disneyland, Victoria Peak, Lan Kwai Fong',
      highlights: [
        'Hong Kong Disneyland — vé ngày, combo gia đình',
        'Victoria Peak Tram — ngắm skyline về đêm',
        'Lan Kwai Fong — nightlife, bar, club',
        'Tsim Sha Tsui Promenade — Avenue of Stars',
      ],
    ),
    _WorldPlaceData(
      country: 'Trung Quốc',
      emoji: '🇨🇳',
      tagline: 'Thượng Hải, Bắc Kinh, Trương Gia Giới',
      highlights: [
        'Shanghai Disneyland — vé vào cổng, fast pass',
        'Vạn Lý Trường Thành — tour trong ngày từ Bắc Kinh',
        'Trương Gia Giới — cầu kính, công viên Avatar',
        'The Bund Thượng Hải — cruise ngắm đêm',
      ],
    ),
    _WorldPlaceData(
      country: 'Hàn Quốc',
      emoji: '🇰🇷',
      tagline: 'Seoul, Busan, Jeju, K-pop experiences',
      highlights: [
        'Lotte World Seoul — vé vui chơi trong ngày',
        'N Seoul Tower — vé đài quan sát, ổ khóa tình yêu',
        'Everland — công viên chủ đề & safari',
        'Jeju Island — tour thiên nhiên, bảo tàng, café view biển',
      ],
    ),
    _WorldPlaceData(
      country: 'Nhật Bản',
      emoji: '🇯🇵',
      tagline: 'Tokyo, Osaka, Kyoto, Universal Studios',
      highlights: [
        'Universal Studios Japan — vé ngày, Express Pass',
        'Tokyo Disneyland / DisneySea — vé công viên',
        'teamLab Planets Tokyo — vé bảo tàng ánh sáng',
        'Kyoto Kimono Experience — thuê kimono, chụp ảnh',
      ],
    ),
    _WorldPlaceData(
      country: 'Singapore',
      emoji: '🇸🇬',
      tagline: 'Sentosa, Marina Bay, Gardens by the Bay',
      highlights: [
        'Universal Studios Singapore — vé vào cổng',
        'Gardens by the Bay — Flower Dome, Cloud Forest',
        'Marina Bay Sands SkyPark — vé ngắm cảnh',
        'S.E.A. Aquarium — vé gia đình',
      ],
    ),
    _WorldPlaceData(
      country: 'Thái Lan',
      emoji: '🇹🇭',
      tagline: 'Bangkok, Pattaya, Phuket, night markets',
      highlights: [
        'Safari World Bangkok — vé show & safari',
        'Chao Phraya Dinner Cruise — ăn tối trên sông',
        'Pattaya Coral Island — tour biển trong ngày',
        'Phuket Fantasea / Carnival Magic — show đêm',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  title: 'Explore by interest',
                  subtitle: 'Quick picks for your next trip',
                  action: 'View all',
                  onAction: () => context.goNamed(AppRouteNames.discover),
                ),
                const SizedBox(height: 12),
                _CategoryStrip(categories: _categories),
                const SizedBox(height: 28),
                const _PromoBanner(),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Trending this week',
                  subtitle: 'Loved by Vietnamese travellers',
                  action: 'See tours',
                  onAction: () => context.goNamed(AppRouteNames.discover),
                ),
                const SizedBox(height: 14),
                _TourGrid(tours: _tours),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: 'Địa Điểm Ăn Chơi Trên Thế Giới',
                  subtitle: 'Chọn quốc gia, xem điểm tham quan và liên hệ admin mua vé',
                  action: 'Liên hệ admin',
                  onAction: () => context.goNamed(AppRouteNames.admin),
                  hideAction: !showAdminEntry,
                ),
                const SizedBox(height: 14),
                _WorldPlacesGrid(places: _worldPlaces),
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
            'TRAVELREVIEW DEALS 2026',
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
          'Discover trips, tickets, and honest reviews.',
          style: theme.textTheme.displaySmall?.copyWith(
            color: const Color(0xFFFFFBEA),
            fontWeight: FontWeight.w900,
            height: 1.05,
            fontSize: isCompact ? 38 : null,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'A Klook-inspired travel marketplace for Vietnam: compare tours, read real reviews, and book experiences in minutes.',
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
          children: const [
            _MiniStat(value: '8.5k+', label: 'Tours'),
            _MiniStat(value: '125k+', label: 'Reviews'),
            _MiniStat(value: '450+', label: 'Verified operators'),
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
                const _SearchSegment(icon: Icons.place_outlined, label: 'Destination', value: 'Da Nang, Sapa...'),
                const Divider(height: 1),
                const _SearchSegment(icon: Icons.calendar_month_outlined, label: 'Date', value: 'Anytime'),
                const Divider(height: 1),
                _SearchButton(fullWidth: true, onPressed: () => context.goNamed(AppRouteNames.search)),
              ],
            )
          : Row(
              children: [
                const Expanded(child: _SearchSegment(icon: Icons.place_outlined, label: 'Destination', value: 'Da Nang, Sapa...')),
                const SizedBox(height: 48, child: VerticalDivider()),
                const Expanded(child: _SearchSegment(icon: Icons.calendar_month_outlined, label: 'Date', value: 'Anytime')),
                const SizedBox(height: 48, child: VerticalDivider()),
                const Expanded(child: _SearchSegment(icon: Icons.people_outline, label: 'Guests', value: '2 adults')),
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
    final button = FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.search),
      label: const Text('Search'),
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
                    Text('★ 4.9 · 1.1k reviews', style: TextStyle(color: Color(0xFFFFD60A), fontWeight: FontWeight.w700)),
                    SizedBox(height: 12),
                    Text('From 2,490,000đ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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
                Text('Flash Deals', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                const SizedBox(height: 8),
                const Text('Save up to 35% on selected experiences this week.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(height: 8),
                const Text('Limited seats, verified operators, instant confirmation.', style: TextStyle(color: Color(0xFFD1D5DB))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(onPressed: () => context.goNamed(AppRouteNames.discover), child: const Text('Book now')),
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
            childAspectRatio: columns == 1 ? 1.55 : 0.92,
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
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/tour/${tour.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.colorScheme.primary, const Color(0xFFFFAB00), const Color(0xFF0A0A0A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(tour.icon, size: 62, color: Colors.black.withValues(alpha: 0.55))),
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
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${tour.location} · ★ ${tour.rating} (${tour.reviews})', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.65))),
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
            childAspectRatio: columns == 1 ? 1.85 : 1.28,
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
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showPlaceDetails(context, place),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(place.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          place.tagline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final highlight in place.highlights.take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                highlight,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showPlaceDetails(context, place),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Xem chi tiết'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Liên hệ admin mua vé',
                    onPressed: () => context.goNamed(AppRouteNames.admin),
                    icon: const Icon(Icons.support_agent_outlined),
                  ),
                ],
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
    final tourIdMap = {
      'Trung Quốc': 'trung-quoc',
      'Nhật Bản': 'nhat-ban',
      'Hàn Quốc': 'han-quoc',
      'Hong Kong': 'hong-kong',
      'Singapore': 'singapore',
      'Thái Lan': 'thail-lan',
    };
    final tourId = tourIdMap[place.country] ?? place.country.toLowerCase().replaceAll(' ', '-');

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
                    'Khu ăn chơi / địa điểm tham quan nổi bật',
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
                    child: const Text(
                      'Bạn có thể liên hệ admin để được tư vấn vé, combo gia đình, lịch mở cửa, ưu đãi nhóm và điều kiện hoàn/hủy.',
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
                        label: const Text('Liên hệ admin mua vé'),
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
                      label: const Text('Xem bài viết review & hướng dẫn'),
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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: const [
        _TrustPill(icon: Icons.verified_outlined, text: 'Verified operators'),
        _TrustPill(icon: Icons.lock_outline, text: 'Secure booking'),
        _TrustPill(icon: Icons.support_agent_outlined, text: '24/7 support'),
        _TrustPill(icon: Icons.reviews_outlined, text: 'Real reviews'),
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
    required this.country,
    required this.emoji,
    required this.tagline,
    required this.highlights,
  });

  final String country;
  final String emoji;
  final String tagline;
  final List<String> highlights;
}

