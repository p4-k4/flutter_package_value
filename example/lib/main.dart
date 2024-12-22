import 'package:flutter/material.dart';
import 'package:value/value.dart';
import 'state.dart' as app_state;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Value Counter Example'),
      ),
      body: Subscriber(
        (context) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Counter Value:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 16),
              Text(
                switch (app_state.counter.last) {
                  Data(value: final v) => '$v',
                  _ => '0',
                },
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: app_state.decrementCounter,
                    icon: const Icon(Icons.remove),
                    label: const Text('Decrease'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: app_state.resetCounter,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: app_state.incrementCounter,
                    icon: const Icon(Icons.add),
                    label: const Text('Increase'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
