import '../../../models/model_category.dart';
import '../../../models/model_descriptor.dart';
import '../adapters/model_catalog_adapter.dart';

final _openAiKnownHeuristics = <String, Set<ModelCategory>>{
  // Chat
  'gpt-3.5-turbo': {ModelCategory.chat},
  'gpt-4o': {ModelCategory.chat},
  'gpt-4o-mini': {ModelCategory.chat},
  'gpt-4.1': {ModelCategory.chat},
  'gpt-4.1-mini': {ModelCategory.chat},
  'gpt-5': {ModelCategory.chat},
  'gpt-5-mini': {ModelCategory.chat},
  'gpt-5-nano': {ModelCategory.chat},
  // Reasoning
  'o1': {ModelCategory.reasoning},
  'o1-mini': {ModelCategory.reasoning},
  'o3': {ModelCategory.reasoning},
  'o3-mini': {ModelCategory.reasoning},
  // Image
  'gpt-image-1': {ModelCategory.image},
  'dall-e-3': {ModelCategory.image},
  'dall-e-2': {ModelCategory.image},
  // Embeddings
  'text-embedding-3-small': {ModelCategory.embeddings},
  'text-embedding-3-large': {ModelCategory.embeddings},
  'text-embedding-ada-002': {ModelCategory.embeddings},
  // Audio
  'whisper-1': {ModelCategory.audioTranscribe},
  'tts-1': {ModelCategory.audioTts},
  'tts-1-hd': {ModelCategory.audioTts},
  'gpt-4o-transcribe': {ModelCategory.audioTranscribe},
  'gpt-4o-mini-tts': {ModelCategory.audioTts},
  // Moderation
  'omni-moderation-latest': {ModelCategory.moderation},
};

Set<ModelCategory> _categorizeOpenAiId(String id) {
  final lower = id.toLowerCase();

  // direct matches or prefix matches of known keys
  for (final key in _openAiKnownHeuristics.keys) {
    if (lower == key || lower.startsWith('$key-')) {
      return _openAiKnownHeuristics[key]!;
    }
  }

  if (lower.contains('embedding')) return {ModelCategory.embeddings};
  if (lower.contains('whisper')) return {ModelCategory.audioTranscribe};
  if (lower.contains('tts')) return {ModelCategory.audioTts};
  if (lower.contains('moderation')) return {ModelCategory.moderation};
  if (lower.startsWith('dall-e') || lower.contains('image')) {
    return {ModelCategory.image};
  }
  if (lower.startsWith('o1') || lower.startsWith('o3')) {
    return {ModelCategory.reasoning};
  }
  if (lower.contains('instruct')) {
    return {ModelCategory.chat}; // legacy completion, treat as chat-capable
  }
  if (lower.startsWith('gpt-')) return {ModelCategory.chat};

  return {ModelCategory.other};
}

class OpenAiModelCatalog implements ModelCatalogAdapter {
  @override
  ProviderType get provider => ProviderType.openai;

  @override
  Future<List<ModelDescriptor>> fetchModels(
      {required String? apiKeyOrEndpoint}) async {
    if (apiKeyOrEndpoint == null || apiKeyOrEndpoint.isEmpty) {
      return fallbackModels();
    }

    // Minimal GET /v1/models (OpenAI returns sparse info)
    // Implement with your HTTP layer; mapping focuses on id -> categories via heuristics.
    // final resp = await http.get('https://api.openai.com/v1/models', headers: {...});
    // final data = jsonDecode(resp.body)['data'] as List;
    // return data.map((m) { ... }).toList();

    throw UnimplementedError('Wire to ApiService; use _categorizeOpenAiId(id)');
  }

  @override
  List<ModelDescriptor> fallbackModels() {
    const ids = [
      'gpt-4o',
      'gpt-4o-mini',
      'gpt-4.1',
      'gpt-4.1-mini',
      'o3-mini',
      'o1-mini',
      'text-embedding-3-small',
      'text-embedding-3-large',
      'gpt-image-1',
      'dall-e-3',
      'whisper-1',
      'tts-1',
      'omni-moderation-latest',
    ];
    return ids.map((id) {
      final cats = _categorizeOpenAiId(id);
      return ModelDescriptor(
        provider: ProviderType.openai,
        id: id,
        displayName: id,
        categories: cats,
      );
    }).toList();
  }
}
