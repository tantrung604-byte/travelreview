import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'TravelReview'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá'**
  String get navHome;

  /// No description provided for @navSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm'**
  String get navSearch;

  /// No description provided for @navBookings.
  ///
  /// In vi, this message translates to:
  /// **'Đơn của tôi'**
  String get navBookings;

  /// No description provided for @navProfile.
  ///
  /// In vi, this message translates to:
  /// **'Cá nhân'**
  String get navProfile;

  /// No description provided for @welcomeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chào mừng đến với TravelReview!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Riverpod + Firebase đã sẵn sàng.'**
  String get welcomeSubtitle;

  /// No description provided for @counterLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bộ đếm: {count}'**
  String counterLabel(int count);

  /// No description provided for @incrementTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Tăng'**
  String get incrementTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageLabel;

  /// No description provided for @languageSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get languageSystem;

  /// No description provided for @languageVi.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVi;

  /// No description provided for @languageEn.
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @bookNow.
  ///
  /// In vi, this message translates to:
  /// **'Đặt ngay'**
  String get bookNow;

  /// No description provided for @priceFrom.
  ///
  /// In vi, this message translates to:
  /// **'Từ {price}'**
  String priceFrom(String price);

  /// No description provided for @reviewsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, =0{Chưa có đánh giá} =1{1 đánh giá} other{{count} đánh giá}}'**
  String reviewsCount(int count);

  /// No description provided for @legalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Pháp lý & Chính sách'**
  String get legalTitle;

  /// No description provided for @legalIntro.
  ///
  /// In vi, this message translates to:
  /// **'Các tài liệu sau áp dụng khi bạn sử dụng TravelReview. Vui lòng đọc kỹ trước khi tiếp tục.'**
  String get legalIntro;

  /// No description provided for @legalPrivacy.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách Quyền riêng tư'**
  String get legalPrivacy;

  /// No description provided for @legalPrivacySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách chúng tôi thu thập và bảo vệ dữ liệu của bạn'**
  String get legalPrivacySubtitle;

  /// No description provided for @legalTerms.
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản Dịch vụ'**
  String get legalTerms;

  /// No description provided for @legalTermsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Quyền và nghĩa vụ khi sử dụng ứng dụng'**
  String get legalTermsSubtitle;

  /// No description provided for @legalCommunity.
  ///
  /// In vi, this message translates to:
  /// **'Quy tắc Cộng đồng'**
  String get legalCommunity;

  /// No description provided for @legalCommunitySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nguyên tắc đăng review, ảnh và bình luận'**
  String get legalCommunitySubtitle;

  /// No description provided for @legalCookies.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách Cookie'**
  String get legalCookies;

  /// No description provided for @legalCookiesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ áp dụng cho phiên bản web'**
  String get legalCookiesSubtitle;

  /// No description provided for @legalAccountDeletion.
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu xóa tài khoản'**
  String get legalAccountDeletion;

  /// No description provided for @legalAccountDeletionSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản và dữ liệu cá nhân của bạn'**
  String get legalAccountDeletionSubtitle;

  /// No description provided for @legalAbout.
  ///
  /// In vi, this message translates to:
  /// **'Về TravelReview'**
  String get legalAbout;

  /// No description provided for @legalAboutSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản, pháp nhân, liên hệ'**
  String get legalAboutSubtitle;

  /// No description provided for @legalLicenses.
  ///
  /// In vi, this message translates to:
  /// **'Giấy phép mã nguồn mở'**
  String get legalLicenses;

  /// No description provided for @legalLicensesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Các thư viện bên thứ ba được sử dụng'**
  String get legalLicensesSubtitle;

  /// No description provided for @legalLoadError.
  ///
  /// In vi, this message translates to:
  /// **'Không thể tải tài liệu. Vui lòng thử lại sau.'**
  String get legalLoadError;

  /// No description provided for @legalFooter.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version} • Cập nhật {date}'**
  String legalFooter(String version, String date);

  /// No description provided for @legalAndPolicies.
  ///
  /// In vi, this message translates to:
  /// **'Pháp lý & Chính sách'**
  String get legalAndPolicies;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'vi':
      return AppL10nVi();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
