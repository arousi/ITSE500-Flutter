import '../../../models/model_descriptor.dart';

abstract class ModelCatalogAdapter {
  ProviderType get provider;
  Future<List<ModelDescriptor>> fetchModels(
      {required String? apiKeyOrEndpoint});
  // Optional curated fallback when key is missing or fetch fails
  List<ModelDescriptor> fallbackModels();
}
