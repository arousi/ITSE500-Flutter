import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/utils/log_redaction.dart';

void main() {
  group('LogRedaction.redactString', () {
    test('redacts a Bearer token', () {
      const input = 'Authorization: Bearer sk-abc123XYZ456';
      final result = LogRedaction.redactString(input);
      expect(result, isNot(contains('sk-abc123XYZ456')));
      expect(result, contains('Bearer ***'));
    });

    test('redacts a raw OpenAI-style key without a Bearer prefix', () {
      const input = 'key=sk-proj-abcdef1234567890';
      expect(LogRedaction.redactString(input),
          isNot(contains('sk-proj-abcdef1234567890')));
    });

    test('redacts a raw Google API key (AIza... prefix)', () {
      const input = 'Using key AIzaSyD-abcdefghijklmnopqrstuvwxyz1234';
      expect(LogRedaction.redactString(input),
          isNot(contains('AIzaSyD-abcdefghijklmnopqrstuvwxyz1234')));
    });

    test('redacts a raw Hugging Face key (hf_... prefix)', () {
      const input = 'token hf_abcdefghijklmnopqrstuvwxyz';
      expect(LogRedaction.redactString(input),
          isNot(contains('hf_abcdefghijklmnopqrstuvwxyz')));
    });

    test('redacts a ?key= query parameter (Gemini-style URL)', () {
      const input =
          'https://generativelanguage.googleapis.com/v1beta/models/'
          'gemini-pro:generateContent?key=AIzaSyD-abcdefghijklmnopqrstuvwxyz1234';
      final result = LogRedaction.redactString(input);
      expect(result, isNot(contains('AIzaSyD-abcdefghijklmnopqrstuvwxyz1234')));
      expect(result, contains('?key=***'));
      // Path before the query string is preserved (not fully hidden).
      expect(result, contains('generativelanguage.googleapis.com'));
    });

    test('redacts an &access_token= query parameter', () {
      const input = 'https://example.com/callback?state=abc&access_token=deadbeef123';
      final result = LogRedaction.redactString(input);
      expect(result, isNot(contains('deadbeef123')));
      expect(result, contains('&access_token=***'));
    });

    test('leaves non-sensitive strings untouched', () {
      const input = 'Sending LLM request to https://api.openai.com/v1/';
      expect(LogRedaction.redactString(input), input);
    });
  });

  group('LogRedaction.redactMap', () {
    test('fully redacts values under sensitive key names, case-insensitively',
        () {
      final input = <String, dynamic>{
        'Authorization': 'Bearer sk-secret',
        'access_token': 'abc.def.ghi',
        'nested': {'api_key': 'sk-nested-secret', 'safe': 'ok'},
        'safeField': 'hello',
      };
      final result = LogRedaction.redactMap(input);
      expect(result['Authorization'], '***');
      expect(result['access_token'], '***');
      expect((result['nested'] as Map)['api_key'], '***');
      expect((result['nested'] as Map)['safe'], 'ok');
      expect(result['safeField'], 'hello');
    });

    test('scrubs a secret pattern embedded in a non-sensitive-key string value',
        () {
      final input = <String, dynamic>{
        'note': 'used Bearer sk-embedded-in-a-sentence-token for the call',
      };
      final result = LogRedaction.redactMap(input);
      expect(result['note'], isNot(contains('sk-embedded-in-a-sentence')));
    });

    test('scrubs a ?key= secret embedded in a url-valued field', () {
      final input = <String, dynamic>{
        'url': 'https://generativelanguage.googleapis.com/v1beta/models/'
            'gemini-pro:generateContent?key=AIzaSyD-realsecretvalue1234',
      };
      final result = LogRedaction.redactMap(input);
      expect(
          result['url'], isNot(contains('AIzaSyD-realsecretvalue1234')));
    });
  });
}
