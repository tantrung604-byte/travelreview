import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../l10n/gen/app_localizations.dart';
import 'widgets/simple_markdown.dart';

/// Hiển thị 1 file markdown pháp lý từ `assets/legal/{lang}/{slug}.md`.
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    super.key,
    required this.slug,
    required this.title,
  });

  /// Tên file (không kèm .md): `privacy`, `terms`, `community`,
  /// `cookies`, `account_deletion`, `about`.
  final String slug;
  final String title;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late Future<String> _content;

  @override
  void initState() {
    super.initState();
    _content = _load();
  }

  Future<String> _load() async {
    final lang = Localizations.localeOf(context).languageCode == 'en' ? 'en' : 'vi';
    final path = 'assets/legal/$lang/${widget.slug}.md';
    try {
      return await rootBundle.loadString(path);
    } catch (_) {
      // Fallback sang tiếng Việt nếu không có bản dịch
      return rootBundle.loadString('assets/legal/vi/${widget.slug}.md');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<String>(
        future: _content,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(child: Text(l.legalLoadError));
          }
          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: ContentConstrained(
                maxWidth: Breakpoints.readableMaxWidth,
                padding: EdgeInsets.zero,
                child: SimpleMarkdown(snap.data!),
              ),
            ),
          );
        },
      ),
    );
  }
}

