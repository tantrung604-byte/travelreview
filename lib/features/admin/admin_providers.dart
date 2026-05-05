import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/firebase/firebase_providers.dart';

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return false;

  // TODO: Implement actual admin check logic (e.g., custom claims or Firestore doc)
  // For now, we can use a whitelist of emails or a flag from environment
  const adminEmails = [
    'admin@travelreview.app',
    'tantr@travelreview.app',
    // Add more admin emails here
  ];

  return adminEmails.contains(user.email);
});

