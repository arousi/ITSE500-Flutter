import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/model_resolver.dart';

void main() {
  const resolver = ModelResolver();

  group('ModelResolver.resolve', () {
    test('returns null when requested model is null or empty', () {
      expect(resolver.resolve(ProviderId.openai, null), isNull);
      expect(resolver.resolve(ProviderId.openai, ''), isNull);
    });

    test('strips "models/" prefix for Gemini', () {
      expect(resolver.resolve(ProviderId.gemini, 'models/gemini-1.5-flash'),
          'gemini-1.5-flash');
    });

    test('leaves an already-unprefixed Gemini model id unchanged', () {
      expect(resolver.resolve(ProviderId.gemini, 'gemini-1.5-pro'),
          'gemini-1.5-pro');
    });

    test('passes through model id unchanged for non-Gemini providers', () {
      for (final provider in [
        ProviderId.openai,
        ProviderId.openrouter,
        ProviderId.lmstudio,
        ProviderId.huggingface,
      ]) {
        expect(resolver.resolve(provider, 'some-model'), 'some-model');
      }
    });

    test('does not strip an internal "models/" occurrence for non-Gemini',
        () {
      expect(
        resolver.resolve(ProviderId.openai, 'org/models/foo'),
        'org/models/foo',
      );
    });
  });
}
