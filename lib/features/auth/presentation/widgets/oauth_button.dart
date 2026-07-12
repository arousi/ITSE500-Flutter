import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class OAuthButton extends StatelessWidget {
  final String provider; // 'openrouter' | 'google'
  final IconData icon;
  const OAuthButton._({
    super.key,
    required this.provider,
    required this.icon,
  });

  factory OAuthButton.openRouter({Key? key}) => OAuthButton._(
        key: key,
        provider: 'openrouter',
        icon: Icons.vpn_key,
      );

  factory OAuthButton.google({Key? key}) => OAuthButton._(
        key: key,
        provider: 'google',
        icon: Icons.g_mobiledata,
      );

  String _idleLabel(AppLocalizations l10n) => provider == 'google'
      ? l10n.continueWithGoogle
      : l10n.continueWithOpenRouter;

  String _busyLabel(AppLocalizations l10n) => provider == 'google'
      ? l10n.connectingGoogle
      : l10n.connectingOpenRouter;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthOAuthError && state.provider == provider) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('${providerLabel()} OAuth error: ${state.error}')),
          );
        } else if (state is AuthOAuthSuccess && state.provider == provider) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(successMessage())),
          );
        } else if (state is AuthOAuthAwaitingRedirect &&
            state.provider == provider) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening browser: ${state.authorizeUri}')),
          );
        }
      },
      builder: (context, state) {
        final busy = state is AuthOAuthInProgress ||
            state is AuthOAuthAwaitingRedirect ||
            state is AuthOAuthCompleting;
        final l10n = AppLocalizations.of(context)!;
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(icon),
            label: Text(busy ? _busyLabel(l10n) : _idleLabel(l10n)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              minimumSize: const Size.fromHeight(44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: busy
                ? null
                : () {
                    final cubit = context.read<AuthCubit>();
                    if (provider == 'openrouter') {
                      cubit.startOpenRouterOAuth(
                          redirectSchemeHost: 'prompeteer://oauth/openrouter');
                    } else if (provider == 'google') {
                      cubit.startGoogleOAuth(
                          redirectSchemeHost: 'prompeteer://oauth/google');
                    }
                  },
          ),
        );
      },
    );
  }

  String providerLabel() => provider == 'google' ? 'Google' : 'OpenRouter';
  String successMessage() => provider == 'google'
      ? 'Signed in with Google'
      : 'OpenRouter linked successfully';
}
