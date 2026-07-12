import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/core/theme/app_theme.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';
import '../../logic/auth_cubit.dart';

/// A reusable Material-styled logout button that triggers the AuthCubit logout method.
/// Place this widget anywhere in your UI to provide a logout action.
class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isGuest = state is AuthGuest;
        final palette = Theme.of(context).extension<AppPalette>();
        final l10n = AppLocalizations.of(context)!;
        return ElevatedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.white),
          label: Text(
            isGuest ? l10n.exitGuest : l10n.logout,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: palette?.logoutButton,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          onPressed: () async {
            if (isGuest) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.exitGuestModeTitle),
                  content: Text(l10n.exitGuestModeBody),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel)),
                    FilledButton.tonal(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.deleteAndExit)),
                  ],
                ),
              );
              if (confirmed == true) {
                await context.read<AuthCubit>().logoutVisitorAndPurge();
              }
            } else {
              // Normal server-aware logout
              // ignore: use_build_context_synchronously
              await context.read<AuthCubit>().logout();
            }
          },
        );
      },
    );
  }
}
