import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class SignupLink extends StatelessWidget {
  const SignupLink({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(l10n.newUserQuestion, style: Theme.of(context).textTheme.bodyLarge),
        GestureDetector(
          onTap: () => GoRouter.of(context).go('/signup'),
          child: Text(l10n.signup,
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
