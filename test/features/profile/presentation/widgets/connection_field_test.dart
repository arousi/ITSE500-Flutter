import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/features/profile/presentation/widgets/provider_config_block.dart';

void main() {
  group('ConnectionField API key masking', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController(text: 'sk-super-secret-key');
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildField({required bool usesApiKey}) {
      return MaterialApp(
        home: Scaffold(
          body: ConnectionField(
            displayName: 'OpenAI',
            providerKey: 'openai',
            enabled: true,
            statusColor: Colors.green,
            statusText: 'Connected',
            controller: controller,
            usesApiKey: usesApiKey,
            isEditable: true,
            checking: false,
            connected: true,
            fieldLabel: 'OpenAI API Key',
            docsUrl: 'https://platform.openai.com/api-keys',
            onToggleEnabled: (_) {},
            onChanged: (_) {},
            onFieldSubmitted: () {},
          ),
        ),
      );
    }

    bool obscured(WidgetTester tester) =>
        tester.widget<EditableText>(find.byType(EditableText)).obscureText;

    testWidgets('API key field starts obscured by default', (tester) async {
      await tester.pumpWidget(buildField(usesApiKey: true));
      expect(obscured(tester), isTrue);
    });

    testWidgets('reveal toggle un-obscures then re-obscures the key',
        (tester) async {
      await tester.pumpWidget(buildField(usesApiKey: true));

      // Reveal icon is present for API-key fields.
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(obscured(tester), isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Toggle back off.
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      expect(obscured(tester), isTrue);
    });

    testWidgets('submitting the field re-masks a revealed key',
        (tester) async {
      await tester.pumpWidget(buildField(usesApiKey: true));

      // Focus the field so a submit action has something to act on.
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      expect(obscured(tester), isFalse);

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(obscured(tester), isTrue);
    });

    testWidgets('non-API-key fields (e.g. endpoint URL) are never obscured',
        (tester) async {
      await tester.pumpWidget(buildField(usesApiKey: false));
      expect(obscured(tester), isFalse);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });
  });
}
