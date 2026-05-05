/// Widget chuyển ngôn ngữ (System / Tiếng Việt / English).
///
/// Có thể đặt làm dropdown trên AppBar (web), hoặc bottom sheet (mobile).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/gen/app_localizations.dart';
import 'locale_controller.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key, this.compact = false});

  /// Hiển thị dạng IconButton (true) hay ListTile (false).
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final current = ref.watch(localeControllerProvider);

    if (compact) {
      return PopupMenuButton<Locale?>(
        tooltip: l.languageLabel,
        icon: const Icon(Icons.language),
        initialValue: current,
        onSelected: (loc) =>
            ref.read(localeControllerProvider.notifier).setLocale(loc),
        itemBuilder: (_) => [
          PopupMenuItem(value: null, child: Text(l.languageSystem)),
          PopupMenuItem(value: const Locale('vi'), child: Text(l.languageVi)),
          PopupMenuItem(value: const Locale('en'), child: Text(l.languageEn)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(l.languageLabel),
          leading: const Icon(Icons.language),
        ),
        RadioGroup<Locale?>(
          groupValue: current,
          onChanged: (v) =>
              ref.read(localeControllerProvider.notifier).setLocale(v),
          child: Column(
            children: [
              RadioListTile<Locale?>(
                value: null,
                title: Text(l.languageSystem),
              ),
              RadioListTile<Locale?>(
                value: const Locale('vi'),
                title: Text(l.languageVi),
              ),
              RadioListTile<Locale?>(
                value: const Locale('en'),
                title: Text(l.languageEn),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

