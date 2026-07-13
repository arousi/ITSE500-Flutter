import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/openai_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

void main() {
  group('OpenAIAdapter.buildRequest', () {
    final adapter = OpenAIAdapter();

    GenerationContext ctx({
      String? credential = 'sk-test',
      MessageRequest? request,
    }) {
      return GenerationContext(
        providerId: ProviderId.openai,
        model: 'gpt-4o',
        requestId: 'req-1',
        credential: credential,
        request: request ??
            MessageRequest(
              requestId: 'req-1',
              requestUserContent: 'Hello there',
              requestUserRole: 'user',
            ),
      );
    }

    test('id and capabilities are stable', () {
      expect(adapter.id, 'openai');
      expect(adapter.capabilities, contains(Capability.temperature));
      expect(adapter.capabilities, contains(Capability.topP));
      expect(adapter.capabilities, contains(Capability.streaming));
      expect(adapter.capabilities, contains(Capability.systemPrompt));
      expect(adapter.capabilities, contains(Capability.structuredOutput));
      expect(adapter.capabilities, isNot(contains(Capability.vision)));
    });

    test('builds correct URL and auth header when credential provided', () {
      final r = adapter.buildRequest(ctx: ctx(), stream: false);
      expect(r.url, 'https://api.openai.com/v1/chat/completions');
      expect(r.headers['Authorization'], 'Bearer sk-test');
      expect(r.headers['Content-Type'], 'application/json');
    });

    test('omits Authorization header when credential is null', () {
      final r = adapter.buildRequest(ctx: ctx(credential: null), stream: false);
      expect(r.headers.containsKey('Authorization'), isFalse);
    });

    test('request body includes model, messages, and stream flag', () {
      final r = adapter.buildRequest(ctx: ctx(), stream: true);
      expect(r.body['model'], 'gpt-4o');
      expect(r.body['stream'], isTrue);
      final messages = r.body['messages'] as List;
      expect(messages.last, {'role': 'user', 'content': 'Hello there'});
    });

    test('includes system prompt as first message when present', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'Hi',
        requestUserRole: 'user',
        requestSystemPrompt: 'You are a helpful assistant.',
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final messages = r.body['messages'] as List;
      expect(messages.first, {
        'role': 'system',
        'content': 'You are a helpful assistant.',
      });
    });

    test('includes prior chat history in order before the user turn', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'follow up',
        requestUserRole: 'user',
        requestChatMessages: [
          {'role': 'user', 'content': 'first'},
          {'role': 'assistant', 'content': 'first reply'},
        ],
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final messages = (r.body['messages'] as List).cast<Map>();
      expect(messages[0]['content'], 'first');
      expect(messages[1]['content'], 'first reply');
      expect(messages[2]['content'], 'follow up');
    });

    test('composes multimodal content when image attachments are present',
        () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'describe this',
        requestUserRole: 'user',
        requestAttachments: [
          {
            'type': 'image',
            'dataUrl': 'data:image/png;base64,AAA',
            'mime': 'image/png',
          },
        ],
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final messages = (r.body['messages'] as List).cast<Map>();
      final userMsg = messages.last;
      final content = userMsg['content'] as List;
      expect(content[0], {'type': 'text', 'text': 'describe this'});
      expect(content[1]['type'], 'image_url');
      expect(content[1]['image_url']['url'], 'data:image/png;base64,AAA');
    });

    test('includes optional sampling params only when set', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'hi',
        requestTemperature: 0.7,
        requestTopP: 0.9,
        requestMaxTokens: 128,
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(r.body['temperature'], 0.7);
      expect(r.body['top_p'], 0.9);
      expect(r.body['max_tokens'], 128);
    });

    test('structured output schema is included when requested', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'hi',
        requestUseStructuredOutput: true,
        requestStructuredSchema: '{"type":"object"}',
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(r.body['response_format']['type'], 'json_schema');
      expect(r.body['response_format']['json_schema']['schema'],
          {'type': 'object'});
    });
  });

  group('OpenAIAdapter.parseResponse', () {
    final adapter = OpenAIAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.openai,
      model: 'gpt-4o',
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('extracts assistant message content from choices[0]', () {
      final json = {
        'id': 'resp-123',
        'model': 'gpt-4o',
        'created': 1700000000,
        'choices': [
          {
            'message': {'role': 'assistant', 'content': 'Hi there!'}
          }
        ],
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.response.responseId, 'resp-123');
      expect(parsed.response.status, 'completed');
      expect(parsed.output.outputContentText, 'Hi there!');
      expect(parsed.output.outputRole, 'assistant');
    });

    test('falls back to "No response" when content missing', () {
      final json = {'id': 'resp-empty', 'choices': []};
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'No response');
    });
  });

  group('OpenAIAdapter.streamParser', () {
    final adapter = OpenAIAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.openai,
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('yields delta text chunks then stop on [DONE]', () async {
      final raw = Stream<String>.fromIterable([
        'data: {"choices":[{"delta":{"content":"Hel"}}]}\n',
        'data: {"choices":[{"delta":{"content":"lo"}}]}\n',
        'data: [DONE]\n',
      ]);
      final chunks = await adapter.streamParser(raw, ctx).toList();
      expect(chunks[0].deltaText, 'Hel');
      expect(chunks[1].deltaText, 'lo');
      expect(chunks.last.finishReason, 'stop');
    });

    test('ignores malformed SSE lines without throwing', () async {
      final raw = Stream<String>.fromIterable([
        'data: {not valid json\n',
        'data: [DONE]\n',
      ]);
      final chunks = await adapter.streamParser(raw, ctx).toList();
      expect(chunks.last.finishReason, 'stop');
    });
  });
}
