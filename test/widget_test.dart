// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travelreview_app/app/app.dart';

void main() {
  testWidgets('Home landing renders and routes to Discover', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TravelReviewApp()));
    await tester.pumpAndSettle();

    expect(find.text('TravelReview'), findsOneWidget);
    expect(find.text('Discover trips, tickets, and honest reviews.'), findsOneWidget);
    expect(find.text('Search'), findsWidgets);

    await tester.tap(find.text('Discover').first);
    await tester.pumpAndSettle();

    expect(find.text('Khám phá'), findsOneWidget);
  });
}
