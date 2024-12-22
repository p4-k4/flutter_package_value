import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:value/value.dart';

void main() {
  group('Value', () {
    test('initializes with NoData when no initial value provided', () {
      final value = Value<int>();
      expect(value.last, isA<NoData<int>>());
      expect(value.prev, isA<NoData<int>>());
      expect(value.lastKnownValue, isNull);
    });

    test('initializes with Data when initial value provided', () {
      final value = Value<int>(42);
      expect(value.last, isA<Data<int>>());
      expect((value.last as Data<int>).value, 42);
      expect(value.prev, isA<Data<int>>());
      expect((value.prev as Data<int>).value, 42);
      expect(value.lastKnownValue, 42);
    });

    test('setValue updates state correctly', () {
      final value = Value<int>(0);
      value.setValue(42);
      expect(value.last, isA<Data<int>>());
      expect((value.last as Data<int>).value, 42);
      expect(value.lastKnownValue, 42);
    });

    test('setWaiting updates state correctly', () {
      final value = Value<int>(0);
      value.setWaiting();
      expect(value.last, isA<Waiting<int>>());
      expect(value.lastKnownValue, isNull);
    });

    test('setError updates state correctly', () {
      final value = Value<int>(0);
      final error = Exception('test error');
      final stackTrace = StackTrace.current;
      value.setError(error, stackTrace);
      expect(value.last, isA<Error<int>>());
      final errorState = value.last as Error<int>;
      expect(errorState.error, error);
      expect(errorState.stackTrace, stackTrace);
      expect(value.lastKnownValue, isNull);
    });

    test('reset updates state correctly', () {
      final value = Value<int>(42);
      value.reset();
      expect(value.last, isA<NoData<int>>());
      expect(value.lastKnownValue, isNull);
    });

    test('notifies listeners when state changes', () {
      final value = Value<int>(0);
      var notificationCount = 0;
      value.addListener(() => notificationCount++);

      value.setValue(42);
      value.notify();
      expect(notificationCount, 1);

      value.setWaiting();
      value.notify();
      expect(notificationCount, 2);

      value.setError(Exception('test'), StackTrace.current);
      value.notify();
      expect(notificationCount, 3);

      value.reset();
      value.notify();
      expect(notificationCount, 4);
    });
  });

  group('Subscriber Widget', () {
    testWidgets('rebuilds when Value changes', (tester) async {
      final counter = Value<int>(0);
      var buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Subscriber(
            (context) {
              buildCount++;
              return Text(
                switch (counter.last) {
                  Data(value: final v) => '$v',
                  _ => 'no data',
                },
              );
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);

      counter.setValue(42);
      counter.notify();
      await tester.pump();

      expect(buildCount, 2);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('handles multiple Values', (tester) async {
      final counter1 = Value<int>(0);
      final counter2 = Value<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Subscriber(
            (context) => Column(
              children: [
                Text('Counter 1: ${counter1.lastKnownValue}'),
                Text('Counter 2: ${counter2.lastKnownValue}'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Counter 1: 0'), findsOneWidget);
      expect(find.text('Counter 2: 0'), findsOneWidget);

      counter1.setValue(1);
      counter1.notify();
      await tester.pump();

      expect(find.text('Counter 1: 1'), findsOneWidget);
      expect(find.text('Counter 2: 0'), findsOneWidget);

      counter2.setValue(2);
      counter2.notify();
      await tester.pump();

      expect(find.text('Counter 1: 1'), findsOneWidget);
      expect(find.text('Counter 2: 2'), findsOneWidget);
    });

    testWidgets('handles error states', (tester) async {
      final value = Value<String>();

      await tester.pumpWidget(
        MaterialApp(
          home: Subscriber(
            (context) => Text(
              switch (value.last) {
                Data(value: final v) => v,
                Error(error: final e) => 'Error: $e',
                Waiting() => 'Loading...',
                NoData() => 'No data',
              },
            ),
          ),
        ),
      );

      expect(find.text('No data'), findsOneWidget);

      value.setWaiting();
      value.notify();
      await tester.pump();
      expect(find.text('Loading...'), findsOneWidget);

      value.setError(Exception('test error'), StackTrace.current);
      value.notify();
      await tester.pump();
      expect(find.text('Error: Exception: test error'), findsOneWidget);

      value.setValue('Success');
      value.notify();
      await tester.pump();
      expect(find.text('Success'), findsOneWidget);
    });

    testWidgets('disposes listeners properly', (tester) async {
      final value = Value<int>(0);
      var hasListeners = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Subscriber(
            (context) {
              // Access value to trigger subscription
              value.lastKnownValue;
              return const SizedBox();
            },
          ),
        ),
      );

      // Verify listener was added
      expect(value.hasListeners, true);

      // Dispose by replacing with empty container
      await tester.pumpWidget(Container());

      // Verify listener was removed
      expect(value.hasListeners, false);
    });
  });
}
