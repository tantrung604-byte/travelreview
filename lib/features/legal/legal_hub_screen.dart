import 'package:flutter/material.dart';

import '../../core/responsive/breakpoints.dart';
import '../../core/responsive/responsive_layout.dart';
import '../../l10n/gen/app_localizations.dart';
import 'legal_document_screen.dart';

/// Trung tâm Pháp lý & Chính sách — đáp ứng yêu cầu của Google Play & App Store.
class LegalHubScreen extends StatelessWidget {
  const LegalHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final items = <_LegalItem>[
      _LegalItem(
        icon: Icons.privacy_tip_outlined,
        title: l.legalPrivacy,
        subtitle: l.legalPrivacySubtitle,
        slug: 'privacy',
      ),
      _LegalItem(
        icon: Icons.gavel_outlined,
        title: l.legalTerms,
        subtitle: l.legalTermsSubtitle,
        slug: 'terms',
      ),
      _LegalItem(
        icon: Icons.groups_outlined,
        title: l.legalCommunity,
        subtitle: l.legalCommunitySubtitle,
        slug: 'community',
      ),
      _LegalItem(
        icon: Icons.cookie_outlined,
        title: l.legalCookies,
        subtitle: l.legalCookiesSubtitle,
        slug: 'cookies',
      ),
      _LegalItem(
        icon: Icons.delete_forever_outlined,
        title: l.legalAccountDeletion,
        subtitle: l.legalAccountDeletionSubtitle,
        slug: 'account_deletion',
        danger: true,
      ),
      _LegalItem(
        icon: Icons.info_outline,
        title: l.legalAbout,
        subtitle: l.legalAboutSubtitle,
        slug: 'about',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.legalTitle)),
      body: ContentConstrained(
        maxWidth: Breakpoints.readableMaxWidth,
        padding: EdgeInsets.zero,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Header version
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              l.legalIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          ...items.map((it) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: it.danger
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    it.icon,
                    color: it.danger
                        ? Theme.of(context).colorScheme.onErrorContainer
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(it.title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(it.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LegalDocumentScreen(
                      slug: it.slug,
                      title: it.title,
                    ),
                  ),
                ),
              )),
          const Divider(height: 32),
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.code)),
            title: Text(l.legalLicenses,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(l.legalLicensesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l.appTitle,
              applicationVersion: '1.0.0',
              applicationLegalese: '© 2026 TravelReview',
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              l.legalFooter('1.0.0', '05/05/2026'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
        ],
        ),
      ),
    );
  }
}

class _LegalItem {
  const _LegalItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.slug,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String slug;
  final bool danger;
}

