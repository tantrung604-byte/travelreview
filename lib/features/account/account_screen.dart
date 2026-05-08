import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../auth/auth_providers.dart';
import '../cart/cart_providers.dart';
import '../checkout/booking_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;
    final bookingsAsync = ref.watch(myBookingsProvider);
    final needsVerify = ref.watch(needsEmailVerificationProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Bạn chưa đăng nhập'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/auth?next=/account'),
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập / Đăng ký'),
              ),
            ],
          ),
        ),
      );
    }

    final initial = (user.displayName?.isNotEmpty == true
            ? user.displayName!
            : user.email ?? 'U')
        .characters
        .first
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go('/setting'),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(initial,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        )),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName?.isNotEmpty == true
                              ? user.displayName!
                              : (user.isAnonymous ? 'Khách ẩn danh' : (user.email ?? '—')),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                        if (user.email != null) Text(user.email!),
                        if (user.isAnonymous)
                          Text('Tài khoản ẩn danh',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange))
                        else if (user.emailVerified)
                          Row(children: [
                            const Icon(Icons.verified, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('Đã xác thực',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: Colors.green, fontWeight: FontWeight.w700)),
                          ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (needsVerify) ...[
            _VerifyEmailBanner(email: user.email ?? ''),
            const SizedBox(height: 16),
          ],
          Text('Lịch sử đặt tour',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          bookingsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Lỗi tải đơn: $e'),
            data: (list) {
              if (list.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        const Text('Bạn chưa có đơn hàng nào'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () => context.goNamed(AppRouteNames.discover),
                          child: const Text('Khám phá tour'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  for (final b in list)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(b.status, theme),
                          child: Icon(
                            b.status == 'paid'
                                ? Icons.check
                                : b.status == 'failed'
                                    ? Icons.close
                                    : Icons.schedule,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          b.items.isNotEmpty ? b.items.first.title : 'Đơn ${b.id}',
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          '${b.items.length} mục · ${b.paymentMethod.toUpperCase()} · ${b.status}',
                        ),
                        trailing: Text(formatVnd(b.totalVnd),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.primary,
                            )),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(String s, ThemeData t) {
    switch (s) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return t.colorScheme.error;
      default:
        return Colors.orange;
    }
  }
}

/// Banner nhắc xác thực email (hiện ở Account khi user đăng nhập password
/// nhưng chưa click link xác thực).
class _VerifyEmailBanner extends ConsumerStatefulWidget {
  const _VerifyEmailBanner({required this.email});
  final String email;

  @override
  ConsumerState<_VerifyEmailBanner> createState() => _VerifyEmailBannerState();
}

class _VerifyEmailBannerState extends ConsumerState<_VerifyEmailBanner> {
  bool _busy = false;
  String? _msg;

  Future<void> _resend() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (mounted) setState(() => _msg = 'Đã gửi lại email xác thực.');
    } catch (e) {
      if (mounted) setState(() => _msg = 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _check() async {
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      final ok = await ref.read(authServiceProvider).reloadAndCheckVerified();
      if (!mounted) return;
      setState(() => _msg = ok
          ? 'Email đã được xác thực 🎉'
          : 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.orange.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mark_email_unread_outlined,
                    color: Colors.orange.shade800),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Email chưa được xác thực',
                      style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Chúng tôi đã gửi liên kết xác thực tới ${widget.email}. '
              'Hãy mở email và bấm vào liên kết để mở khoá đầy đủ tính năng.',
              style: const TextStyle(fontSize: 13),
            ),
            if (_msg != null) ...[
              const SizedBox(height: 8),
              Text(_msg!, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _resend,
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: const Text('Gửi lại'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _check,
                    icon: _busy
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh, size: 18),
                    label: const Text('Tôi đã xác thực'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

