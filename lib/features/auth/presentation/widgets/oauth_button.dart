import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';

class OAuthButton extends StatelessWidget {
  final String provider; // 'openrouter' | 'google'
  final IconData icon;
  final String idleLabel;
  final String busyLabel;
  const OAuthButton._({
    super.key,
    required this.provider,
    required this.icon,
    required this.idleLabel,
    required this.busyLabel,
  });

  factory OAuthButton.openRouter({Key? key}) => OAuthButton._(
        key: key,
        provider: 'openrouter',
        icon: Icons.vpn_key,
        idleLabel: 'Continue with OpenRouter',
        busyLabel: 'Connecting OpenRouter…',
      );

  factory OAuthButton.google({Key? key}) => OAuthButton._(
        key: key,
        provider: 'google',
        icon: Icons.g_mobiledata,
        idleLabel: 'Continue with Google',
        busyLabel: 'Connecting Google…',
      );

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
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(icon),
            label: Text(busy ? busyLabel : idleLabel),
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
