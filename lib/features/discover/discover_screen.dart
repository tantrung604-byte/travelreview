import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// User-facing Discover page — placeholder production route.
/// TODO: replace mock cards with Firestore-backed tour feed.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  static const sampleTours = [
    ('da-nang-ba-na-hills', 'Đà Nẵng — Bà Nà Hills 3N2Đ', '1.290.000đ', '★ 4.9'),
    ('sapa-fansipan', 'Sapa — Fansipan 2N1Đ', '1.890.000đ', '★ 4.8'),
    ('phu-quoc-hon-thom', 'Phú Quốc — Hòn Thơm 4N3Đ', '2.490.000đ', '★ 4.9'),
  ];

  static const worldDestinations = [
    ('trung-quoc', 'Trung Quốc', 'Vạn Lý Trường Thành, Cửu Trại Câu...', '🇨🇳'),
    ('nhat-ban', 'Nhật Bản', 'Núi Phú Sĩ, Tokyo, Kyoto...', '🇯🇵'),
    ('han-quoc', 'Hàn Quốc', 'Seoul, Đảo Jeju, Nami...', '🇰🇷'),
    ('thail-lan', 'Thái Lan', 'Bangkok, Phuket, Pattaya...', '🇹🇭'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khám phá'),
        actions: [
          IconButton(
            tooltip: 'Tìm kiếm',
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Bạn muốn đi đâu hôm nay?',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            onTap: () => context.go('/search'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.travel_explore),
              hintText: 'Tìm tour, địa điểm, trải nghiệm...',
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('🏖 Biển')),
              Chip(label: Text('⛰ Núi')),
              Chip(label: Text('🍜 Ẩm thực')),
              Chip(label: Text('🥾 Trekking')),
            ],
          ),
          const SizedBox(height: 28),
          Text('🔥 Trending tuần này', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final tour in sampleTours)
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.landscape, color: theme.colorScheme.onPrimary),
                ),
                title: Text(tour.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${tour.$4} · từ ${tour.$3}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/tour/${tour.$1}'),
              ),
            ),
          const SizedBox(height: 28),
          Text('🌍 Địa Điểm Ăn Chơi Trên Thế Giới', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.8,
            ),
            itemCount: worldDestinations.length,
            itemBuilder: (context, index) {
              final dest = worldDestinations[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/tour/${dest.$1}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: theme.colorScheme.primaryContainer,
                          child: Center(
                            child: Text(dest.$4, style: const TextStyle(fontSize: 48)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dest.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              dest.$3,
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

