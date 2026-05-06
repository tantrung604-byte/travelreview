/// UserSessionRecorder – tự động ghi IP + device info vào Firestore khi login.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/device_info/session_info.dart';
import '../core/firebase/firebase_providers.dart';
import '../features/auth/auth_providers.dart';

/// Watch provider này 1 lần ở root widget.
final userSessionRecorderProvider = Provider<void>((ref) {
  ref.watch(currentUserProvider).whenData((user) async {
    if (user == null || user.isAnonymous) return;
    try {
      final info = await getSessionInfo();
      final db = ref.read(firestoreProvider);
      final col = db.collection('users');

      await col.doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'lastIp': info['ip'] ?? '',
        'userAgent': info['userAgent'] ?? '',
        'platform': info['platform'] ?? 'web',
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Init mặc định nếu là user mới
      final doc = await col.doc(user.uid).get();
      if ((doc.data() ?? {})['createdAt'] == null) {
        await col.doc(user.uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'active',
          'reviewCount': 0,
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  });
});

