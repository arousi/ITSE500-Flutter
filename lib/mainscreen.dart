import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/widgets/customAppBar.dart';
import 'package:flutter_app_itse500/core/widgets/drawer.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart'; // Unified logging
import 'package:flutter_bloc/flutter_bloc.dart'; // Import BlocProvider
import 'features/auth/logic/auth_cubit.dart'; // Import AuthCubit
//import 'package:go_router/go_router.dart'; // Import GoRouterState

import 'core/utils/design_patterns/repositories/data_repository.dart';
import 'shared_preferences.dart';
import 'features/auth/presentation/screens/signupscreen.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/profile/logic/profile_cubit.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:desktop_drop/desktop_drop.dart';
import 'core/utils/responsive.dart';
import 'l10n/app_localizations.dart';
import 'core/models/conversation.dart';

class MainScreen extends StatefulWidget {
  final Widget child;
  const MainScreen({super.key, Widget? child})
      : child = child ?? const ChatScreen();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _checkServerHealth();
    // If we mount while already authenticated (e.g., right after login navigation),
    // make sure the profile gets (re)loaded so UI doesn't keep stale "logged out" state.
    Future.microtask(() {
      final auth = context.read<AuthCubit>().state;
      if (auth is AuthAuthenticated ||
          auth is AuthGuest ||
          auth is AuthRegistrationNoEmailVerification) {
        try {
          context.read<ProfileCubit>().loadProfile(force: true);
        } catch (_) {}
      }
    });
  }

  Future<void> _checkServerHealth() async {
    final mode = await SharedPref().getString('storage_mode');
    if (mode == 'local') return; // Private: don't ping server
    final isUp = await DataRepository().healthCheck();
    if (!isUp && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.serverDownWarning)),
      );
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ChatCubit get chatCubit => context.read<ChatCubit>();

  @override
  Widget build(BuildContext context) {
    final logger = UnifiedLogger.instance;
    final onConversationTap = (Conversation conversation) {
      logger.i('Conversation tapped: ${conversation.title}');
      context
          .read<ChatCubit>()
          .setActiveConversationId(conversation.conversationId);
      context.go('/chat');
    };
    final bool useRail = context.isTablet || context.isDesktop;
    return Scaffold(
      key: _scaffoldKey,
      drawer: useRail ? null : CustomDrawer(onConversationTap: onConversationTap),
      // Removed const so CustomAppBar rebuilds and can detect current route (e.g., /profile) for back arrow logic
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.appTitle,
      ),
      body: Row(
        children: [
          if (useRail) const _MainNavigationRail(),
          if (useRail) const VerticalDivider(width: 1),
          Expanded(child: BlocListener<AuthCubit, AuthState>(
        listener: (context, astate) {
          // Reload profile whenever auth becomes active again
          if (astate is AuthAuthenticated ||
              astate is AuthGuest ||
              astate is AuthRegistrationNoEmailVerification) {
            try {
              context.read<ProfileCubit>().loadProfile(force: true);
            } catch (_) {}
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            logger.i('AuthState: ${state.runtimeType}');
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AuthBiometricLocked) {
              return _LockedOverlay(
                reason: state.reason,
                onUnlock: () => context
                    .read<AuthCubit>()
                    .attemptBiometricUnlock(reason: 'manual'),
              );
            } else if (state is AuthBiometricAuthenticating) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AuthAuthenticated ||
                state is AuthGuest ||
                state is AuthRegistrationNoEmailVerification) {
              // Authenticated (or guest) and not locked
              Widget content = GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => context.read<AuthCubit>().userActivityPing(),
                onPanDown: (_) => context.read<AuthCubit>().userActivityPing(),
                child: widget.child,
              );
              // Wrap with DropTarget on desktop for DnD
              if (!kIsWeb && Platform.isWindows) {
                content = DropTarget(
                  onDragDone: (detail) {
                    logger.i(
                        'Dropped files: \\n${detail.files.map((f) => f.path).join('\n')}');
                  },
                  child: content,
                );
              }
              return content;
            } else {
              return const SignUpScreen();
            }
          },
        ),
      )),
        ],
      ),
    );
  }
}

/// Desktop/tablet-only navigation rail shown beside the body instead of a
/// [Drawer]. Mirrors the primary destinations available from [CustomDrawer].
class _MainNavigationRail extends StatelessWidget {
  const _MainNavigationRail();

  int _indexFor(String location) {
    if (location.startsWith('/profile')) return 1;
    if (location.startsWith('/models')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    return NavigationRail(
      selectedIndex: _indexFor(location),
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: (index) {
        switch (index) {
          case 0:
            context.go('/chat');
            break;
          case 1:
            context.push('/profile');
            break;
          case 2:
            context.push('/models');
            break;
        }
      },
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.chat_bubble_outline),
          selectedIcon: const Icon(Icons.chat_bubble),
          label: Text(AppLocalizations.of(context)!.chat),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          label: Text(AppLocalizations.of(context)!.profile),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.auto_awesome_motion_outlined),
          selectedIcon: const Icon(Icons.auto_awesome_motion),
          label: Text(AppLocalizations.of(context)!.models),
        ),
      ],
    );
  }
}

class _LockedOverlay extends StatelessWidget {
  final String reason;
  final VoidCallback onUnlock;
  const _LockedOverlay({required this.reason, required this.onUnlock});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black87)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.white70),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.locked(reason),
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.fingerprint),
                label: Text(AppLocalizations.of(context)!.unlock),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
