import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_controller.dart';
import '../../../l10n/gen/app_localizations.dart';
/// Drawer tùy biến theme — DÙNG CHUNG cho User App + Admin Portal.
/// Mọi thay đổi áp dụng global qua appThemeControllerProvider và auto-persist.
class ThemeCustomizerDrawer extends ConsumerWidget {
  const ThemeCustomizerDrawer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final s = ref.watch(appThemeControllerProvider);
    final ctrl = ref.read(appThemeControllerProvider.notifier);
    final theme = Theme.of(context);
    return Drawer(
      width: 360,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(l.themeCustomizerTitle,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ),
                  IconButton(
                    tooltip: l.themeCustomizerReset,
                    icon: const Icon(Icons.restart_alt),
                    onPressed: () {
                      ctrl.reset();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.themeCustomizerResetDone)),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.devices, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l.themeCustomizerApplyEverywhere,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(l.themePrimaryColor),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final p in kThemePresetColors)
                        _ColorSwatch(
                          color: p.color,
                          label: p.name,
                          selected: p.color.toARGB32() == s.primary.toARGB32(),
                          onTap: () => ctrl.setPrimary(p.color),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(l.themeRgbAdjust),
                  const SizedBox(height: 8),
                  _RgbSliders(color: s.primary, onChanged: ctrl.setPrimary),
                  const SizedBox(height: 24),
                  _SectionTitle(l.themeModeTitle),
                  const SizedBox(height: 8),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(value: ThemeMode.light, label: Text(l.themeModeLight), icon: Icon(Icons.light_mode_outlined)),
                      ButtonSegment(value: ThemeMode.dark, label: Text(l.themeModeDark), icon: Icon(Icons.dark_mode_outlined)),
                      ButtonSegment(value: ThemeMode.system, label: Text(l.themeModeSystem), icon: Icon(Icons.brightness_auto_outlined)),
                    ],
                    selected: {s.themeMode},
                    onSelectionChanged: (v) => ctrl.setThemeMode(v.first),
                  ),
                  const SizedBox(height: 20),
                  _SectionTitle(l.themeTextContrast),
                  const SizedBox(height: 4),
                  SwitchListTile.adaptive(
                    value: s.highContrast,
                    onChanged: ctrl.setHighContrast,
                    title: Text(l.themeHighContrast),
                    subtitle: Text(l.themeHighContrastHint),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  _SectionTitle(l.themeFontScale),
                  Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: Slider(
                          value: s.fontScale,
                          min: 0.85,
                          max: 1.25,
                          divisions: 8,
                          label: '${(s.fontScale * 100).round()}%',
                          onChanged: ctrl.setFontScale,
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionTitle(l.themeDensity),
                  const SizedBox(height: 8),
                  SegmentedButton<UiDensity>(
                    segments: [
                      ButtonSegment(value: UiDensity.compact, label: Text(l.themeDensityCompact), icon: Icon(Icons.density_small)),
                      ButtonSegment(value: UiDensity.standard, label: Text(l.themeDensityStandard), icon: Icon(Icons.density_medium)),
                      ButtonSegment(value: UiDensity.comfortable, label: Text(l.themeDensityComfortable), icon: Icon(Icons.density_large)),
                    ],
                    selected: {s.density},
                    onSelectionChanged: (v) => ctrl.setDensity(v.first),
                  ),
                  const SizedBox(height: 28),
                  _PreviewCard(state: s),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
    );
  }
}
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
              width: 3,
            ),
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 12, spreadRadius: 1)]
                : null,
          ),
          child: selected
              ? Icon(Icons.check, size: 20,
                  color: ThemeData.estimateBrightnessForColor(color) == Brightness.dark
                      ? Colors.white : Colors.black)
              : null,
        ),
      ),
    );
  }
}
class _RgbSliders extends StatelessWidget {
  const _RgbSliders({required this.color, required this.onChanged});
  final Color color;
  final ValueChanged<Color> onChanged;
  @override
  Widget build(BuildContext context) {
    int channel(double v) => v.round().clamp(0, 255);
    final r = ((color.toARGB32() >> 16) & 0xFF).toDouble();
    final g = ((color.toARGB32() >> 8) & 0xFF).toDouble();
    final b = (color.toARGB32() & 0xFF).toDouble();
    Widget row(String label, double value, Color tint, ValueChanged<double> on) {
      return Row(
        children: [
          SizedBox(width: 16, child: Text(label, style: TextStyle(color: tint, fontWeight: FontWeight.w800))),
          Expanded(child: Slider(value: value, min: 0, max: 255, activeColor: tint, onChanged: on)),
          SizedBox(
            width: 36,
            child: Text(channel(value).toString(),
                textAlign: TextAlign.end,
                style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
          ),
        ],
      );
    }
    return Column(
      children: [
        row('R', r, Colors.red, (v) => onChanged(Color.fromARGB(255, channel(v), channel(g), channel(b)))),
        row('G', g, Colors.green, (v) => onChanged(Color.fromARGB(255, channel(r), channel(v), channel(b)))),
        row('B', b, Colors.blue, (v) => onChanged(Color.fromARGB(255, channel(r), channel(g), channel(v)))),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black12),
              ),
            ),
            const SizedBox(width: 10),
            SelectableText(
              '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
              style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    );
  }
}
class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.state});
  final AppThemeState state;
  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.themePreviewTitle, style: theme.textTheme.labelSmall),
          const SizedBox(height: 8),
          Text(l.themePreviewMetricLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Text('2.41B', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(onPressed: () {}, child: Text(l.themePreviewApprove)),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: () {}, child: Text(l.themePreviewReject)),
            ],
          ),
        ],
      ),
    );
  }
}
