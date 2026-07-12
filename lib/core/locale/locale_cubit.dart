import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app's active [Locale] (English / Arabic) and persists the
/// user's choice to SharedPreferences, mirroring the pattern used by
/// [ThemeCubit].
class LocaleCubit extends Cubit<Locale> {
  static const _prefsKey = 'app_locale';
  static const supported = [Locale('en'), Locale('ar')];

  LocaleCubit() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && supported.any((l) => l.languageCode == saved)) {
        emit(Locale(saved));
        return;
      }
      // Fall back to system locale if supported, else default to English.
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      if (supported.any((l) => l.languageCode == systemLocale.languageCode)) {
        emit(Locale(systemLocale.languageCode));
      }
    } catch (_) {
      // Keep default (English) on any failure.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supported.any((l) => l.languageCode == locale.languageCode)) return;
    emit(locale);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (_) {}
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}
