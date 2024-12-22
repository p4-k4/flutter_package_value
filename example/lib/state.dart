import 'package:flutter_value/value.dart';

final counter = Value<int>(0);

void incrementCounter() {
  if (counter.lastKnownValue case final value?) {
    counter.setValue(value + 1);
    counter.notify();
  }
}

void decrementCounter() {
  if (counter.lastKnownValue case final value?) {
    counter.setValue(value - 1);
    counter.notify();
  }
}

void resetCounter() {
  counter.setValue(0);
  counter.notify();
}
