import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../cart/cart_providers.dart';
import 'booking_providers.dart';
import 'payment_service.dart';

class CheckoutSuccessScreen extends ConsumerWidget {
  const CheckoutSuccessScreen({super.key, required this.bookingId, this.result});

  final String bookingId;
  final PaymentResult? result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));
    final isOk = result?.success ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(isOk ? 'Đặt tour thành công' : 'Thanh toán thất bại'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
      ),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không tải được đơn: $e')),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Không tìm thấy đơn hàng.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    Icon(
                      isOk ? Icons.check_circle : Icons.error_outline,
                      size: 96,
                      color: isOk ? Colors.green : theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isOk
                          ? 'Cảm ơn bạn! Đơn của bạn đã được ghi nhận.'
                          : (result?.message ?? 'Giao dịch không thành công.'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text('Mã đơn: ${booking.id}',
                        style: theme.textTheme.bodySmall),
                    if (booking.transactionId.isNotEmpty)
                      Text('Mã giao dịch: ${booking.transactionId}',
                          style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chi tiết đơn',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      _row('Khách hàng', booking.customerName),
                      _row('Điện thoại', booking.customerPhone),
                      _row('Email', booking.userEmail),
                      _row('Phương thức', booking.paymentMethod.toUpperCase()),
                      _row('Trạng thái', booking.status.toUpperCase()),
                      const Divider(),
                      for (final it in booking.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text('${it.title} ×${it.quantity}')),
                              Text(formatVnd(it.priceVnd * it.quantity)),
                            ],
                          ),
                        ),
                      const Divider(),
                      Row(
                        children: [
                          const Text('Tổng',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                          const Spacer(),
                          Text(formatVnd(booking.totalVnd),
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (booking.paymentMethod == 'bankTransfer')
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hướng dẫn chuyển khoản',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                        SizedBox(height: 8),
                        Text('Ngân hàng: Vietcombank'),
                        Text('Số TK: 0123 456 789'),
                        Text('Chủ TK: TRAVEL REVIEW JSC'),
                        SizedBox(height: 6),
                        Text('Nội dung CK: <Mã đơn> <Họ tên>',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.goNamed(AppRouteNames.account),
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('Xem đơn của tôi'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.goNamed(AppRouteNames.discover),
                      icon: const Icon(Icons.explore_outlined),
                      label: const Text('Khám phá thêm'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text(k, style: const TextStyle(color: Colors.grey))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
      );
}

