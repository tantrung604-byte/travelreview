
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/seo/seo_config.dart';

/// Admin SEO Manager — quản lý H1, H2, meta tags, keywords, schema structure v.v.
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

  @override
  void initState() {
    super.initState();
    final routeKey = widget.routeKey ?? '/';
    final seoCtrl = ref.read(seoControllerProvider.notifier);
    final current = seoCtrl.getPageSeo(routeKey) ?? SeoMetadata();

    _titleCtrl = TextEditingController(text: current.title);
    _descCtrl = TextEditingController(text: current.description);
    _keywordsCtrl = TextEditingController(text: current.keywords);
    _h1Ctrl = TextEditingController(text: current.h1);
    _h2Ctrl = TextEditingController();
    _canonicalCtrl = TextEditingController(text: current.canonicalUrl);
    _ogImageCtrl = TextEditingController(text: current.ogImage);
    _schemaCtrl = TextEditingController(text: current.schemaJson);
    _h2List = [...current.h2List];
    _noindex = current.noindex;
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

  void _saveSeo() {
    final routeKey = widget.routeKey ?? '/';
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
    ref.read(seoControllerProvider.notifier).setPageSeo(routeKey, newSeo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã lưu SEO cho route: $routeKey'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('SEO Manager'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $seoScore/100',
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
            // ===== Title Meta Tag =====
            _buildField(
              label: 'Page Title (Meta tag)',
              hint: '30-60 ký tự (${_titleCtrl.text.length})',
              controller: _titleCtrl,
              maxLines: 2,
              helperText: 'Hiển thị trên tab trình duyệt & kết quả tìm kiếm',
            ),
            const SizedBox(height: 16),

            // ===== Description Meta Tag =====
            _buildField(
              label: 'Meta Description',
              hint: '120-160 ký tự (${_descCtrl.text.length})',
              controller: _descCtrl,
              maxLines: 3,
              helperText: 'Mô tả nội dung dưới title trên Google',
            ),
            const SizedBox(height: 16),

            // ===== Keywords =====
            _buildField(
              label: 'Keywords (từ khoá)',
              hint: 'Cách nhau bằng dấu phẩy',
              controller: _keywordsCtrl,
              maxLines: 2,
              helperText: 'Meta keywords (ít quan trọng nhưng vẫn tốt)',
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
                        'H1 Heading (Rất quan trọng)',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildField(
                    label: '',
                    hint: 'Tiêu đề chính của trang (chỉ 1 H1)',
                    controller: _h1Ctrl,
                    maxLines: 2,
                    helperText: 'Phải khác với title tag',
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
                        'H2 Headings (Sections)',
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
                            hintText: 'Nhập H2 heading',
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
              label: 'Canonical URL',
              hint: 'https://travelreview.vn/page-url',
              controller: _canonicalCtrl,
              helperText: 'Tránh duplicate content',
            ),
            const SizedBox(height: 16),

            _buildField(
              label: 'OG Image URL (Social Media)',
              hint: 'https://travelreview.vn/og-image.jpg',
              controller: _ogImageCtrl,
              helperText: 'Ảnh hiển thị khi share trên Facebook, etc.',
            ),
            const SizedBox(height: 16),

            // ===== JSON-LD Schema =====
            _buildField(
              label: 'JSON-LD Structured Data',
              hint: '{"@context": "https://schema.org", "@type": "WebPage", ...}',
              controller: _schemaCtrl,
              maxLines: 6,
              helperText: 'Schema.org markup cho Rich Snippets',
            ),
            const SizedBox(height: 16),

            // ===== robots noindex =====
            SwitchListTile.adaptive(
              value: _noindex,
              onChanged: (v) => setState(() => _noindex = v),
              title: const Text('🚫 Robots: NOINDEX'),
              subtitle: const Text('Không index trang này trên Google'),
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
                    '🔍 Google Search Result Preview',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _titleCtrl.text.isEmpty
                        ? 'Page Title'
                        : _titleCtrl.text,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    _canonicalCtrl.text.isEmpty
                        ? 'https://travelreview.vn'
                        : _canonicalCtrl.text,
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _descCtrl.text.isEmpty
                        ? 'Meta description...'
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
                onPressed: _saveSeo,
                icon: const Icon(Icons.save),
                label: const Text('💾 Lưu SEO Config'),
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

