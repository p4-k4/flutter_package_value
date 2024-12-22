import 'package:flutter_test/flutter_test.dart';
import 'package:example/main.dart';

void main() {
  testWidgets('Counter app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Verify that our counter starts at 0
    expect(find.text('0'), findsOneWidget);

    // Tap the increase button and trigger a frame
    await tester.tap(find.text('Increase'));
    await tester.pump();

    // Verify that our counter has incremented
    expect(find.text('1'), findsOneWidget);

    // Tap the decrease button and trigger a frame
    await tester.tap(find.text('Decrease'));
    await tester.pump();

    // Verify that our counter is back to 0
    expect(find.text('0'), findsOneWidget);

    // Tap the reset button and trigger a frame
    await tester.tap(find.text('Reset'));
    await tester.pump();

    // Verify that our counter is still 0
    expect(find.text('0'), findsOneWidget);
  });
}
