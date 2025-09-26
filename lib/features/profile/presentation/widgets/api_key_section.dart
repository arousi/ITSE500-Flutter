import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/model_repository.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import 'package:flutter_app_itse500/features/profile/presentation/widgets/provider_config_block.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiKeySection extends StatefulWidget {
  final bool isEditable;

  const ApiKeySection({super.key, required this.isEditable});

  @override
  State<ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends State<ApiKeySection> {
  final _openAiController = TextEditingController();
  final _openRouterController = TextEditingController();
  final _geminiController = TextEditingController();
  final _lmStudioEndpointController =
      TextEditingController(text: 'http://127.0.0.1:1234/');
  final _huggingFaceKeyController = TextEditingController();
  // Enriched metadata cache for OpenRouter (model id -> meta map)
  final Map<String, Map<String, String>> _openRouterMeta = {};

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    const storage = FlutterSecureStorage();
    _openAiController.text = await storage.read(key: 'openai_key') ?? '';
    _openRouterController.text =
        await storage.read(key: 'openrouter_key') ?? '';
    // Migration: prefer new 'gemini_key', fallback to legacy 'google_key'
    _geminiController.text = (await storage.read(key: 'gemini_key')) ??
        (await storage.read(key: 'google_key')) ??
        '';
    _lmStudioEndpointController.text =
        await storage.read(key: 'lmstudio_endpoint') ??
            _lmStudioEndpointController.text;
    _huggingFaceKeyController.text =
        await storage.read(key: 'huggingface_key') ?? '';
    if (mounted) setState(() {});
  }

  // Grouping strategies
  Map<String, List<String>> _groupOpenAI(List<String> models) {
    final map = <String, List<String>>{};
    for (final m in models) {
      String cat = 'Other';
      final lower = m.toLowerCase();
      if (lower.contains('gpt-5')) {
        cat = 'GPT-5';
      } else if (lower.contains('gpt-4o')) {
        cat = 'GPT-4o';
      } else if (lower.contains('gpt-4')) {
        cat = 'GPT-4';
      } else if (lower.contains('gpt-3.5')) {
        cat = 'GPT-3.5';
      } else if (lower.contains('whisper')) {
        cat = 'Audio';
      } else if (lower.contains('tts')) {
        cat = 'TTS';
      } else if (lower.contains('dall') || lower.contains('image')) {
        cat = 'Image';
      } else if (lower.contains('embed')) {
        cat = 'Embeddings';
      }
      map.putIfAbsent(cat, () => []).add(m);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: (map[k]!..sort())};
  }

  Map<String, List<String>> _groupOpenRouter(List<String> models) {
    // Prefer grouping by vendor (top providers) if metadata is present, else fallback to prefix grouping
    final hasMeta = _openRouterMeta.isNotEmpty;
    final map = <String, List<String>>{};
    for (final id in models) {
      String group = 'Other';
      if (hasMeta && _openRouterMeta.containsKey(id)) {
        final meta = _openRouterMeta[id]!;
        final vendor = (meta['vendor'] ?? '').toLowerCase();
        if (vendor.contains('openai')) {
          group = 'OpenAI';
        } else if (vendor.contains('google'))
          group = 'Google';
        else if (vendor.contains('deepseek'))
          group = 'DeepSeek';
        else if (vendor.contains('anthropic'))
          group = 'Anthropic';
        else if (vendor.isNotEmpty) group = meta['vendor']!;
        // Secondary: bucket by context length if available
        final ctxStr = meta['ctx'];
        if (ctxStr != null) {
          final ctx = int.tryParse(ctxStr) ?? 0;
          final bucket =
              ctx <= 8192 ? ' ≤8k' : (ctx <= 32768 ? ' 8k–32k' : ' 32k+');
          group = '$group$bucket';
        }
        // Tertiary: modalities hint
        final inMods = (meta['in'] ?? '').toLowerCase();
        final outMods = (meta['out'] ?? '').toLowerCase();
        if (inMods.contains('image') || outMods.contains('image')) {
          group = '$group · Vision';
        }
      } else {
        final parts = id.split('/');
        group = parts.length > 1 ? parts.first : 'Other';
      }
      map.putIfAbsent(group, () => []).add(id);
    }
    final keys = map.keys.toList()..sort();
    for (final k in keys) {
      map[k]!.sort();
    }
    return {for (final k in keys) k: map[k]!};
  }

  Map<String, List<String>> _groupGemini(List<String> models) {
    final map = <String, List<String>>{};
    for (final m in models) {
      String cat = 'Gemini';
      if (m.contains('flash')) {
        cat = 'Flash';
      } else if (m.contains('vision')) {
        cat = 'Vision';
      } else if (m.contains('pro')) {
        cat = 'Pro';
      }
      map.putIfAbsent(cat, () => []).add(m);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: (map[k]!..sort())};
  }

  Map<String, List<String>> _groupLmStudio(List<String> models) {
    final map = <String, List<String>>{};
    for (final m in models) {
      String cat = 'Other';
      if (m.contains('-')) {
        cat = m.split('-').first;
      } else if (m.contains('_')) {
        cat = m.split('_').first;
      }
      map.putIfAbsent(cat, () => []).add(m);
    }
    final keys = map.keys.toList()..sort();
    return {for (final k in keys) k: (map[k]!..sort())};
  }

  Map<String, List<String>> _groupHuggingFace(List<String> models) {
    // Group by org/namespace (prefix before '/'), then maybe by broad family inside.
    final map = <String, List<String>>{};
    for (final id in models) {
      final parts = id.split('/');
      final org = parts.length > 1 ? parts.first : 'Other';
      map.putIfAbsent(org, () => []).add(id);
    }
    final keys = map.keys.toList()..sort();
    for (final k in keys) {
      map[k]!.sort();
    }
    return {for (final k in keys) k: map[k]!};
  }

  // Metadata builders
  Map<String, String> _metaDefault(String _) => {};
  Map<String, String> _metaOpenRouter(String id) => _openRouterMeta[id] ?? {};

  @override
  Widget build(BuildContext context) {
    final dataRepo = DataRepository();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Providers header
        Text('Providers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        // Order: 1 Gemini 2 LM Studio 3 OpenAI 4 OpenRouter
        ProviderConfigBlock(
          providerKey: 'huggingface',
          displayName: 'HuggingFace',
          isEditable: widget.isEditable,
          usesApiKey: true,
          controller: _huggingFaceKeyController,
          onValidate: (k) async =>
              k.startsWith('hf_') && k.length > 10, // simple prefix heuristic
          onFetchModels: (k) async {
            // For MVP we rely on fallback curated list in ModelRepository
            // No network call until adapter wired to HF API.
            final list = await ModelRepository.I.getModels(
                provider: ProviderType.huggingface,
                apiKeyOrEndpoint: k,
                forceRefresh: true);
            return list.map((d) => d.id).toList();
          },
          groupingStrategy: _groupHuggingFace,
          metadataBuilder: _metaDefault,
          fieldLabel: 'HuggingFace API Token',
          docsUrl: 'https://huggingface.co/settings/tokens',
        ),
        const Divider(height: 32),
        ProviderConfigBlock(
          providerKey: 'gemini',
          displayName: 'Google Gemini',
          isEditable: widget.isEditable,
          usesApiKey: true,
          controller: _geminiController,
          onValidate: (k) => dataRepo.checkGoogleKey(k),
          onFetchModels: (k) => dataRepo.fetchGoogleGeminiModels(k),
          groupingStrategy: _groupGemini,
          metadataBuilder: _metaDefault,
          fieldLabel: 'Gemini API Key',
          docsUrl: 'https://aistudio.google.com/apikey',
        ),
        const Divider(height: 32),
        ProviderConfigBlock(
          providerKey: 'lmstudio',
          displayName: 'LM Studio',
          isEditable: widget.isEditable,
          usesApiKey: false,
          controller: _lmStudioEndpointController,
          autoValidateOnChange: false,
          onValidate: (endpoint) async {
            final status = await dataRepo.checkLmStudioStatus(endpoint);
            return status == 'up';
          },
          onFetchModels: (endpoint) async =>
              dataRepo.fetchLmStudioModels(baseUrl: endpoint),
          groupingStrategy: _groupLmStudio,
          metadataBuilder: _metaDefault,
          fieldLabel: 'LM Studio Base URL',
          docsUrl: 'https://lmstudio.ai',
        ),
        const Divider(height: 32),
        ProviderConfigBlock(
          providerKey: 'openai',
          displayName: 'OpenAI',
          isEditable: widget.isEditable,
          usesApiKey: true,
          controller: _openAiController,
          onValidate: (k) => dataRepo.checkOpenAiKey(k),
          onFetchModels: (k) => dataRepo.fetchOpenAIModels(k),
          groupingStrategy: _groupOpenAI,
          metadataBuilder: _metaDefault,
          fieldLabel: 'OpenAI API Key',
          docsUrl: 'https://platform.openai.com/api-keys',
        ),
        const Divider(height: 32),
        ProviderConfigBlock(
          providerKey: 'openrouter',
          displayName: 'OpenRouter',
          isEditable: widget.isEditable,
          usesApiKey: true,
          controller: _openRouterController,
          onValidate: (k) => dataRepo.checkOpenRouterKey(k),
          onFetchModels: (k) async {
            final ids =
                await dataRepo.fetchOpenRouterModels(k, forceRefresh: true);
            try {
              final raw = await dataRepo.fetchOpenRouterModelsRaw(k,
                  forceRefresh: true);
              _openRouterMeta.clear();
              for (final m in raw) {
                final id = (m['id'] ?? '').toString();
                if (id.isEmpty) continue;
                _openRouterMeta[id] = dataRepo.openRouterMetaFrom(m);
              }
            } catch (_) {}
            return ids;
          },
          groupingStrategy: _groupOpenRouter,
          metadataBuilder: _metaOpenRouter,
          fieldLabel: 'OpenRouter API Key',
          docsUrl: 'https://openrouter.ai/settings/keys',
        ),
      ],
    );
  }
}
