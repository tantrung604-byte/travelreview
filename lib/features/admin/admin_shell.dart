import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme_controller.dart';
import 'seo_manager_screen.dart';
import 'image_upload_manager_screen.dart'; // Thêm mới
import 'widgets/theme_customizer_drawer.dart';

/// Shell Admin Portal — chia sẻ theme với User App qua `appThemeControllerProvider`.
/// Đổi màu/font/density ở đây = đổi cả app + web cùng lúc.
class AdminShell extends ConsumerWidget {
  const AdminShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch để admin shell tự rebuild khi đổi theme global.
    ref.watch(appThemeControllerProvider);
    return _AdminScaffold(initialIndex: initialIndex);
  }
}

class _AdminScaffold extends ConsumerStatefulWidget {
  const _AdminScaffold({required this.initialIndex});

  final int initialIndex;

  @override
  ConsumerState<_AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends ConsumerState<_AdminScaffold> {
  late int _navIdx;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _navIdx = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ThemeCustomizerDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            _NavRail(
              selected: _navIdx,
              onSelect: (i) => setState(() => _navIdx = i),
              isDark: isDark,
              primary: theme.colorScheme.primary,
            ),
            Expanded(
              child: Column(
                children: [
                  _TopBar(
                    onOpenCustomizer: () =>
                        _scaffoldKey.currentState?.openEndDrawer(),
                    onBackHome: () => Navigator.of(context).maybePop(),
                  ),
                  const Divider(height: 1),
                  Expanded(child: _DashboardBody(navIdx: _navIdx)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        icon: const Icon(Icons.palette_outlined),
        label: const Text('Đổi giao diện'),
      ),
    );
  }
}

// ===================== NAV RAIL =====================
class _NavRail extends StatelessWidget {
  const _NavRail({
    required this.selected,
    required this.onSelect,
    required this.isDark,
    required this.primary,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final bool isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.dashboard_outlined, 'Tổng quan'),
      (Icons.business_outlined, 'Operators'),
      (Icons.people_outline, 'Users'),
      (Icons.map_outlined, 'Tours'),
      (Icons.event_note_outlined, 'Bookings'),
      (Icons.gavel_outlined, 'Disputes'),
      (Icons.payments_outlined, 'Payouts'),
      (Icons.image_outlined, 'Upload Ảnh'), // Thêm mới item mục số 7
      (Icons.code_outlined, 'AI Console'),
      (Icons.search_outlined, '🔍 SEO Manager'),
      (Icons.history, 'Audit'),
    ];

    return Container(
      width: 232,
      color: isDark ? const Color(0xFF111114) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('T',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Admin',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Text('⚠ PROD',
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++)
            _navItem(context, items[i].$1, items[i].$2, i == selected,
                () => onSelect(i)),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext ctx, IconData icon, String label,
      bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: active ? primary.withValues(alpha: 0.16) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 3, height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: active ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(icon,
                    size: 20,
                    color: active
                        ? primary
                        : Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7)),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    color: active
                        ? primary
                        : Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== TOP BAR =====================
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onOpenCustomizer, required this.onBackHome});
  final VoidCallback onOpenCustomizer;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 60,
      color: theme.cardTheme.color,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Về app',
            icon: const Icon(Icons.arrow_back),
            onPressed: onBackHome,
          ),
          const SizedBox(width: 4),
          Text('Admin', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          const Text(' / '),
          const Text('Tổng quan',
              style: TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          // Search
          SizedBox(
            width: 320,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tìm operator, tour, user...',
                prefixIcon: const Icon(Icons.search, size: 18),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Center(
                      child: Text('⌘K',
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            tooltip: 'Tùy biến giao diện',
            icon: const Icon(Icons.palette_outlined),
            onPressed: onOpenCustomizer,
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const Positioned(
                right: 8, top: 8,
                child: CircleAvatar(
                    radius: 7,
                    backgroundColor: Color(0xFFEF4444),
                    child: Text('3',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800))),
              ),
            ],
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Text('T',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimary)),
          ),
          const SizedBox(width: 8),
          const Text('tantr',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ===================== DASHBOARD BODY =====================
class _DashboardBody extends StatelessWidget {
  final int navIdx;

  const _DashboardBody({required this.navIdx});

  @override
  Widget build(BuildContext context) {
    // Route to different pages based on navIdx
    switch (navIdx) {
      case 7: // Upload Ảnh
        return const ImageUploadManagerScreen();
      case 9: // SEO Manager (Cập nhật từ 8 lên 9 vì thêm Upload Ảnh ở trên)
        return const SeoManagerScreen(routeKey: '/');
      default:
        return _DefaultDashboard();
    }
  }
}

class _DefaultDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng quan platform',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Cập nhật 2 phút trước · 30 ngày qua',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12)),
          const SizedBox(height: 24),

          // KPI grid
          LayoutBuilder(builder: (ctx, c) {
            final cols = c.maxWidth > 1100 ? 4 : (c.maxWidth > 700 ? 2 : 1);
            return GridView.count(
              crossAxisCount: cols,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.1,
              children: const [
                _KpiCard(label: 'GMV THÁNG', value: '2.41B', delta: '+18%', up: true),
                _KpiCard(label: 'BOOKINGS', value: '8.214', delta: '+22%', up: true),
                _KpiCard(label: 'MAU', value: '142k', delta: '+9%', up: true),
                _KpiCard(label: 'DISPUTE RATE', value: '0.42%', delta: '+0.05%', up: false),
              ],
            );
          }),

          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('⏳ Chờ duyệt KYC',
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('12 mới',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final op in const [
                    ('VT', 'Vietravel Premium', 'Hà Nội · 2h trước · Risk: 12', false),
                    ('DT', 'DalatTours.vn', 'Đà Lạt · 5h trước · Risk: 28', false),
                    ('PQ', 'PhuQuoc Adventure', 'Phú Quốc · 1d · Risk: 71 ⚠', true),
                    ('SP', 'Sapa Trekking Co.', 'Sapa · 1d · Risk: 8', false),
                  ])
                    _OperatorRow(
                      initials: op.$1,
                      name: op.$2,
                      meta: op.$3,
                      risky: op.$4,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.up,
  });
  final String label;
  final String value;
  final String delta;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface)),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    delta,
                    style: TextStyle(
                      color: up ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Sparkline
            SizedBox(
              height: 26,
              child: CustomPaint(
                painter: _SparkPainter(theme.colorScheme.primary),
                size: const Size(double.infinity, 26),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.color);
  final Color color;
  @override
  void paint(Canvas c, Size s) {
    final pts = const [22.0, 18, 20, 12, 16, 8, 4, 14, 6];
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    final path = Path();
    final stepX = s.width / (pts.length - 1);
    for (var i = 0; i < pts.length; i++) {
      final y = s.height - (pts[i] / 22) * s.height;
      i == 0 ? path.moveTo(0, y) : path.lineTo(stepX * i, y);
    }
    c.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.color != color;
}

class _OperatorRow extends StatelessWidget {
  const _OperatorRow({
    required this.initials,
    required this.name,
    required this.meta,
    required this.risky,
  });
  final String initials;
  final String name;
  final String meta;
  final bool risky;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primary,
            child: Text(initials,
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(meta,
                    style: TextStyle(
                        fontSize: 11,
                        color: risky
                            ? const Color(0xFFEF4444)
                            : theme.colorScheme.onSurface
                                .withValues(alpha: 0.6))),
              ],
            ),
          ),
          if (risky)
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFEF4444)),
              ),
              child: const Text('Soi kỹ'),
            )
          else
            FilledButton(
              onPressed: () {},
              child: const Text('Duyệt'),
            ),
        ],
      ),
    );
  }
}

