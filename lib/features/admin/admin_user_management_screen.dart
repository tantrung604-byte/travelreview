import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_providers.dart';

/// Admin User Management Screen
/// Quản lý user: xem IP/device, khóa tài khoản, cấm review, xóa review.
class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() =>
      _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState
    extends ConsumerState<AdminUserManagementScreen> {
  String _search = '';
  UserStatus? _filterStatus; // null = tất cả

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usersAsync = ref.watch(adminUsersStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              Text('👥 Quản Lý Người Dùng',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900)),
              const Spacer(),
              usersAsync.whenOrNull(
                data: (users) => _StatRow(users: users),
              ) ??
                  const SizedBox(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Search + Filter ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Tìm theo email, tên, IP...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (v) => setState(() => _search = v.toLowerCase()),
                ),
              ),
              const SizedBox(width: 12),
              _FilterChips(
                selected: _filterStatus,
                onSelect: (s) => setState(() => _filterStatus = s),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),

        // ── User list ───────────────────────────────────────────────────
        Expanded(
          child: usersAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Lỗi tải dữ liệu: $e'),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () =>
                        ref.invalidate(adminUsersStreamProvider),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
            data: (users) {
              // Filter
              var filtered = users.where((u) {
                final q = _search;
                final matchSearch = q.isEmpty ||
                    u.email.toLowerCase().contains(q) ||
                    u.displayName.toLowerCase().contains(q) ||
                    u.lastIp.contains(q) ||
                    u.uid.contains(q);
                final matchStatus =
                    _filterStatus == null || u.status == _filterStatus;
                return matchSearch && matchStatus;
              }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_search,
                          size: 56,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
                      const SizedBox(height: 12),
                      Text(
                        _search.isNotEmpty
                            ? 'Không tìm thấy người dùng nào'
                            : 'Chưa có người dùng nào trong hệ thống',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
                itemCount: filtered.length,
                separatorBuilder: (_, __)  => const SizedBox(height: 8),
                itemBuilder: (ctx, i) => _UserCard(
                  user: filtered[i],
                  onStatusChanged: () =>
                      ref.invalidate(adminUsersStreamProvider),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Stat summary ──────────────────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  const _StatRow({required this.users});
  final List<AdminUserModel> users;

  @override
  Widget build(BuildContext context) {
    final active = users.where((u) => u.status == UserStatus.active).length;
    final banned = users.where((u) => u.status == UserStatus.banned).length;
    final reviewBanned =
        users.where((u) => u.status == UserStatus.reviewBanned).length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stat(label: 'Tổng', value: '${users.length}', color: Colors.blueGrey),
        const SizedBox(width: 10),
        _Stat(label: 'Active', value: '$active', color: Colors.green),
        const SizedBox(width: 10),
        _Stat(label: 'Bị khóa', value: '$banned', color: Colors.red),
        const SizedBox(width: 10),
        _Stat(label: 'Cấm review', value: '$reviewBanned', color: Colors.orange),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 16)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Filter chips ──────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelect});
  final UserStatus? selected;
  final ValueChanged<UserStatus?> onSelect;

  @override
  Widget build(BuildContext context) {
    final items = <(UserStatus?, String, Color)>[
      (null, 'Tất cả', Colors.blueGrey),
      (UserStatus.active, '🟢 Active', Colors.green),
      (UserStatus.banned, '🔴 Bị khóa', Colors.red),
      (UserStatus.reviewBanned, '📝 Cấm review', Colors.orange),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 6),
              child: ChoiceChip(
                label: Text(item.$2, style: const TextStyle(fontSize: 12)),
                selected: selected == item.$1,
                selectedColor: item.$3.withValues(alpha: 0.2),
                side: BorderSide(
                    color: selected == item.$1
                        ? item.$3
                        : Colors.grey.withValues(alpha: 0.3)),
                onSelected: (_) => onSelect(item.$1),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─── User Card ─────────────────────────────────────────────────────────────────
class _UserCard extends ConsumerStatefulWidget {
  const _UserCard({required this.user, required this.onStatusChanged});
  final AdminUserModel user;
  final VoidCallback onStatusChanged;

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard> {
  bool _expanded = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (user.status) {
      case UserStatus.banned:
        statusColor = Colors.red;
        statusLabel = '🔴 Bị khóa';
        statusIcon = Icons.lock_outline;
        break;
      case UserStatus.reviewBanned:
        statusColor = Colors.orange;
        statusLabel = '📝 Cấm review';
        statusIcon = Icons.rate_review_outlined;
        break;
      case UserStatus.active:
        statusColor = Colors.green;
        statusLabel = '🟢 Active';
        statusIcon = Icons.check_circle_outline;
        break;
    }

    final initial = user.displayName.isNotEmpty
        ? user.displayName.characters.first.toUpperCase()
        : user.email.isNotEmpty
            ? user.email.characters.first.toUpperCase()
            : '?';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: user.status == UserStatus.banned
              ? Colors.red.withValues(alpha: 0.3)
              : user.status == UserStatus.reviewBanned
                  ? Colors.orange.withValues(alpha: 0.3)
                  : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: avatar + info + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary,
                  backgroundImage: user.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user.photoUrl.isEmpty
                      ? Text(initial,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: theme.colorScheme.onPrimary))
                      : null,
                ),
                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + status badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName
                                  : '(Chưa đặt tên)',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 15),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon,
                                    size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(statusLabel,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: statusColor,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Email
                      Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 13,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.5)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              user.email.isNotEmpty
                                  ? user.email
                                  : '(Ẩn danh)',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.75)),
                            ),
                          ),
                          // Copy UID button
                          Tooltip(
                            message: 'UID: ${user.uid}',
                            child: InkWell(
                              onTap: () =>
                                  Clipboard.setData(ClipboardData(text: user.uid))
                                      .then((_) => ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                        content: Text('Đã copy UID'),
                                        duration: Duration(seconds: 1),
                                      ))),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'UID: ${user.uid.substring(0, 8)}...',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // IP + Device
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _InfoChip(
                            icon: Icons.router_outlined,
                            label: user.lastIp.isNotEmpty
                                ? 'IP: ${user.lastIp}'
                                : 'IP: Chưa ghi nhận',
                            copyValue: user.lastIp,
                          ),
                          _InfoChip(
                            icon: Icons.devices_outlined,
                            label: user.deviceSummary,
                          ),
                          if (user.lastLoginAt != null)
                            _InfoChip(
                              icon: Icons.access_time_outlined,
                              label:
                                  'Login: ${_relativeDate(user.lastLoginAt!)}',
                            ),
                          _InfoChip(
                            icon: Icons.rate_review_outlined,
                            label: '${user.reviewCount} reviews',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Ban reason (if banned) ───────────────────────────────────
            if (user.status != UserStatus.active && user.banReason != null &&
                user.banReason!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: Colors.red.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Lý do: ${user.banReason}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Full UA (expandable) ─────────────────────────────────────
            if (user.userAgent.isNotEmpty) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 13,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _expanded
                              ? user.userAgent
                              : 'User-Agent: ${user.userAgent.length > 60 ? "${user.userAgent.substring(0, 60)}..." : user.userAgent}',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // ── Action buttons ───────────────────────────────────────────
            if (_loading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Khóa / Mở khóa tài khoản
                  if (user.status == UserStatus.banned)
                    _ActionBtn(
                      icon: Icons.lock_open_outlined,
                      label: 'Mở khóa TK',
                      color: Colors.green,
                      onPressed: () => _updateStatus(UserStatus.active),
                    )
                  else
                    _ActionBtn(
                      icon: Icons.lock_outline,
                      label: 'Khóa TK',
                      color: Colors.red,
                      onPressed: () => _showBanDialog(),
                    ),

                  // Cấm / Bỏ cấm review
                  if (user.status == UserStatus.reviewBanned)
                    _ActionBtn(
                      icon: Icons.rate_review_outlined,
                      label: 'Bỏ cấm review',
                      color: Colors.green,
                      onPressed: () => _updateStatus(UserStatus.active),
                    )
                  else if (user.status != UserStatus.banned)
                    _ActionBtn(
                      icon: Icons.no_accounts_outlined,
                      label: 'Cấm review',
                      color: Colors.orange,
                      onPressed: () =>
                          _showReviewBanDialog(),
                    ),

                  // Xóa tất cả review
                  _ActionBtn(
                    icon: Icons.delete_sweep_outlined,
                    label: 'Xóa tất cả review',
                    color: Colors.deepOrange,
                    onPressed: () => _showDeleteReviewsDialog(),
                  ),

                  // Xem chi tiết UA
                  _ActionBtn(
                    icon: Icons.info_outline,
                    label: 'Chi tiết thiết bị',
                    color: Colors.blueGrey,
                    onPressed: () => _showDeviceDetailDialog(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(UserStatus status, {String? reason}) async {
    setState(() => _loading = true);
    try {
      await ref
          .read(userRepositoryProvider)
          .updateStatus(widget.user.uid, status, reason: reason);
      widget.onStatusChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(status == UserStatus.active
                ? '✅ Đã mở khóa tài khoản'
                : status == UserStatus.banned
                    ? '🔒 Đã khóa tài khoản'
                    : '📝 Đã cấm review'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showBanDialog() {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Khóa tài khoản'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khóa TK của: ${widget.user.displayName.isNotEmpty ? widget.user.displayName : widget.user.email}'),
            const SizedBox(height: 8),
            const Text('User sẽ không thể đăng nhập và sử dụng app.'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Lý do khóa (tùy chọn)',
                hintText: 'Vd: Vi phạm điều khoản sử dụng...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(UserStatus.banned,
                  reason: reasonCtrl.text.trim());
            },
            child: const Text('Xác nhận khóa'),
          ),
        ],
      ),
    );
  }

  void _showReviewBanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.no_accounts_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Cấm viết review'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cấm review của: ${widget.user.displayName.isNotEmpty ? widget.user.displayName : widget.user.email}'),
            const SizedBox(height: 8),
            const Text(
                'User vẫn có thể xem tour và mua tour, nhưng không thể viết review mới.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(UserStatus.reviewBanned);
            },
            child: const Text('Xác nhận cấm review'),
          ),
        ],
      ),
    );
  }

  void _showDeleteReviewsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_sweep_outlined, color: Colors.deepOrange),
            SizedBox(width: 8),
            Text('Xóa tất cả review'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Xóa tất cả review của: ${widget.user.displayName.isNotEmpty ? widget.user.displayName : widget.user.email}'),
            const SizedBox(height: 8),
            const Text(
                '⚠️ Hành động này không thể hoàn tác!\nTất cả review của user sẽ bị xóa vĩnh viễn.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy')),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                final count = await ref
                    .read(userRepositoryProvider)
                    .deleteAllReviewsOfUser(widget.user.uid);
                widget.onStatusChanged();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('🗑️ Đã xóa $count review của user')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }

  void _showDeviceDetailDialog() {
    final user = widget.user;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.devices_outlined, color: Colors.blueGrey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Thông tin thiết bị – ${user.displayName.isNotEmpty ? user.displayName : user.email}',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'UID', value: user.uid),
              _DetailRow(label: 'Email', value: user.email),
              _DetailRow(label: 'Tên hiển thị', value: user.displayName),
              _DetailRow(
                  label: 'Trạng thái',
                  value: user.status == UserStatus.active
                      ? '🟢 Active'
                      : user.status == UserStatus.banned
                          ? '🔴 Bị khóa'
                          : '📝 Cấm review'),
              const Divider(height: 16),
              _DetailRow(
                  label: 'IP cuối',
                  value: user.lastIp.isNotEmpty ? user.lastIp : '—'),
              _DetailRow(
                  label: 'Platform',
                  value:
                      user.platform.isNotEmpty ? user.platform : '—'),
              _DetailRow(
                  label: 'Thiết bị',
                  value: user.deviceSummary),
              const Divider(height: 16),
              _DetailRow(
                label: 'User-Agent',
                value: user.userAgent.isNotEmpty ? user.userAgent : '—',
                mono: true,
              ),
              const Divider(height: 16),
              _DetailRow(
                  label: 'Ngày đăng ký',
                  value: user.createdAt != null
                      ? '${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                      : '—'),
              _DetailRow(
                  label: 'Đăng nhập lần cuối',
                  value: user.lastLoginAt != null
                      ? _fullDate(user.lastLoginAt!)
                      : '—'),
              _DetailRow(
                  label: 'Số review', value: '${user.reviewCount}'),
              if (user.banReason != null && user.banReason!.isNotEmpty)
                _DetailRow(label: 'Lý do khóa', value: user.banReason!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(
                    ClipboardData(text: user.uid))
                .then((_) => ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                        content: Text('Đã copy UID'),
                        duration: Duration(seconds: 1)))),
            child: const Text('Copy UID'),
          ),
          FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng')),
        ],
      ),
    );
  }

  static String _relativeDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inHours < 1) return '${diff.inMinutes}p trước';
    if (diff.inDays < 1) return '${diff.inHours}h trước';
    if (diff.inDays < 30) return '${diff.inDays}d trước';
    return '${d.day}/${d.month}/${d.year}';
  }

  static String _fullDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

// ─── Helper widgets ────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.copyValue});
  final IconData icon;
  final String label;
  final String? copyValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 12,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7))),
        ],
      ),
    );

    if (copyValue != null && copyValue!.isNotEmpty) {
      chip = Tooltip(
        message: 'Click để copy: $copyValue',
        child: InkWell(
          onTap: () => Clipboard.setData(ClipboardData(text: copyValue!))
              .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Đã copy!'),
                        duration: Duration(seconds: 1)),
                  )),
          child: chip,
        ),
      );
    }

    return chip;
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(
      {required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                  fontSize: 12,
                  fontFamily: mono ? 'monospace' : null,
                  color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

