import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/builders/message_request_builder.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';

void main() {
  const builder = MessageRequestBuilder();

  group('MessageRequestBuilder.build', () {
    test('omits sampling params entirely when capabilities are empty', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
          useTemperature: true,
          temperature: 1.5,
        ),
        capabilities: const {}, // provider supports nothing extra
      );
      expect(req.requestTemperature, isNull);
      expect(req.requestTopP, isNull);
      expect(req.requestSystemPrompt, isNull);
    });

    test('includes temperature only when both capability and toggle are set',
        () {
      final withToggleOff = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
            useTemperature: false, temperature: 0.9),
        capabilities: const {Capability.temperature},
      );
      expect(withToggleOff.requestTemperature, isNull);

      final withBoth = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
            useTemperature: true, temperature: 0.9),
        capabilities: const {Capability.temperature},
      );
      expect(withBoth.requestTemperature, 0.9);
    });

    test('clamps temperature to [0, paramLimits.temperatureMax]', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
            useTemperature: true, temperature: 5.0),
        capabilities: const {Capability.temperature},
        paramLimits: const ParamBounds(temperatureMax: 1.0),
      );
      expect(req.requestTemperature, 1.0);
    });

    test('clamps topP to [0, 1] regardless of paramLimits', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state:
            const InferenceSettingsState(useTopP: true, topP: 3.0),
        capabilities: const {Capability.topP},
      );
      expect(req.requestTopP, 1.0);
    });

    test('clamps and rounds topK to an int within [1, topKMax]', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(useTopK: true, topK: 999),
        capabilities: const {Capability.topK},
        paramLimits: const ParamBounds(topKMax: 50),
      );
      expect(req.requestTopK, 50.0);
    });

    test('trims and includes systemPrompt only when non-empty', () {
      final blank = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
            useSystemPrompt: true, systemPrompt: '   '),
        capabilities: const {Capability.systemPrompt},
      );
      expect(blank.requestSystemPrompt, isNull);

      final withPrompt = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
            useSystemPrompt: true, systemPrompt: '  Be nice.  '),
        capabilities: const {Capability.systemPrompt},
      );
      expect(withPrompt.requestSystemPrompt, 'Be nice.');
    });

    test('includes structured schema only when capability+toggle+non-empty',
        () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        state: const InferenceSettingsState(
          useStructuredOutput: true,
          structuredSchema: '{"type":"object"}',
        ),
        capabilities: const {Capability.structuredOutput},
      );
      expect(req.requestUseStructuredOutput, isTrue);
      expect(req.requestStructuredSchema, '{"type":"object"}');
    });

    test('strips attachments when provider lacks vision capability', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'describe',
        attachments: [
          {'type': 'image', 'path': '/tmp/a.png'}
        ],
        capabilities: const {Capability.temperature}, // no vision
      );
      expect(req.requestAttachments, isNull);
    });

    test('keeps attachments when provider has vision capability', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'describe',
        attachments: [
          {'type': 'image', 'path': '/tmp/a.png'}
        ],
        capabilities: const {Capability.vision},
      );
      expect(req.requestAttachments, isNotNull);
      expect(req.requestAttachments!.length, 1);
    });

    test('defaults to InferenceSettingsState() when state is null', () {
      final req = builder.build(
        requestId: 'r1',
        userContent: 'hi',
        capabilities: const {Capability.temperature},
      );
      // useTemperature defaults to false, so temperature stays unset.
      expect(req.requestTemperature, isNull);
    });

    test('carries through requestId, model, userContent, and stream flag',
        () {
      final req = builder.build(
        requestId: 'req-42',
        model: 'gpt-4o',
        userContent: 'hello world',
        stream: true,
      );
      expect(req.requestId, 'req-42');
      expect(req.requestModel, 'gpt-4o');
      expect(req.requestUserContent, 'hello world');
      expect(req.requestUserRole, 'user');
      expect(req.requestStream, isTrue);
    });
  });
}
