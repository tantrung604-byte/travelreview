import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
// import 'firebase_options.dart'; // Uncomment sau khi chạy `flutterfire configure`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase. Nếu chưa cấu hình firebase_options.dart,
  // hãy chạy `flutterfire configure` trước khi build.
  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped (chưa cấu hình firebase_options.dart): $e');
  }

  runApp(
    const ProviderScope(
      child: TravelReviewApp(),
    ),
  );
}
