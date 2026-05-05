import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
      'title': 'Khám phá Trung Quốc: Bắc Kinh - Thượng Hải - Trương Gia Giới',
      'description': 'Trung Quốc là một đất nước có bề dày lịch sử và văn hóa đồ sộ. Hãy cùng khám phá những địa danh biểu tượng nhất.',
      'itinerary': 'Ngày 1: Tham quan Vạn Lý Trường Thành & Thập Tam Lăng · Ngày 2: Khám phá Tử Cấm Thành, Quảng Trường Thiên An Môn & Di Hòa Viên (Cung Điện Mùa Hè) · Ngày 3: Trải nghiệm Phố Cổ Thượng Hải và mua sắm tại Nam Kinh Lộ.',
      'guide': 'Hướng dẫn: Bạn nên đổi tiền sang Nhân dân tệ trước và cài đặt các ứng dụng thanh toán như Alipay hoặc WeChat Pay. Để tham quan Tử Cấm Thành, bạn cần đặt vé trước ít nhất 7 ngày qua ứng dụng chính thức.',
      'places': 'Tử Cấm Thành, Vạn Lý Trường Thành, Cung Điện Mùa Hè (Di Hòa Viên), Sân vận động Tổ Chim, Thiên Đàn.',
    },
    'nhat-ban': {
      'title': 'Nhật Bản: Cung đường vàng Tokyo - Kyoto - Osaka',
      'description': 'Trải nghiệm sự kết hợp hoàn hảo giữa hiện đại và truyền thống tại xứ sở hoa anh đào.',
      'itinerary': 'Ngày 1: Tokyo sôi động · Ngày 2: Kyoto cổ kính · Ngày 3: Osaka - thiên đường ẩm thực.',
      'guide': 'Hướng dẫn: Mua JR Pass nếu bạn di chuyển giữa các thành phố bằng Shinkansen.',
    },
    'da-nang-ba-na-hills': {
      'title': 'Đà Nẵng — Bà Nà Hills 3N2Đ',
      'description': 'Tận hưởng không khí se lạnh và check-in Cầu Vàng nổi tiếng thế giới.',
      'itinerary': 'Ngày 1: Đón khách, Ngũ Hành Sơn · Ngày 2: Bà Nà Hills full day · Ngày 3: Bán đảo Sơn Trà, mua sắm.',
      'guide': 'Hướng dẫn: Đặt vé cáp treo trước để tránh xếp hàng dài.',
    },
  };

  final List<_ReviewData> _reviews = [
    const _ReviewData(
      name: 'Minh Anh',
      rating: 5,
      content: 'Tour rất đáng tiền, hướng dẫn viên nhiệt tình và lịch trình đúng giờ.',
      date: 'Hôm qua',
    ),
    const _ReviewData(
      name: 'Quang Huy',
      rating: 4,
      content: 'Cảnh đẹp, dịch vụ ổn. Nên chuẩn bị giày đi bộ vì di chuyển khá nhiều.',
      date: '3 ngày trước',
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

  void _submitReview() {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung đánh giá')),
      );
      return;
    }

    setState(() {
      _reviews.insert(
        0,
        _ReviewData(
          name: 'Bạn',
          rating: _selectedRating,
          content: text,
          date: 'Vừa xong',
        ),
      );
      _selectedRating = 5;
      _reviewController.clear();
    });

    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cảm ơn bạn đã gửi đánh giá!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avg = _averageRating;
    
    // Sử dụng ref.listen để bắt lỗi từ Provider mà không làm sập build method
    final tourAsync = ref.watch(tourDetailProvider(widget.tourId));

    // Dữ liệu hardcoded để sử dụng khi Firebase lỗi hoặc không có dữ liệu
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
    final title = tour?.title ?? hardcodedData?['title'] ?? 'Tour ${widget.tourId}';
    final description = tour?.description ?? hardcodedData?['description'] ?? 'Đang cập nhật...';
    final guide = tour?.guide ?? hardcodedData?['guide'] ?? 'Đang cập nhật...';
    final itinerary = tour?.itinerary ?? hardcodedData?['itinerary'] ?? 'Đang cập nhật...';
    final places = tour?.places ?? hardcodedData?['places'] ?? 'Đang cập nhật...';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Thông tin liên hệ', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Họ và tên'),
                      subtitle: Text('Admin TravelReview'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Số điện thoại'),
                      subtitle: const Text('090 123 4567'),
                      trailing: IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () async {
                          final url = Uri.parse('tel:0901234567');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Đóng'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          icon: const Icon(Icons.contact_support_outlined),
          label: const Text('Liên hệ'),
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
            child: Center(
              child: Text(tour?.emoji ?? '📍', style: const TextStyle(fontSize: 72)),
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
                '${avg.toStringAsFixed(1)} · ${_reviews.length} đánh giá · 3 ngày 2 đêm',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖 Giới thiệu & Review', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (tour?.subDestinations != null && tour!.subDestinations!.isNotEmpty) ...[
            Text('📂 Danh lục các vùng', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            for (final sub in tour.subDestinations!)
              ExpansionTile(
                title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(sub.details),
                  ),
                ],
              ),
            const SizedBox(height: 20),
          ],
          Card(
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 Hướng dẫn du lịch', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(guide),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📍 Các địa điểm nổi bật', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(places),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('✨ AI tóm tắt review', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('Khách yêu thích hướng dẫn viên thân thiện, lịch trình rõ ràng và điểm đến đẹp. Nên chuẩn bị giày đi bộ và áo khoác nhẹ.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('H2: Lịch trình nổi bật', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 8),
          Text(itinerary),
          const SizedBox(height: 28),
          _ReviewComposer(
            rating: _selectedRating,
            controller: _reviewController,
            onRatingChanged: (value) => setState(() => _selectedRating = value),
            onSubmit: _submitReview,
          ),
          const SizedBox(height: 24),
          Text(
            'Đánh giá từ khách hàng',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          for (final review in _reviews) _ReviewCard(review: review),
        ],
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
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Viết đánh giá của bạn',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StarRatingPicker(value: rating, onChanged: onRatingChanged),
                const SizedBox(width: 10),
                Text('$rating/5 sao', style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: 'Chia sẻ trải nghiệm tour của bạn...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Gửi đánh giá'),
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
    final color = Theme.of(context).colorScheme.primary;
    return Semantics(
      label: 'Chọn số sao đánh giá',
      value: '$value trên 5 sao',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: '$i sao',
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
