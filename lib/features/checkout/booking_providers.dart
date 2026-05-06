/// Booking model + repository ghi `bookings/{autoId}` trên Firestore.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/firebase/firebase_providers.dart';
import '../auth/auth_providers.dart';
import '../cart/cart_providers.dart';
import 'payment_service.dart';

class BookingItem {
  BookingItem({
    required this.tourId,
    required this.title,
    required this.priceVnd,
    required this.quantity,
    this.departureDate,
  });

  final String tourId;
  final String title;
  final int priceVnd;
  final int quantity;
  final DateTime? departureDate;

  Map<String, dynamic> toMap() => {
        'tourId': tourId,
        'title': title,
        'priceVnd': priceVnd,
        'quantity': quantity,
        'departureDate': departureDate?.toIso8601String(),
      };

  factory BookingItem.fromCartItem(CartItem c) => BookingItem(
        tourId: c.tourId,
        title: c.title,
        priceVnd: c.priceVnd,
        quantity: c.quantity,
        departureDate: c.departureDate,
      );

  factory BookingItem.fromMap(Map<String, dynamic> m) => BookingItem(
        tourId: m['tourId'] as String,
        title: m['title'] as String,
        priceVnd: (m['priceVnd'] ?? 0) as int,
        quantity: (m['quantity'] ?? 1) as int,
        departureDate: m['departureDate'] != null
            ? DateTime.tryParse(m['departureDate'] as String)
            : null,
      );
}

class BookingModel {
  BookingModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.customerName,
    required this.customerPhone,
    required this.note,
    required this.items,
    required this.totalVnd,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String userEmail;
  final String customerName;
  final String customerPhone;
  final String note;
  final List<BookingItem> items;
  final int totalVnd;
  final String paymentMethod;
  final String transactionId;
  final String status; // pending | paid | cancelled | failed
  final DateTime createdAt;

  factory BookingModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final ts = m['createdAt'];
    return BookingModel(
      id: d.id,
      userId: (m['userId'] ?? '') as String,
      userEmail: (m['userEmail'] ?? '') as String,
      customerName: (m['customerName'] ?? '') as String,
      customerPhone: (m['customerPhone'] ?? '') as String,
      note: (m['note'] ?? '') as String,
      items: ((m['items'] as List?) ?? const [])
          .map((e) => BookingItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      totalVnd: (m['totalVnd'] ?? 0) as int,
      paymentMethod: (m['paymentMethod'] ?? 'cod') as String,
      transactionId: (m['transactionId'] ?? '') as String,
      status: (m['status'] ?? 'pending') as String,
      createdAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }
}

class BookingRepository {
  BookingRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col => _db.collection('bookings');

  /// Trả về docId của booking vừa tạo.
  Future<String> create({
    required String userId,
    required String userEmail,
    required String customerName,
    required String customerPhone,
    required String note,
    required List<BookingItem> items,
    required int totalVnd,
    required PaymentMethod method,
    required PaymentResult payment,
  }) async {
    final doc = await _col.add({
      'userId': userId,
      'userEmail': userEmail,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'note': note,
      'items': items.map((e) => e.toMap()).toList(),
      'totalVnd': totalVnd,
      'paymentMethod': method.name,
      'transactionId': payment.transactionId,
      'status': payment.success
          ? (method == PaymentMethod.cod || method == PaymentMethod.bankTransfer
              ? 'pending'
              : 'paid')
          : 'failed',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Stream<List<BookingModel>> watchByUser(String userId) {
    return _col
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(BookingModel.fromDoc).toList());
  }

  Future<BookingModel?> getById(String bookingId) async {
    final d = await _col.doc(bookingId).get();
    if (!d.exists) return null;
    return BookingModel.fromDoc(d);
  }
}

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(firestoreProvider));
});

final myBookingsProvider = StreamProvider<List<BookingModel>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const []);
  return ref.watch(bookingRepositoryProvider).watchByUser(user.uid);
});

final bookingDetailProvider =
    FutureProvider.family<BookingModel?, String>((ref, id) {
  return ref.watch(bookingRepositoryProvider).getById(id);
});

