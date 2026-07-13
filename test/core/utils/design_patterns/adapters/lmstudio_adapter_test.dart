import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/lmstudio_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

void main() {
  group('LMStudioAdapter.buildRequest', () {
    final adapter = LMStudioAdapter();

    GenerationContext ctx({String? credential, required MessageRequest request}) {
      return GenerationContext(
        providerId: ProviderId.lmstudio,
        model: 'local-model',
        requestId: 'req-1',
        credential: credential,
        request: request,
      );
    }

    test('id and capabilities are stable', () {
      expect(adapter.id, 'lmstudio');
      expect(adapter.capabilities, contains(Capability.temperature));
      expect(adapter.capabilities, contains(Capability.streaming));
      expect(adapter.capabilities, contains(Capability.systemPrompt));
      expect(adapter.capabilities, isNot(contains(Capability.vision)));
    });

    test('defaults to local base URL when credential is empty', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(r.url, startsWith('http://10.0.2.2:1234/'));
    });

    test('uses OpenAI-compatible chat/completions path when base contains /v1/',
        () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(
        ctx: ctx(credential: 'http://localhost:1234/v1/', request: req),
        stream: false,
      );
      expect(r.url, 'http://localhost:1234/v1/chat/completions');
      expect(r.body['messages'], isA<List>());
    });

    test('falls back to legacy prompt concatenation for non-v1 base', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'what time is it',
        requestSystemPrompt: 'be terse',
        requestChatMessages: [
          {'role': 'user', 'content': 'earlier question'},
          {'role': 'assistant', 'content': 'earlier answer'},
        ],
      );
      final r = adapter.buildRequest(
        ctx: ctx(credential: 'http://localhost:1234/', request: req),
        stream: false,
      );
      expect(r.url, 'http://localhost:1234/api/v0/completions');
      final prompt = r.body['prompt'] as String;
      expect(prompt, contains('System: be terse'));
      expect(prompt, contains('User: earlier question'));
      expect(prompt, contains('Assistant: earlier answer'));
      expect(prompt, contains('User: what time is it'));
    });

    test('appends trailing slash to base URL when missing', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(
        ctx: ctx(credential: 'http://localhost:1234', request: req),
        stream: false,
      );
      expect(r.url, 'http://localhost:1234/api/v0/completions');
    });
  });

  group('LMStudioAdapter.parseResponse', () {
    final adapter = LMStudioAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.lmstudio,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('parses legacy "completion" field', () {
      final parsed = adapter.parseResponse({'completion': 'legacy text'}, ctx);
      expect(parsed.output.outputContentText, 'legacy text');
    });

    test('parses OpenAI-style choices[0].message.content', () {
      final json = {
        'choices': [
          {
            'message': {'content': 'chat text'}
          }
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'chat text');
    });

    test('parses OpenAI-style choices[0].text (completions API)', () {
      final json = {
        'choices': [
          {'text': 'completion text'}
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'completion text');
    });

    test('falls back to "No response" when nothing matches', () {
      final parsed = adapter.parseResponse({}, ctx);
      expect(parsed.output.outputContentText, 'No response');
    });
  });

  group('LMStudioAdapter.streamParser', () {
    final adapter = LMStudioAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.lmstudio,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('parses OpenAI-style delta chunks and finish reason', () async {
      final raw = Stream<String>.fromIterable([
        '{"choices":[{"delta":{"content":"Hi"},"finish_reason":null}]}\n',
        '{"choices":[{"delta":{},"finish_reason":"stop"}]}\n',
      ]);
      final chunks = await adapter.streamParser(raw, ctx).toList();
      expect(chunks.first.deltaText, 'Hi');
      expect(chunks.last.finishReason, 'stop');
    });
  });
}
