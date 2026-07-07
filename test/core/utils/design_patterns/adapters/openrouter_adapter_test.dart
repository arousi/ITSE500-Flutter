import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/openrouter_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

void main() {
  group('OpenRouterAdapter.buildRequest', () {
    final adapter = OpenRouterAdapter();

    GenerationContext ctx({required MessageRequest request, String? credential = 'or-key'}) {
      return GenerationContext(
        providerId: ProviderId.openrouter,
        model: 'openrouter/auto',
        requestId: 'req-1',
        credential: credential,
        request: request,
      );
    }

    test('id and capabilities are stable (no vision, no structuredOutput)', () {
      expect(adapter.id, 'openrouter');
      expect(adapter.capabilities, contains(Capability.temperature));
      expect(adapter.capabilities, contains(Capability.streaming));
      expect(adapter.capabilities, isNot(contains(Capability.vision)));
      expect(adapter.capabilities, isNot(contains(Capability.structuredOutput)));
    });

    test('targets the OpenRouter chat completions endpoint', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(r.url, 'https://openrouter.ai/api/v1/chat/completions');
      expect(r.headers['Authorization'], 'Bearer or-key');
    });

    test('composes multimodal parts for image attachments', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'what is this',
        requestAttachments: [
          {'type': 'image', 'dataUrl': 'data:image/png;base64,BBB'},
        ],
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final messages = (r.body['messages'] as List).cast<Map>();
      final content = messages.last['content'] as List;
      expect(content[0]['type'], 'text');
      expect(content[1]['type'], 'image_url');
    });

    test('body reflects stream flag', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: true);
      expect(r.body['stream'], isTrue);
    });
  });

  group('OpenRouterAdapter.parseResponse', () {
    final adapter = OpenRouterAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.openrouter,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('extracts content from choices[0].message', () {
      final json = {
        'id': 'gen-1',
        'model': 'openrouter/auto',
        'choices': [
          {
            'message': {'role': 'assistant', 'content': 'Answer text'}
          }
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.response.responseId, 'gen-1');
      expect(parsed.output.outputContentText, 'Answer text');
    });
  });

  group('OpenRouterAdapter.streamParser', () {
    final adapter = OpenRouterAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.openrouter,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('yields incremental deltas and stop on [DONE]', () async {
      final raw = Stream<String>.fromIterable([
        'data: {"choices":[{"delta":{"content":"A"}}]}\n'
            'data: {"choices":[{"delta":{"content":"B"}}]}\n',
        'data: [DONE]\n',
      ]);
      final chunks = await adapter.streamParser(raw, ctx).toList();
      expect(chunks.map((c) => c.deltaText).where((t) => t != null).toList(),
          ['A', 'B']);
      expect(chunks.last.finishReason, 'stop');
    });
  });

  group('OpenRouterAdapter.generateEmbedding', () {
    final adapter = OpenRouterAdapter();

    test('produces a deterministic fixed-length pseudo-embedding', () async {
      final a = await adapter.generateEmbedding(
          text: 'hello', model: 'any', credential: null);
      final b = await adapter.generateEmbedding(
          text: 'hello', model: 'any', credential: null);
      expect(a, b);
      expect(a.length, 128 * 4);
    });

    test('differs for different input text', () async {
      final a = await adapter.generateEmbedding(
          text: 'hello', model: 'any', credential: null);
      final b = await adapter.generateEmbedding(
          text: 'world', model: 'any', credential: null);
      expect(a, isNot(equals(b)));
    });
  });
}
