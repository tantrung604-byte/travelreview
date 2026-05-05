import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State điều khiển toàn bộ theme app + admin — thay đổi runtime,
/// auto-persist vào SharedPreferences.
class AppThemeState {
  const AppThemeState({
    this.primary = const Color(0xFFFFD60A),
    this.themeMode = ThemeMode.system,
    this.highContrast = false,
    this.fontScale = 1.0,
    this.density = UiDensity.standard,
  });

  final Color primary;
  final ThemeMode themeMode;
  final bool highContrast;
  final double fontScale;
  final UiDensity density;

  AppThemeState copyWith({
    Color? primary,
    ThemeMode? themeMode,
    bool? highContrast,
    double? fontScale,
    UiDensity? density,
  }) =>
      AppThemeState(
        primary: primary ?? this.primary,
        themeMode: themeMode ?? this.themeMode,
        highContrast: highContrast ?? this.highContrast,
        fontScale: fontScale ?? this.fontScale,
        density: density ?? this.density,
      );

  Map<String, dynamic> toJson() => {
        'primary': primary.toARGB32(),
        'themeMode': themeMode.index,
        'highContrast': highContrast,
        'fontScale': fontScale,
        'density': density.index,
      };

  factory AppThemeState.fromJson(Map<String, dynamic> j) => AppThemeState(
        primary: Color((j['primary'] as num?)?.toInt() ?? 0xFFFFD60A),
        themeMode: ThemeMode.values[(j['themeMode'] as num?)?.toInt() ?? 2],
        highContrast: (j['highContrast'] as bool?) ?? false,
        fontScale: ((j['fontScale'] as num?)?.toDouble() ?? 1.0).clamp(0.85, 1.25),
        density: UiDensity.values[(j['density'] as num?)?.toInt() ?? 1],
      );
}

enum UiDensity {
  compact,
  standard,
  comfortable;

  VisualDensity get visualDensity => switch (this) {
        UiDensity.compact => const VisualDensity(horizontal: -2, vertical: -2),
        UiDensity.standard => VisualDensity.standard,
        UiDensity.comfortable => const VisualDensity(horizontal: 1, vertical: 1),
      };
}

const List<({String name, Color color})> kThemePresetColors = [
  (name: 'Vàng', color: Color(0xFFFFD60A)),
  (name: 'Cam', color: Color(0xFFFF8A00)),
  (name: 'Đỏ', color: Color(0xFFEF4444)),
  (name: 'Hồng', color: Color(0xFFEC4899)),
  (name: 'Tím', color: Color(0xFF8B5CF6)),
  (name: 'Xanh dương', color: Color(0xFF3B82F6)),
  (name: 'Teal', color: Color(0xFF0E7C66)),
  (name: 'Xanh lá', color: Color(0xFF22C55E)),
];

class AppThemeController extends Notifier<AppThemeState> {
  static const _kPrefsKey = 'app_theme_v1';
  SharedPreferences? _prefs;

  @override
  AppThemeState build() {
    _load();
    return const AppThemeState();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_kPrefsKey);
    if (raw != null) {
      try {
        state = AppThemeState.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {/* keep default */}
    }
  }

  Future<void> _persist() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_kPrefsKey, jsonEncode(state.toJson()));
  }

  void setPrimary(Color c) {
    state = state.copyWith(primary: c);
    _persist();
  }

  void setThemeMode(ThemeMode m) {
    state = state.copyWith(themeMode: m);
    _persist();
  }

  void setHighContrast(bool v) {
    state = state.copyWith(highContrast: v);
    _persist();
  }

  void setFontScale(double v) {
    state = state.copyWith(fontScale: v.clamp(0.85, 1.25));
    _persist();
  }

  void setDensity(UiDensity d) {
    state = state.copyWith(density: d);
    _persist();
  }

  void reset() {
    state = const AppThemeState();
    _persist();
  }
}

final appThemeControllerProvider =
    NotifierProvider<AppThemeController, AppThemeState>(
  AppThemeController.new,
);

/// Builder ThemeData từ AppThemeState — dùng cho cả User App lẫn Admin.
ThemeData buildAppTheme(AppThemeState s, {required Brightness brightness}) {
  final isDark = brightness == Brightness.dark;

  // onPrimary tự chọn đen/trắng theo độ sáng của primary
  final onPrimary =
      ThemeData.estimateBrightnessForColor(s.primary) == Brightness.dark
          ? Colors.white
          : Colors.black;

  final scheme = ColorScheme.fromSeed(
    seedColor: s.primary,
    brightness: brightness,
  ).copyWith(
    primary: s.primary,
    onPrimary: onPrimary,
    surface: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFFFBEA),
    onSurface: isDark
        ? (s.highContrast ? Colors.white : const Color(0xFFE5E7EB))
        : (s.highContrast ? Colors.black : const Color(0xFF0A0A0A)),
    error: const Color(0xFFEF4444),
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    visualDensity: s.density.visualDensity,
    splashFactory: InkSparkle.splashFactory,
    textTheme: ThemeData(brightness: brightness)
        .textTheme
        .apply(fontSizeFactor: s.fontScale),
  );

  return base.copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 18 * s.fontScale,
        fontWeight: FontWeight.w800,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.onSurface, width: 1.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      elevation: 4,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: isDark ? const Color(0xFF1A1A1D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark ? const Color(0xFF1A1A1D) : Colors.white,
      selectedColor: scheme.primary,
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide(color: scheme.onSurface.withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF1A1A1D) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: scheme.onSurface.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF0A0A0A),
      selectedItemColor: scheme.primary,
      unselectedItemColor: const Color(0xFF9CA3AF),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0A0A0A),
      indicatorColor: scheme.primary,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : const Color(0xFF9CA3AF),
          fontWeight: FontWeight.w700,
          fontSize: 11 * s.fontScale,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : const Color(0xFF9CA3AF),
        ),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.onSurface.withValues(alpha: 0.08),
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF0A0A0A),
      contentTextStyle: const TextStyle(
          color: Color(0xFFFFFBEA), fontWeight: FontWeight.w600),
      actionTextColor: scheme.primary,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

