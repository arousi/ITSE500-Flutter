import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/model_repository.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';

part 'model_catalog_state.dart';

/// Lightweight cubit to cache per-provider model descriptor lists.
/// Future extensions: pricing merge, family grouping, search/sort filters.
class ModelCatalogCubit extends Cubit<ModelCatalogState> {
  ModelCatalogCubit() : super(const ModelCatalogState.initial());

  final ModelRepository _repo = ModelRepository.I;
  final UnifiedLogger _logger = UnifiedLogger.instance;

  Future<void> ensureLoaded(
      {required ProviderType provider,
      required String? credential,
      bool forceRefresh = false}) async {
    final s = state;
    if (!forceRefresh) {
      final last = s.lastUpdated[provider];
      if (last != null &&
          DateTime.now().difference(last) < const Duration(minutes: 5) &&
          (s.models[provider]?.isNotEmpty ?? false)) {
        return; // still fresh
      }
    }
    emit(s.copyWith(loading: true));
    try {
      final models = await _repo.getModels(
          provider: provider,
          apiKeyOrEndpoint: credential,
          forceRefresh: forceRefresh);
      final updatedModels = {...s.models, provider: models};
      final updatedTimes = {...s.lastUpdated, provider: DateTime.now()};
      emit(s.copyWith(
          models: updatedModels, lastUpdated: updatedTimes, loading: false));
      await _logger.event('catalog.fetch',
          payload: {'provider': provider.name, 'count': models.length},
          category: 'catalog',
          className: 'ModelCatalogCubit',
          methodName: 'ensureLoaded');
    } catch (e) {
      emit(s.copyWith(loading: false, error: e.toString()));
      await _logger.event('catalog.fetch.error',
          payload: {'provider': provider.name, 'error': e.toString()},
          category: 'catalog',
          className: 'ModelCatalogCubit',
          methodName: 'ensureLoaded',
          status: 'error');
    }
  }
}
