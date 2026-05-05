/// Wrapper truy cập FirebaseAuth, Firestore, Storage thông qua Riverpod.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  try {
    return FirebaseFirestore.instance;
  } catch (e) {
    // Trả về một instance dummy hoặc ném lỗi có kiểm soát để tránh crash toàn bộ provider
    throw UnimplementedError('Firebase not initialized');
  }
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  try {
    return FirebaseStorage.instance;
  } catch (e) {
    throw UnimplementedError('Firebase not initialized');
  }
});

/// Stream trạng thái đăng nhập của user (null = chưa login).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

