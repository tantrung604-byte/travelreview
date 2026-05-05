import 'package:flutter/material.dart';

import 'breakpoints.dart';

/// Build UI khác nhau theo window size — tránh `if/else MediaQuery` rải rác.
///
/// ```dart
/// ResponsiveLayout(
///   compact: (_) => MobileHome(),
///   medium:  (_) => TabletHome(),
///   expanded:(_) => DesktopHome(),
/// )
/// ```
/// Nếu không truyền `medium`/`expanded`/`large` → fallback xuống size nhỏ hơn.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
  });

  final WidgetBuilder compact;
  final WidgetBuilder? medium;
  final WidgetBuilder? expanded;
  final WidgetBuilder? large;

  @override
  Widget build(BuildContext context) {
    final ws = Breakpoints.of(context);
    return switch (ws) {
      WindowSize.large => (large ?? expanded ?? medium ?? compact)(context),
      WindowSize.expanded => (expanded ?? medium ?? compact)(context),
      WindowSize.medium => (medium ?? compact)(context),
      WindowSize.compact => compact(context),
    };
  }
}

/// Bọc nội dung lại với `maxWidth` + center — chuẩn cho web/tablet.
///
/// Mobile (compact): trả về `child` nguyên bản (không thừa padding).
class ContentConstrained extends StatelessWidget {
  const ContentConstrained({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.of(context) == WindowSize.compact) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Padding adaptive theo size: 16 trên mobile, 24 trên tablet, 32 trên desktop.
class AdaptivePadding extends StatelessWidget {
  const AdaptivePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ws = Breakpoints.of(context);
    final pad = switch (ws) {
      WindowSize.compact => 16.0,
      WindowSize.medium => 24.0,
      WindowSize.expanded => 32.0,
      WindowSize.large => 40.0,
    };
    return Padding(padding: EdgeInsets.all(pad), child: child);
  }
}

