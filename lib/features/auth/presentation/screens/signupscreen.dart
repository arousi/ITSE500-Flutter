// sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';
import 'package:flutter_app_itse500/features/profile/logic/profile_cubit.dart';

import '../widgets/signup_form.dart';

class SignUpScreen extends StatelessWidget {
  // convert to stateful make it listen to states
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = UnifiedLogger.instance;
    logger.i('Building #SignUpScreen'); // No sensitive data
    return GestureDetector(
      onTap: () {
        logger.i('Tapped outside input fields');
        // Dismiss keyboard when tapping outside input fields.
        FocusScope.of(context).unfocus();
      },
      child: BlocListener<AuthCubit, AuthState>(
        listener: (ctx, state) async {
          // On successful registration (or if already authenticated), push to /home and refresh profile
          if (state is AuthRegistrationNoEmailVerification ||
              state is AuthAuthenticated ||
              state is AuthGuest) {
            try {
              ctx.read<ProfileCubit>().loadProfile(force: true);
            } catch (_) {}
            if (ctx.mounted) GoRouter.of(ctx).go('/home');
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: const SafeArea(
            minimum: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(width: double.infinity, child: SignUpForm())),
            ),
          ),
        ),
      ),
    );
  }
}
