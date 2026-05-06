/// Cart: lưu danh sách tour user định mua. Persist qua SharedPreferences.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  CartItem({
    required this.tourId,
    required this.title,
    required this.priceText,
    required this.priceVnd,
    required this.imageUrl,
    required this.quantity,
    required this.departureDate,
  });

  final String tourId;
  final String title;
  final String priceText;
  final int priceVnd;
  final String imageUrl;
  int quantity;
  DateTime? departureDate;

  int get subtotal => priceVnd * quantity;

  Map<String, dynamic> toJson() => {
        'tourId': tourId,
        'title': title,
        'priceText': priceText,
        'priceVnd': priceVnd,
        'imageUrl': imageUrl,
        'quantity': quantity,
        'departureDate': departureDate?.toIso8601String(),
      };

  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
        tourId: j['tourId'] as String,
        title: j['title'] as String,
        priceText: (j['priceText'] ?? '') as String,
        priceVnd: (j['priceVnd'] ?? 0) as int,
        imageUrl: (j['imageUrl'] ?? '') as String,
        quantity: (j['quantity'] ?? 1) as int,
        departureDate: j['departureDate'] != null
            ? DateTime.tryParse(j['departureDate'] as String)
            : null,
      );

  CartItem copyWith({int? quantity, DateTime? departureDate}) => CartItem(
        tourId: tourId,
        title: title,
        priceText: priceText,
        priceVnd: priceVnd,
        imageUrl: imageUrl,
        quantity: quantity ?? this.quantity,
        departureDate: departureDate ?? this.departureDate,
      );
}

/// Parse text giá kiểu "12,500,000đ" → 12500000.
int parseVndPrice(String? raw) {
  if (raw == null) return 0;
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return int.tryParse(digits) ?? 0;
}

const _prefsKey = 'cart_items_v1';

class CartController extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsKey);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    } catch (_) {/* ignore */}
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_prefsKey, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  void addOrIncrement(CartItem item) {
    final idx = state.indexWhere((c) => c.tourId == item.tourId);
    if (idx >= 0) {
      final updated = [...state];
      updated[idx] = updated[idx].copyWith(
        quantity: updated[idx].quantity + item.quantity,
      );
      state = updated;
    } else {
      state = [...state, item];
    }
    _save();
  }

  void setQuantity(String tourId, int qty) {
    if (qty <= 0) {
      remove(tourId);
      return;
    }
    state = [
      for (final c in state) c.tourId == tourId ? c.copyWith(quantity: qty) : c,
    ];
    _save();
  }

  void setDeparture(String tourId, DateTime date) {
    state = [
      for (final c in state)
        c.tourId == tourId ? c.copyWith(departureDate: date) : c,
    ];
    _save();
  }

  void remove(String tourId) {
    state = state.where((c) => c.tourId != tourId).toList();
    _save();
  }

  void clear() {
    state = const [];
    _save();
  }

  int get total => state.fold(0, (sum, c) => sum + c.subtotal);
  int get itemCount => state.fold(0, (sum, c) => sum + c.quantity);
}

final cartControllerProvider =
    NotifierProvider<CartController, List<CartItem>>(CartController.new);

final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (s, c) => s + c.quantity);
});

final cartTotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (s, c) => s + c.subtotal);
});

String formatVnd(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return '${buf.toString()}đ';
}

