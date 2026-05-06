import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../content/travel_content.dart';
import '../../l10n/gen/app_localizations.dart';

/// User-facing Discover page — placeholder production route.
/// TODO: replace mock cards with Firestore-backed tour feed.
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navHome),
        actions: [
          IconButton(
            tooltip: l.navSearch,
            icon: const Icon(Icons.search),
            onPressed: () => context.go('/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l.discoverHeroTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            onTap: () => context.go('/search'),
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.travel_explore),
              hintText: l.discoverSearchHint,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('🏖 Beaches')),
              Chip(label: Text('⛰ Mountains')),
              Chip(label: Text('🍜 Food')),
              Chip(label: Text('🥾 Trekking')),
            ],
          ),
          const SizedBox(height: 28),
          Text(l.discoverTrending,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final tour in seededTours)
            Card(
              margin: const EdgeInsets.only(bottom: 14),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset(
                    tour.imageAsset,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(tour.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('★ ${tour.rating} · ${l.discoverFromPrice(tour.price)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/tour/${tour.id}'),
              ),
            ),
          const SizedBox(height: 28),
          Text(l.discoverWorldTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
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
            itemCount: seededWorldDestinations.length,
            itemBuilder: (context, index) {
              final dest = seededWorldDestinations[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/tour/${dest.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SvgPicture.asset(
                          dest.imageAsset,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(dest.country, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              dest.tagline,
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

