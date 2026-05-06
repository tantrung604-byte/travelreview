/// Auth providers: current user stream + sign in/up/out helpers.
/// Hỗ trợ: Email/Password (kèm xác thực email), Google Sign-In, Anonymous.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/firebase/firebase_providers.dart';
/// Stream user hiện tại (null = chưa đăng nhập).
final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// True nếu user đã đăng nhập (kể cả anonymous).
final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).maybeWhen(
        data: (u) => u != null,
        orElse: () => false,
      );
});

/// True nếu user đăng nhập bằng email/Google (không anonymous) — dùng cho thanh toán
/// để bắt buộc có email liên hệ.
final hasVerifiedIdentityProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).maybeWhen(
        data: (u) => u != null && !u.isAnonymous && (u.email?.isNotEmpty ?? false),
        orElse: () => false,
      );
});

/// True nếu email đã được xác thực HOẶC user đăng nhập qua Google.
final isEmailVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).maybeWhen(
        data: (u) => u != null && !u.isAnonymous && u.emailVerified,
        orElse: () => false,
      );
});

/// True nếu user đăng nhập bằng password nhưng email chưa xác thực.
final needsEmailVerificationProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider).maybeWhen(
        data: (u) {
          if (u == null || u.isAnonymous) return false;
          final providers = u.providerData.map((p) => p.providerId).toSet();
          if (!providers.contains('password')) return false;
          return !u.emailVerified;
        },
        orElse: () => false,
      );
});

class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  GoogleSignIn? _googleSignIn;
  GoogleSignIn get _google => _googleSignIn ??= GoogleSignIn(
        scopes: const ['email', 'profile'],
      );

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<UserCredential> registerWithEmail(
    String email,
    String password, {
    String? displayName,
    bool sendVerification = true,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await cred.user?.updateDisplayName(displayName.trim());
      await cred.user?.reload();
    }
    if (sendVerification) {
      try {
        await cred.user?.sendEmailVerification();
      } catch (_) {/* không chặn flow đăng ký */}
    }
    return cred;
  }

  /// Gửi (lại) email xác thực cho user hiện tại.
  Future<void> sendEmailVerification() async {
    final u = _auth.currentUser;
    if (u == null) {
      throw FirebaseAuthException(code: 'no-user', message: 'Chưa đăng nhập');
    }
    if (u.emailVerified) return;
    await u.sendEmailVerification();
  }

  /// Reload user để cập nhật `emailVerified` sau khi click link trong mail.
  Future<bool> reloadAndCheckVerified() async {
    final u = _auth.currentUser;
    if (u == null) return false;
    await u.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Đăng nhập bằng Google (Web: popup; Mobile/Desktop: google_sign_in).
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile')
        ..setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }
    final account = await _google.signIn();
    if (account == null) {
      throw FirebaseAuthException(
        code: 'google-cancelled',
        message: 'Bạn đã hủy đăng nhập Google',
      );
    }
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();


  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        if (await _google.isSignedIn()) {
          await _google.signOut();
        }
      } catch (_) {/* ignore */}
    }
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(firebaseAuthProvider));
});

