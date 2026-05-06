/// Reviews lưu vào Firestore: `tours/{tourId}/reviews/{autoId}`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_providers.dart';
import '../admin/admin_providers.dart';
import '../auth/auth_providers.dart';

class ReviewModel {
  ReviewModel({
    required this.id,
    required this.tourId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String tourId;
  final String userId;
  final String userName;
  final int rating;
  final String content;
  final DateTime createdAt;

  factory ReviewModel.fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d, String tourId) {
    final m = d.data();
    final ts = m['createdAt'];
    return ReviewModel(
      id: d.id,
      tourId: tourId,
      userId: (m['userId'] ?? '') as String,
      userName: (m['userName'] ?? 'Ẩn danh') as String,
      rating: (m['rating'] ?? 5) as int,
      content: (m['content'] ?? '') as String,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

class ReviewRepository {
  ReviewRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _col(String tourId) =>
      _db.collection('tours').doc(tourId).collection('reviews');

  Stream<List<ReviewModel>> watch(String tourId) {
    return _col(tourId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ReviewModel.fromDoc(d, tourId)).toList());
  }

  Future<void> add({
    required String tourId,
    required String userId,
    required String userName,
    required int rating,
    required String content,
  }) async {
    await _col(tourId).add({
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String tourId, String reviewId) =>
      _col(tourId).doc(reviewId).delete();
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(firestoreProvider));
});

final tourReviewsStreamProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, tourId) {
  return ref.watch(reviewRepositoryProvider).watch(tourId);
});

/// Helper: gửi review nếu user đã đăng nhập và KHÔNG bị cấm review.
final submitReviewProvider = Provider((ref) {
  return ({
    required String tourId,
    required int rating,
    required String content,
  }) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) {
      throw StateError('Bạn cần đăng nhập để viết review.');
    }

    // ── Kiểm tra trạng thái ban ─────────────────────────────────────────
    final userStatus =
        await ref.read(userRepositoryProvider).getUserStatus(user.uid);
    if (userStatus == UserStatus.banned) {
      throw StateError(
          'Tài khoản của bạn đã bị khóa. Vui lòng liên hệ admin.');
    }
    if (userStatus == UserStatus.reviewBanned) {
      throw StateError(
          'Tài khoản của bạn đã bị hạn chế viết review. Vui lòng liên hệ admin.');
    }

    final name = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!.trim()
        : (user.email?.split('@').first ?? 'Khách');
    await ref.read(reviewRepositoryProvider).add(
          tourId: tourId,
          userId: user.uid,
          userName: name,
          rating: rating,
          content: content,
        );

    // Tăng reviewCount trong user doc
    try {
      ref
          .read(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .set({'reviewCount': FieldValue.increment(1)}, SetOptions(merge: true));
    } catch (_) {}
  };
});

