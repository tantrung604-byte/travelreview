import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader component cho smooth loading UX
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.count = 3,
    this.itemHeight = 200,
    this.backgroundColor,
  });

  final int count;
  final double itemHeight;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.grey[200]!;
    final highlightColor = Colors.grey[100]!;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => SkeletonCard(
        height: itemHeight,
        backgroundColor: bg,
        highlightColor: highlightColor,
      ),
    );
  }
}

/// Single skeleton card (tour card placeholder)
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({
    super.key,
    this.height = 200,
    this.backgroundColor,
    this.highlightColor,
  });

  final double height;
  final Color? backgroundColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.grey[300]!;
    final highlight = highlightColor ?? Colors.grey[200]!;

    return Shimmer.fromColors(
      baseColor: bg,
      highlightColor: highlight,
      enabled: true,
      direction: ShimmerDirection.ltr,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    color: Colors.grey[400],
                    margin: const EdgeInsets.only(bottom: 8),
                  ),
                  Container(
                    height: 14,
                    color: Colors.grey[400],
                    width: MediaQuery.sizeOf(context).width * 0.6,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        height: 12,
                        width: 60,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 12,
                        width: 80,
                        color: Colors.grey[400],
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

/// Skeleton grid untuk multiple cards
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    this.count = 6,
    this.crossAxisCount = 3,
    this.itemHeight = 200,
  });

  final int count;
  final int crossAxisCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: count,
      itemBuilder: (_, __) => SkeletonCard(height: itemHeight),
    );
  }
}

