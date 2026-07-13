import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/gemini_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

void main() {
  group('GeminiAdapter.buildRequest', () {
    final adapter = GeminiAdapter();

    GenerationContext ctx({
      String? model = 'gemini-1.5-flash',
      String? credential = 'test-key',
      required MessageRequest request,
    }) {
      return GenerationContext(
        providerId: ProviderId.gemini,
        model: model,
        requestId: 'req-1',
        credential: credential,
        request: request,
      );
    }

    test('id and capabilities include vision and streaming', () {
      expect(adapter.id, 'gemini');
      expect(adapter.capabilities, contains(Capability.vision));
      expect(adapter.capabilities, contains(Capability.streaming));
      expect(adapter.capabilities, contains(Capability.topK));
    });

    test('strips "models/" prefix from model id in URL', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(
        ctx: ctx(model: 'models/gemini-1.5-flash', request: req),
        stream: false,
      );
      expect(r.url, contains('models/gemini-1.5-flash:generateContent'));
      expect(r.url, isNot(contains('models/models/')));
    });

    test('uses streamGenerateContent endpoint when stream=true', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: true);
      expect(r.url, contains(':streamGenerateContent'));
    });

    test('sends API key via x-goog-api-key header', () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'hi');
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(r.headers['x-goog-api-key'], 'test-key');
    });

    test('maps assistant role to "model" in chat history', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'follow up',
        requestChatMessages: [
          {'role': 'user', 'content': 'hi'},
          {'role': 'assistant', 'content': 'hello'},
        ],
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final contents = r.body['contents'] as List;
      expect(contents[0]['role'], 'user');
      expect(contents[1]['role'], 'model');
      expect(contents.last['role'], 'user');
    });

    test('includes inline_data part for image attachments with base64', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'describe',
        requestAttachments: [
          {'type': 'image', 'b64': 'AAAA', 'mime': 'image/png'},
        ],
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final contents = r.body['contents'] as List;
      final userParts = contents.last['parts'] as List;
      expect(userParts.any((p) => p['inline_data'] != null), isTrue);
    });

    test('omits systemInstruction for image-generation models', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'draw a cat',
        requestSystemPrompt: 'be creative',
      );
      final r = adapter.buildRequest(
        ctx: ctx(model: 'gemini-2.0-image-generation', request: req),
        stream: false,
      );
      expect(r.body.containsKey('system_instruction'), isFalse);
    });

    test('includes systemInstruction for regular text models', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'hi',
        requestSystemPrompt: 'be nice',
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      expect(r.body['system_instruction']['parts'][0]['text'], 'be nice');
    });

    test('sets responseModalities to TEXT+IMAGE for image-gen model hint',
        () {
      final req = MessageRequest(requestId: 'req-1', requestUserContent: 'x');
      final r = adapter.buildRequest(
        ctx: ctx(model: 'gemini-image-generation', request: req),
        stream: false,
      );
      expect(r.body['generationConfig']['responseModalities'],
          ['TEXT', 'IMAGE']);
    });

    test('generationConfig carries temperature/topP/topK/maxTokens', () {
      final req = MessageRequest(
        requestId: 'req-1',
        requestUserContent: 'hi',
        requestTemperature: 0.5,
        requestTopP: 0.8,
        requestTopK: 20,
        requestMaxTokens: 256,
      );
      final r = adapter.buildRequest(ctx: ctx(request: req), stream: false);
      final gc = r.body['generationConfig'] as Map;
      expect(gc['temperature'], 0.5);
      expect(gc['topP'], 0.8);
      expect(gc['topK'], 20);
      expect(gc['maxOutputTokens'], 256);
    });
  });

  group('GeminiAdapter.parseResponse', () {
    final adapter = GeminiAdapter();
    final ctx = GenerationContext(
      providerId: ProviderId.gemini,
      model: 'gemini-1.5-flash',
      requestId: 'req-1',
      request: MessageRequest(requestId: 'req-1'),
    );

    test('extracts text from candidates[0].content.parts', () {
      final json = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': 'Hello '},
                {'text': 'world'},
              ]
            }
          }
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputContentText, 'Hello world');
      expect(parsed.output.outputType, 'text');
    });

    test('extracts inline image data and marks output multimodal', () {
      final json = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'inline_data': {'mime_type': 'image/png', 'data': 'AAAA'}
                }
              ]
            }
          }
        ]
      };
      final parsed = adapter.parseResponse(json, ctx);
      expect(parsed.output.outputType, 'multimodal');
      expect(parsed.output.outputContentAnnotations, contains('AAAA'));
    });

    test('handles empty candidates gracefully', () {
      final parsed = adapter.parseResponse({'candidates': []}, ctx);
      expect(parsed.output.outputContentText, 'No response');
    });
  });
}
