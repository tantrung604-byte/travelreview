import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_providers.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isSaving = false;
  String? _errorMsg;
  String? _successMsg;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameCtrl = TextEditingController(text: user?.displayName ?? '');
    _phoneCtrl = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Tải số điện thoại từ Firestore (nếu có lưu)
  Future<void> _loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final phone = doc.data()?['phoneNumber'] as String? ?? '';
        if (mounted) {
          _phoneCtrl.text = phone;
        }
      }
    } catch (_) {
      // Silent fail
    }
  }

  /// Lưu profile (tên + số điện thoại)
  Future<void> _saveProfile() async {
    if (_nameCtrl.text.isEmpty && _phoneCtrl.text.isEmpty) {
      setState(() => _errorMsg = 'Vui lòng nhập tên hoặc số điện thoại');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMsg = null;
      _successMsg = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      // Cập nhật displayName trong Firebase Auth
      if (_nameCtrl.text.isNotEmpty) {
        await user.updateDisplayName(_nameCtrl.text.trim());
        await user.reload();
      }

      // Lưu vào Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'displayName': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));

      setState(() {
        _successMsg = 'Cập nhật thành công';
        _isSaving = false;
      });

      // Auto clear thông báo sau 3s
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _successMsg = null);
    } catch (e) {
      setState(() {
        _errorMsg = 'Lỗi: ${e.toString()}';
        _isSaving = false;
      });
    }
  }

  /// Xóa tài khoản ngay lập tức
  Future<void> _deleteAccount() async {
    final context = this.context;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⚠️ Xóa tài khoản'),
        content: const Text(
          'Hành động này không thể hoàn tác. Toàn bộ dữ liệu của bạn sẽ bị xóa vĩnh viễn',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      final uid = user.uid;

      // 1. Xóa document user từ Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // 2. Xóa tất cả review của user
      final reviews = await FirebaseFirestore.instance
          .collectionGroup('reviews')
          .where('userId', isEqualTo: uid)
          .get();

      for (final review in reviews.docs) {
        await review.reference.delete();
      }

      // 3. Xóa tất cả booking của user
      final bookings = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: uid)
          .get();

      for (final booking in bookings.docs) {
        await booking.reference.delete();
      }

      // 4. Xóa account từ Firebase Auth
      await user.delete();

      // 5. Đăng xuất và quay lại home
      if (context.mounted) {
        context.go('/');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tài khoản đã bị xóa')),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Mở link điều khoản/chính sách (lấy từ legal folder hoặc web)
  Future<void> _openLegalLink(String path) async {
    try {
      final uri = Uri.parse('https://travelreview.example.com/$path');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider).value;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_outlined, size: 80, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Bạn chưa đăng nhập'),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => context.go('/auth?next=/setting'),
                icon: const Icon(Icons.login),
                label: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    final initial = (user.displayName?.isNotEmpty == true ? user.displayName! : user.email ?? 'U')
        .characters
        .first
        .toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Profile Info ──────────────────────────────────────────────────
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'Người dùng',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'N/A',
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Profile Form ─────────────────────────────────────────────────
          _buildSectionTitle('👤 Thông tin cá nhân'),
          const SizedBox(height: 12),

          // Tên
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          // Số điện thoại
          TextField(
            controller: _phoneCtrl,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Thông báo
          if (_errorMsg != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Text(_errorMsg!, style: const TextStyle(color: Colors.red)),
            ),
          if (_successMsg != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
              ),
              child: Text(_successMsg!, style: const TextStyle(color: Colors.green)),
            ),
          const SizedBox(height: 16),

          // Nút lưu
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
            label: Text(_isSaving ? 'Đang lưu...' : 'Lưu thay đổi'),
          ),
          const SizedBox(height: 32),

          // ─── Legal & Policies ──────────────────────────────────────────────
          _buildSectionTitle('📋 Điều khoản & Chính sách'),
          const SizedBox(height: 12),

          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Điều khoản dịch vụ'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openLegalLink('terms'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Chính sách bảo mật'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openLegalLink('privacy'),
          ),
          const SizedBox(height: 32),

          // ─── Danger Zone ───────────────────────────────────────────────────
          _buildSectionTitle('⚠️ Vùng nguy hiểm'),
          const SizedBox(height: 12),

          FilledButton.icon(
            onPressed: _isSaving ? null : _deleteAccount,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Xóa tài khoản vĩnh viễn'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bạn sẽ không thể khôi phục dữ liệu sau khi xóa',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

