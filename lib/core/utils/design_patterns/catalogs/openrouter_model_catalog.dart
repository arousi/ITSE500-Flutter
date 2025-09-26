import 'package:flutter_app_itse500/core/models/model_category.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

import '../adapters/model_catalog_adapter.dart';

Set<ModelCategory> _categorizeOpenRouter(Map<String, dynamic> m) {
  final arch = (m['architecture'] as Map?) ?? {};
  final modality = (arch['modality'] as String? ?? '').toLowerCase();
  final outputs = (arch['output_modalities'] as List?)
          ?.cast<String>()
          .map((e) => e.toLowerCase())
          .toList() ??
      [];
  final id = (m['id'] as String? ?? '').toLowerCase();
  final tags = (m['tags'] as List?)
          ?.cast<String>()
          .map((e) => e.toLowerCase())
          .toList() ??
      [];

  final cats = <ModelCategory>{};

  // Text/chat determination
  if (modality.contains('text->text') ||
      outputs.contains('text') ||
      tags.contains('chat')) {
    cats.add(ModelCategory.chat);
  }

  // Image capability heuristics
  if (outputs.contains('image') ||
      tags.any((t) => t.contains('image')) ||
      id.contains('diffusion') ||
      id.contains('flux') ||
      id.contains('sd3') ||
      id.contains('stable-diffusion') ||
      id.contains('pixart') ||
      id.contains('recraft')) {
    cats.add(ModelCategory.image);
  }

  // Embeddings
  if (id.contains('embed') ||
      id.contains('embedding') ||
      tags.contains('embedding')) {
    cats.add(ModelCategory.embeddings);
  }

  // Reasoning / thinking models
  if (id.contains('reason') ||
      id.contains('/r1') ||
      id.contains('deepseek-r1') ||
      tags.contains('reasoning')) {
    cats.add(ModelCategory.reasoning);
    cats.add(ModelCategory.chat);
  }

  if (cats.isEmpty) cats.add(ModelCategory.other);
  return cats;
}

class OpenRouterModelCatalog implements ModelCatalogAdapter {
  @override
  ProviderType get provider => ProviderType.openrouter;

  @override
  Future<List<ModelDescriptor>> fetchModels(
      {required String? apiKeyOrEndpoint}) async {
    if (apiKeyOrEndpoint == null || apiKeyOrEndpoint.isEmpty) {
      return fallbackModels();
    }
    try {
      // Delegate raw fetch via DataRepository to leverage caching/logging.
      final raw = await DataRepository.instance
          .fetchOpenRouterModelsRaw(apiKeyOrEndpoint, forceRefresh: true);
      if (raw.isEmpty) return fallbackModels();
      final list = <ModelDescriptor>[];
      for (final m in raw) {
        final id = (m['id'] ?? '').toString();
        if (id.isEmpty) continue;
        final cats = _categorizeOpenRouter(m);
        final pricing =
            (m['pricing'] as Map?)?.map((k, v) => MapEntry(k.toString(), v));
        // OpenRouter pricing is USD per 1M tokens. Internally we store per 1K for consistency across providers.
        double? pPrompt;
        double? pComp;
        try {
          final pp = pricing?['prompt'];
          if (pp != null) {
            final v = double.tryParse(pp.toString());
            if (v != null) pPrompt = v / 1000.0; // normalize to per 1K
          }
          final pc = pricing?['completion'];
          if (pc != null) {
            final v = double.tryParse(pc.toString());
            if (v != null) pComp = v / 1000.0;
          }
        } catch (_) {}
        // Heuristic: mark billing required if any non-zero pricing present.
        final requiresBilling = (pPrompt ?? 0) > 0 || (pComp ?? 0) > 0;
        final arch = (m['architecture'] as Map?) ?? {};
        final outputs = (arch['output_modalities'] as List?)
                ?.cast<String>()
                .map((e) => e.toLowerCase())
                .toList() ??
            const <String>[];
        final visionCapable =
            outputs.contains('image') || outputs.contains('vision');
        final embeddingCapable =
            id.contains('embed') || id.contains('embedding');
        final imageCapable = outputs.contains('image');
        list.add(ModelDescriptor(
          provider: ProviderType.openrouter,
          id: id,
          displayName: id,
          categories: cats,
          raw: m.map((k, v) => MapEntry(k.toString(), v)),
          contextLength: (m['context_length'] ??
                  m['top_provider']?['context_length']) is int
              ? (m['context_length'] ?? m['top_provider']?['context_length'])
                  as int
              : null,
          promptPrice: pPrompt,
          completionPrice: pComp,
          requiresBilling: requiresBilling,
          visionCapable: visionCapable,
          embeddingCapable: embeddingCapable,
          imageGenCapable: imageCapable,
          lastUpdated: DateTime.now(),
        ));
      }
      return list;
    } catch (_) {
      return fallbackModels();
    }
  }

  @override
  List<ModelDescriptor> fallbackModels() {
    const ids = [
      'openrouter/auto',
      'anthropic/claude-3.7-sonnet',
      'meta-llama/llama-3.1-70b-instruct',
      'qwen/qwen2.5-7b-instruct',
      'google/gemma-3-27b-it'
    ];
    return ids
        .map((id) => ModelDescriptor(
              provider: ProviderType.openrouter,
              id: id,
              displayName: id,
              categories: {ModelCategory.chat},
            ))
        .toList();
  }
}
