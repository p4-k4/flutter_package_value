# Value

[![pub package](https://img.shields.io/pub/v/value.svg)](https://pub.dev/packages/value)
[![GitHub](https://img.shields.io/github/license/p4-k4/flutter_package_value.svg)](https://github.com/p4-k4/flutter_package_value/blob/master/LICENSE)

A lightweight state management solution for Flutter that makes handling loading, error, and data states elegant and type-safe using Dart's pattern matching.

Created by [p4-k4](https://github.com/p4-k4).

## Features

- 🎯 Type-safe state management
- 🔄 Built-in loading state handling
- ⚠️ Elegant error state management
- 🎨 Clean and simple API
- 📦 Minimal boilerplate
- 🔍 Pattern matching friendly
- 🎭 Separation of concerns with state files

## Installation

Add `value` to your `pubspec.yaml`:

```yaml
dependencies:
  value: ^0.0.1
```

## Usage

### Basic Example

```dart
// Create a Value instance
final counter = Value<int>(0);

// Update the value
counter.setValue(42);
counter.notify();

// Access the value using pattern matching
switch (counter.last) {
  case Data(value: final v):
    print('Current value: $v');
  case Waiting():
    print('Loading...');
  case Error(error: final e):
    print('Error: $e');
  case NoData():
    print('No data available');
}
```

### Complete Counter Example

Here's a complete counter example showing how to use Value with Flutter:

```dart
// state.dart
import 'package:value/value.dart';

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

// main.dart
import 'package:flutter/material.dart';
import 'package:value/value.dart';
import 'state.dart' as app_state;

class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Subscriber(
      (context) => Column(
        children: [
          Text(
            switch (app_state.counter.last) {
              Data(value: final v) => '$v',
              _ => '0',
            },
          ),
          Row(
            children: [
              FilledButton(
                onPressed: app_state.decrementCounter,
                child: Text('Decrease'),
              ),
              FilledButton(
                onPressed: app_state.resetCounter,
                child: Text('Reset'),
              ),
              FilledButton(
                onPressed: app_state.incrementCounter,
                child: Text('Increase'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Handling Async Operations

Value makes it easy to handle async operations with built-in loading and error states:

```dart
final userProfile = Value<UserProfile>();

Future<void> fetchProfile() async {
  userProfile.setWaiting();
  userProfile.notify();
  
  try {
    final profile = await api.fetchUserProfile();
    userProfile.setValue(profile);
  } catch (e, s) {
    userProfile.setError(e, s);
  }
  userProfile.notify();
}

// In your widget
Subscriber(
  (context) => switch (userProfile.last) {
    Data(value: final profile) => ProfileView(profile),
    Waiting() => CircularProgressIndicator(),
    Error(error: final e) => Text('Error: $e'),
    NoData() => Text('No profile data'),
  },
)
```

## State Types

Value provides several state types to handle different scenarios:

- `Data<T>`: Contains the actual value
- `Waiting<T>`: Represents a loading state
- `Error<T>`: Contains error information
- `NoData<T>`: Represents absence of data

## Best Practices

1. **Separate State Logic**: Keep your Value instances and related functions in separate state files
2. **Import with Alias**: When importing state files, use aliases to make the code more readable
3. **Pattern Matching**: Leverage Dart's pattern matching for clean state handling
4. **Notify After Changes**: Call `notify()` after updating values to trigger UI updates
5. **Use lastKnownValue**: For simple value access when you don't need full state information

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request to our [GitHub repository](https://github.com/p4-k4/flutter_package_value).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author
Paurini Taketakehikuroa Wiringi
