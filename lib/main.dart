import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';
import 'package:flutter_app_itse500/core/locale/locale_cubit.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:flutter_app_itse500/features/profile/logic/profile_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'features/model_catalog/logic/model_catalog_cubit.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'core/theme/theme_cubit.dart';
import 'core/theme/app_theme.dart';
import 'app_router.dart'; // Import the centralized router
import 'package:go_router/go_router.dart';
import 'core/utils/unified_logger.dart';
import 'core/di/locator.dart';
import 'core/desktop/desktop_init.dart';
import 'core/desktop/desktop_protocol.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Web uses Flutter's default HASH url strategy (e.g. /app/#/chat/5).
  // The app is served by Django under /app/ with <base href> rewritten to
  // /static/flutter-web/ (see ITSE500-Django/core/views.py). A path-based
  // strategy round-trips those two prefixes incorrectly: in-app navigation
  // rewrites the visible URL to /static/flutter-web/<route>, which 404s on
  // refresh because Django's static route only serves literal files there.
  // Hash URLs are immune to this — only the fragment changes, so the
  // browser never sends the internal route to the server. Do not switch
  // back to a path strategy without first reconciling base href with the
  // actual /app/ mount path on the Django side.
  // Initialize sqflite: web uses FFI Web implementation; desktop uses FFI
  try {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  } catch (_) {
    // If Platform is unavailable (tests) or any error occurs, ignore;
    // mobile keeps default factory.
  }
  // Desktop window setup (Windows-only; fixed default size and centered)
  try {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      await initDesktopShell(
        title: 'ITSE500',
        initialSize: const Size(1280, 800),
        fixed: false,
        centerOnPrimary: true,
      );
    }
  } catch (_) {
    // Non-fatal; continue startup if desktop init fails (e.g., tests)
  }
  try {
    if (kIsWeb) {
      // On web the .env asset is publicly fetchable AND Django's collectstatic
      // drops dot-files (so it 404s anyway). Initialize dotenv with an empty map
      // — no network fetch, no console 404 — and rely on the in-code default
      // base URLs. Provider keys on web come from OAuth / secure storage, never
      // from a bundled .env.
      dotenv.testLoad(fileInput: '');
    } else {
      await dotenv.load(fileName: '.env');
    }
  } catch (e) {
    // Fallback silently if .env not packaged; defaults in code will be used.
    debugPrint('dotenv load failed (continuing with defaults): $e');
  }
  // Best-effort telemetry retention cleanup (non-blocking)
  // Keep 7 days by default; adjust as needed.
  // Fire and forget; ignore result to avoid startup delays.
  // Use Future.microtask to avoid blocking main isolate at startup.
  Future.microtask(() => UnifiedLogger.instance.cleanOldLogs(retainDays: 7));
  // Setup DI
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoRouter? _router; // lazily initialized once
  // Removed didChangeDependencies-based initialization because at that point
  // the AuthCubit provider is not yet in the widget tree. We now initialize
  // the router only after the MultiBlocProvider is built (see Builder below).

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<LocaleCubit>(
          create: (context) => LocaleCubit(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => ChatCubit(),
        ),
        BlocProvider<InferenceSettingsCubit>(
          create: (context) => InferenceSettingsCubit(),
        ),
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(dataRepo: DataRepository()),
        ),
        BlocProvider<ModelCatalogCubit>(
          create: (context) => ModelCatalogCubit(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Ensure router created after providers
          _router ??= createRouter(context);
          // Attach protocol routing for desktop deep links
          if (_router != null) {
            attachProtocolRouting(_router!);
          }
          return BlocBuilder<ThemeCubit, dynamic>(
            builder: (context, state) {
              // ThemeCubit emits ThemeState with a ThemeData field
              final ThemeData current =
                  (state as dynamic).themeData as ThemeData? ??
                      customLightTheme;
              final isDark = current.brightness == Brightness.dark;
              return BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return MaterialApp.router(
                    routerConfig: _router!,
                    title: 'ITSE500',
                    theme: customLightTheme,
                    darkTheme: customDarkTheme,
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    locale: locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
