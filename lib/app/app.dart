import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_theme_controller.dart';
import '../l10n/gen/app_localizations.dart';
import 'locale/locale_controller.dart';
import 'router/app_router.dart';

class TravelReviewApp extends ConsumerWidget {
  const TravelReviewApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final theme = ref.watch(appThemeControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      onGenerateTitle: (ctx) => AppL10n.of(ctx).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: theme.themeMode,
      theme: buildAppTheme(theme, brightness: Brightness.light),
      darkTheme: buildAppTheme(theme, brightness: Brightness.dark),

      // ===== i18n / Bilingual (vi + en) =====
      locale: locale, // null = follow system
      supportedLocales: LocaleController.supported,
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supported) {
        if (locale != null) return locale;
        for (final s in supported) {
          if (s.languageCode == deviceLocale?.languageCode) return s;
        }
        return const Locale('vi');
      },

      // Clamp text scale 1.0–1.3 để user dùng font siêu lớn không phá layout,
      // nhưng vẫn tôn trọng accessibility ở mức hợp lý.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final clamped = mq.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: clamped),
          child: Stack(
            children: [
              child ?? const SizedBox.shrink(),
              _ZaloSupportButton(),
            ],
          ),
        );
      },
    );
  }
}

class _ZaloSupportButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80, // Above bottom bar if any
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final url = Uri.parse('https://zalo.me/your_zalo_id_or_phone'); // Replace with actual Zalo link
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0068FF), // Zalo Blue
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}
