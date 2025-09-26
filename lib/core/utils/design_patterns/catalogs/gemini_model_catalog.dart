import 'package:flutter_app_itse500/core/models/model_category.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';

import '../adapters/model_catalog_adapter.dart';

Set<ModelCategory> _categorizeGemini(Map<String, dynamic> m) {
  final name = (m['name'] as String? ?? '').toLowerCase();
  final methods =
      (m['supportedGenerationMethods'] as List?)?.cast<String>() ?? const [];
  final thinking = m['thinking'] == true;

  final cats = <ModelCategory>{};

  final isEmbedding =
      name.contains('embedding') || methods.contains('embedText');
  if (isEmbedding) cats.add(ModelCategory.embeddings);

  // Broaden image detection beyond just "imagen" models.
  final isImage = name.contains('imagen') ||
      name.contains('-image-') ||
      name.contains('image-generation') ||
      // Experimental flash image generation variants
      name.contains('flash-exp-image') ||
      // Generic suffix sometimes used
      name.endsWith('-image');
  if (isImage) {
    cats.add(ModelCategory.image);
    // Most Gemini image-capable models are also chat-capable (multimodal)
    cats.add(ModelCategory.chat);
  }

  if (thinking) {
    cats.add(ModelCategory.reasoning);
    cats.add(ModelCategory.chat);
  }

  if (cats.isEmpty) {
    if (methods.contains('generateContent') ||
        methods.contains('batchGenerateContent')) {
      cats.add(ModelCategory.chat);
    }
  }

  if (cats.isEmpty) cats.add(ModelCategory.other);
  return cats;
}

class GeminiModelCatalog implements ModelCatalogAdapter {
  @override
  ProviderType get provider => ProviderType.gemini;

  @override
  Future<List<ModelDescriptor>> fetchModels(
      {required String? apiKeyOrEndpoint}) async {
    if (apiKeyOrEndpoint == null || apiKeyOrEndpoint.isEmpty) {
      return fallbackModels();
    }
    // GET https://generativelanguage.googleapis.com/v1beta/models?key=API_KEY
    // Map response['models'].
    throw UnimplementedError(
        'Wire to ApiService, then map with _categorizeGemini');
  }

  @override
  List<ModelDescriptor> fallbackModels() {
    // Curated, safe defaults
    const names = [
      'models/gemini-2.5-flash', 'models/gemini-1.5-pro',
      'models/gemini-1.5-flash',
      // Add preview image-generation variant (returns inline image data with responseModalities)
      'models/gemini-2.0-flash-preview-image-generation',
      'models/gemma-3-4b-it', 'models/gemma-3-12b-it',
      'models/text-embedding-004',
      'models/imagen-3.0-generate-002',
    ];
    return names.map((n) {
      // Provide richer hints so _categorizeGemini can mark embeddings & image correctly.
      final methods = <String>["generateContent"];
      if (n.contains('embedding')) methods.add('embedText');
      return ModelDescriptor(
        provider: ProviderType.gemini,
        id: n,
        displayName: n.replaceFirst('models/', ''),
        categories: _categorizeGemini(
            {'name': n, 'supportedGenerationMethods': methods}),
      );
    }).toList();
  }
}
