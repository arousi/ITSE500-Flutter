import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/openai_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/openrouter_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/gemini_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/lmstudio_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/huggingface_adapter.dart';

/// Abstract Factory to get the right adapter.
class ProviderAdapterFactory {
  ProviderAdapterFactory();

  ProviderAdapter forProvider(ProviderId id) {
    switch (id) {
      case ProviderId.openai:
        return OpenAIAdapter();
      case ProviderId.openrouter:
        return OpenRouterAdapter();
      case ProviderId.gemini:
        return GeminiAdapter();
      case ProviderId.lmstudio:
        return LMStudioAdapter();
      case ProviderId.huggingface:
        return HuggingFaceAdapter();
    }
  }
}
