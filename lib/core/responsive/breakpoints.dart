import 'package:flutter/material.dart';

/// Material 3 window size classes — chuẩn Google.
/// https://m3.material.io/foundations/layout/applying-layout/window-size-classes
enum WindowSize {
  /// 0 – 599 dp: phần lớn điện thoại dọc.
  compact,

  /// 600 – 839 dp: tablet dọc, foldable mở, điện thoại ngang.
  medium,

  /// 840 – 1199 dp: tablet ngang, laptop nhỏ.
  expanded,

  /// ≥ 1200 dp: desktop.
  large;

  bool get isMobile => this == WindowSize.compact;
  bool get isTablet => this == WindowSize.medium || this == WindowSize.expanded;
  bool get isDesktop => this == WindowSize.large;
  bool get isWide => index >= WindowSize.medium.index;
}

/// Breakpoint tiêu chuẩn (đơn vị **logical pixel / dp**, không phải px vật lý).
class Breakpoints {
  Breakpoints._();

  static const double compactMax = 600;
  static const double mediumMax = 840;
  static const double expandedMax = 1200;

  /// Chiều rộng tối đa cho khối nội dung đọc (text-heavy) — chuẩn ~70 ký tự/dòng.
  static const double readableMaxWidth = 720;

  /// Chiều rộng tối đa cho form / detail view trên màn rộng.
  static const double formMaxWidth = 560;

  /// Chiều rộng tối đa cho list/dashboard trên màn rộng.
  static const double contentMaxWidth = 1200;

  /// Phân loại theo width hiện tại.
  static WindowSize of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < compactMax) return WindowSize.compact;
    if (w < mediumMax) return WindowSize.medium;
    if (w < expandedMax) return WindowSize.expanded;
    return WindowSize.large;
  }
}

/// Extension cho gọn:
/// `context.windowSize.isWide`, `context.isCompact` ...
extension BreakpointContext on BuildContext {
  WindowSize get windowSize => Breakpoints.of(this);
  bool get isCompact => windowSize == WindowSize.compact;
  bool get isWide => windowSize.isWide;
}

