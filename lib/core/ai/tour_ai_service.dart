import 'package:google_generative_ai/google_generative_ai.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cấu hình API Key Gemini
//   1. Lấy key miễn phí tại: https://aistudio.google.com/app/apikey
//   2. Dán key vào hằng số dưới đây HOẶC đưa vào env / Firebase Remote Config
// ─────────────────────────────────────────────────────────────────────────────
const _kGeminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '', // để trống → dùng chế độ demo offline
);

// ─── Chat message model ───────────────────────────────────────────────────────
class AiMessage {
  final String text;
  final bool isUser;
  final bool isLoading;
  final bool isError;

  const AiMessage({
    required this.text,
    required this.isUser,
    this.isLoading = false,
    this.isError = false,
  });

  AiMessage copyWith({String? text, bool? isLoading, bool? isError}) =>
      AiMessage(
        text: text ?? this.text,
        isUser: isUser,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError,
      );
}

// ─── Câu hỏi gợi ý nhanh ─────────────────────────────────────────────────────
const quickQuestionsVi = [
  '📅 Lịch trình chi tiết thế nào?',
  '💰 Chi phí phát sinh thêm?',
  '👨‍👩‍👧‍👦 Phù hợp cho gia đình?',
  '🎒 Cần mang những gì?',
  '🌤 Thời điểm đi đẹp nhất?',
];

const quickQuestionsEn = [
  '📅 What is the itinerary?',
  '💰 Any additional costs?',
  '👨‍👩‍👧‍👦 Family-friendly?',
  '🎒 What to pack?',
  '🌤 Best time to go?',
];

// ─── Service ──────────────────────────────────────────────────────────────────
class TourAiService {
  TourAiService({required this.tourContext});

  /// Context về tour (tiêu đề, mô tả, lịch trình) truyền vào system prompt
  final String tourContext;

  GenerativeModel? _model;
  ChatSession? _chat;

  bool get isAvailable => _kGeminiApiKey.isNotEmpty;

  void _initIfNeeded() {
    if (_model != null) return;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _kGeminiApiKey,
      systemInstruction: Content.system(
        'Bạn là trợ lý du lịch AI thân thiện của TravelReview. '
        'Nhiệm vụ của bạn là tư vấn về tour du lịch dựa trên thông tin dưới đây. '
        'Trả lời ngắn gọn, dễ hiểu bằng tiếng Việt (hoặc tiếng Anh nếu khách hỏi tiếng Anh). '
        'Nếu không biết thông tin nào, hãy đề nghị khách liên hệ admin để được tư vấn.\n\n'
        '--- THÔNG TIN TOUR ---\n$tourContext\n--- HẾT ---',
      ),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 400,
      ),
    );
    _chat = _model!.startChat(history: []);
  }

  /// Gửi tin nhắn và nhận phản hồi từ Gemini
  Future<String> sendMessage(String userMessage) async {
    if (!isAvailable) {
      return _demoReply(userMessage);
    }
    _initIfNeeded();
    final response = await _chat!.sendMessage(Content.text(userMessage));
    return response.text ?? 'Xin lỗi, tôi không hiểu câu hỏi này.';
  }

  /// Phản hồi demo khi chưa cấu hình API key
  String _demoReply(String q) {
    final lower = q.toLowerCase();
    if (lower.contains('lịch') || lower.contains('ngày') || lower.contains('itinerary')) {
      return '📅 Tour có lịch trình chi tiết được hiển thị ngay phía trên. '
          'Bạn có thể mở rộng từng ngày để xem hoạt động cụ thể.';
    }
    if (lower.contains('giá') || lower.contains('phí') || lower.contains('cost') || lower.contains('price')) {
      return '💰 Giá tour đã bao gồm xe đưa đón, khách sạn và hướng dẫn viên. '
          'Chi phí phát sinh: bữa ăn cá nhân, mua sắm và vé vào một số điểm tham quan thêm.';
    }
    if (lower.contains('gia đình') || lower.contains('trẻ em') || lower.contains('family')) {
      return '👨‍👩‍👧‍👦 Tour rất phù hợp cho gia đình! Xe thoải mái, khách sạn đạt chuẩn, '
          'trẻ em dưới 5 tuổi thường được miễn phí (liên hệ admin để xác nhận).';
    }
    if (lower.contains('mang') || lower.contains('đồ') || lower.contains('pack')) {
      return '🎒 Bạn nên mang: quần áo thoải mái, giày đi bộ, kem chống nắng, '
          'thuốc cá nhân, và một ít tiền mặt để mua sắm tại địa phương.';
    }
    if (lower.contains('thời tiết') || lower.contains('mùa') || lower.contains('weather')) {
      return '🌤 Thời điểm đẹp nhất thường là tháng 3–5 và tháng 9–11. '
          'Tránh mùa hè nóng và tháng 7–8 thường có mưa. '
          'Liên hệ admin để biết lịch khởi hành phù hợp nhất!';
    }
    return '🤖 Cảm ơn câu hỏi của bạn! Tính năng AI đầy đủ đang được kích hoạt. '
        'Hiện tại bạn có thể liên hệ admin qua nút "Liên hệ" bên dưới để được tư vấn trực tiếp.';
  }

  void dispose() {
    _chat = null;
    _model = null;
  }
}

