// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TravelReview';

  @override
  String get navHome => 'Discover';

  @override
  String get navSearch => 'Search';

  @override
  String get navBookings => 'My Bookings';

  @override
  String get navProfile => 'Profile';

  @override
  String get welcomeTitle => 'Welcome to TravelReview!';

  @override
  String get welcomeSubtitle => 'Riverpod + Firebase are ready.';

  @override
  String counterLabel(int count) {
    return 'Counter: $count';
  }

  @override
  String get incrementTooltip => 'Increment';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'English';

  @override
  String get bookNow => 'Book now';

  @override
  String priceFrom(String price) {
    return 'From $price';
  }

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
      zero: 'No reviews',
    );
    return '$_temp0';
  }

  @override
  String get legalTitle => 'Legal & Policies';

  @override
  String get legalIntro =>
      'The following documents apply when you use TravelReview. Please read carefully before continuing.';

  @override
  String get legalPrivacy => 'Privacy Policy';

  @override
  String get legalPrivacySubtitle => 'How we collect and protect your data';

  @override
  String get legalTerms => 'Terms of Service';

  @override
  String get legalTermsSubtitle => 'Your rights and duties when using the app';

  @override
  String get legalCommunity => 'Community Guidelines';

  @override
  String get legalCommunitySubtitle =>
      'Rules for posting reviews, photos and comments';

  @override
  String get legalCookies => 'Cookie Policy';

  @override
  String get legalCookiesSubtitle => 'Web version only';

  @override
  String get legalAccountDeletion => 'Account Deletion';

  @override
  String get legalAccountDeletionSubtitle =>
      'Delete your account and personal data';

  @override
  String get legalAbout => 'About TravelReview';

  @override
  String get legalAboutSubtitle => 'Version, legal entity, contact';

  @override
  String get legalLicenses => 'Open-source Licenses';

  @override
  String get legalLicensesSubtitle => 'Third-party libraries used';

  @override
  String get legalLoadError =>
      'Could not load document. Please try again later.';

  @override
  String legalFooter(String version, String date) {
    return 'Version $version • Updated $date';
  }

  @override
  String get legalAndPolicies => 'Legal & Policies';
}
