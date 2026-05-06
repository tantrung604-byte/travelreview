/// Payment abstraction. Hiện tại dùng `MockPaymentService` mô phỏng các cổng
/// (COD, Bank Transfer, MoMo, VNPay). Có thể thay bằng integration thật bằng
/// cách swap impl trong `paymentServiceProvider`.
library;

import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PaymentMethod { cod, bankTransfer, momo, vnpay, card }

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán khi nhận dịch vụ (COD)';
      case PaymentMethod.bankTransfer:
        return 'Chuyển khoản ngân hàng';
      case PaymentMethod.momo:
        return 'Ví MoMo';
      case PaymentMethod.vnpay:
        return 'VNPay QR';
      case PaymentMethod.card:
        return 'Thẻ tín dụng / ghi nợ';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.cod:
        return 'Thanh toán tiền mặt cho hướng dẫn viên trước giờ khởi hành.';
      case PaymentMethod.bankTransfer:
        return 'Chúng tôi sẽ gửi thông tin chuyển khoản qua email.';
      case PaymentMethod.momo:
        return 'Mở app MoMo và quét mã QR để xác nhận.';
      case PaymentMethod.vnpay:
        return 'Quét mã QR VNPay bằng app ngân hàng để thanh toán.';
      case PaymentMethod.card:
        return 'Hỗ trợ Visa, Mastercard, JCB qua cổng thanh toán an toàn.';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.cod:
        return '💵';
      case PaymentMethod.bankTransfer:
        return '🏦';
      case PaymentMethod.momo:
        return '📱';
      case PaymentMethod.vnpay:
        return '🇻🇳';
      case PaymentMethod.card:
        return '💳';
    }
  }
}

class PaymentResult {
  PaymentResult({
    required this.success,
    required this.transactionId,
    required this.method,
    this.message,
  });

  final bool success;
  final String transactionId;
  final PaymentMethod method;
  final String? message;
}

abstract class PaymentService {
  /// `amount` tính bằng VND.
  Future<PaymentResult> charge({
    required PaymentMethod method,
    required int amount,
    required String orderId,
    required String customerEmail,
  });
}

class MockPaymentService implements PaymentService {
  @override
  Future<PaymentResult> charge({
    required PaymentMethod method,
    required int amount,
    required String orderId,
    required String customerEmail,
  }) async {
    // Mô phỏng độ trễ gọi cổng thanh toán
    await Future.delayed(const Duration(milliseconds: 1200));
    final rng = Random();
    final txn = 'TXN${DateTime.now().millisecondsSinceEpoch}_${rng.nextInt(9999)}';

    // COD luôn thành công (chỉ ghi nhận đơn)
    if (method == PaymentMethod.cod) {
      return PaymentResult(success: true, transactionId: txn, method: method);
    }
    // Mock 95% success cho các phương thức khác
    final success = rng.nextDouble() > 0.05;
    return PaymentResult(
      success: success,
      transactionId: txn,
      method: method,
      message: success ? 'Thanh toán thành công (mô phỏng)' : 'Giao dịch bị từ chối, vui lòng thử lại',
    );
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return MockPaymentService();
});

