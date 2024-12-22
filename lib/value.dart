import 'dart:async';
import 'package:flutter/material.dart';

/// A reactive state management class that handles different states of a value
/// including data, loading, error, and no data states.
///
/// The [Value] class extends [ChangeNotifier] to provide reactive updates to UI
/// when the state changes. It maintains both the current and previous states,
/// allowing for state transition tracking.
///
/// Example:
/// ```dart
/// final counter = Value<int>(0);
/// counter.setValue(42);
/// counter.notify();
///
/// // Access value using pattern matching
/// switch (counter.last) {
///   case Data(value: final v):
///     print('Current value: $v');
///   case Waiting():
///     print('Loading...');
///   case Error(error: final e):
///     print('Error: $e');
///   case NoData():
///     print('No data available');
/// }
/// ```
class Value<T> extends ChangeNotifier {
  /// Creates a new [Value] instance with an optional initial value.
  ///
  /// If [_initial] is provided, both [_prev] and [_last] states are initialized
  /// as [Data] with the initial value. Otherwise, they are initialized as [NoData].
  Value([this._initial]) {
    if (_initial != null) {
      _prev = Data<T>(_initial);
      _last = Data<T>(_initial);
    } else {
      _prev = NoData<T>();
      _last = NoData<T>();
    }
  }

  /// The initial value provided during instantiation.
  final T? _initial;

  /// The previous state of the value.
  late ValueState<T> _prev;

  /// The current state of the value.
  late ValueState<T> _last;

  /// Gets the previous state of the value.
  ///
  /// Automatically subscribes the current [Subscriber] widget to updates
  /// from this [Value] instance.
  ValueState<T> get prev {
    _subscribe();
    return _prev;
  }

  /// Gets the current state of the value.
  ///
  /// Automatically subscribes the current [Subscriber] widget to updates
  /// from this [Value] instance.
  ValueState<T> get last {
    _subscribe();
    return _last;
  }

  /// Gets the last known value if available.
  ///
  /// Returns null if the current state is not [Data].
  /// Automatically subscribes the current [Subscriber] widget to updates.
  T? get lastKnownValue {
    _subscribe();
    if (_last case Data(value: var v)) return v;
    return null;
  }

  /// Notifies all listeners that the state has changed.
  ///
  /// This should be called after modifying the state using [setValue],
  /// [setWaiting], [setError], or [reset].
  void notify() => notifyListeners();

  /// Updates the current state with a new value.
  ///
  /// The value is wrapped in a [Data] state.
  void setValue(T value) async {
    _last = Data<T>(value);
  }

  /// Sets the current state to [Waiting] to indicate a loading state.
  void setWaiting() {
    _last = Waiting<T>();
  }

  /// Sets the current state to [Error] with the provided error and stack trace.
  void setError(Object e, StackTrace s) {
    _last = Error<T>(e, s);
  }

  /// Resets the current state to [NoData].
  void reset() {
    _last = NoData<T>();
  }

  /// Subscribes the current [Subscriber] widget to updates from this [Value].
  ///
  /// This is automatically called when accessing [prev], [last], or [lastKnownValue].
  void _subscribe() {
    final currentSubscriber = SubscriberState._currentState;
    if (currentSubscriber != null) {
      currentSubscriber.addNotifier(this);
    }
  }
}

/// Base class for all possible states of a [Value].
///
/// This is a sealed class with four implementations:
/// - [Data]: Contains the actual value
/// - [NoData]: Represents absence of data
/// - [Error]: Contains error information
/// - [Waiting]: Represents a loading state
sealed class ValueState<T> {
  const ValueState();
}

/// Represents a state that contains actual data.
class Data<T> extends ValueState<T> {
  /// Creates a [Data] state with the provided value.
  const Data(this.value);

  /// The actual value being stored.
  final T value;
}

/// Represents a state where no data is available.
class NoData<T> extends ValueState<T> {
  /// Creates a [NoData] state.
  const NoData();
}

/// Represents an error state with associated error information.
class Error<T> extends ValueState<T> {
  /// Creates an [Error] state with the provided error and stack trace.
  const Error(
    this.error,
    this.stackTrace,
  );

  /// The error that occurred.
  final Object error;

  /// The stack trace associated with the error.
  final StackTrace stackTrace;
}

/// Represents a loading or waiting state.
class Waiting<T> extends ValueState<T> {
  /// Creates a [Waiting] state.
  const Waiting();
}

/// A widget that subscribes to [Value] instances and rebuilds when they change.
///
/// This widget automatically manages subscriptions to any [Value] instances
/// accessed within its [builder] function.
///
/// Example:
/// ```dart
/// Subscriber(
///   (context) => Text(
///     switch (counter.last) {
///       Data(value: final v) => '$v',
///       _ => 'No value',
///     },
///   ),
/// )
/// ```
class Subscriber extends StatefulWidget {
  /// Creates a [Subscriber] widget.
  ///
  /// The [builder] function is called whenever any accessed [Value]
  /// instances notify of changes.
  const Subscriber(this.builder, {super.key});

  /// The builder function that constructs the widget tree.
  ///
  /// This function can access [Value] instances, and the widget will
  /// automatically rebuild when those values change.
  final Widget Function(BuildContext context) builder;

  @override
  State<Subscriber> createState() => SubscriberState();
}

/// The state for a [Subscriber] widget.
///
/// This class manages subscriptions to [Value] instances and rebuilds
/// the widget when those values change.
class SubscriberState extends State<Subscriber> {
  /// The currently active [SubscriberState].
  ///
  /// This is used internally by [Value] instances to automatically
  /// subscribe the current widget to updates.
  static SubscriberState? _currentState;

  /// The set of [ChangeNotifier]s (including [Value] instances) that
  /// this widget is subscribed to.
  final Set<ChangeNotifier> _notifiers = {};

  /// Adds a notifier to the subscription list.
  ///
  /// If the notifier hasn't been added before, it's added and the
  /// widget subscribes to its updates.
  void addNotifier(ChangeNotifier notifier) {
    if (_notifiers.add(notifier)) {
      notifier.addListener(_update);
    }
  }

  /// Updates the widget's state if it's still mounted.
  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var notifier in _notifiers) {
      notifier.removeListener(_update);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previousSubscriber = _currentState;
    _currentState = this;
    final result = widget.builder(context);
    _currentState = previousSubscriber;
    return result;
  }
}
