import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sample counter Notifier dùng Riverpod 3.x API.
class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
  void reset() => state = 0;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

