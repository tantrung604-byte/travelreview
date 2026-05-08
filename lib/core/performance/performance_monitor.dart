import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// Performance monitoring & analytics helper
/// Note: Uses Firebase Analytics for event tracking
/// Firebase Performance Monitoring for tracing (auto-collected)
class PerformanceMonitor {
  static final instance = PerformanceMonitor._();

  late final FirebaseAnalytics _analytics;

  PerformanceMonitor._();

  Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _analytics.setAnalyticsCollectionEnabled(true);
  }

  /// Track screen view
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  /// Track custom event
  Future<void> logEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  /// Manual timing trace via debug print
  /// In production, Firebase tracks these automatically
  void startSystemTrace(String label) {
    PerformanceTracker.start(label);
  }

  void endSystemTrace(String label) {
    PerformanceTracker.end(label);
  }

  /// Log error/crash
  Future<void> logError(String message, Object error, StackTrace stack) async {
    await _analytics.logEvent(
      name: 'error',
      parameters: {
        'message': message,
        'error': error.toString(),
        'stack_trace': stack.toString().substring(0, 100), // Limit length
      },
    );
  }

  /// Log tour interaction
  Future<void> logTourView(String tourId, String tourTitle) async {
    await _analytics.logEvent(
      name: 'tour_view',
      parameters: {
        'tour_id': tourId,
        'tour_title': tourTitle,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log search action
  Future<void> logSearch(String query, int resultCount) async {
    await _analytics.logEvent(
      name: 'search',
      parameters: {
        'search_term': query,
        'result_count': resultCount,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
  }

  /// Log filter action
  Future<void> logFilter(String filterType, String filterValue) async {
    await _analytics.logEvent(
      name: 'filter_applied',
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
      },
    );
  }

  /// Log add to cart
  Future<void> logAddToCart(String tourId, double price) async {
    await _analytics.logAddToCart(
      items: [
        AnalyticsEventItem(itemId: tourId, itemName: tourId, price: price),
      ],
    );
  }

  /// Log purchase
  Future<void> logPurchase(
    String transactionId,
    double value,
  ) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: 'VND',
    );
  }
}

/// Widget performance tracker (for debugging)
class PerformanceTracker {
  static final Map<String, Stopwatch> _stopwatches = {};

  static void start(String label) {
    _stopwatches[label] = Stopwatch()..start();
  }

  static void end(String label) {
    final stopwatch = _stopwatches[label];
    if (stopwatch != null) {
      stopwatch.stop();
      if (kDebugMode) {
        print('⏱️ $label: ${stopwatch.elapsedMilliseconds}ms');
      }
      _stopwatches.remove(label);
    }
  }

  static Duration? getDuration(String label) {
    return _stopwatches[label]?.elapsed;
  }
}

