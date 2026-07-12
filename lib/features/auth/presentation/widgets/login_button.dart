import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const LoginButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: onPressed,
      child: Text(AppLocalizations.of(context)!.login.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
