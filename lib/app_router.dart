import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'auth_cubit_listenable.dart';
import 'features/auth/presentation/screens/loginscreen.dart';
import 'features/auth/presentation/screens/signupscreen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'mainscreen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/model_catalog/model_catalog_screen.dart';
import 'features/model_catalog/provider_models_screen.dart';
import 'core/widgets/not_found_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

GoRouter createRouter(BuildContext context) {
  final authCubit = BlocProvider.of<AuthCubit>(context);
  final authListenable = AuthCubitListenable(authCubit);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    refreshListenable: authListenable,
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: <RouteBase>[
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          // Single MainScreen wrapper to avoid nested AppBars
          return MainScreen(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (context, state) => const ChatScreen(),
          ),
          // Clean chat route without exposing conversationId in the URL
          GoRoute(
            path: '/chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
          ),
          GoRoute(
            path: '/chat/:conversationId',
            name: 'chat_legacy',
            builder: (context, state) {
              final cid = state.pathParameters['conversationId'];
              return ChatScreen(conversationId: cid);
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/models',
            name: 'models',
            builder: (context, state) => const ModelCatalogScreen(),
          ),
          GoRoute(
            path: '/models/:provider',
            name: 'provider_models',
            builder: (context, state) => ProviderModelsScreen(
                provider: state.pathParameters['provider']!),
          ),
        ],
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/guest',
        // Avoid instantiating a second MainScreen (which wraps another BlocListener)
        // Re-use ShellRoute MainScreen wrapper; present ChatScreen as content.
        builder: (context, state) => const ChatScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoggedIn = authState is AuthAuthenticated ||
          authState is AuthGuest ||
          authState is AuthRegistrationNoEmailVerification;
      final currentPath = state.uri.toString();
      final isOnAuth = currentPath == '/login' || currentPath == '/signup';
      if (!isLoggedIn && !isOnAuth) {
        return '/login';
      }
      if (isLoggedIn && isOnAuth) {
        return '/chat';
      }
      return null;
    },
  );
}
