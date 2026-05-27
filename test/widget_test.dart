import 'package:flutter_test/flutter_test.dart';

import 'package:fover/main.dart';

void main() {
  testWidgets('Home page basic render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoverApp());

    // Verify that the home page displays the expected text and app bar title.
    expect(find.text('Production Football App'), findsOneWidget);
    expect(find.text('Fover'), findsOneWidget);
  });
}
