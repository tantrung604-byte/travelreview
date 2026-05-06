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
  String get searchTitle => 'Search tours';

  @override
  String get searchHint => 'Da Nang, Sapa, Phu Quoc...';

  @override
  String get searchQuickSuggestions => 'Quick suggestions';

  @override
  String get discoverHeroTitle => 'Where do you want to go today?';

  @override
  String get discoverSearchHint => 'Search tours, destinations, experiences...';

  @override
  String get discoverTrending => '🔥 Trending this week';

  @override
  String discoverFromPrice(String price) {
    return 'from $price';
  }

  @override
  String get discoverWorldTitle => '🌍 World destinations';

  @override
  String get bookingTitle => 'Book tour';

  @override
  String get bookingContinue => 'Continue';

  @override
  String get bookingBack => 'Back';

  @override
  String get bookingStepDateGuests => 'Date & guests';

  @override
  String bookingStepDateGuestsContent(String tourId) {
    return 'Tour: $tourId\nSelect departure date and number of guests.';
  }

  @override
  String get bookingStepContact => 'Contact details';

  @override
  String get bookingStepContactContent =>
      'Enter email, phone number, and special notes.';

  @override
  String get bookingStepPayment => 'Payment';

  @override
  String get bookingStepPaymentContent =>
      'Apply voucher and choose a payment method.';

  @override
  String get bookingCompleteDemo => 'Complete demo';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundRouteLabel => 'Route does not exist:';

  @override
  String get notFoundGoHome => 'Go home';

  @override
  String get homeAdminLabel => 'Admin';

  @override
  String get homeCustomizeTheme => 'Customize theme';

  @override
  String get homeExploreByInterestTitle => 'Explore by interest';

  @override
  String get homeExploreByInterestSubtitle => 'Quick picks for your next trip';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeTrendingTitle => 'Trending this week';

  @override
  String get homeTrendingSubtitle => 'Loved by Vietnamese travellers';

  @override
  String get homeSeeTours => 'See tours';

  @override
  String get homeWorldPlacesTitle => 'World places to explore';

  @override
  String get homeWorldPlacesSubtitle =>
      'Choose a country, see attractions, and contact admin to buy tickets';

  @override
  String get homeContactAdmin => 'Contact admin';

  @override
  String get homeHeroBadge => 'TRAVELREVIEW DEALS 2026';

  @override
  String get homeHeroTitle => 'Discover trips, tickets, and honest reviews.';

  @override
  String get homeHeroSubtitle =>
      'A Klook-inspired travel marketplace for Vietnam: compare tours, read real reviews, and book experiences in minutes.';

  @override
  String get homeMiniStatTours => 'Tours';

  @override
  String get homeMiniStatReviews => 'Reviews';

  @override
  String get homeMiniStatVerifiedOperators => 'Verified operators';

  @override
  String get homeSearchDestination => 'Destination';

  @override
  String get homeSearchDestinationValue => 'Da Nang, Sapa...';

  @override
  String get homeSearchDate => 'Date';

  @override
  String get homeSearchAnytime => 'Anytime';

  @override
  String get homeSearchGuests => 'Guests';

  @override
  String get homeSearchGuestsValue => '2 adults';

  @override
  String get homePromoTitle => 'Flash Deals';

  @override
  String get homePromoHeadline =>
      'Save up to 35% on selected experiences this week.';

  @override
  String get homePromoSubtitle =>
      'Limited seats, verified operators, instant confirmation.';

  @override
  String get homeViewDetails => 'View details';

  @override
  String get homeTopAttractions => 'Top attractions';

  @override
  String get homeContactAdminHelp =>
      'Contact admin for ticket consultation, family combos, opening hours, group discounts, and refund/cancel conditions.';

  @override
  String get homeViewReviewGuide => 'View review & guide';

  @override
  String get homeTrustVerifiedOperators => 'Verified operators';

  @override
  String get homeTrustSecureBooking => 'Secure booking';

  @override
  String get homeTrustSupport247 => '24/7 support';

  @override
  String get homeTrustRealReviews => 'Real reviews';

  @override
  String get tourReviewEmptyError => 'Please enter your review content';

  @override
  String get tourReviewThanks => 'Thank you for your review!';

  @override
  String get tourContactMissingInfo =>
      'Please enter full name and phone number';

  @override
  String get tourContactOpenEmailError =>
      'Cannot open an email app on this device';

  @override
  String tourFallbackTitle(String id) {
    return 'Tour $id';
  }

  @override
  String get tourUpdating => 'Updating...';

  @override
  String get tourContact => 'Contact';

  @override
  String tourRatingLine(String avg, int count) {
    return '$avg · $count reviews · 3 days 2 nights';
  }

  @override
  String get tourIntroReview => '📋 Tour Programme';

  @override
  String get tourProgramDescription => '📖 General Overview';

  @override
  String get tourScheduleHeading => '🗓 Detailed Itinerary';

  @override
  String tourScheduleDay(int day) {
    return 'Day $day';
  }

  @override
  String get tourScheduleNote => '📌 Note:';

  @override
  String get tourScheduleNoData =>
      'Itinerary not yet available — admin is updating.';

  @override
  String get tourSubDestinations => '📂 Sub-destinations';

  @override
  String get tourTravelGuide => '💡 Travel guide';

  @override
  String get tourTopPlaces => '📍 Top places';

  @override
  String get tourAiSummary => '✨ AI review summary';

  @override
  String get tourAiSummaryBody =>
      'Travelers love friendly guides, clear itineraries, and beautiful destinations. Bring walking shoes and a light jacket.';

  @override
  String get tourItineraryHeading => 'H2: Highlight itinerary';

  @override
  String get tourCustomerReviews => 'Customer reviews';

  @override
  String get tourWriteReview => 'Write your review';

  @override
  String tourRatingOutOf5(int rating) {
    return '$rating/5 stars';
  }

  @override
  String get tourReviewHint => 'Share your tour experience...';

  @override
  String get tourSubmitReview => 'Submit review';

  @override
  String get tourSelectStarRating => 'Select star rating';

  @override
  String tourStarCount(int count) {
    return '$count stars';
  }

  @override
  String get tourContactModalTitle =>
      'Leave your phone number for a free consultation call!';

  @override
  String get tourContactNameLabel => 'Full name *';

  @override
  String get tourContactNameHint => 'Full name';

  @override
  String get tourContactPhoneLabel => 'Phone number *';

  @override
  String get tourContactPhoneHint => 'Phone number';

  @override
  String get tourRecaptchaLabel => 'I\'m not a robot';

  @override
  String get tourSend => 'Send';

  @override
  String get adminNavOverview => 'Overview';

  @override
  String get adminNavOperators => 'Operators';

  @override
  String get adminNavUsers => 'Users';

  @override
  String get adminNavTours => 'Tours';

  @override
  String get adminNavBookings => 'Bookings';

  @override
  String get adminNavDisputes => 'Disputes';

  @override
  String get adminNavPayouts => 'Payouts';

  @override
  String get adminNavImageUpload => 'Image upload';

  @override
  String get adminNavAiConsole => 'AI Console';

  @override
  String get adminNavSeo => 'SEO Manager';

  @override
  String get adminNavAudit => 'Audit';

  @override
  String get adminProdTag => '⚠ PROD';

  @override
  String get adminBackToApp => 'Back to app';

  @override
  String get adminSearchHint => 'Search operator, tour, user...';

  @override
  String get adminOverviewPlatform => 'Platform overview';

  @override
  String get adminOverviewLastUpdated => 'Updated 2 minutes ago · Last 30 days';

  @override
  String get adminKpiGmv => 'MONTHLY GMV';

  @override
  String get adminKpiBookings => 'BOOKINGS';

  @override
  String get adminKpiMau => 'MAU';

  @override
  String get adminKpiDisputeRate => 'DISPUTE RATE';

  @override
  String get adminKycPending => '⏳ Pending KYC approval';

  @override
  String adminKycNewCount(int count) {
    return '$count new';
  }

  @override
  String get adminInspect => 'Inspect';

  @override
  String get adminApprove => 'Approve';

  @override
  String get adminImageUploadTitle => 'Image Upload Manager';

  @override
  String get adminImageUploadNow => 'Upload now';

  @override
  String get adminImageUploadHeading =>
      'Choose images for tours & destinations';

  @override
  String get adminImageUploadDescription =>
      'Uploaded images will provide URLs you can attach to review and guide content.';

  @override
  String adminImageUploadSuccess(int count) {
    return 'Success! Uploaded $count images.';
  }

  @override
  String adminImageUploadError(String error) {
    return 'Error: $error';
  }

  @override
  String get adminImagePickFromDevice => 'Pick images from device';

  @override
  String get themeCustomizerTitle => 'Customize theme';

  @override
  String get themeCustomizerReset => 'Reset default';

  @override
  String get themeCustomizerResetDone => 'Reset to default completed';

  @override
  String get themeCustomizerApplyEverywhere =>
      'Change once - apply to User App, Admin, and Web.';

  @override
  String get themePrimaryColor => 'Primary color';

  @override
  String get themeRgbAdjust => 'RGB adjustment';

  @override
  String get themeModeTitle => 'Light / Dark mode';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeTextContrast => 'Text contrast';

  @override
  String get themeHighContrast => 'High-contrast text';

  @override
  String get themeHighContrastHint =>
      'Use pure black/white instead of gray for better readability';

  @override
  String get themeFontScale => 'Font size';

  @override
  String get themeDensity => 'UI density';

  @override
  String get themeDensityCompact => 'Compact';

  @override
  String get themeDensityStandard => 'Standard';

  @override
  String get themeDensityComfortable => 'Comfortable';

  @override
  String get themePreviewTitle => 'Preview';

  @override
  String get themePreviewMetricLabel => 'Monthly GMV';

  @override
  String get themePreviewApprove => 'Approve';

  @override
  String get themePreviewReject => 'Reject';

  @override
  String adminSeoSaved(String route) {
    return '✅ Saved SEO for route: $route';
  }

  @override
  String adminSeoScore(int score) {
    return 'Score: $score/100';
  }

  @override
  String get adminSeoPageTitle => 'Page Title (meta tag)';

  @override
  String adminSeoTitleHint(int length) {
    return '30-60 characters ($length)';
  }

  @override
  String get adminSeoTitleHelper => 'Shown in browser tab and search results';

  @override
  String get adminSeoMetaDescription => 'Meta Description';

  @override
  String adminSeoDescriptionHint(int length) {
    return '120-160 characters ($length)';
  }

  @override
  String get adminSeoDescriptionHelper =>
      'Content snippet shown below title on Google';

  @override
  String get adminSeoKeywords => 'Keywords';

  @override
  String get adminSeoKeywordsHint => 'Separate by commas';

  @override
  String get adminSeoKeywordsHelper =>
      'Meta keywords (less important but still useful)';

  @override
  String get adminSeoH1 => 'H1 Heading (Very important)';

  @override
  String get adminSeoH1Hint => 'Main page heading (only one H1)';

  @override
  String get adminSeoH1Helper => 'Should differ from title tag';

  @override
  String get adminSeoH2 => 'H2 Headings (Sections)';

  @override
  String get adminSeoH2InputHint => 'Enter H2 heading';

  @override
  String get adminSeoCanonical => 'Canonical URL';

  @override
  String get adminSeoCanonicalHelper => 'Avoid duplicate content';

  @override
  String get adminSeoOgImage => 'OG Image URL (Social Media)';

  @override
  String get adminSeoOgImageHelper =>
      'Image shown when sharing on social platforms';

  @override
  String get adminSeoJsonLd => 'JSON-LD Structured Data';

  @override
  String get adminSeoJsonLdHelper => 'Schema.org markup for Rich Snippets';

  @override
  String get adminSeoNoindexTitle => '🚫 Robots: NOINDEX';

  @override
  String get adminSeoNoindexSubtitle => 'Do not index this page on Google';

  @override
  String get adminSeoPreviewTitle => '🔍 Google Search Result Preview';

  @override
  String get adminSeoCanonicalDefault => 'https://travelreview.vn';

  @override
  String get adminSeoMetaDescriptionPlaceholder => 'Meta description...';

  @override
  String get adminSeoSaveButton => '💾 Save SEO Config';

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

  @override
  String get aiChatTitle => '🤖 Ask AI about this tour';

  @override
  String get aiChatSubtitle => 'Get instant answers to your questions';

  @override
  String get aiChatInputHint => 'Ask a question about this tour...';

  @override
  String get aiChatSend => 'Send';

  @override
  String get aiChatWelcome =>
      'Hi there! I\'m TravelReview\'s AI assistant 👋\nFeel free to ask me about the itinerary, costs, what to pack, and more.';

  @override
  String get aiChatTyping => 'AI is typing...';

  @override
  String get aiChatErrorRetry => 'An error occurred. Tap to retry.';

  @override
  String get aiChatQuickQuestions => 'Quick questions';
}
