import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_providers.dart';

/// Màn hình đăng nhập / đăng ký dùng email-password + Google + ẩn danh.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key, this.redirect});
  final String? redirect;

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();
  bool _isRegister = false;
  bool _busy = false;
  String? _error;
  String? _info; // thông báo thành công (vd: đã gửi mail xác thực)

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      final svc = ref.read(authServiceProvider);
      if (_isRegister) {
        await svc.registerWithEmail(
          _email.text,
          _password.text,
          displayName: _displayName.text,
        );
        if (!mounted) return;
        // Sau khi đăng ký: hiện màn hình "kiểm tra email"
        setState(() {
          _info =
              'Đã gửi email xác thực tới ${_email.text.trim()}. Vui lòng mở mail và bấm vào liên kết để kích hoạt tài khoản.';
        });
        return;
      } else {
        await svc.signInWithEmail(_email.text, _password.text);
      }
      if (!mounted) return;
      _goNext();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      _goNext();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'google-cancelled') {
        // user huỷ — không hiện lỗi đỏ
      } else {
        setState(() => _error = _friendlyError(e));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInAnon() async {
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authServiceProvider).signInAnonymously();
      if (!mounted) return;
      _goNext();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authServiceProvider).sendEmailVerification();
      if (!mounted) return;
      setState(() => _info = 'Đã gửi lại email xác thực.');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Nhập email hợp lệ rồi bấm "Quên mật khẩu" lại.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await ref.read(authServiceProvider).sendPasswordReset(email);
      if (!mounted) return;
      setState(() => _info = 'Đã gửi email đặt lại mật khẩu tới $email.');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hoá.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email đã được đăng ký. Hãy đăng nhập hoặc dùng "Quên mật khẩu".';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật trong Firebase Console.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Bạn đã đóng cửa sổ Google.';
      default:
        return e.message ?? e.code;
    }
  }

  void _goNext() {
    final next = widget.redirect;
    if (next != null && next.isNotEmpty && next != '/auth') {
      context.go(next);
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Tạo tài khoản' : 'Đăng nhập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.travel_explore, size: 64, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    _isRegister
                        ? 'Tạo tài khoản để đặt tour & bình luận'
                        : 'Đăng nhập để mua tour và viết review',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),

                  // ---- Google Sign-in (đặt trên cùng cho dễ thấy) ----
                  _GoogleButton(onPressed: _busy ? null : _signInGoogle),
                  const SizedBox(height: 12),
                  Row(children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('hoặc', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 12),

                  if (_isRegister) ...[
                    TextFormField(
                      controller: _displayName,
                      decoration: const InputDecoration(
                        labelText: 'Họ tên',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return 'Vui lòng nhập email';
                      if (!t.contains('@')) return 'Email không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) {
                      if ((v ?? '').length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),

                  if (!_isRegister)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy ? null : _forgotPassword,
                        child: const Text('Quên mật khẩu?'),
                      ),
                    ),

                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_error!,
                          style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                    ),
                  ],

                  if (_info != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.mark_email_read_outlined,
                              color: Colors.green, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(_info!,
                                style: const TextStyle(color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                    if (_isRegister) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _busy ? null : _resendVerification,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Gửi lại email'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _busy ? null : _goNext,
                              icon: const Icon(Icons.check),
                              label: const Text('Tôi đã xác thực'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: _busy
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(_isRegister ? Icons.person_add : Icons.login),
                    label: Text(_isRegister ? 'Đăng ký' : 'Đăng nhập'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _isRegister = !_isRegister;
                              _error = null;
                              _info = null;
                            }),
                    child: Text(_isRegister
                        ? 'Đã có tài khoản? Đăng nhập'
                        : 'Chưa có tài khoản? Đăng ký'),
                  ),
                  const Divider(height: 32),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _signInAnon,
                    icon: const Icon(Icons.person_outline),
                    label: const Text('Tiếp tục với khách (ẩn danh)'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tài khoản khách có thể duyệt và thêm vào giỏ, nhưng cần nâng cấp lên tài khoản email khi thanh toán.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nút "Sign in with Google" theo guideline brand (icon G màu + nền trắng).
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.grey.shade400),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const _GoogleLogo(size: 20),
        label: const Text(
          'Tiếp tục với Google',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

/// Logo "G" 4 màu vẽ bằng Container (không cần asset).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    // Dùng ký tự "G" với gradient — nhẹ và không cần thêm asset.
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: ShaderMask(
        shaderCallback: (rect) => const LinearGradient(
          colors: [
            Color(0xFF4285F4), // blue
            Color(0xFF34A853), // green
            Color(0xFFFBBC05), // yellow
            Color(0xFFEA4335), // red
          ],
        ).createShader(rect),
        child: Text(
          'G',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
      ),
    );
  }
}
