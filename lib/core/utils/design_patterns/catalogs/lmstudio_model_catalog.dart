import '../../../models/model_category.dart';
import '../../../models/model_descriptor.dart';
import '../adapters/model_catalog_adapter.dart';

Set<ModelCategory> _categorizeLmStudioId(String id) {
  final lower = id.toLowerCase();
  if (lower.contains('embed')) return {ModelCategory.embeddings};
  // Most local GGUFs are text chat/instruct
  return {ModelCategory.chat};
}

class LmStudioModelCatalog implements ModelCatalogAdapter {
  @override
  ProviderType get provider => ProviderType.lmstudio;

  @override
  Future<List<ModelDescriptor>> fetchModels(
      {required String? apiKeyOrEndpoint}) async {
    final endpoint = apiKeyOrEndpoint; // endpoint-as-key fallback
    if (endpoint == null || endpoint.isEmpty) return fallbackModels();
    // GET <endpoint>/v1/models (OpenAI compatible)
    throw UnimplementedError(
        'Wire to ApiService; map id -> categories with _categorizeLmStudioId');
  }

  @override
  List<ModelDescriptor> fallbackModels() {
    const ids = [
      'TheBloke/Mistral-7B-Instruct-GGUF',
      'Qwen/Qwen2.5-7B-Instruct-GGUF',
      'nomic-ai/nomic-embed-text-v1.5'
    ];
    return ids
        .map((id) => ModelDescriptor(
              provider: ProviderType.lmstudio,
              id: id,
              displayName: id.split('/').last,
              categories: _categorizeLmStudioId(id),
            ))
        .toList();
  }
}
