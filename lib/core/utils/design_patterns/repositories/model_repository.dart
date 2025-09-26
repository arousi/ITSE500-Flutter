import 'dart:async';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import '../../pricing/manual_pricing_loader.dart';
import '../../pricing/pricing_markdown_writer.dart';

import '../adapters/model_catalog_adapter.dart';
import '../catalogs/openai_model_catalog.dart';
import '../catalogs/openrouter_model_catalog.dart';
import '../catalogs/gemini_model_catalog.dart';
import '../catalogs/lmstudio_model_catalog.dart';
import '../catalogs/huggingface_model_catalog.dart';

class ModelRepository {
  ModelRepository._();
  static final ModelRepository I = ModelRepository._();

  final Map<ProviderType, ModelCatalogAdapter> _adapters = {
    ProviderType.openai: OpenAiModelCatalog(),
    ProviderType.openrouter: OpenRouterModelCatalog(),
    ProviderType.gemini: GeminiModelCatalog(),
    ProviderType.lmstudio: LmStudioModelCatalog(),
    ProviderType.huggingface: HuggingFaceModelCatalog(),
  };

  final Map<ProviderType, List<ModelDescriptor>> _cache = {};
  final Map<ProviderType, Set<String>> _pinned =
      {}; // selected on profile_screen

  Future<List<ModelDescriptor>> getModels({
    required ProviderType provider,
    required String? apiKeyOrEndpoint,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache[provider]?.isNotEmpty == true) {
      return _cache[provider]!;
    }
    final adapter = _adapters[provider]!;
    try {
      final models =
          await adapter.fetchModels(apiKeyOrEndpoint: apiKeyOrEndpoint);
      await ManualPricingLoader.I.ensureLoaded();
      final enriched = models.map((m) {
        if (m.promptPrice != null || m.completionPrice != null) return m;
        final entry = ManualPricingLoader.I.lookup(m.provider, m.id);
        if (entry == null || (entry.prompt == null && entry.completion == null))
          return m;
        return ModelDescriptor(
          provider: m.provider,
          id: m.id,
          displayName: m.displayName,
          categories: m.categories,
          contextLength: m.contextLength,
          raw: m.raw,
          promptPrice: entry.prompt,
          completionPrice: entry.completion,
          requiresBilling: m.requiresBilling ||
              ((entry.prompt ?? 0) > 0 || (entry.completion ?? 0) > 0),
          visionCapable: m.visionCapable,
          embeddingCapable: m.embeddingCapable,
          imageGenCapable: m.imageGenCapable,
          lastUpdated: DateTime.now(),
        );
      }).toList();
      // Dedupe by canonical id (strip optional 'models/' prefix, lowercase)
      List<ModelDescriptor> dedupe(List<ModelDescriptor> list) {
        final seen = <String>{};
        String canon(String id) {
          final s =
              id.startsWith('models/') ? id.substring('models/'.length) : id;
          return s.toLowerCase();
        }

        final out = <ModelDescriptor>[];
        for (final d in list) {
          if (seen.add(canon(d.id))) out.add(d);
        }
        return out;
      }

      final deduped = dedupe(enriched);
      _cache[provider] = deduped;
      unawaited(PricingMarkdownWriter.I.upsertFromModels(deduped));
      return deduped;
    } catch (_) {
      final fallback = adapter.fallbackModels();
      await ManualPricingLoader.I.ensureLoaded();
      final enriched = fallback.map((m) {
        final entry = ManualPricingLoader.I.lookup(m.provider, m.id);
        if (entry == null) return m;
        return ModelDescriptor(
          provider: m.provider,
          id: m.id,
          displayName: m.displayName,
          categories: m.categories,
          contextLength: m.contextLength,
          raw: m.raw,
          promptPrice: entry.prompt,
          completionPrice: entry.completion,
          requiresBilling: m.requiresBilling ||
              ((entry.prompt ?? 0) > 0 || (entry.completion ?? 0) > 0),
          visionCapable: m.visionCapable,
          embeddingCapable: m.embeddingCapable,
          imageGenCapable: m.imageGenCapable,
          lastUpdated: DateTime.now(),
        );
      }).toList();
      // Dedupe fallback too
      List<ModelDescriptor> dedupe(List<ModelDescriptor> list) {
        final seen = <String>{};
        String canon(String id) {
          final s =
              id.startsWith('models/') ? id.substring('models/'.length) : id;
          return s.toLowerCase();
        }

        final out = <ModelDescriptor>[];
        for (final d in list) {
          if (seen.add(canon(d.id))) out.add(d);
        }
        return out;
      }

      final deduped = dedupe(enriched);
      _cache[provider] = deduped;
      unawaited(PricingMarkdownWriter.I.upsertFromModels(deduped));
      return deduped;
    }
  }

  List<ModelDescriptor> getCached(ProviderType provider) =>
      _cache[provider] ?? const [];

  void pinModel(ProviderType provider, String modelId, {bool pinned = true}) {
    final set = _pinned.putIfAbsent(provider, () => <String>{});
    if (pinned) {
      set.add(modelId);
    } else {
      set.remove(modelId);
    }
  }

  Set<String> getPinned(ProviderType provider) => _pinned[provider] ?? const {};

  // Utility to order pinned first
  List<ModelDescriptor> orderPinnedFirst(
      ProviderType provider, List<ModelDescriptor> models) {
    final pins = getPinned(provider);
    final pinned = <ModelDescriptor>[];
    final others = <ModelDescriptor>[];
    for (final m in models) {
      (pins.contains(m.id) ? pinned : others).add(m);
    }
    return [...pinned, ...others];
  }
}
