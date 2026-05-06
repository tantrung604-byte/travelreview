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

  /// No description provided for @searchTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm tour'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In vi, this message translates to:
  /// **'Đà Nẵng, Sapa, Phú Quốc...'**
  String get searchHint;

  /// No description provided for @searchQuickSuggestions.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý nhanh'**
  String get searchQuickSuggestions;

  /// No description provided for @discoverHeroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn đi đâu hôm nay?'**
  String get discoverHeroTitle;

  /// No description provided for @discoverSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm tour, địa điểm, trải nghiệm...'**
  String get discoverSearchHint;

  /// No description provided for @discoverTrending.
  ///
  /// In vi, this message translates to:
  /// **'🔥 Trending tuần này'**
  String get discoverTrending;

  /// No description provided for @discoverFromPrice.
  ///
  /// In vi, this message translates to:
  /// **'từ {price}'**
  String discoverFromPrice(String price);

  /// No description provided for @discoverWorldTitle.
  ///
  /// In vi, this message translates to:
  /// **'🌍 Địa Điểm Ăn Chơi Trên Thế Giới'**
  String get discoverWorldTitle;

  /// No description provided for @bookingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt tour'**
  String get bookingTitle;

  /// No description provided for @bookingContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get bookingContinue;

  /// No description provided for @bookingBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get bookingBack;

  /// No description provided for @bookingStepDateGuests.
  ///
  /// In vi, this message translates to:
  /// **'Ngày & số khách'**
  String get bookingStepDateGuests;

  /// No description provided for @bookingStepDateGuestsContent.
  ///
  /// In vi, this message translates to:
  /// **'Tour: {tourId}\nChọn ngày khởi hành và số lượng khách.'**
  String bookingStepDateGuestsContent(String tourId);

  /// No description provided for @bookingStepContact.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin liên hệ'**
  String get bookingStepContact;

  /// No description provided for @bookingStepContactContent.
  ///
  /// In vi, this message translates to:
  /// **'Điền email, số điện thoại, ghi chú đặc biệt.'**
  String get bookingStepContactContent;

  /// No description provided for @bookingStepPayment.
  ///
  /// In vi, this message translates to:
  /// **'Thanh toán'**
  String get bookingStepPayment;

  /// No description provided for @bookingStepPaymentContent.
  ///
  /// In vi, this message translates to:
  /// **'Áp voucher và chọn phương thức thanh toán.'**
  String get bookingStepPaymentContent;

  /// No description provided for @bookingCompleteDemo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất demo'**
  String get bookingCompleteDemo;

  /// No description provided for @notFoundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy trang'**
  String get notFoundTitle;

  /// No description provided for @notFoundRouteLabel.
  ///
  /// In vi, this message translates to:
  /// **'Route không tồn tại:'**
  String get notFoundRouteLabel;

  /// No description provided for @notFoundGoHome.
  ///
  /// In vi, this message translates to:
  /// **'Về trang chủ'**
  String get notFoundGoHome;

  /// No description provided for @homeAdminLabel.
  ///
  /// In vi, this message translates to:
  /// **'Admin'**
  String get homeAdminLabel;

  /// No description provided for @homeCustomizeTheme.
  ///
  /// In vi, this message translates to:
  /// **'Tùy biến giao diện'**
  String get homeCustomizeTheme;

  /// No description provided for @homeExploreByInterestTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá theo sở thích'**
  String get homeExploreByInterestTitle;

  /// No description provided for @homeExploreByInterestSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý nhanh cho chuyến đi kế tiếp'**
  String get homeExploreByInterestSubtitle;

  /// No description provided for @homeViewAll.
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get homeViewAll;

  /// No description provided for @homeTrendingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng tuần này'**
  String get homeTrendingTitle;

  /// No description provided for @homeTrendingSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Được du khách Việt yêu thích'**
  String get homeTrendingSubtitle;

  /// No description provided for @homeSeeTours.
  ///
  /// In vi, this message translates to:
  /// **'Xem tour'**
  String get homeSeeTours;

  /// No description provided for @homeWorldPlacesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Địa Điểm Ăn Chơi Trên Thế Giới'**
  String get homeWorldPlacesTitle;

  /// No description provided for @homeWorldPlacesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn quốc gia, xem điểm tham quan và liên hệ admin mua vé'**
  String get homeWorldPlacesSubtitle;

  /// No description provided for @homeContactAdmin.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ admin'**
  String get homeContactAdmin;

  /// No description provided for @homeHeroBadge.
  ///
  /// In vi, this message translates to:
  /// **'TRAVELREVIEW DEALS 2026'**
  String get homeHeroBadge;

  /// No description provided for @homeHeroTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khám phá tour, vé và review chân thực.'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nền tảng du lịch cảm hứng Klook cho người Việt: so sánh tour, đọc review thật và đặt trải nghiệm trong vài phút.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeMiniStatTours.
  ///
  /// In vi, this message translates to:
  /// **'Tours'**
  String get homeMiniStatTours;

  /// No description provided for @homeMiniStatReviews.
  ///
  /// In vi, this message translates to:
  /// **'Reviews'**
  String get homeMiniStatReviews;

  /// No description provided for @homeMiniStatVerifiedOperators.
  ///
  /// In vi, this message translates to:
  /// **'Đối tác xác minh'**
  String get homeMiniStatVerifiedOperators;

  /// No description provided for @homeSearchDestination.
  ///
  /// In vi, this message translates to:
  /// **'Điểm đến'**
  String get homeSearchDestination;

  /// No description provided for @homeSearchDestinationValue.
  ///
  /// In vi, this message translates to:
  /// **'Đà Nẵng, Sapa...'**
  String get homeSearchDestinationValue;

  /// No description provided for @homeSearchDate.
  ///
  /// In vi, this message translates to:
  /// **'Ngày đi'**
  String get homeSearchDate;

  /// No description provided for @homeSearchAnytime.
  ///
  /// In vi, this message translates to:
  /// **'Bất kỳ'**
  String get homeSearchAnytime;

  /// No description provided for @homeSearchGuests.
  ///
  /// In vi, this message translates to:
  /// **'Khách'**
  String get homeSearchGuests;

  /// No description provided for @homeSearchGuestsValue.
  ///
  /// In vi, this message translates to:
  /// **'2 người lớn'**
  String get homeSearchGuestsValue;

  /// No description provided for @homePromoTitle.
  ///
  /// In vi, this message translates to:
  /// **'Flash Deals'**
  String get homePromoTitle;

  /// No description provided for @homePromoHeadline.
  ///
  /// In vi, this message translates to:
  /// **'Giảm đến 35% cho trải nghiệm chọn lọc tuần này.'**
  String get homePromoHeadline;

  /// No description provided for @homePromoSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Số chỗ có hạn, đối tác xác minh, xác nhận tức thì.'**
  String get homePromoSubtitle;

  /// No description provided for @homeViewDetails.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết'**
  String get homeViewDetails;

  /// No description provided for @homeTopAttractions.
  ///
  /// In vi, this message translates to:
  /// **'Khu ăn chơi / địa điểm tham quan nổi bật'**
  String get homeTopAttractions;

  /// No description provided for @homeContactAdminHelp.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể liên hệ admin để được tư vấn vé, combo gia đình, lịch mở cửa, ưu đãi nhóm và điều kiện hoàn/hủy.'**
  String get homeContactAdminHelp;

  /// No description provided for @homeViewReviewGuide.
  ///
  /// In vi, this message translates to:
  /// **'Xem bài viết review & hướng dẫn'**
  String get homeViewReviewGuide;

  /// No description provided for @homeTrustVerifiedOperators.
  ///
  /// In vi, this message translates to:
  /// **'Đối tác xác minh'**
  String get homeTrustVerifiedOperators;

  /// No description provided for @homeTrustSecureBooking.
  ///
  /// In vi, this message translates to:
  /// **'Đặt chỗ an toàn'**
  String get homeTrustSecureBooking;

  /// No description provided for @homeTrustSupport247.
  ///
  /// In vi, this message translates to:
  /// **'Hỗ trợ 24/7'**
  String get homeTrustSupport247;

  /// No description provided for @homeTrustRealReviews.
  ///
  /// In vi, this message translates to:
  /// **'Review thật'**
  String get homeTrustRealReviews;

  /// No description provided for @tourReviewEmptyError.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập nội dung đánh giá'**
  String get tourReviewEmptyError;

  /// No description provided for @tourReviewThanks.
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn đã gửi đánh giá!'**
  String get tourReviewThanks;

  /// No description provided for @tourContactMissingInfo.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập họ tên và số điện thoại'**
  String get tourContactMissingInfo;

  /// No description provided for @tourContactOpenEmailError.
  ///
  /// In vi, this message translates to:
  /// **'Không mở được ứng dụng email trên thiết bị này'**
  String get tourContactOpenEmailError;

  /// No description provided for @tourFallbackTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tour {id}'**
  String tourFallbackTitle(String id);

  /// No description provided for @tourUpdating.
  ///
  /// In vi, this message translates to:
  /// **'Đang cập nhật...'**
  String get tourUpdating;

  /// No description provided for @tourContact.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get tourContact;

  /// No description provided for @tourRatingLine.
  ///
  /// In vi, this message translates to:
  /// **'{avg} · {count} đánh giá · 3 ngày 2 đêm'**
  String tourRatingLine(String avg, int count);

  /// No description provided for @tourIntroReview.
  ///
  /// In vi, this message translates to:
  /// **'📋 Thông Tin Chương Trình'**
  String get tourIntroReview;

  /// No description provided for @tourProgramDescription.
  ///
  /// In vi, this message translates to:
  /// **'📖 Giới thiệu chung'**
  String get tourProgramDescription;

  /// No description provided for @tourScheduleHeading.
  ///
  /// In vi, this message translates to:
  /// **'🗓 Lịch Trình Chi Tiết'**
  String get tourScheduleHeading;

  /// No description provided for @tourScheduleDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày {day}'**
  String tourScheduleDay(int day);

  /// No description provided for @tourScheduleNote.
  ///
  /// In vi, this message translates to:
  /// **'📌 Lưu ý:'**
  String get tourScheduleNote;

  /// No description provided for @tourScheduleNoData.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lịch trình — admin đang cập nhật.'**
  String get tourScheduleNoData;

  /// No description provided for @tourSubDestinations.
  ///
  /// In vi, this message translates to:
  /// **'📂 Danh lục các vùng'**
  String get tourSubDestinations;

  /// No description provided for @tourTravelGuide.
  ///
  /// In vi, this message translates to:
  /// **'💡 Hướng dẫn du lịch'**
  String get tourTravelGuide;

  /// No description provided for @tourTopPlaces.
  ///
  /// In vi, this message translates to:
  /// **'📍 Các địa điểm nổi bật'**
  String get tourTopPlaces;

  /// No description provided for @tourAiSummary.
  ///
  /// In vi, this message translates to:
  /// **'✨ AI tóm tắt review'**
  String get tourAiSummary;

  /// No description provided for @tourAiSummaryBody.
  ///
  /// In vi, this message translates to:
  /// **'Khách yêu thích hướng dẫn viên thân thiện, lịch trình rõ ràng và điểm đến đẹp. Nên chuẩn bị giày đi bộ và áo khoác nhẹ.'**
  String get tourAiSummaryBody;

  /// No description provided for @tourItineraryHeading.
  ///
  /// In vi, this message translates to:
  /// **'H2: Lịch trình nổi bật'**
  String get tourItineraryHeading;

  /// No description provided for @tourCustomerReviews.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá từ khách hàng'**
  String get tourCustomerReviews;

  /// No description provided for @tourWriteReview.
  ///
  /// In vi, this message translates to:
  /// **'Viết đánh giá của bạn'**
  String get tourWriteReview;

  /// No description provided for @tourRatingOutOf5.
  ///
  /// In vi, this message translates to:
  /// **'{rating}/5 sao'**
  String tourRatingOutOf5(int rating);

  /// No description provided for @tourReviewHint.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ trải nghiệm tour của bạn...'**
  String get tourReviewHint;

  /// No description provided for @tourSubmitReview.
  ///
  /// In vi, this message translates to:
  /// **'Gửi đánh giá'**
  String get tourSubmitReview;

  /// No description provided for @tourSelectStarRating.
  ///
  /// In vi, this message translates to:
  /// **'Chọn số sao đánh giá'**
  String get tourSelectStarRating;

  /// No description provided for @tourStarCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} sao'**
  String tourStarCount(int count);

  /// No description provided for @tourContactModalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Để lại số điện thoại để nhận cuộc gọi tư vấn miễn phí!'**
  String get tourContactModalTitle;

  /// No description provided for @tourContactNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên *'**
  String get tourContactNameLabel;

  /// No description provided for @tourContactNameHint.
  ///
  /// In vi, this message translates to:
  /// **'Họ tên'**
  String get tourContactNameHint;

  /// No description provided for @tourContactPhoneLabel.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại *'**
  String get tourContactPhoneLabel;

  /// No description provided for @tourContactPhoneHint.
  ///
  /// In vi, this message translates to:
  /// **'Số điện thoại'**
  String get tourContactPhoneHint;

  /// No description provided for @tourRecaptchaLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tôi không phải người máy'**
  String get tourRecaptchaLabel;

  /// No description provided for @tourSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get tourSend;

  /// No description provided for @adminNavOverview.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan'**
  String get adminNavOverview;

  /// No description provided for @adminNavOperators.
  ///
  /// In vi, this message translates to:
  /// **'Operators'**
  String get adminNavOperators;

  /// No description provided for @adminNavUsers.
  ///
  /// In vi, this message translates to:
  /// **'Users'**
  String get adminNavUsers;

  /// No description provided for @adminNavTours.
  ///
  /// In vi, this message translates to:
  /// **'Tours'**
  String get adminNavTours;

  /// No description provided for @adminNavBookings.
  ///
  /// In vi, this message translates to:
  /// **'Bookings'**
  String get adminNavBookings;

  /// No description provided for @adminNavDisputes.
  ///
  /// In vi, this message translates to:
  /// **'Disputes'**
  String get adminNavDisputes;

  /// No description provided for @adminNavPayouts.
  ///
  /// In vi, this message translates to:
  /// **'Payouts'**
  String get adminNavPayouts;

  /// No description provided for @adminNavImageUpload.
  ///
  /// In vi, this message translates to:
  /// **'Upload ảnh'**
  String get adminNavImageUpload;

  /// No description provided for @adminNavAiConsole.
  ///
  /// In vi, this message translates to:
  /// **'AI Console'**
  String get adminNavAiConsole;

  /// No description provided for @adminNavSeo.
  ///
  /// In vi, this message translates to:
  /// **'SEO Manager'**
  String get adminNavSeo;

  /// No description provided for @adminNavAudit.
  ///
  /// In vi, this message translates to:
  /// **'Audit'**
  String get adminNavAudit;

  /// No description provided for @adminProdTag.
  ///
  /// In vi, this message translates to:
  /// **'⚠ PROD'**
  String get adminProdTag;

  /// No description provided for @adminBackToApp.
  ///
  /// In vi, this message translates to:
  /// **'Về app'**
  String get adminBackToApp;

  /// No description provided for @adminSearchHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm operator, tour, user...'**
  String get adminSearchHint;

  /// No description provided for @adminOverviewPlatform.
  ///
  /// In vi, this message translates to:
  /// **'Tổng quan platform'**
  String get adminOverviewPlatform;

  /// No description provided for @adminOverviewLastUpdated.
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật 2 phút trước · 30 ngày qua'**
  String get adminOverviewLastUpdated;

  /// No description provided for @adminKpiGmv.
  ///
  /// In vi, this message translates to:
  /// **'GMV THÁNG'**
  String get adminKpiGmv;

  /// No description provided for @adminKpiBookings.
  ///
  /// In vi, this message translates to:
  /// **'BOOKINGS'**
  String get adminKpiBookings;

  /// No description provided for @adminKpiMau.
  ///
  /// In vi, this message translates to:
  /// **'MAU'**
  String get adminKpiMau;

  /// No description provided for @adminKpiDisputeRate.
  ///
  /// In vi, this message translates to:
  /// **'DISPUTE RATE'**
  String get adminKpiDisputeRate;

  /// No description provided for @adminKycPending.
  ///
  /// In vi, this message translates to:
  /// **'⏳ Chờ duyệt KYC'**
  String get adminKycPending;

  /// No description provided for @adminKycNewCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} mới'**
  String adminKycNewCount(int count);

  /// No description provided for @adminInspect.
  ///
  /// In vi, this message translates to:
  /// **'Soi kỹ'**
  String get adminInspect;

  /// No description provided for @adminApprove.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get adminApprove;

  /// No description provided for @adminImageUploadTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quản lý Upload Hình Ảnh'**
  String get adminImageUploadTitle;

  /// No description provided for @adminImageUploadNow.
  ///
  /// In vi, this message translates to:
  /// **'Tải lên ngay'**
  String get adminImageUploadNow;

  /// No description provided for @adminImageUploadHeading.
  ///
  /// In vi, this message translates to:
  /// **'Chọn hình ảnh cho các Tour & Vùng du lịch'**
  String get adminImageUploadHeading;

  /// No description provided for @adminImageUploadDescription.
  ///
  /// In vi, this message translates to:
  /// **'Hình ảnh sau khi tải lên sẽ có link URL để bạn gắn vào bài viết review và hướng dẫn.'**
  String get adminImageUploadDescription;

  /// No description provided for @adminImageUploadSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Thành công! Đã tải lên {count} ảnh.'**
  String adminImageUploadSuccess(int count);

  /// No description provided for @adminImageUploadError.
  ///
  /// In vi, this message translates to:
  /// **'Lỗi: {error}'**
  String adminImageUploadError(String error);

  /// No description provided for @adminImagePickFromDevice.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ảnh từ máy tính'**
  String get adminImagePickFromDevice;

  /// No description provided for @themeCustomizerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tùy biến giao diện'**
  String get themeCustomizerTitle;

  /// No description provided for @themeCustomizerReset.
  ///
  /// In vi, this message translates to:
  /// **'Reset mặc định'**
  String get themeCustomizerReset;

  /// No description provided for @themeCustomizerResetDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã reset về mặc định'**
  String get themeCustomizerResetDone;

  /// No description provided for @themeCustomizerApplyEverywhere.
  ///
  /// In vi, this message translates to:
  /// **'Đổi 1 lần — áp dụng cho cả User App, Admin và Web.'**
  String get themeCustomizerApplyEverywhere;

  /// No description provided for @themePrimaryColor.
  ///
  /// In vi, this message translates to:
  /// **'Màu chủ đạo'**
  String get themePrimaryColor;

  /// No description provided for @themeRgbAdjust.
  ///
  /// In vi, this message translates to:
  /// **'Tinh chỉnh màu (RGB)'**
  String get themeRgbAdjust;

  /// No description provided for @themeModeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ sáng / tối'**
  String get themeModeTitle;

  /// No description provided for @themeModeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeModeDark;

  /// No description provided for @themeModeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Hệ thống'**
  String get themeModeSystem;

  /// No description provided for @themeTextContrast.
  ///
  /// In vi, this message translates to:
  /// **'Độ tương phản chữ'**
  String get themeTextContrast;

  /// No description provided for @themeHighContrast.
  ///
  /// In vi, this message translates to:
  /// **'Chữ tương phản cao'**
  String get themeHighContrast;

  /// No description provided for @themeHighContrastHint.
  ///
  /// In vi, this message translates to:
  /// **'Dùng đen/trắng tuyệt đối thay vì xám — dễ đọc hơn'**
  String get themeHighContrastHint;

  /// No description provided for @themeFontScale.
  ///
  /// In vi, this message translates to:
  /// **'Cỡ chữ'**
  String get themeFontScale;

  /// No description provided for @themeDensity.
  ///
  /// In vi, this message translates to:
  /// **'Mật độ giao diện'**
  String get themeDensity;

  /// No description provided for @themeDensityCompact.
  ///
  /// In vi, this message translates to:
  /// **'Compact'**
  String get themeDensityCompact;

  /// No description provided for @themeDensityStandard.
  ///
  /// In vi, this message translates to:
  /// **'Chuẩn'**
  String get themeDensityStandard;

  /// No description provided for @themeDensityComfortable.
  ///
  /// In vi, this message translates to:
  /// **'Thoáng'**
  String get themeDensityComfortable;

  /// No description provided for @themePreviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xem trước'**
  String get themePreviewTitle;

  /// No description provided for @themePreviewMetricLabel.
  ///
  /// In vi, this message translates to:
  /// **'GMV tháng'**
  String get themePreviewMetricLabel;

  /// No description provided for @themePreviewApprove.
  ///
  /// In vi, this message translates to:
  /// **'Duyệt'**
  String get themePreviewApprove;

  /// No description provided for @themePreviewReject.
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get themePreviewReject;

  /// No description provided for @adminSeoSaved.
  ///
  /// In vi, this message translates to:
  /// **'✅ Đã lưu SEO cho route: {route}'**
  String adminSeoSaved(String route);

  /// No description provided for @adminSeoScore.
  ///
  /// In vi, this message translates to:
  /// **'Score: {score}/100'**
  String adminSeoScore(int score);

  /// No description provided for @adminSeoPageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Page Title (Meta tag)'**
  String get adminSeoPageTitle;

  /// No description provided for @adminSeoTitleHint.
  ///
  /// In vi, this message translates to:
  /// **'30-60 ký tự ({length})'**
  String adminSeoTitleHint(int length);

  /// No description provided for @adminSeoTitleHelper.
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị trên tab trình duyệt & kết quả tìm kiếm'**
  String get adminSeoTitleHelper;

  /// No description provided for @adminSeoMetaDescription.
  ///
  /// In vi, this message translates to:
  /// **'Meta Description'**
  String get adminSeoMetaDescription;

  /// No description provided for @adminSeoDescriptionHint.
  ///
  /// In vi, this message translates to:
  /// **'120-160 ký tự ({length})'**
  String adminSeoDescriptionHint(int length);

  /// No description provided for @adminSeoDescriptionHelper.
  ///
  /// In vi, this message translates to:
  /// **'Mô tả nội dung dưới title trên Google'**
  String get adminSeoDescriptionHelper;

  /// No description provided for @adminSeoKeywords.
  ///
  /// In vi, this message translates to:
  /// **'Keywords (từ khóa)'**
  String get adminSeoKeywords;

  /// No description provided for @adminSeoKeywordsHint.
  ///
  /// In vi, this message translates to:
  /// **'Cách nhau bằng dấu phẩy'**
  String get adminSeoKeywordsHint;

  /// No description provided for @adminSeoKeywordsHelper.
  ///
  /// In vi, this message translates to:
  /// **'Meta keywords (ít quan trọng nhưng vẫn tốt)'**
  String get adminSeoKeywordsHelper;

  /// No description provided for @adminSeoH1.
  ///
  /// In vi, this message translates to:
  /// **'H1 Heading (Rất quan trọng)'**
  String get adminSeoH1;

  /// No description provided for @adminSeoH1Hint.
  ///
  /// In vi, this message translates to:
  /// **'Tiêu đề chính của trang (chỉ 1 H1)'**
  String get adminSeoH1Hint;

  /// No description provided for @adminSeoH1Helper.
  ///
  /// In vi, this message translates to:
  /// **'Phải khác với title tag'**
  String get adminSeoH1Helper;

  /// No description provided for @adminSeoH2.
  ///
  /// In vi, this message translates to:
  /// **'H2 Headings (Sections)'**
  String get adminSeoH2;

  /// No description provided for @adminSeoH2InputHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập H2 heading'**
  String get adminSeoH2InputHint;

  /// No description provided for @adminSeoCanonical.
  ///
  /// In vi, this message translates to:
  /// **'Canonical URL'**
  String get adminSeoCanonical;

  /// No description provided for @adminSeoCanonicalHelper.
  ///
  /// In vi, this message translates to:
  /// **'Tránh duplicate content'**
  String get adminSeoCanonicalHelper;

  /// No description provided for @adminSeoOgImage.
  ///
  /// In vi, this message translates to:
  /// **'OG Image URL (Social Media)'**
  String get adminSeoOgImage;

  /// No description provided for @adminSeoOgImageHelper.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh hiển thị khi share trên Facebook, etc.'**
  String get adminSeoOgImageHelper;

  /// No description provided for @adminSeoJsonLd.
  ///
  /// In vi, this message translates to:
  /// **'JSON-LD Structured Data'**
  String get adminSeoJsonLd;

  /// No description provided for @adminSeoJsonLdHelper.
  ///
  /// In vi, this message translates to:
  /// **'Schema.org markup cho Rich Snippets'**
  String get adminSeoJsonLdHelper;

  /// No description provided for @adminSeoNoindexTitle.
  ///
  /// In vi, this message translates to:
  /// **'🚫 Robots: NOINDEX'**
  String get adminSeoNoindexTitle;

  /// No description provided for @adminSeoNoindexSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Không index trang này trên Google'**
  String get adminSeoNoindexSubtitle;

  /// No description provided for @adminSeoPreviewTitle.
  ///
  /// In vi, this message translates to:
  /// **'🔍 Google Search Result Preview'**
  String get adminSeoPreviewTitle;

  /// No description provided for @adminSeoCanonicalDefault.
  ///
  /// In vi, this message translates to:
  /// **'https://travelreview.vn'**
  String get adminSeoCanonicalDefault;

  /// No description provided for @adminSeoMetaDescriptionPlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Meta description...'**
  String get adminSeoMetaDescriptionPlaceholder;

  /// No description provided for @adminSeoSaveButton.
  ///
  /// In vi, this message translates to:
  /// **'💾 Lưu SEO Config'**
  String get adminSeoSaveButton;

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

  /// No description provided for @aiChatTitle.
  ///
  /// In vi, this message translates to:
  /// **'🤖 Hỏi AI về tour này'**
  String get aiChatTitle;

  /// No description provided for @aiChatSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Đặt câu hỏi để được tư vấn ngay'**
  String get aiChatSubtitle;

  /// No description provided for @aiChatInputHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập câu hỏi về tour...'**
  String get aiChatInputHint;

  /// No description provided for @aiChatSend.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get aiChatSend;

  /// No description provided for @aiChatWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào! Tôi là trợ lý AI của TravelReview 👋\nBạn có thể hỏi tôi về lịch trình, chi phí, những gì cần mang theo và nhiều hơn nữa.'**
  String get aiChatWelcome;

  /// No description provided for @aiChatTyping.
  ///
  /// In vi, this message translates to:
  /// **'AI đang trả lời...'**
  String get aiChatTyping;

  /// No description provided for @aiChatErrorRetry.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra. Nhấn để thử lại.'**
  String get aiChatErrorRetry;

  /// No description provided for @aiChatQuickQuestions.
  ///
  /// In vi, this message translates to:
  /// **'Câu hỏi thường gặp'**
  String get aiChatQuickQuestions;
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
