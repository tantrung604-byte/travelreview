import 'package:flutter/material.dart';

import '../../../core/ui/optimized_image.dart';

/// Improved image gallery for tour detail page
/// Features: Swipeable images, photo counter, quality indicators
class ImprovedImageGallery extends StatefulWidget {
  const ImprovedImageGallery({
    super.key,
    required this.images,
    this.onImageTapped,
  });

  final List<String> images;
  final Function(int)? onImageTapped;

  @override
  State<ImprovedImageGallery> createState() => _ImprovedImageGalleryState();
}

class _ImprovedImageGalleryState extends State<ImprovedImageGallery> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48),
        ),
      );
    }

    return Column(
      children: [
        // Main image carousel
        Stack(
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  widget.onImageTapped?.call(index);
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) => OptimizedImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                  borderRadius: 0,
                ),
              ),
            ),

            // Photo counter
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${widget.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Left arrow (if not first)
            if (_currentIndex > 0)
              Positioned(
                left: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left,
                          color: Colors.white, size: 24),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),

            // Right arrow (if not last)
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 12,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right,
                          color: Colors.white, size: 24),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Thumbnail strip
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              final isSelected = index == _currentIndex;

              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: OptimizedImage(
                      imageUrl: widget.images[index],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      borderRadius: 0,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Rating overview with distribution chart
class RatingOverview extends StatelessWidget {
  const RatingOverview({
    super.key,
    required this.avgRating,
    required this.totalReviews,
    required this.distribution, // {5: count, 4: count, ...}
  });

  final double avgRating;
  final int totalReviews;
  final Map<int, int> distribution; // {5: 1500, 4: 600, ...}

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with avg rating
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StarRating(rating: avgRating, size: 16),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '$totalReviews ${totalReviews == 1 ? 'review' : 'reviews'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Distribution bars
            ...[5, 4, 3, 2, 1].map((rating) {
              final count = distribution[rating] ?? 0;
              final percentage =
                  totalReviews > 0 ? (count / totalReviews * 100).toInt() : 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 30, child: Text('$rating★')),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_getRatingColor(rating)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 35,
                      child: Text(
                        '$percentage%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 5:
        return Colors.green;
      case 4:
        return Colors.lightGreen;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

/// Star rating display
class _StarRating extends StatelessWidget {
  const _StarRating({
    required this.rating,
    this.size = 16,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final fillRatio = (rating - index).clamp(0.0, 1.0);

          return Stack(
            children: [
              Icon(Icons.star_outline, size: size, color: Colors.grey[400]),
              ClipRect(
                clipper: _StarClipper(fillRatio),
                child: Icon(Icons.star, size: size, color: Colors.amber),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _StarClipper extends CustomClipper<Rect> {
  final double fillRatio;

  _StarClipper(this.fillRatio);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * fillRatio, size.height);
  }

  @override
  bool shouldReclip(_StarClipper oldClipper) {
    return oldClipper.fillRatio != fillRatio;
  }
}

/// Review card with media & engagement
class ReviewCardEnhanced extends StatefulWidget {
  const ReviewCardEnhanced({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.title,
    required this.content,
    required this.daysAgo,
    this.photos = const [],
    this.isVerified = false,
    this.likesCount = 0,
    this.onLike,
    this.onReply,
  });

  final String userName;
  final String userAvatar;
  final int rating;
  final String title;
  final String content;
  final int daysAgo;
  final List<String> photos;
  final bool isVerified;
  final int likesCount;
  final VoidCallback? onLike;
  final VoidCallback? onReply;

  @override
  State<ReviewCardEnhanced> createState() => _ReviewCardEnhancedState();
}

class _ReviewCardEnhancedState extends State<ReviewCardEnhanced> {
  late int _likes;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    _likes = widget.likesCount;
    _isLiked = false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.userAvatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (widget.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: Colors.blue),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      _StarRating(rating: widget.rating.toDouble(), size: 12),
                    ],
                  ),
                ),
                Text(
                  '${widget.daysAgo}d ago',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review content
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[800]),
            ),

            // Photos
            if (widget.photos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.photos.map((photo) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: OptimizedImage(
                          imageUrl: photo,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Engagement buttons
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  TextButton.icon(
                    icon: Icon(
                      _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                      size: 16,
                      color: _isLiked ? Colors.blue : Colors.grey[600],
                    ),
                    label: Text(
                      '$_likes',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isLiked ? Colors.blue : Colors.grey[600],
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                        _likes = _isLiked ? _likes + 1 : _likes - 1;
                      });
                      widget.onLike?.call();
                    },
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: Icon(Icons.comment_outlined,
                        size: 16, color: Colors.grey[600]),
                    label: Text(
                      'Reply',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    onPressed: widget.onReply,
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

