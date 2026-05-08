import 'package:flutter/material.dart';

/// Responsive breakpoint helper cho device-agnostic layouts
class ResponsiveConfig {
  // Breakpoints
  static const double mobileMaxWidth = 599;
  static const double tabletMaxWidth = 1199;
  static const double desktopMinWidth = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width > mobileMaxWidth &&
      MediaQuery.sizeOf(context).width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > tabletMaxWidth;

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= mobileMaxWidth) return DeviceType.mobile;
    if (width <= tabletMaxWidth) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  // Grid cross axis count
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  // Padding
  static EdgeInsets getContentPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(24);
  }

  // Font scale
  static double getFontScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).textScaleFactor;
  }

  // Image height (adapt to screen)
  static double getImageHeight(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (isMobile(context)) return width * 0.5; // 50% of width
    if (isTablet(context)) return width * 0.4;
    return 300; // Fixed height for desktop
  }
}

enum DeviceType { mobile, tablet, desktop }

/// Responsive widget builder
class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return switch (ResponsiveConfig.deviceType(context)) {
      DeviceType.mobile => mobile,
      DeviceType.tablet => tablet,
      DeviceType.desktop => desktop,
    };
  }
}

