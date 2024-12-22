import 'dart:async';
import 'package:flutter/material.dart';

class Value<T> extends ChangeNotifier {
  Value([this._initial]) {
    if (_initial != null) {
      _prev = Data<T>(_initial);
      _last = Data<T>(_initial);
    } else {
      _prev = NoData<T>();
      _last = NoData<T>();
    }
  }

  final T? _initial;

  late ValueState<T> _prev;
  late ValueState<T> _last;

  ValueState<T> get prev {
    _subscribe();
    return _prev;
  }

  ValueState<T> get last {
    _subscribe();
    return _last;
  }

  T? get lastKnownValue {
    _subscribe();
    if (_last case Data(value: var v)) return v;
    return null;
  }

  void notify() => notifyListeners();

  void setValue(T value) async {
    _last = Data<T>(value);
  }

  void setWaiting() {
    _last = Waiting<T>();
  }

  void setError(Object e, StackTrace s) {
    _last = Error<T>(e, s);
  }

  void reset() {
    _last = NoData<T>();
  }

  void _subscribe() {
    final currentSubscriber = SubscriberState._currentState;
    if (currentSubscriber != null) {
      currentSubscriber.addNotifier(this);
    }
  }
}

// class Value<T> extends ChangeNotifier {
//   Value([T? initial]) {
//     if (initial != null) {
//       _updateState(Data(initial));
//     }
//   }
//
//   ValueState<T> _newState = NoData<T>();
//   ValueState<T> get newState {
//     _subscribe();
//     return _newState;
//   }
//
//   ValueState<T> _currentState = NoData<T>();
//   ValueState<T> get currentState {
//     _subscribe();
//     return _currentState;
//   }
//
//   T? get lastKnownValue {
//     _subscribe();
//     return switch (_currentState) {
//       Data(value: var v) => v,
//       Waiting() => null,
//       Error() => null,
//       NoData() => null,
//     };
//   }
//
//   void _subscribe() {
//     final currentSubscriber = SubscriberState._currentState;
//     if (currentSubscriber != null) {
//       currentSubscriber.addNotifier(this);
//     }
//   }
//
//   Future<void> setWaiting() async {
//     _updateState(Waiting());
//     notifyListeners();
//   }
//
//   Future<void> setError(Object error, StackTrace stackTrace) async {
//     _updateState(Error(error: error, stackTrace: stackTrace));
//     notifyListeners();
//   }
//
//   Future<void> setValue(
//     FutureOr<T> Function() fn, {
//     bool notifyIfData = true,
//     bool notifyIfWaiting = false,
//     bool notifyIfError = false,
//   }) async {
//     // if (currentState case Waiting()) return;
//     _updateState(Waiting());
//     if (notifyIfWaiting) notifyListeners();
//     try {
//       final value = await fn();
//       _updateState(Data(value));
//       if (notifyIfData) notifyListeners();
//     } catch (e, stackTrace) {
//       _updateState(Error(error: e, stackTrace: stackTrace));
//       if (notifyIfError) notifyListeners();
//     }
//   }
//
//   void _updateState(ValueState<T> newState) {
//     if (_newState case Data()) {
//       _currentState = _newState;
//     }
//     _newState = newState;
//   }
//
//   void reset() {
//     _updateState(NoData<T>());
//     notifyListeners();
//   }
// }

sealed class ValueState<T> {
  const ValueState();
}

class Data<T> extends ValueState<T> {
  const Data(this.value);
  final T value;
}

class NoData<T> extends ValueState<T> {
  const NoData();
}

class Error<T> extends ValueState<T> {
  const Error(
    this.error,
    this.stackTrace,
  );
  final Object error;
  final StackTrace stackTrace;
}

class Waiting<T> extends ValueState<T> {
  const Waiting();
}

// Subscriber Widget
class Subscriber extends StatefulWidget {
  const Subscriber(this.builder, {super.key});
  final Widget Function(BuildContext context) builder;
  @override
  State<Subscriber> createState() => SubscriberState();
}

class SubscriberState extends State<Subscriber> {
  static SubscriberState? _currentState;
  final Set<ChangeNotifier> _notifiers = {};

  void addNotifier(ChangeNotifier notifier) {
    if (_notifiers.add(notifier)) {
      notifier.addListener(_update);
    }
  }

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
