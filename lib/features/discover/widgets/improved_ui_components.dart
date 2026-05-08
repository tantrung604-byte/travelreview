import 'package:flutter/material.dart';

/// Filter & Sort bar component (Sticky on scroll)
class FilterSortBar extends StatefulWidget {
  const FilterSortBar({
    super.key,
    required this.onFilterTap,
    required this.onSortChanged,
    required this.resultCount,
  });

  final VoidCallback onFilterTap;
  final Function(String) onSortChanged;
  final int resultCount;

  @override
  State<FilterSortBar> createState() => _FilterSortBarState();
}

class _FilterSortBarState extends State<FilterSortBar> {
  String _sortBy = 'popularity';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Filter & Sort buttons
          Row(
            children: [
              // Filter button
              OutlinedButton.icon(
                onPressed: widget.onFilterTap,
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 8),

              // Sort dropdown
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() => _sortBy = value);
                  widget.onSortChanged(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'popularity', child: Text('🔥 Most Popular')),
                  const PopupMenuItem(value: 'price_low', child: Text('💰 Price: Low to High')),
                  const PopupMenuItem(value: 'price_high', child: Text('💸 Price: High to Low')),
                  const PopupMenuItem(value: 'rating', child: Text('⭐ Top Rated')),
                  const PopupMenuItem(value: 'newest', child: Text('✨ Newest')),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.sort, size: 18),
                  label: Text(_sortBy == 'popularity' ? 'Popular ▼' : 'Sort ▼'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const Spacer(),

              // Map button
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to map view
                },
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Map'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Result count
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${widget.resultCount} tours',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tour card with improved design (Badge, Benefits, Price)
class TourCardImproved extends StatelessWidget {
  const TourCardImproved({
    super.key,
    required this.tourTitle,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.benefits,
    required this.badge,
    required this.onTap,
  });

  final String tourTitle;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int price;
  final List<String> benefits;
  final String? badge; // e.g. "Free Cancel", "Best Seller"
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with badge
            Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, url, error) => Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),

                // Badge
                if (badge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    tourTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Rating & Reviews
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${rating.toStringAsFixed(1)} ($reviewCount reviews)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Benefits chips
                  if (benefits.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      children: benefits.take(2).map((benefit) {
                        final icons = {
                          'Free Cancel': '✅',
                          'Pickup': '🚐',
                          'Meals': '🍽️',
                          'Guide': '👨‍🏫',
                        };
                        final icon = icons.entries
                            .firstWhere(
                              (e) => benefit.contains(e.key),
                              orElse: () => MapEntry('', '•'),
                            )
                            .value;

                        return Chip(
                          label: Text(
                            '$icon ${benefit.split(':')[0]}',
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                          backgroundColor: Colors.blue[50],
                          side: BorderSide(color: Colors.blue[200]!),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),

                  // Price & Action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'from',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'VND ${(price / 1000000).toStringAsFixed(1)}M',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick filter chips on home screen
class QuickFilterChips extends StatefulWidget {
  const QuickFilterChips({
    super.key,
    required this.onFilterSelected,
  });

  final Function(String) onFilterSelected;

  @override
  State<QuickFilterChips> createState() => _QuickFilterChipsState();
}

class _QuickFilterChipsState extends State<QuickFilterChips> {
  String _selectedFilter = 'trending';

  static const filters = [
    ('trending', '🔥 Trending'),
    ('budget', '💰 Budget'),
    ('free_cancel', '✅ Free Cancel'),
    ('best_rated', '⭐ Best Rated'),
    ('family', '👨‍👩‍👧‍👦 Family'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: filters.map((filter) {
          final (id, label) = filter;
          final isSelected = _selectedFilter == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = id);
                widget.onFilterSelected(id);
              },
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.blue[100],
              side: BorderSide(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

