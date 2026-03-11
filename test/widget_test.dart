// Basic smoke test for the Westo application.

import 'package:flutter_test/flutter_test.dart';

import 'package:westo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const WestoApp());

    // Verify the app renders without crashing.
    expect(tester.takeException(), isNull);
  });
}
