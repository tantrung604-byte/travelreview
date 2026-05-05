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
}
