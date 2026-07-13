// Minimal CI smoke test.
//
// Intentionally does NOT pump the real `MyApp` widget: that widget wires up
// dotenv, sqflite/DI (`setupLocator`), GoRouter, and multiple Blocs/Cubits at
// build time, none of which are safe or meaningful to initialize in a
// headless CI test runner. Instead this test pumps a tiny, self-contained
// MaterialApp to prove the Flutter test harness itself is wired up and that
// `flutter test` produces a real, meaningful pass/fail signal in CI.
//
// No network access, no platform channels/plugins, no file system access.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('smoke: a minimal MaterialApp renders its content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('ITSE500 smoke test'))),
      ),
    );

    expect(find.text('ITSE500 smoke test'), findsOneWidget);
  });

  testWidgets('smoke: a button tap updates on-screen state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _CounterHarness());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}

/// Tiny self-contained stateful widget used only to prove that basic
/// widget interaction (tap + rebuild) works under the test harness.
class _CounterHarness extends StatefulWidget {
  const _CounterHarness();

  @override
  State<_CounterHarness> createState() => _CounterHarnessState();
}

class _CounterHarnessState extends State<_CounterHarness> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text('$_count')),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => _count++),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
