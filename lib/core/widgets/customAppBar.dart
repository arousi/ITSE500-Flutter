import 'package:flutter/material.dart';
// shared_preferences used inside PrivacyToggle; no direct use here after refactor
import 'package:flutter_app_itse500/core/widgets/privacy_toggle.dart';
import 'package:flutter_app_itse500/core/theme/app_theme.dart';
import 'package:flutter_app_itse500/core/locale/locale_cubit.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/features/chat_inference/widgets/configure_dialog.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  const CustomAppBar({
    this.title,
    super.key,
  });

  bool _shouldShowMenu(BuildContext context, {required bool onProfile}) {
    // Show the hamburger only on top-level (non-profile) root pages where we cannot pop.
    if (onProfile) return false;
    final canPop = Navigator.of(context).canPop();
    if (canPop) return false; // if we can pop, prefer back arrow over menu
    return Scaffold.maybeOf(context)?.hasDrawer ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();
    final onProfile = location.startsWith('/profile');
    final palette = Theme.of(context).extension<AppPalette>();
    const titleStyle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20);
    return AppBar(
      elevation: 2,
      backgroundColor: palette?.appBar,
      leading: onProfile
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            )
          : (_shouldShowMenu(context, onProfile: onProfile)
              ? Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                )
              : (canPop
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    )
                  : null)),
      title: Text(title ?? AppLocalizations.of(context)!.appTitle,
          style: titleStyle),
      centerTitle: false,
      actions: [
        const Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 8.0),
          child: PrivacyToggle(),
        ),
        IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          tooltip: AppLocalizations.of(context)!.switchLanguage,
          onPressed: () => context.read<LocaleCubit>().toggle(),
        ),
        IconButton(
          icon: const Icon(Icons.add_comment, color: Colors.white),
          tooltip: AppLocalizations.of(context)!.newConversation,
          onPressed: () async {
            final chat = context.read<ChatCubit>();
            final id = await chat.startNewConversation();
            if (context.mounted) {
              // Keep the conversation id in app state, not in the URL
              chat.setActiveConversationId(id);
              context.go('/chat');
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          tooltip: AppLocalizations.of(context)!.configurationAndInference,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const ConfigureDialog(),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// (Old privacy widgets removed; using reusable PrivacyToggle now.)
