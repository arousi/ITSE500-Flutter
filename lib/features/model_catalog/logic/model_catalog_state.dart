part of 'model_catalog_cubit.dart';

class ModelCatalogState extends Equatable {
  final Map<ProviderType, List<ModelDescriptor>>
      models; // cached models per provider
  final Map<ProviderType, DateTime> lastUpdated; // fetch timestamps
  final bool loading;
  final String? error;

  const ModelCatalogState({
    required this.models,
    required this.lastUpdated,
    required this.loading,
    required this.error,
  });

  const ModelCatalogState.initial()
      : models = const {},
        lastUpdated = const {},
        loading = false,
        error = null;

  ModelCatalogState copyWith({
    Map<ProviderType, List<ModelDescriptor>>? models,
    Map<ProviderType, DateTime>? lastUpdated,
    bool? loading,
    String? error,
  }) =>
      ModelCatalogState(
        models: models ?? this.models,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [models, lastUpdated, loading, error];
}
