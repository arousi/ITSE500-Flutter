import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

class ModelResolver {
  const ModelResolver();

  String? resolve(ProviderId provider, String? requested) {
    if (requested == null || requested.isEmpty) return null;
    // Only normalize provider-specific prefixes; never override the user’s selection.
    switch (provider) {
      case ProviderId.gemini:
        return requested.replaceFirst('models/', '');
      case ProviderId.openai:
      case ProviderId.openrouter:
      case ProviderId.lmstudio:
      case ProviderId.huggingface:
        return requested;
    }
  }
}
