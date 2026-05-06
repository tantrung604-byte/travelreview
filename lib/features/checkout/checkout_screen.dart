import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../auth/auth_providers.dart';
import '../cart/cart_providers.dart';
import 'booking_providers.dart';
import 'payment_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _note = TextEditingController();
  PaymentMethod _method = PaymentMethod.bankTransfer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    if (user != null) {
      _email.text = user.email ?? '';
      _name.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final items = ref.read(cartControllerProvider);
    if (items.isEmpty) {
      _snack('Giỏ hàng đang trống');
      return;
    }
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      // Buộc login trước
      context.go('/auth?next=/checkout');
      return;
    }
    setState(() => _busy = true);
    try {
      final total = ref.read(cartTotalProvider);
      final orderRef = 'ORD${DateTime.now().millisecondsSinceEpoch}';
      final result = await ref.read(paymentServiceProvider).charge(
            method: _method,
            amount: total,
            orderId: orderRef,
            customerEmail: _email.text.trim(),
          );

      final bookingId = await ref.read(bookingRepositoryProvider).create(
            userId: user.uid,
            userEmail: _email.text.trim(),
            customerName: _name.text.trim(),
            customerPhone: _phone.text.trim(),
            note: _note.text.trim(),
            items: items.map(BookingItem.fromCartItem).toList(),
            totalVnd: total,
            method: _method,
            payment: result,
          );

      if (result.success) {
        ref.read(cartControllerProvider.notifier).clear();
      }

      if (!mounted) return;
      context.goNamed(
        AppRouteNames.checkoutSuccess,
        pathParameters: {'bookingId': bookingId},
        extra: result,
      );
    } catch (e) {
      _snack('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalProvider);
    final user = ref.watch(currentUserProvider).value;

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thanh toán')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Giỏ hàng trống — không có gì để thanh toán.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => context.goNamed(AppRouteNames.discover),
                child: const Text('Quay về Khám phá'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _busy ? null : _submit,
            icon: _busy
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.lock_outline),
            label: Text(_busy
                ? 'Đang xử lý...'
                : 'Xác nhận & thanh toán ${formatVnd(total)}'),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ----- Order summary -----
          _SectionTitle('Tóm tắt đơn hàng'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  for (final c in items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${c.title}  ×${c.quantity}',
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(formatVnd(c.subtotal),
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      const Text('Tổng',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const Spacer(),
                      Text(
                        formatVnd(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ----- Auth gate notice -----
          if (user == null || user.isAnonymous)
            Card(
              color: theme.colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Cần tài khoản email'),
                subtitle: const Text(
                    'Bạn cần đăng nhập bằng email để nhận xác nhận đơn hàng.'),
                trailing: TextButton(
                  onPressed: () => context.go('/auth?next=/checkout'),
                  child: const Text('Đăng nhập'),
                ),
              ),
            ),
          if (user == null || user.isAnonymous) const SizedBox(height: 16),
          // ----- Customer info -----
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Thông tin liên hệ'),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Họ tên', prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Vui lòng nhập họ tên' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại', prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.length < 8) return 'Số điện thoại không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email', prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (!t.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _note,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Ghi chú (tuỳ chọn)',
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ----- Payment methods -----
          _SectionTitle('Phương thức thanh toán'),
          for (final m in PaymentMethod.values)
            _MethodTile(
              method: m,
              selected: _method == m,
              onTap: () => setState(() => _method = m),
            ),
          const SizedBox(height: 12),
          Text(
            'Mọi giao dịch được mã hoá. Đây là môi trường demo — không có khoản tiền thật nào bị trừ.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({required this.method, required this.selected, required this.onTap});
  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: selected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(method.icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(method.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(method.description, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

