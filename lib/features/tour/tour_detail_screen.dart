import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_providers.dart';
import '../cart/cart_providers.dart';
import '../content/travel_content.dart';
import '../reviews/review_providers.dart';
import '../../app/router/app_router.dart';
import '../../core/ai/tour_ai_service.dart';
import '../../l10n/gen/app_localizations.dart';
import 'tour_provider.dart';

class TourDetailScreen extends ConsumerStatefulWidget {
  const TourDetailScreen({super.key, required this.tourId});

  final String tourId;

  @override
  ConsumerState<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends ConsumerState<TourDetailScreen> {
  final _reviewController = TextEditingController();
  int _selectedRating = 5;

  static const Map<String, Map<String, String>> tourData = {
    'trung-quoc': {
      'title': 'KhÃ¡m phÃ¡ Trung Quá»‘c: Báº¯c Kinh - ThÆ°á»£ng Háº£i - TrÆ°Æ¡ng Gia Giá»›i',
      'description': 'Trung Quá»‘c lÃ  má»™t Ä‘áº¥t nÆ°á»›c cÃ³ bá» dÃ y lá»‹ch sá»­ vÃ  vÄƒn hÃ³a Ä‘á»“ sá»™. HÃ£y cÃ¹ng khÃ¡m phÃ¡ nhá»¯ng Ä‘á»‹a danh biá»ƒu tÆ°á»£ng nháº¥t.',
      'itinerary': 'NgÃ y 1: Tham quan Váº¡n LÃ½ TrÆ°á»ng ThÃ nh & Tháº­p Tam LÄƒng Â· NgÃ y 2: KhÃ¡m phÃ¡ Tá»­ Cáº¥m ThÃ nh, Quáº£ng TrÆ°á»ng ThiÃªn An MÃ´n & Di HÃ²a ViÃªn (Cung Äiá»‡n MÃ¹a HÃ¨) Â· NgÃ y 3: Tráº£i nghiá»‡m Phá»‘ Cá»• ThÆ°á»£ng Háº£i vÃ  mua sáº¯m táº¡i Nam Kinh Lá»™.',
      'guide': 'HÆ°á»›ng dáº«n: Báº¡n nÃªn Ä‘á»•i tiá»n sang NhÃ¢n dÃ¢n tá»‡ trÆ°á»›c vÃ  cÃ i Ä‘áº·t cÃ¡c á»©ng dá»¥ng thanh toÃ¡n nhÆ° Alipay hoáº·c WeChat Pay. Äá»ƒ tham quan Tá»­ Cáº¥m ThÃ nh, báº¡n cáº§n Ä‘áº·t vÃ© trÆ°á»›c Ã­t nháº¥t 7 ngÃ y qua á»©ng dá»¥ng chÃ­nh thá»©c.',
      'places': 'Tá»­ Cáº¥m ThÃ nh, Váº¡n LÃ½ TrÆ°á»ng ThÃ nh, Cung Äiá»‡n MÃ¹a HÃ¨ (Di HÃ²a ViÃªn), SÃ¢n váº­n Ä‘á»™ng Tá»• Chim, ThiÃªn ÄÃ n.',
    },
    'nhat-ban': {
      'title': 'Nháº­t Báº£n: Cung Ä‘Æ°á»ng vÃ ng Tokyo - Kyoto - Osaka',
      'description': 'Tráº£i nghiá»‡m sá»± káº¿t há»£p hoÃ n háº£o giá»¯a hiá»‡n Ä‘áº¡i vÃ  truyá»n thá»‘ng táº¡i xá»© sá»Ÿ hoa anh Ä‘Ã o.',
      'itinerary': 'NgÃ y 1: Tokyo sÃ´i Ä‘á»™ng Â· NgÃ y 2: Kyoto cá»• kÃ­nh Â· NgÃ y 3: Osaka - thiÃªn Ä‘Æ°á»ng áº©m thá»±c.',
      'guide': 'HÆ°á»›ng dáº«n: Mua JR Pass náº¿u báº¡n di chuyá»ƒn giá»¯a cÃ¡c thÃ nh phá»‘ báº±ng Shinkansen.',
    },
    'da-nang-ba-na-hills': {
      'title': 'ÄÃ  Náºµng â€” BÃ  NÃ  Hills 3N2Ä',
      'description': 'Táº­n hÆ°á»Ÿng khÃ´ng khÃ­ se láº¡nh vÃ  check-in Cáº§u VÃ ng ná»•i tiáº¿ng tháº¿ giá»›i.',
      'itinerary': 'NgÃ y 1: ÄÃ³n khÃ¡ch, NgÅ© HÃ nh SÆ¡n Â· NgÃ y 2: BÃ  NÃ  Hills full day Â· NgÃ y 3: BÃ¡n Ä‘áº£o SÆ¡n TrÃ , mua sáº¯m.',
      'guide': 'HÆ°á»›ng dáº«n: Äáº·t vÃ© cÃ¡p treo trÆ°á»›c Ä‘á»ƒ trÃ¡nh xáº¿p hÃ ng dÃ i.',
    },
  };

  final List<_ReviewData> _reviews = [
    const _ReviewData(
      name: 'Minh Anh',
      rating: 5,
      content: 'Tour ráº¥t Ä‘Ã¡ng tiá»n, hÆ°á»›ng dáº«n viÃªn nhiá»‡t tÃ¬nh vÃ  lá»‹ch trÃ¬nh Ä‘Ãºng giá».',
      date: 'HÃ´m qua',
    ),
    const _ReviewData(
      name: 'Quang Huy',
      rating: 4,
      content: 'Cáº£nh Ä‘áº¹p, dá»‹ch vá»¥ á»•n. NÃªn chuáº©n bá»‹ giÃ y Ä‘i bá»™ vÃ¬ di chuyá»ƒn khÃ¡ nhiá»u.',
      date: '3 ngÃ y trÆ°á»›c',
    ),
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  void _submitReview() async {
    final l = AppL10n.of(context);
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tourReviewEmptyError)),
      );
      return;
    }

    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      // YÃªu cáº§u login trÆ°á»›c khi gá»­i review
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('ÄÄƒng nháº­p Ä‘á»ƒ viáº¿t review'),
          content: const Text('Báº¡n cáº§n Ä‘Äƒng nháº­p Ä‘á»ƒ chia sáº» tráº£i nghiá»‡m vá»›i cá»™ng Ä‘á»“ng.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Äá»ƒ sau')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('ÄÄƒng nháº­p')),
          ],
        ),
      );
      if (!mounted) return;
      if (shouldLogin == true) {
        context.go('/auth?next=/tour/${widget.tourId}');
      }
      return;
    }

    try {
      await ref.read(submitReviewProvider)(
        tourId: widget.tourId,
        rating: _selectedRating,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        _selectedRating = 5;
        _reviewController.clear();
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tourReviewThanks)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('KhÃ´ng gá»­i Ä‘Æ°á»£c review: $e')),
      );
    }
  }

  Future<void> _addToCart(String title, String priceText, String? imageUrl, {bool buyNow = false}) async {
    final priceVnd = parseVndPrice(priceText);
    if (priceVnd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tour chÆ°a cÃ³ giÃ¡ â€” vui lÃ²ng liÃªn há»‡ tÆ° váº¥n.')),
      );
      return;
    }
    ref.read(cartControllerProvider.notifier).addOrIncrement(
          CartItem(
            tourId: widget.tourId,
            title: title,
            priceText: priceText,
            priceVnd: priceVnd,
            imageUrl: imageUrl ?? '',
            quantity: 1,
            departureDate: null,
          ),
        );
    if (!mounted) return;
    if (buyNow) {
      context.goNamed(AppRouteNames.checkout);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ÄÃ£ thÃªm vÃ o giá» hÃ ng'),
          action: SnackBarAction(
            label: 'XEM GIá»Ž',
            onPressed: () => context.goNamed(AppRouteNames.cart),
          ),
        ),
      );
    }
  }

  Future<void> _sendContactEmail(String tourTitle, String name, String phone) async {
    final l = AppL10n.of(context);
    final customerName = name.trim();
    final customerPhone = phone.trim();

    if (customerName.isEmpty || customerPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tourContactMissingInfo)),
      );
      return;
    }

    final subject = Uri.encodeComponent('Yeu cau tu van tour: $tourTitle');
    final body = Uri.encodeComponent(
      'Xin chao Admin TravelReview,\n\n'
      'Khach hang vua gui thong tin lien he:\n'
      '- Ho ten: $customerName\n'
      '- So dien thoai: $customerPhone\n'
      '- Tour quan tam: $tourTitle\n\n'
      'Vui long lien he lai som.\n',
    );

    final emailUri = Uri.parse(
      'mailto:admin@travelreview.app?subject=$subject&body=$body',
    );

    final didLaunch = await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    if (!didLaunch) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.tourContactOpenEmailError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = _averageRating;
    
    // Sá»­ dá»¥ng ref.listen Ä‘á»ƒ báº¯t lá»—i tá»« Provider mÃ  khÃ´ng lÃ m sáº­p build method
    final tourAsync = ref.watch(tourDetailProvider(widget.tourId));

    // Dá»¯ liá»‡u hardcoded Ä‘á»ƒ sá»­ dá»¥ng khi Firebase lá»—i hoáº·c khÃ´ng cÃ³ dá»¯ liá»‡u
    final hardcodedData = _TourDetailScreenState.tourData[widget.tourId];

    return Scaffold(
      body: tourAsync.maybeWhen(
        data: (tour) => _buildContent(context, tour, hardcodedData, theme, avg),
        loading: () => const Center(child: CircularProgressIndicator()),
        orElse: () => _buildContent(context, null, hardcodedData, theme, avg),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TourModel? tour, Map<String, String>? hardcodedData, ThemeData theme, double avg) {
    final l = AppL10n.of(context);
    final seeded = seededTourById[widget.tourId];
    final title = tour?.title ?? seeded?.title ?? hardcodedData?['title'] ?? l.tourFallbackTitle(widget.tourId);
    final description = tour?.description ?? seeded?.description ?? hardcodedData?['description'] ?? l.tourUpdating;
    final guide = tour?.guide ?? seeded?.guide ?? hardcodedData?['guide'] ?? l.tourUpdating;
    final places = tour?.places ?? seeded?.places ?? hardcodedData?['places'] ?? l.tourUpdating;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((tour?.price ?? seeded?.price ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Text('GiÃ¡ tá»«', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(
                      tour?.price ?? seeded?.price ?? '',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _addToCart(
                      title,
                      tour?.price ?? seeded?.price ?? '',
                      (tour?.imageUrls.isNotEmpty ?? false) ? tour!.imageUrls.first : null,
                    ),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('ThÃªm giá»'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _addToCart(
                      title,
                      tour?.price ?? seeded?.price ?? '',
                      (tour?.imageUrls.isNotEmpty ?? false) ? tour!.imageUrls.first : null,
                      buyNow: true,
                    ),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Mua ngay'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: l.tourContact,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => _ContactFormModal(
                        tourTitle: title,
                        onSend: (name, phone) => _sendContactEmail(title, name, phone),
                      ),
                    );
                  },
                  icon: const Icon(Icons.contact_support_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, const Color(0xFF0A0A0A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _TourHero(
                imageUrls: tour?.imageUrls ?? const [],
                fallbackSvgAsset: seeded?.imageAsset,
                fallbackEmoji: tour?.emoji ?? 'ðŸ“',
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StarRatingDisplay(rating: avg.round()),
              const SizedBox(width: 8),
              Text(
                tour != null
                    ? l.tourRatingLine(avg.toStringAsFixed(1), _reviews.length)
                    : '${avg.toStringAsFixed(1)} Â· ${_reviews.length} reviews Â· ${seeded?.duration ?? '3 days 2 nights'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // ─── THÔNG TIN CHƯƠNG TRÌNH ──────────────────────────────────
          _ProgramInfoSection(
            l: l,
            theme: theme,
            description: description,
            guide: guide,
            places: places,
            scheduleItems: tour?.scheduleItems ?? const [],
            subDestinations: tour?.subDestinations,
          ),
          const SizedBox(height: 28),
          // ─── AI CHAT ────────────────────────────────────────────────
          _AiChatSection(
            tour: tour,
            title: title,
            description: description,
          ),
          const SizedBox(height: 28),
          _ReviewComposer(
            rating: _selectedRating,
            controller: _reviewController,
            onRatingChanged: (value) => setState(() => _selectedRating = value),
            onSubmit: _submitReview,
          ),
          const SizedBox(height: 24),
          Text(
            l.tourCustomerReviews,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Consumer(builder: (ctx, ref2, _) {
            final remoteAsync = ref2.watch(tourReviewsStreamProvider(widget.tourId));
            return remoteAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => Column(
                children: [for (final r in _reviews) _ReviewCard(review: r)],
              ),
              data: (remote) {
                final all = <_ReviewData>[
                  ...remote.map((r) => _ReviewData(
                        name: r.userName,
                        rating: r.rating,
                        content: r.content,
                        date: _relativeDate(r.createdAt),
                      )),
                  ..._reviews,
                ];
                if (all.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('ChÆ°a cÃ³ review nÃ o â€” hÃ£y lÃ  ngÆ°á»i Ä‘áº§u tiÃªn!'),
                  );
                }
                return Column(
                  children: [for (final r in all) _ReviewCard(review: r)],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  static String _relativeDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Vá»«a xong';
    if (diff.inHours < 1) return '${diff.inMinutes} phÃºt trÆ°á»›c';
    if (diff.inDays < 1) return '${diff.inHours} giá» trÆ°á»›c';
    if (diff.inDays < 30) return '${diff.inDays} ngÃ y trÆ°á»›c';
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ============================================================================
// Thông Tin Chương Trình – hiển thị lịch trình admin nhập từ CMS
// ============================================================================

class _ProgramInfoSection extends StatelessWidget {
  const _ProgramInfoSection({
    required this.l,
    required this.theme,
    required this.description,
    required this.guide,
    required this.places,
    required this.scheduleItems,
    this.subDestinations,
  });

  final AppL10n l;
  final ThemeData theme;
  final String description;
  final String guide;
  final String places;
  final List<DayScheduleItem> scheduleItems;
  final List<SubDestination>? subDestinations;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Thông Tin Chương Trình ───────────────────────────
        Text(
          l.tourIntroReview,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),

        // ── Giới thiệu chung ────────────────────────────────────────
        if (description.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.tourProgramDescription,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(description, style: const TextStyle(height: 1.55)),
                ],
              ),
            ),
          ),

        // ── Sub-destinations ────────────────────────────────────────
        if (subDestinations != null && subDestinations!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(l.tourSubDestinations,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          for (final sub in subDestinations!)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(sub.details, style: const TextStyle(height: 1.5)),
                  ),
                ],
              ),
            ),
        ],

        // ── Lịch trình chi tiết ─────────────────────────────────────
        const SizedBox(height: 20),
        Text(
          l.tourScheduleHeading,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),

        if (scheduleItems.isEmpty)
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.tourScheduleNoData,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Accordion view
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < scheduleItems.length; i++)
                    _DayAccordionItem(
                      item: scheduleItems[i],
                      l: l,
                    ),
                ],
              ),
            ),
          ),

        // ── Địa điểm nổi bật ────────────────────────────────────────
        if (places.isNotEmpty) ...[
          const SizedBox(height: 20),
          Card(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.tourTopPlaces,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(places, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ),
        ],

        // ── Hướng dẫn du lịch ───────────────────────────────────────
        if (guide.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.tourTravelGuide,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(guide, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// Accordion item cho lịch trình từng ngày – giống hình thiết kế
// ============================================================================
class _DayAccordionItem extends StatefulWidget {
  const _DayAccordionItem({required this.item, required this.l});

  final DayScheduleItem item;
  final AppL10n l;

  @override
  State<_DayAccordionItem> createState() => _DayAccordionItemState();
}

class _DayAccordionItemState extends State<_DayAccordionItem>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _iconTurn;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _iconTurn = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final l = widget.l;
    // Màu vàng theo thiết kế
    const badgeColor = Color(0xFFFFD600);
    const titleColor = Color(0xFFD94A1E); // cam đỏ như hình

    final headerTitle = item.title.isNotEmpty
        ? '${item.label.isNotEmpty ? item.label : 'NGÀY ${item.day}'}: ${item.title}'.toUpperCase()
        : (item.label.isNotEmpty ? item.label : 'NGÀY ${item.day}').toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Số ngày – huy hiệu tròn vàng
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.day}',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tiêu đề ngày
                  Expanded(
                    child: Text(
                      headerTitle,
                      style: const TextStyle(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // Mũi tên xoay
                  RotationTransition(
                    turns: _iconTurn,
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF555555),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Nội dung mở rộng ────────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: badgeColor,
                    width: 3,
                    // Dart không có dashed border native, dùng solid vàng đậm
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 14, top: 4, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Danh sách hoạt động
                    for (final activity in item.activities)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _ActivityText(text: activity),
                      ),

                    // Ghi chú
                    if (item.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.push_pin_outlined,
                                size: 14, color: Colors.amber.shade800),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${l.tourScheduleNote} ${item.note}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.shade900,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Render một hoạt động – hỗ trợ text có **bold** bằng cú pháp "**text**"
class _ActivityText extends StatelessWidget {
  const _ActivityText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    // Tách thành spans: phần trong **…** in đậm, phần còn lại bình thường
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xFF333333)),
        children: spans.isEmpty ? [TextSpan(text: text)] : spans,
      ),
    );
  }
}

class _ReviewComposer extends StatelessWidget {
  const _ReviewComposer({
    required this.rating,
    required this.controller,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final int rating;
  final TextEditingController controller;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.tourWriteReview,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StarRatingPicker(value: rating, onChanged: onRatingChanged),
                const SizedBox(width: 10),
                Text(l.tourRatingOutOf5(rating),
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: l.tourReviewHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.rate_review_outlined),
                label: Text(l.tourSubmitReview),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRatingPicker extends StatelessWidget {
  const _StarRatingPicker({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: l.tourSelectStarRating,
      value: l.tourRatingOutOf5(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: l.tourStarCount(i),
              onPressed: () => onChanged(i),
              icon: Icon(
                i <= value ? Icons.star_rounded : Icons.star_border_rounded,
                color: color,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}

class _StarRatingDisplay extends StatelessWidget {
  const _StarRatingDisplay({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: color,
            size: 18,
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final _ReviewData review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    review.name.characters.first.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(review.date, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                _StarRatingDisplay(rating: review.rating),
              ],
            ),
            const SizedBox(height: 12),
            Text(review.content),
          ],
        ),
      ),
    );
  }
}

class _ReviewData {
  const _ReviewData({
    required this.name,
    required this.rating,
    required this.content,
    required this.date,
  });

  final String name;
  final int rating;
  final String content;
  final String date;
}

class _ContactFormModal extends StatefulWidget {
  final String tourTitle;
  final Function(String name, String phone) onSend;

  const _ContactFormModal({required this.tourTitle, required this.onSend});

  @override
  State<_ContactFormModal> createState() => _ContactFormModalState();
}

class _ContactFormModalState extends State<_ContactFormModal> {  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isRobotChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l.tourContactModalTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(l.tourContactNameLabel,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: l.tourContactNameHint,
              fillColor: Colors.blue.shade50.withValues(alpha: 0.3),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.tourContactPhoneLabel,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: l.tourContactPhoneHint,
              fillColor: Colors.blue.shade50.withValues(alpha: 0.3),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Giáº£ láº­p reCAPTCHA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _isRobotChecked,
                  onChanged: (v) => setState(() => _isRobotChecked = v ?? false),
                ),
                Expanded(child: Text(l.tourRecaptchaLabel)),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, color: Colors.blue.shade700, size: 20),
                    const Text('reCAPTCHA', style: TextStyle(fontSize: 8, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _isRobotChecked
                  ? () => widget.onSend(_nameController.text, _phoneController.text)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
               child: Text(l.tourSend,
                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// AI Chat Section – Hỏi AI về tour, đặt ngay bên dưới lịch trình
// ============================================================================

class _AiChatSection extends StatefulWidget {
  const _AiChatSection({
    required this.tour,
    required this.title,
    required this.description,
  });

  final TourModel? tour;
  final String title;
  final String description;

  @override
  State<_AiChatSection> createState() => _AiChatSectionState();
}

class _AiChatSectionState extends State<_AiChatSection>
    with SingleTickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  late TourAiService _aiService;
  late AnimationController _expandController;
  late Animation<double> _expandAnim;

  final List<AiMessage> _messages = [];
  bool _expanded = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnim = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _buildService();
  }

  void _buildService() {
    final tour = widget.tour;
    final scheduleText = tour?.scheduleItems.isNotEmpty == true
        ? tour!.scheduleItems.map((s) {
            final acts = s.activities.join('; ');
            return '${s.label.isEmpty ? "Ngày ${s.day}" : s.label}: ${s.title}. $acts${s.note.isNotEmpty ? " (Lưu ý: ${s.note})" : ""}';
          }).join('\n')
        : 'Lịch trình đang được cập nhật.';

    final highlights = tour?.highlights.isNotEmpty == true
        ? tour!.highlights.join(', ')
        : 'Chưa có thông tin';

    _aiService = TourAiService(
      tourContext: '''
Tên tour: ${widget.title}
Giá: ${tour?.price ?? 'Liên hệ'}
Đánh giá: ${tour?.rating ?? '5.0'}/5
Mô tả: ${widget.description}
Điểm nổi bật: $highlights
Địa điểm: ${tour?.places ?? ''}
Hướng dẫn: ${tour?.guide ?? ''}
Lịch trình:
$scheduleText
''',
    );
  }

  @override
  void didUpdateWidget(_AiChatSection old) {
    super.didUpdateWidget(old);
    if (old.tour != widget.tour) {
      _buildService();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _expandController.dispose();
    _aiService.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _expandController.forward();
        // Thêm tin nhắn chào nếu chưa có
        if (_messages.isEmpty) {
          final l = AppL10n.of(context);
          _messages.add(AiMessage(text: l.aiChatWelcome, isUser: false));
        }
      } else {
        _expandController.reverse();
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    final question = text.trim();
    if (question.isEmpty || _isSending) return;

    _inputController.clear();
    setState(() {
      _messages.add(AiMessage(text: question, isUser: true));
      _messages.add(AiMessage(text: '...', isUser: false, isLoading: true));
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final reply = await _aiService.sendMessage(question);
      if (!mounted) return;
      setState(() {
        _messages.removeLast();
        _messages.add(AiMessage(text: reply, isUser: false));
        _isSending = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l = AppL10n.of(context);
      setState(() {
        _messages.removeLast();
        _messages.add(AiMessage(
          text: l.aiChatErrorRetry,
          isUser: false,
          isError: true,
        ));
        _isSending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final isVi = Localizations.localeOf(context).languageCode == 'vi';
    final quickQuestions = isVi ? quickQuestionsVi : quickQuestionsEn;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A237E).withValues(alpha: 0.04),
            const Color(0xFF7C4DFF).withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF7C4DFF).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF2979FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.aiChatTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A237E),
                          ),
                        ),
                        Text(
                          l.aiChatSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5)
                        .animate(_expandController),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body (collapsible) ──────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                const Divider(height: 1),

                // Quick question chips
                if (_messages.length <= 1) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.aiChatQuickQuestions,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Row(
                      children: quickQuestions
                          .map(
                            (q) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                label: Text(
                                  q,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.08),
                                side: BorderSide(
                                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                                ),
                                onPressed: () => _sendMessage(q),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],

                // Chat messages
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: ListView.builder(
                    controller: _scrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) => _ChatBubble(
                      message: _messages[i],
                      onRetry: _messages[i].isError
                          ? () {
                              // Tìm câu hỏi trước đó
                              final prevUser = _messages
                                  .sublist(0, i)
                                  .lastWhere((m) => m.isUser, orElse: () => const AiMessage(text: '', isUser: true));
                              if (prevUser.text.isNotEmpty) {
                                setState(() => _messages.removeAt(i));
                                _sendMessage(prevUser.text);
                              }
                            }
                          : null,
                    ),
                  ),
                ),

                // Input area
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          enabled: !_isSending,
                          textInputAction: TextInputAction.send,
                          onSubmitted: _sendMessage,
                          decoration: InputDecoration(
                            hintText: l.aiChatInputHint,
                            hintStyle: const TextStyle(fontSize: 13),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                color: Color(0xFF7C4DFF),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isSending
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton.filled(
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF7C4DFF),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(40, 40),
                              ),
                              onPressed: () => _sendMessage(_inputController.text),
                              icon: const Icon(Icons.send_rounded, size: 18),
                              tooltip: l.aiChatSend,
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chat bubble ──────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, this.onRetry});

  final AiMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF2979FF)],
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: GestureDetector(
              onTap: message.isError ? onRetry : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser
                      ? const Color(0xFF7C4DFF)
                      : message.isError
                          ? Colors.red.shade50
                          : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: message.isError
                      ? Border.all(color: Colors.red.shade200)
                      : null,
                ),
                child: message.isLoading
                    ? _TypingIndicator()
                    : Text(
                        message.text,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : message.isError
                                  ? Colors.red.shade700
                                  : theme.colorScheme.onSurface,
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 6),
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
              child: Icon(Icons.person_outline,
                  size: 16, color: const Color(0xFF7C4DFF)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 16,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final phase = (_controller.value - i * 0.15).clamp(0.0, 1.0);
              final opacity = (0.3 + 0.7 * (0.5 - (phase - 0.5).abs() * 2).clamp(0, 1));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF7C4DFF),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ============================================================================
/// Hero ảnh tour: ưu tiên carousel ảnh từ Firestore (`imageUrls`), fallback SVG seed,
/// cuá»‘i cÃ¹ng lÃ  emoji. Tá»± áº©n dot indicator khi chá»‰ cÃ³ 1 áº£nh.
class _TourHero extends StatefulWidget {
  const _TourHero({
    required this.imageUrls,
    this.fallbackSvgAsset,
    required this.fallbackEmoji,
  });

  final List<String> imageUrls;
  final String? fallbackSvgAsset;
  final String fallbackEmoji;

  @override
  State<_TourHero> createState() => _TourHeroState();
}

class _TourHeroState extends State<_TourHero> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    if (urls.isEmpty) {
      if (widget.fallbackSvgAsset != null) {
        return SvgPicture.asset(widget.fallbackSvgAsset!, fit: BoxFit.cover);
      }
      return Center(
        child: Text(widget.fallbackEmoji, style: const TextStyle(fontSize: 72)),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: urls.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (_, i) => Image.network(
            urls[i],
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
            },
            errorBuilder: (_, _, _) => Center(
              child: Text(widget.fallbackEmoji, style: const TextStyle(fontSize: 72)),
            ),
          ),
        ),
        if (urls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < urls.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        if (urls.length > 1)
          Positioned(
            top: 8,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_index + 1}/${urls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }
}
