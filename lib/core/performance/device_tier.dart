import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Phân loại hiệu năng thiết bị — quyết định bật/tắt hiệu ứng đắt tiền.
enum DeviceTier {
  /// Máy yếu: Android Go, RAM 2GB, 60Hz, dpr ≤ 2.0, hoặc trình duyệt cũ.
  /// → Tắt blur, particle, parallax. Animation ngắn. Ảnh chất lượng thấp.
  low,

  /// Máy phổ thông: hầu hết Android tầm trung, iPhone SE/8.
  /// → Bật phần lớn hiệu ứng, giảm bớt particle.
  mid,

  /// Máy mạnh: flagship, iPad Pro, desktop, refresh rate ≥ 90Hz.
  /// → Full effects.
  high;

  bool get supportsBlur => this != DeviceTier.low;
  bool get supportsParticles => this == DeviceTier.high;
  bool get supportsParallax => this != DeviceTier.low;
}

/// Heuristic detect — KHÔNG cần thêm dependency `device_info_plus`.
/// Có thể nâng cấp sau bằng cách bind từ native channel hoặc `device_info_plus`.
DeviceTier detectDeviceTier({
  required Size logicalSize,
  required double devicePixelRatio,
  required double refreshRate,
}) {
  // Web: assume mid trừ khi màn rất nhỏ.
  if (kIsWeb) {
    if (logicalSize.shortestSide < 360) return DeviceTier.low;
    return DeviceTier.mid;
  }

  // Desktop luôn high.
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    return DeviceTier.high;
  }

  // iOS: ngưỡng theo dpr và physical size.
  if (Platform.isIOS) {
    // iPhone SE 1st gen / 5s: dpr=2, shortestSide=320 → low
    if (devicePixelRatio < 2.0 || logicalSize.shortestSide < 340) {
      return DeviceTier.low;
    }
    if (refreshRate >= 90) return DeviceTier.high;
    return DeviceTier.mid;
  }

  // Android:
  if (Platform.isAndroid) {
    // Heuristic: máy yếu thường dpr thấp + screen nhỏ.
    final physicalShort = logicalSize.shortestSide * devicePixelRatio;
    if (devicePixelRatio < 2.0 && physicalShort < 720) return DeviceTier.low;
    if (refreshRate >= 90 && devicePixelRatio >= 2.5) return DeviceTier.high;
    return DeviceTier.mid;
  }

  return DeviceTier.mid;
}

/// Provider cấp tier hiện tại — đọc từ `MediaQuery` qua context.
/// Sử dụng:
/// ```dart
/// final tier = ref.watch(deviceTierProvider(context));
/// ```
final deviceTierProvider =
    Provider.family<DeviceTier, BuildContext>((ref, context) {
  final mq = MediaQuery.of(context);
  final dispatcher = PlatformDispatcher.instance;
  final view = View.maybeOf(context);
  // refreshRate fallback 60 nếu không lấy được.
  final refresh = view?.display.refreshRate ??
      dispatcher.views.first.display.refreshRate;
  return detectDeviceTier(
    logicalSize: mq.size,
    devicePixelRatio: mq.devicePixelRatio,
    refreshRate: refresh,
  );
});

/// Cấu hình hiệu ứng dựa theo tier — gọn gàng để dùng khắp nơi.
class PerfSettings {
  const PerfSettings({
    required this.tier,
    required this.animationScale,
    required this.imageQuality,
    required this.enableBlur,
    required this.enableParticles,
    required this.enableShadows,
    required this.maxConcurrentImageLoads,
  });

  final DeviceTier tier;

  /// Nhân với mọi `Duration` animation.
  /// 0.7 = nhanh hơn 30% (máy yếu cần feedback ngay), 1.0 = chuẩn.
  final double animationScale;

  /// `FilterQuality` cho ảnh.
  final FilterQuality imageQuality;

  /// Có dùng `BackdropFilter` (glassmorphism)?
  final bool enableBlur;

  /// Confetti, particle effect?
  final bool enableParticles;

  /// Box shadow / elevation thật?
  final bool enableShadows;

  /// Số ảnh tải cùng lúc — máy yếu giới hạn để không OOM.
  final int maxConcurrentImageLoads;

  factory PerfSettings.fromTier(DeviceTier tier) {
    switch (tier) {
      case DeviceTier.low:
        return const PerfSettings(
          tier: DeviceTier.low,
          animationScale: 0.7,
          imageQuality: FilterQuality.low,
          enableBlur: false,
          enableParticles: false,
          enableShadows: false,
          maxConcurrentImageLoads: 2,
        );
      case DeviceTier.mid:
        return const PerfSettings(
          tier: DeviceTier.mid,
          animationScale: 1.0,
          imageQuality: FilterQuality.medium,
          enableBlur: true,
          enableParticles: false,
          enableShadows: true,
          maxConcurrentImageLoads: 4,
        );
      case DeviceTier.high:
        return const PerfSettings(
          tier: DeviceTier.high,
          animationScale: 1.0,
          imageQuality: FilterQuality.high,
          enableBlur: true,
          enableParticles: true,
          enableShadows: true,
          maxConcurrentImageLoads: 8,
        );
    }
  }

  /// Helper: rút ngắn duration theo tier.
  Duration scale(Duration d) =>
      Duration(milliseconds: (d.inMilliseconds * animationScale).round());
}

final perfSettingsProvider =
    Provider.family<PerfSettings, BuildContext>((ref, context) {
  final tier = ref.watch(deviceTierProvider(context));
  return PerfSettings.fromTier(tier);
});

