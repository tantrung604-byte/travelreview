import 'package:flutter/material.dart';

/// Renderer Markdown siêu nhẹ, không cần dependency ngoài.
/// Hỗ trợ: # / ## / ###, đoạn văn, danh sách `- `, `**bold**`,
/// blockquote `>`, bảng đơn giản (| col | col |), ngăn cách `---`.
///
/// Không hỗ trợ: ảnh, link click, code block phức tạp.
/// Đủ dùng cho các trang Privacy / Terms / Policy.
class SimpleMarkdown extends StatelessWidget {
  const SimpleMarkdown(this.source, {super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lines = source.split('\n');
    final widgets = <Widget>[];

    int i = 0;
    while (i < lines.length) {
      final line = lines[i];

      // Bảng markdown
      if (line.trim().startsWith('|') && i + 1 < lines.length && lines[i + 1].trim().startsWith('|')) {
        final tableLines = <String>[];
        while (i < lines.length && lines[i].trim().startsWith('|')) {
          tableLines.add(lines[i]);
          i++;
        }
        widgets.add(_buildTable(context, tableLines));
        continue;
      }

      if (line.trim() == '---') {
        widgets.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(),
        ));
      } else if (line.startsWith('### ')) {
        widgets.add(_pad(Text(line.substring(4),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))));
      } else if (line.startsWith('## ')) {
        widgets.add(_pad(Text(line.substring(3),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            top: 20));
      } else if (line.startsWith('# ')) {
        widgets.add(_pad(Text(line.substring(2),
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            top: 8, bottom: 12));
      } else if (line.startsWith('> ')) {
        widgets.add(_pad(Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(left: BorderSide(color: theme.colorScheme.primary, width: 4)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: _richText(context, line.substring(2), italic: true),
        )));
      } else if (line.trimLeft().startsWith('- ')) {
        final indent = line.length - line.trimLeft().length;
        widgets.add(_pad(
          Padding(
            padding: EdgeInsets.only(left: 8.0 + indent * 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: _richText(context, line.trimLeft().substring(2))),
              ],
            ),
          ),
          top: 2, bottom: 2,
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
      } else {
        widgets.add(_pad(_richText(context, line)));
      }
      i++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _pad(Widget child, {double top = 6, double bottom = 6}) =>
      Padding(padding: EdgeInsets.only(top: top, bottom: bottom), child: child);

  /// Parse `**bold**` đơn giản.
  Widget _richText(BuildContext context, String raw, {bool italic = false}) {
    final theme = Theme.of(context);
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int cursor = 0;
    for (final m in regex.allMatches(raw)) {
      if (m.start > cursor) spans.add(TextSpan(text: raw.substring(cursor, m.start)));
      spans.add(TextSpan(text: m.group(1), style: const TextStyle(fontWeight: FontWeight.w700)));
      cursor = m.end;
    }
    if (cursor < raw.length) spans.add(TextSpan(text: raw.substring(cursor)));
    return SelectableText.rich(
      TextSpan(
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.55,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<String> lines) {
    final rows = lines
        .map((l) => l
            .trim()
            .replaceAll(RegExp(r'^\|'), '')
            .replaceAll(RegExp(r'\|$'), '')
            .split('|')
            .map((c) => c.trim())
            .toList())
        .toList();
    if (rows.length < 2) return const SizedBox.shrink();
    // Bỏ row separator (---)
    final dataRows = [rows.first, ...rows.skip(2)];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            for (var r = 0; r < dataRows.length; r++)
              Container(
                decoration: BoxDecoration(
                  color: r == 0 ? theme.colorScheme.surfaceContainerHighest : null,
                  border: r == dataRows.length - 1
                      ? null
                      : Border(bottom: BorderSide(color: theme.dividerColor)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    for (final cell in dataRows[r])
                      Expanded(
                        child: _richText(context, cell),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

