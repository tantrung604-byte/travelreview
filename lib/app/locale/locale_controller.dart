/// Quản lý ngôn ngữ ứng dụng (vi / en / system).
///
/// - `null` = theo hệ thống (Locale của thiết bị).
/// - Lưu lựa chọn vào [SharedPreferences] để giữ giữa các phiên.
/// - Có thể mở rộng đồng bộ lên Firestore (xem §20.5 trong docs/UX_UI_PLAN.md).
library;

import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends Notifier<Locale?> {
  static const _prefsKey = 'app_locale';

  /// Các ngôn ngữ ứng dụng hỗ trợ.
  static const supported = <Locale>[
    Locale('vi'),
    Locale('en'),
  ];

  @override
  Locale? build() {
    // Khởi tạo bất đồng bộ — không block UI.
    _loadFromPrefs();
    return null; // mặc định: theo hệ thống
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      state = Locale(code);
    }
  }

  /// Đặt locale mới. Truyền `null` để follow system.
  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);

