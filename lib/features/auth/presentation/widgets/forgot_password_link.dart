import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class ForgotPasswordLink extends StatelessWidget {
  const ForgotPasswordLink({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).go('/forgot-password');
      },
      child: Text(AppLocalizations.of(context)!.forgotPassword,
          style: const TextStyle(color: Colors.blue),
          textAlign: TextAlign.center),
    );
  }
}
