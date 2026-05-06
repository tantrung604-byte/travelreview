// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppL10nVi extends AppL10n {
  AppL10nVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'TravelReview';

  @override
  String get navHome => 'Khám phá';

  @override
  String get navSearch => 'Tìm kiếm';

  @override
  String get navBookings => 'Đơn của tôi';

  @override
  String get navProfile => 'Cá nhân';

  @override
  String get welcomeTitle => 'Chào mừng đến với TravelReview!';

  @override
  String get welcomeSubtitle => 'Riverpod + Firebase đã sẵn sàng.';

  @override
  String counterLabel(int count) {
    return 'Bộ đếm: $count';
  }

  @override
  String get incrementTooltip => 'Tăng';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageVi => 'Tiếng Việt';

  @override
  String get languageEn => 'English';

  @override
  String get bookNow => 'Đặt ngay';

  @override
  String priceFrom(String price) {
    return 'Từ $price';
  }

  @override
  String reviewsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đánh giá',
      one: '1 đánh giá',
      zero: 'Chưa có đánh giá',
    );
    return '$_temp0';
  }

  @override
  String get searchTitle => 'Tìm kiếm tour';

  @override
  String get searchHint => 'Đà Nẵng, Sapa, Phú Quốc...';

  @override
  String get searchQuickSuggestions => 'Gợi ý nhanh';

  @override
  String get discoverHeroTitle => 'Bạn muốn đi đâu hôm nay?';

  @override
  String get discoverSearchHint => 'Tìm tour, địa điểm, trải nghiệm...';

  @override
  String get discoverTrending => '🔥 Trending tuần này';

  @override
  String discoverFromPrice(String price) {
    return 'từ $price';
  }

  @override
  String get discoverWorldTitle => '🌍 Địa Điểm Ăn Chơi Trên Thế Giới';

  @override
  String get bookingTitle => 'Đặt tour';

  @override
  String get bookingContinue => 'Tiếp tục';

  @override
  String get bookingBack => 'Quay lại';

  @override
  String get bookingStepDateGuests => 'Ngày & số khách';

  @override
  String bookingStepDateGuestsContent(String tourId) {
    return 'Tour: $tourId\nChọn ngày khởi hành và số lượng khách.';
  }

  @override
  String get bookingStepContact => 'Thông tin liên hệ';

  @override
  String get bookingStepContactContent =>
      'Điền email, số điện thoại, ghi chú đặc biệt.';

  @override
  String get bookingStepPayment => 'Thanh toán';

  @override
  String get bookingStepPaymentContent =>
      'Áp voucher và chọn phương thức thanh toán.';

  @override
  String get bookingCompleteDemo => 'Hoàn tất demo';

  @override
  String get notFoundTitle => 'Không tìm thấy trang';

  @override
  String get notFoundRouteLabel => 'Route không tồn tại:';

  @override
  String get notFoundGoHome => 'Về trang chủ';

  @override
  String get homeAdminLabel => 'Admin';

  @override
  String get homeCustomizeTheme => 'Tùy biến giao diện';

  @override
  String get homeExploreByInterestTitle => 'Khám phá theo sở thích';

  @override
  String get homeExploreByInterestSubtitle =>
      'Gợi ý nhanh cho chuyến đi kế tiếp';

  @override
  String get homeViewAll => 'Xem tất cả';

  @override
  String get homeTrendingTitle => 'Xu hướng tuần này';

  @override
  String get homeTrendingSubtitle => 'Được du khách Việt yêu thích';

  @override
  String get homeSeeTours => 'Xem tour';

  @override
  String get homeWorldPlacesTitle => 'Địa Điểm Ăn Chơi Trên Thế Giới';

  @override
  String get homeWorldPlacesSubtitle =>
      'Chọn quốc gia, xem điểm tham quan và liên hệ admin mua vé';

  @override
  String get homeContactAdmin => 'Liên hệ admin';

  @override
  String get homeHeroBadge => 'TRAVELREVIEW DEALS 2026';

  @override
  String get homeHeroTitle => 'Khám phá tour, vé và review chân thực.';

  @override
  String get homeHeroSubtitle =>
      'Nền tảng du lịch cảm hứng Klook cho người Việt: so sánh tour, đọc review thật và đặt trải nghiệm trong vài phút.';

  @override
  String get homeMiniStatTours => 'Tours';

  @override
  String get homeMiniStatReviews => 'Reviews';

  @override
  String get homeMiniStatVerifiedOperators => 'Đối tác xác minh';

  @override
  String get homeSearchDestination => 'Điểm đến';

  @override
  String get homeSearchDestinationValue => 'Đà Nẵng, Sapa...';

  @override
  String get homeSearchDate => 'Ngày đi';

  @override
  String get homeSearchAnytime => 'Bất kỳ';

  @override
  String get homeSearchGuests => 'Khách';

  @override
  String get homeSearchGuestsValue => '2 người lớn';

  @override
  String get homePromoTitle => 'Flash Deals';

  @override
  String get homePromoHeadline =>
      'Giảm đến 35% cho trải nghiệm chọn lọc tuần này.';

  @override
  String get homePromoSubtitle =>
      'Số chỗ có hạn, đối tác xác minh, xác nhận tức thì.';

  @override
  String get homeViewDetails => 'Xem chi tiết';

  @override
  String get homeTopAttractions => 'Khu ăn chơi / địa điểm tham quan nổi bật';

  @override
  String get homeContactAdminHelp =>
      'Bạn có thể liên hệ admin để được tư vấn vé, combo gia đình, lịch mở cửa, ưu đãi nhóm và điều kiện hoàn/hủy.';

  @override
  String get homeViewReviewGuide => 'Xem bài viết review & hướng dẫn';

  @override
  String get homeTrustVerifiedOperators => 'Đối tác xác minh';

  @override
  String get homeTrustSecureBooking => 'Đặt chỗ an toàn';

  @override
  String get homeTrustSupport247 => 'Hỗ trợ 24/7';

  @override
  String get homeTrustRealReviews => 'Review thật';

  @override
  String get tourReviewEmptyError => 'Vui lòng nhập nội dung đánh giá';

  @override
  String get tourReviewThanks => 'Cảm ơn bạn đã gửi đánh giá!';

  @override
  String get tourContactMissingInfo => 'Vui lòng nhập họ tên và số điện thoại';

  @override
  String get tourContactOpenEmailError =>
      'Không mở được ứng dụng email trên thiết bị này';

  @override
  String tourFallbackTitle(String id) {
    return 'Tour $id';
  }

  @override
  String get tourUpdating => 'Đang cập nhật...';

  @override
  String get tourContact => 'Liên hệ';

  @override
  String tourRatingLine(String avg, int count) {
    return '$avg · $count đánh giá · 3 ngày 2 đêm';
  }

  @override
  String get tourIntroReview => '📋 Thông Tin Chương Trình';

  @override
  String get tourProgramDescription => '📖 Giới thiệu chung';

  @override
  String get tourScheduleHeading => '🗓 Lịch Trình Chi Tiết';

  @override
  String tourScheduleDay(int day) {
    return 'Ngày $day';
  }

  @override
  String get tourScheduleNote => '📌 Lưu ý:';

  @override
  String get tourScheduleNoData => 'Chưa có lịch trình — admin đang cập nhật.';

  @override
  String get tourSubDestinations => '📂 Danh lục các vùng';

  @override
  String get tourTravelGuide => '💡 Hướng dẫn du lịch';

  @override
  String get tourTopPlaces => '📍 Các địa điểm nổi bật';

  @override
  String get tourAiSummary => '✨ AI tóm tắt review';

  @override
  String get tourAiSummaryBody =>
      'Khách yêu thích hướng dẫn viên thân thiện, lịch trình rõ ràng và điểm đến đẹp. Nên chuẩn bị giày đi bộ và áo khoác nhẹ.';

  @override
  String get tourItineraryHeading => 'H2: Lịch trình nổi bật';

  @override
  String get tourCustomerReviews => 'Đánh giá từ khách hàng';

  @override
  String get tourWriteReview => 'Viết đánh giá của bạn';

  @override
  String tourRatingOutOf5(int rating) {
    return '$rating/5 sao';
  }

  @override
  String get tourReviewHint => 'Chia sẻ trải nghiệm tour của bạn...';

  @override
  String get tourSubmitReview => 'Gửi đánh giá';

  @override
  String get tourSelectStarRating => 'Chọn số sao đánh giá';

  @override
  String tourStarCount(int count) {
    return '$count sao';
  }

  @override
  String get tourContactModalTitle =>
      'Để lại số điện thoại để nhận cuộc gọi tư vấn miễn phí!';

  @override
  String get tourContactNameLabel => 'Họ tên *';

  @override
  String get tourContactNameHint => 'Họ tên';

  @override
  String get tourContactPhoneLabel => 'Số điện thoại *';

  @override
  String get tourContactPhoneHint => 'Số điện thoại';

  @override
  String get tourRecaptchaLabel => 'Tôi không phải người máy';

  @override
  String get tourSend => 'Gửi';

  @override
  String get adminNavOverview => 'Tổng quan';

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
  String get adminNavImageUpload => 'Upload ảnh';

  @override
  String get adminNavAiConsole => 'AI Console';

  @override
  String get adminNavSeo => 'SEO Manager';

  @override
  String get adminNavAudit => 'Audit';

  @override
  String get adminProdTag => '⚠ PROD';

  @override
  String get adminBackToApp => 'Về app';

  @override
  String get adminSearchHint => 'Tìm operator, tour, user...';

  @override
  String get adminOverviewPlatform => 'Tổng quan platform';

  @override
  String get adminOverviewLastUpdated => 'Cập nhật 2 phút trước · 30 ngày qua';

  @override
  String get adminKpiGmv => 'GMV THÁNG';

  @override
  String get adminKpiBookings => 'BOOKINGS';

  @override
  String get adminKpiMau => 'MAU';

  @override
  String get adminKpiDisputeRate => 'DISPUTE RATE';

  @override
  String get adminKycPending => '⏳ Chờ duyệt KYC';

  @override
  String adminKycNewCount(int count) {
    return '$count mới';
  }

  @override
  String get adminInspect => 'Soi kỹ';

  @override
  String get adminApprove => 'Duyệt';

  @override
  String get adminImageUploadTitle => 'Quản lý Upload Hình Ảnh';

  @override
  String get adminImageUploadNow => 'Tải lên ngay';

  @override
  String get adminImageUploadHeading =>
      'Chọn hình ảnh cho các Tour & Vùng du lịch';

  @override
  String get adminImageUploadDescription =>
      'Hình ảnh sau khi tải lên sẽ có link URL để bạn gắn vào bài viết review và hướng dẫn.';

  @override
  String adminImageUploadSuccess(int count) {
    return 'Thành công! Đã tải lên $count ảnh.';
  }

  @override
  String adminImageUploadError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get adminImagePickFromDevice => 'Chọn ảnh từ máy tính';

  @override
  String get themeCustomizerTitle => 'Tùy biến giao diện';

  @override
  String get themeCustomizerReset => 'Reset mặc định';

  @override
  String get themeCustomizerResetDone => 'Đã reset về mặc định';

  @override
  String get themeCustomizerApplyEverywhere =>
      'Đổi 1 lần — áp dụng cho cả User App, Admin và Web.';

  @override
  String get themePrimaryColor => 'Màu chủ đạo';

  @override
  String get themeRgbAdjust => 'Tinh chỉnh màu (RGB)';

  @override
  String get themeModeTitle => 'Chế độ sáng / tối';

  @override
  String get themeModeLight => 'Sáng';

  @override
  String get themeModeDark => 'Tối';

  @override
  String get themeModeSystem => 'Hệ thống';

  @override
  String get themeTextContrast => 'Độ tương phản chữ';

  @override
  String get themeHighContrast => 'Chữ tương phản cao';

  @override
  String get themeHighContrastHint =>
      'Dùng đen/trắng tuyệt đối thay vì xám — dễ đọc hơn';

  @override
  String get themeFontScale => 'Cỡ chữ';

  @override
  String get themeDensity => 'Mật độ giao diện';

  @override
  String get themeDensityCompact => 'Compact';

  @override
  String get themeDensityStandard => 'Chuẩn';

  @override
  String get themeDensityComfortable => 'Thoáng';

  @override
  String get themePreviewTitle => 'Xem trước';

  @override
  String get themePreviewMetricLabel => 'GMV tháng';

  @override
  String get themePreviewApprove => 'Duyệt';

  @override
  String get themePreviewReject => 'Từ chối';

  @override
  String adminSeoSaved(String route) {
    return '✅ Đã lưu SEO cho route: $route';
  }

  @override
  String adminSeoScore(int score) {
    return 'Score: $score/100';
  }

  @override
  String get adminSeoPageTitle => 'Page Title (Meta tag)';

  @override
  String adminSeoTitleHint(int length) {
    return '30-60 ký tự ($length)';
  }

  @override
  String get adminSeoTitleHelper =>
      'Hiển thị trên tab trình duyệt & kết quả tìm kiếm';

  @override
  String get adminSeoMetaDescription => 'Meta Description';

  @override
  String adminSeoDescriptionHint(int length) {
    return '120-160 ký tự ($length)';
  }

  @override
  String get adminSeoDescriptionHelper =>
      'Mô tả nội dung dưới title trên Google';

  @override
  String get adminSeoKeywords => 'Keywords (từ khóa)';

  @override
  String get adminSeoKeywordsHint => 'Cách nhau bằng dấu phẩy';

  @override
  String get adminSeoKeywordsHelper =>
      'Meta keywords (ít quan trọng nhưng vẫn tốt)';

  @override
  String get adminSeoH1 => 'H1 Heading (Rất quan trọng)';

  @override
  String get adminSeoH1Hint => 'Tiêu đề chính của trang (chỉ 1 H1)';

  @override
  String get adminSeoH1Helper => 'Phải khác với title tag';

  @override
  String get adminSeoH2 => 'H2 Headings (Sections)';

  @override
  String get adminSeoH2InputHint => 'Nhập H2 heading';

  @override
  String get adminSeoCanonical => 'Canonical URL';

  @override
  String get adminSeoCanonicalHelper => 'Tránh duplicate content';

  @override
  String get adminSeoOgImage => 'OG Image URL (Social Media)';

  @override
  String get adminSeoOgImageHelper =>
      'Ảnh hiển thị khi share trên Facebook, etc.';

  @override
  String get adminSeoJsonLd => 'JSON-LD Structured Data';

  @override
  String get adminSeoJsonLdHelper => 'Schema.org markup cho Rich Snippets';

  @override
  String get adminSeoNoindexTitle => '🚫 Robots: NOINDEX';

  @override
  String get adminSeoNoindexSubtitle => 'Không index trang này trên Google';

  @override
  String get adminSeoPreviewTitle => '🔍 Google Search Result Preview';

  @override
  String get adminSeoCanonicalDefault => 'https://travelreview.vn';

  @override
  String get adminSeoMetaDescriptionPlaceholder => 'Meta description...';

  @override
  String get adminSeoSaveButton => '💾 Lưu SEO Config';

  @override
  String get legalTitle => 'Pháp lý & Chính sách';

  @override
  String get legalIntro =>
      'Các tài liệu sau áp dụng khi bạn sử dụng TravelReview. Vui lòng đọc kỹ trước khi tiếp tục.';

  @override
  String get legalPrivacy => 'Chính sách Quyền riêng tư';

  @override
  String get legalPrivacySubtitle =>
      'Cách chúng tôi thu thập và bảo vệ dữ liệu của bạn';

  @override
  String get legalTerms => 'Điều khoản Dịch vụ';

  @override
  String get legalTermsSubtitle => 'Quyền và nghĩa vụ khi sử dụng ứng dụng';

  @override
  String get legalCommunity => 'Quy tắc Cộng đồng';

  @override
  String get legalCommunitySubtitle =>
      'Nguyên tắc đăng review, ảnh và bình luận';

  @override
  String get legalCookies => 'Chính sách Cookie';

  @override
  String get legalCookiesSubtitle => 'Chỉ áp dụng cho phiên bản web';

  @override
  String get legalAccountDeletion => 'Yêu cầu xóa tài khoản';

  @override
  String get legalAccountDeletionSubtitle =>
      'Xóa tài khoản và dữ liệu cá nhân của bạn';

  @override
  String get legalAbout => 'Về TravelReview';

  @override
  String get legalAboutSubtitle => 'Phiên bản, pháp nhân, liên hệ';

  @override
  String get legalLicenses => 'Giấy phép mã nguồn mở';

  @override
  String get legalLicensesSubtitle => 'Các thư viện bên thứ ba được sử dụng';

  @override
  String get legalLoadError => 'Không thể tải tài liệu. Vui lòng thử lại sau.';

  @override
  String legalFooter(String version, String date) {
    return 'Phiên bản $version • Cập nhật $date';
  }

  @override
  String get legalAndPolicies => 'Pháp lý & Chính sách';

  @override
  String get aiChatTitle => '🤖 Hỏi AI về tour này';

  @override
  String get aiChatSubtitle => 'Đặt câu hỏi để được tư vấn ngay';

  @override
  String get aiChatInputHint => 'Nhập câu hỏi về tour...';

  @override
  String get aiChatSend => 'Gửi';

  @override
  String get aiChatWelcome =>
      'Xin chào! Tôi là trợ lý AI của TravelReview 👋\nBạn có thể hỏi tôi về lịch trình, chi phí, những gì cần mang theo và nhiều hơn nữa.';

  @override
  String get aiChatTyping => 'AI đang trả lời...';

  @override
  String get aiChatErrorRetry => 'Có lỗi xảy ra. Nhấn để thử lại.';

  @override
  String get aiChatQuickQuestions => 'Câu hỏi thường gặp';
}
