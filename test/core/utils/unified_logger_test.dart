import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';

void main() {
  group('UnifiedLogger redaction', () {
    final logger = UnifiedLogger.instance;

    test('redacts a Bearer token embedded in a plain message string', () {
      const message = 'Sending request with Authorization: Bearer sk-abc123XYZ456';
      final result = logger.redactStringForTest(message);
      expect(result, isNot(contains('sk-abc123XYZ456')));
      expect(result, contains('Bearer ***'));
    });

    test('redacts a raw OpenAI-style API key even without a Bearer prefix',
        () {
      const message = 'key=sk-proj-abcdef1234567890';
      final result = logger.redactStringForTest(message);
      expect(result, isNot(contains('sk-proj-abcdef1234567890')));
    });

    test('redacts a raw Google API key (AIza... prefix)', () {
      const message = 'Using key AIzaSyD-abcdefghijklmnopqrstuvwxyz1234';
      final result = logger.redactStringForTest(message);
      expect(result, isNot(contains('AIzaSyD-abcdefghijklmnopqrstuvwxyz1234')));
    });

    test('leaves non-sensitive messages untouched', () {
      const message = 'Sending LLM request to https://api.openai.com/v1/';
      final result = logger.redactStringForTest(message);
      expect(result, message);
    });

    test('redacts sensitive keys in a context map, case-insensitively', () {
      final ctx = <String, dynamic>{
        'Authorization': 'Bearer sk-secret',
        'access_token': 'abc.def.ghi',
        'nested': {'api_key': 'sk-nested-secret', 'safe': 'ok'},
        'safeField': 'hello',
      };
      final result = logger.redactCtxForTest(ctx);
      expect(result['Authorization'], '***');
      expect(result['access_token'], '***');
      expect((result['nested'] as Map)['api_key'], '***');
      expect((result['nested'] as Map)['safe'], 'ok');
      expect(result['safeField'], 'hello');
    });

    test('redacts sensitive-looking substrings inside string ctx values',
        () {
      final ctx = <String, dynamic>{
        'note': 'used Bearer sk-embedded-in-a-sentence-token for the call',
      };
      final result = logger.redactCtxForTest(ctx);
      expect(result['note'], isNot(contains('sk-embedded-in-a-sentence')));
    });

    test('redacts a Gemini-style ?key= query param embedded in a ctx value',
        () {
      final ctx = <String, dynamic>{
        'url': 'https://generativelanguage.googleapis.com/v1beta/models/'
            'gemini-pro:generateContent?key=AIzaSyD-realsecretvalue1234',
      };
      final result = logger.redactCtxForTest(ctx);
      expect(
          result['url'], isNot(contains('AIzaSyD-realsecretvalue1234')));
    });

    test(
        'redactStringForTest scrubs a token embedded in an error object\'s '
        'toString(), as unified_logger.e()/w()/d() do before writing to '
        'console or the JSONL file', () {
      final error = Exception(
          'Upstream call failed: Authorization: Bearer sk-liveTOKEN99887766');
      final result = logger.redactStringForTest(error.toString());
      expect(result, isNot(contains('sk-liveTOKEN99887766')));
      expect(result, contains('Bearer ***'));
    });
  });
}
