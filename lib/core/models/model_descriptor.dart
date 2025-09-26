import 'model_category.dart';

enum ProviderType { openai, openrouter, gemini, lmstudio, huggingface }

class ModelDescriptor {
  final ProviderType provider;
  final String
      id; // provider-native id (e.g., "gpt-4o-mini" or "models/gemini-1.5-pro")
  final String displayName;
  final Set<ModelCategory> categories;
  final int? contextLength; // null if unknown
  final Map<String, dynamic> raw; // provider-specific payload
  // Pricing (per 1K tokens) if known; null when not provided by API or manual entry needed.
  final double? promptPrice;
  final double? completionPrice;
  // Whether provider says billing must be enabled / paid plan required to access this model.
  final bool requiresBilling;
  // Cached capability flags (vision = accepts image in, multimodal = image+text, embeddings, etc.)
  final bool visionCapable;
  final bool embeddingCapable;
  final bool imageGenCapable;
  // Last time (UTC) pricing/capability snapshot was updated.
  final DateTime? lastUpdated;

  const ModelDescriptor({
    required this.provider,
    required this.id,
    required this.displayName,
    required this.categories,
    this.contextLength,
    this.raw = const {},
    this.promptPrice,
    this.completionPrice,
    this.requiresBilling = false,
    this.visionCapable = false,
    this.embeddingCapable = false,
    this.imageGenCapable = false,
    this.lastUpdated,
  });

  bool get isChat =>
      categories.contains(ModelCategory.chat) ||
      categories.contains(ModelCategory.reasoning);
  bool get isEmbedding => categories.contains(ModelCategory.embeddings);
  bool get isImageGen => categories.contains(ModelCategory.image);
  bool get isMultimodal =>
      visionCapable || categories.contains(ModelCategory.image);
}
