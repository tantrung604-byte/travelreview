
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/seo/seo_config.dart';
import '../../l10n/gen/app_localizations.dart';
import 'admin_providers.dart';

/// Admin SEO Manager — quản lý H1, H2, meta tags, keywords, schema structure v.v.
/// Đọc / lưu vào Firestore qua [SeoRepository] để mọi client đồng bộ.
class SeoManagerScreen extends ConsumerStatefulWidget {
  final String? routeKey; // e.g. '/', '/tour'

  const SeoManagerScreen({super.key, this.routeKey});

  @override
  ConsumerState<SeoManagerScreen> createState() => _SeoManagerScreenState();
}

class _SeoManagerScreenState extends ConsumerState<SeoManagerScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _keywordsCtrl;
  late TextEditingController _h1Ctrl;
  late TextEditingController _h2Ctrl;
  late TextEditingController _canonicalCtrl;
  late TextEditingController _ogImageCtrl;
  late TextEditingController _schemaCtrl;

  List<String> _h2List = [];
  bool _noindex = false;
  bool _saving = false;
  bool _loading = false;
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.routeKey ?? '/';

    _titleCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _keywordsCtrl = TextEditingController();
    _h1Ctrl = TextEditingController();
    _h2Ctrl = TextEditingController();
    _canonicalCtrl = TextEditingController();
    _ogImageCtrl = TextEditingController();
    _schemaCtrl = TextEditingController();

    // Load SEO của route hiện tại sau frame đầu (cần ref).
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRoute(_currentRoute));
  }

  Future<void> _loadRoute(String route) async {
    setState(() => _loading = true);
    try {
      // Ưu tiên Firestore; fallback về controller in-memory default.
      final fromCloud = await ref.read(seoRepositoryProvider).load(route);
      final current = fromCloud ??
          ref.read(seoControllerProvider.notifier).getPageSeo(route) ??
          const SeoMetadata();

      setState(() {
        _currentRoute = route;
        _titleCtrl.text = current.title;
        _descCtrl.text = current.description;
        _keywordsCtrl.text = current.keywords;
        _h1Ctrl.text = current.h1;
        _h2Ctrl.text = '';
        _canonicalCtrl.text = current.canonicalUrl;
        _ogImageCtrl.text = current.ogImage;
        _schemaCtrl.text = current.schemaJson;
        _h2List = [...current.h2List];
        _noindex = current.noindex;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load SEO failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _keywordsCtrl.dispose();
    _h1Ctrl.dispose();
    _h2Ctrl.dispose();
    _canonicalCtrl.dispose();
    _ogImageCtrl.dispose();
    _schemaCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSeo() async {
    final l = AppL10n.of(context);
    final routeKey = _currentRoute;
    final newSeo = SeoMetadata(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      keywords: _keywordsCtrl.text,
      h1: _h1Ctrl.text,
      h2List: _h2List,
      canonicalUrl: _canonicalCtrl.text,
      ogImage: _ogImageCtrl.text,
      schemaJson: _schemaCtrl.text,
      noindex: _noindex,
    );

    setState(() => _saving = true);
    try {
      // Lưu cả Firestore (đồng bộ tất cả client) và in-memory (cập nhật ngay).
      await ref.read(seoRepositoryProvider).save(routeKey, newSeo);
      ref.read(seoControllerProvider.notifier).setPageSeo(routeKey, newSeo);
      // Invalidate cache để các page khác đọc lại.
      ref.invalidate(seoForRouteProvider(routeKey));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.adminSeoSaved(routeKey)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final theme = Theme.of(context);
    final seoScore = SeoMetadata(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      keywords: _keywordsCtrl.text,
      h1: _h1Ctrl.text,
      h2List: _h2List,
    ).calculateSeoScore();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.search_outlined),
            const SizedBox(width: 8),
            Text(l.adminNavSeo),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l.adminSeoScore(seoScore),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Route selector =====
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 20),
                  const SizedBox(width: 8),
                  const Text('Route:', style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: adminSeoManagedRoutes.contains(_currentRoute)
                          ? _currentRoute
                          : null,
                      hint: Text(_currentRoute),
                      items: [
                        for (final r in adminSeoManagedRoutes)
                          DropdownMenuItem(value: r, child: Text(r)),
                      ],
                      onChanged: _loading
                          ? null
                          : (v) {
                              if (v != null && v != _currentRoute) {
                                _loadRoute(v);
                              }
                            },
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Title Meta Tag =====
            _buildField(
              label: l.adminSeoPageTitle,
              hint: l.adminSeoTitleHint(_titleCtrl.text.length),
              controller: _titleCtrl,
              maxLines: 2,
              helperText: l.adminSeoTitleHelper,
            ),
            const SizedBox(height: 16),

            // ===== Description Meta Tag =====
            _buildField(
              label: l.adminSeoMetaDescription,
              hint: l.adminSeoDescriptionHint(_descCtrl.text.length),
              controller: _descCtrl,
              maxLines: 3,
              helperText: l.adminSeoDescriptionHelper,
            ),
            const SizedBox(height: 16),

            // ===== Keywords =====
            _buildField(
              label: l.adminSeoKeywords,
              hint: l.adminSeoKeywordsHint,
              controller: _keywordsCtrl,
              maxLines: 2,
              helperText: l.adminSeoKeywordsHelper,
            ),
            const SizedBox(height: 24),

            // ===== H1 —— Rất QUAN TRỌNG ======
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.title, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l.adminSeoH1,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    label: '',
                      hint: l.adminSeoH1Hint,
                    controller: _h1Ctrl,
                    maxLines: 2,
                      helperText: l.adminSeoH1Helper,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== H2s Headings =====
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.subject, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l.adminSeoH2,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text('${_h2List.length}'),
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _h2List.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${i + 1}. ${_h2List[i]}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.delete_outline, size: 18),
                            onPressed: () {
                              setState(() => _h2List.removeAt(i));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _h2Ctrl,
                          decoration: InputDecoration(
                            hintText: l.adminSeoH2InputHint,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          if (_h2Ctrl.text.isNotEmpty) {
                            setState(() {
                              _h2List.add(_h2Ctrl.text);
                              _h2Ctrl.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== Other Meta =====
            _buildField(
              label: l.adminSeoCanonical,
              hint: 'https://travelreview.vn/page-url',
              controller: _canonicalCtrl,
              helperText: l.adminSeoCanonicalHelper,
            ),
            const SizedBox(height: 16),

            _buildField(
              label: l.adminSeoOgImage,
              hint: 'https://travelreview.vn/og-image.jpg',
              controller: _ogImageCtrl,
              helperText: l.adminSeoOgImageHelper,
            ),
            const SizedBox(height: 16),

            // ===== JSON-LD Schema =====
            _buildField(
              label: l.adminSeoJsonLd,
              hint: '{"@context": "https://schema.org", "@type": "WebPage", ...}',
              controller: _schemaCtrl,
              maxLines: 6,
              helperText: l.adminSeoJsonLdHelper,
            ),
            const SizedBox(height: 16),

            // ===== robots noindex =====
            SwitchListTile.adaptive(
              value: _noindex,
              onChanged: (v) => setState(() => _noindex = v),
              title: Text(l.adminSeoNoindexTitle),
              subtitle: Text(l.adminSeoNoindexSubtitle),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // ===== Preview =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.adminSeoPreviewTitle,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _titleCtrl.text.isEmpty
                        ? l.adminSeoPageTitle
                        : _titleCtrl.text,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    _canonicalCtrl.text.isEmpty
                        ? l.adminSeoCanonicalDefault
                        : _canonicalCtrl.text,
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _descCtrl.text.isEmpty
                        ? l.adminSeoMetaDescriptionPlaceholder
                        : _descCtrl.text,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ===== Save Button =====
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveSeo,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : l.adminSeoSaveButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String helperText = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.8),
              ),
            ),
          ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (helperText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }
}

