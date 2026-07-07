import 'package:flutter_app_itse500/core/models/model_category.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import '../adapters/model_catalog_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';

Set<ModelCategory> _categorizeHf(String id) {
  final lower = id.toLowerCase();
  final cats = <ModelCategory>{};
  if (lower.contains('embed') || lower.contains('sentence-transformers')) {
    cats.add(ModelCategory.embeddings);
  }
  if (lower.contains('diffusion') ||
      lower.contains('sd3') ||
      lower.contains('stable-diffusion') ||
      lower.contains('flux') ||
      lower.contains('-img') ||
      lower.contains('-image')) {
    cats.add(ModelCategory.image);
  }
  if (lower.contains('whisper') || lower.contains('asr')) {
    cats.add(ModelCategory.audioTranscribe);
  }
  if (lower.contains('tts') || lower.contains('bark')) {
    cats.add(ModelCategory.audioTts);
  }
  if (lower.contains('moderation') || lower.contains('guard')) {
    cats.add(ModelCategory.moderation);
  }
  if (lower.contains('reason') ||
      lower.contains('r1') ||
      lower.contains('deepseek-r1')) {
    cats.add(ModelCategory.reasoning);
  }
  if (lower.contains('instruct') ||
      lower.contains('chat') ||
      lower.contains('qwen') ||
      lower.contains('llama') ||
      lower.contains('mistral') ||
      lower.contains('phi') ||
      lower.contains('gemma')) {
    cats.add(ModelCategory.chat);
  }
  if (cats.isEmpty) cats.add(ModelCategory.other);
  return cats;
}

class HuggingFaceModelCatalog implements ModelCatalogAdapter {
  @override
  ProviderType get provider => ProviderType.huggingface;

  @override
  Future<List<ModelDescriptor>> fetchModels(
      {required String? apiKeyOrEndpoint}) async {
    // Hugging Face allows unauthenticated browsing but we prefer authenticated (more results, private models).
    // We'll limit to popular models (downloads sorted) and filter by pipeline_tag of interest.
    try {
      final raw = await DataRepository.instance
          .fetchHuggingFaceModelsRaw(apiKey: apiKeyOrEndpoint);
      if (raw.isEmpty) return fallbackModels();
      final List<ModelDescriptor> list = [];
      for (final m in raw) {
        final id = m['modelId'] ?? m['id'] ?? m['name'];
        if (id is! String || id.isEmpty) continue;
        final pipeline = m['pipeline_tag']?.toString();
        // Filter to tasks we care about (text generation, embeddings, image generation, ASR, TTS, moderation, reasoning)
        const allowedPipelines = {
          'text-generation',
          'text2text-generation',
          'feature-extraction',
          'sentence-similarity',
          'image-to-image',
          'text-to-image',
          'text-to-speech',
          'automatic-speech-recognition',
          'audio-to-audio',
          'zero-shot-classification'
        };
        if (pipeline != null &&
            pipeline.isNotEmpty &&
            !allowedPipelines.contains(pipeline)) {
          // Skip non-target tasks (e.g., token-classification) to keep catalog lean
          continue;
        }
        final cats = _categorizeHf(id);
        // downloads field available (m['downloads']) but currently only used indirectly for sort; skip individual variable.
        // Determine capability flags heuristically
        final lower = id.toLowerCase();
        final isVision = lower.contains('vision') || lower.contains('llava');
        final isEmbed = cats.contains(ModelCategory.embeddings) ||
            pipeline == 'feature-extraction' ||
            pipeline == 'sentence-similarity';
        final isImgGen = cats.contains(ModelCategory.image) ||
            (pipeline != null && (pipeline.contains('image')));
        list.add(ModelDescriptor(
          provider: ProviderType.huggingface,
          id: id,
          displayName: id.split('/').last,
          categories: cats,
          raw: m.map((k, v) => MapEntry(k.toString(), v)),
          contextLength: null,
          visionCapable: isVision,
          embeddingCapable: isEmbed,
          imageGenCapable: isImgGen,
          lastUpdated: DateTime.now(),
          requiresBilling: false,
          promptPrice: null,
          completionPrice: null,
        ));
      }
      if (list.isEmpty) return fallbackModels();
      // Sort pinned categories or by downloads desc if available
      list.sort((a, b) {
        final da = (a.raw['downloads'] ?? 0) as int? ?? 0;
        final db = (b.raw['downloads'] ?? 0) as int? ?? 0;
        return db.compareTo(da);
      });
      return list;
    } catch (e) {
      UnifiedLogger.instance
          .w('HF model fetch failed, using fallback', error: e);
      return fallbackModels();
    }
  }

  @override
  List<ModelDescriptor> fallbackModels() {
    const ids = [
      'mistralai/Mistral-7B-Instruct-v0.3',
      'meta-llama/Meta-Llama-3.1-8B-Instruct',
      'sentence-transformers/all-mpnet-base-v2',
      'stabilityai/stable-diffusion-2-1',
      'openai/whisper-small',
      'Qwen/Qwen2.5-7B-Instruct',
      'deepseek-ai/DeepSeek-R1-Distill-Qwen-7B',
    ];
    return ids
        .map((id) => ModelDescriptor(
              provider: ProviderType.huggingface,
              id: id,
              displayName: id.split('/').last,
              categories: _categorizeHf(id),
            ))
        .toList();
  }
}
