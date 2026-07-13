import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/huggingface_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

void main() {
  group('HuggingFaceAdapter.buildRequest', () {
    final adapter = HuggingFaceAdapter();

    GenerationContext ctx({String? credential = 'hf-key', required MessageRequest request}) {
      return GenerationContext(
        providerId: ProviderId.huggingface,
        model: 'meta-llama/Llama-3',
        requestId: 'req-1',
        credential: credential,
        request: request,
      );
    }

    test('id and capabilities are stable (no streaming/vision)', () {
      expect(adapter.id, 'huggingface');
      expect(adapter.capabilities, contains(Capability.temperature));
      expect(adapter.capabilities, isNot(contains(Capability.streaming)));
      expect(adapter.capabilities, isNot(contains(Capability.vision)));
    });

    test('URL-encodes each path segment of the model id', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(
        r.url,
        'https://api-inference.huggingface.co/models/meta-llama/Llama-3/chat/completions',
      );
    });

    test('inserts system prompt as first history entry', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'hi',
        requestSystemPrompt: 'be formal',
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final messages = (r.body['messages'] as List).cast<Map>();
      expect(messages.first['role'], 'system');
      expect(messages.first['content'], 'be formal');
    });

    test('substitutes "Hello" when user content is empty', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: '');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final messages = (r.body['messages'] as List).cast<Map>();
      expect(messages.last['content'], 'Hello');
    });

    test('always forces stream:false regardless of stream argument', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: true);
      expect(r.body['stream'], isFalse);
    });

    test('omits Authorization header when credential is empty', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(
          ctx: ctx(credential: '', request: req), stream: false);
      expect(r.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('HuggingFaceAdapter.parseResponse', () {
    final adapter = HuggingFaceAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.huggingface,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('extracts choices[0].message.content (chat/completions shape)', () {
      final json = {
        'choices': [
          {
            'message': {'content': 'hf chat answer'}
          }
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'hf chat answer');
    });

    test('falls back to legacy generated_text field', () {
      final parsed =
          adapter.parseResponse({'generated_text': 'legacy answer'}, ctx);
      expect(parsed.output.outputContentText, 'legacy answer');
    });

    test('falls back to outputs[0].generated_text', () {
      final json = {
        'outputs': [
          {'generated_text': 'outputs answer'}
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'outputs answer');
    });

    test('falls back to data[0].generated_text', () {
      final json = {
        'data': [
          {'generated_text': 'data answer'}
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'data answer');
    });
  });

  group('HuggingFaceAdapter.streamParser', () {
    final adapter = HuggingFaceAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.huggingface,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('emits incremental deltas for a growing generated_text value',
        () async {
      final raw = Stream<String>.fromIterable([
        '{"generated_text":"Hel"}',
        '{"generated_text":"Hello"}',
      ]);
      final chunks = await adapter.streamParser(raw, ctx).toList();
      final deltas =
          chunks.map((c) => c.deltaText).where((t) => t != null).toList();
      expect(deltas.join(), 'Hello');
      expect(chunks.last.finishReason, 'stop');
    });
  });
}
