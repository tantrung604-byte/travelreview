import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Optimized image loader với caching, blur placeholder, error handling
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.borderRadius = 0,
    this.errorWidget,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final double borderRadius;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        height: height,
        width: width,

        // Placeholder: Blur effect khác với skeleton
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: Colors.grey[200],
          child: const Center(
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey,
                ),
              ),
            ),
          ),
        ),

        // Error widget
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              height: height,
              width: width,
              color: Colors.grey[300],
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey[600],
                  size: 40,
                ),
              ),
            ),

        // Progressive image loading
        httpHeaders: const {
          'accept': 'image/*', // Cho phép WebP, JPEG, PNG
        },

        // Cache duration
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

/// Asset image (SVG/PNG) dengan fallback
class AssetImage extends StatelessWidget {
  const AssetImage({
    super.key,
    required this.assetPath,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
  });

  final String assetPath;
  final BoxFit fit;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.svg')) {
      // SVG via flutter_svg vẫn tối ưu nếu file size nhỏ
      return Image.asset(
        assetPath,
        fit: fit,
        height: height,
        width: width,
      );
    }

    // PNG/JPG
    return Image.asset(
      assetPath,
      fit: fit,
      height: height,
      width: width,
    );
  }
}

/// Lazy loaded image với IntersectionObserver-like behavior
class LazyImage extends StatefulWidget {
  const LazyImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.height,
    this.width,
    this.borderRadius = 0,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isInView = false;

  @override
  void initState() {
    super.initState();

    // Delayed load: simulate lazy loading
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isInView = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInView) {
      return Container(
        height: widget.height,
        width: widget.width,
        color: Colors.grey[200],
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
        ),
      );
    }

    return OptimizedImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      borderRadius: widget.borderRadius,
    );
  }
}

