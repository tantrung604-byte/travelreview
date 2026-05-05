import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.tourId});

  final String tourId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt tour')),
      body: Stepper(
        controlsBuilder: (context, details) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              FilledButton(onPressed: details.onStepContinue, child: const Text('Tiếp tục')),
              const SizedBox(width: 8),
              TextButton(onPressed: details.onStepCancel, child: const Text('Quay lại')),
            ],
          ),
        ),
        steps: [
          Step(
            title: const Text('Ngày & số khách'),
            content: Text('Tour: $tourId\nChọn ngày khởi hành và số lượng khách.'),
            isActive: true,
          ),
          const Step(
            title: Text('Thông tin liên hệ'),
            content: Text('Điền email, số điện thoại, ghi chú đặc biệt.'),
          ),
          Step(
            title: const Text('Thanh toán'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Áp voucher và chọn phương thức thanh toán.'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => context.go('/discover'),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Hoàn tất demo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

