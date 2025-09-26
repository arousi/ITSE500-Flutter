import 'package:flutter/material.dart';
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
import 'package:dynamic_path_url_strategy/dynamic_path_url_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use path-based URLs on web (no # hash in the URL).
  // Extra safety: only attempt on web; swallow any unexpected errors.
  try {
    if (kIsWeb) {
      setPathUrlStrategy();
    }
  } catch (e) {
    debugPrint('Path URL strategy setup skipped: $e');
  }
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
    await dotenv.load(fileName: '.env');
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
              return MaterialApp.router(
                routerConfig: _router!,
                title: 'ITSE500',
                theme: customLightTheme,
                darkTheme: customDarkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              );
            },
          );
        },
      ),
    );
  }
}
