import 'package:get_it/get_it.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  if (!locator.isRegistered<DataRepository>()) {
    locator.registerLazySingleton<DataRepository>(() => DataRepository());
  }
}
