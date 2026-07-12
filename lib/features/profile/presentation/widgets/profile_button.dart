import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.person),
      label: Text(AppLocalizations.of(context)!.profile.toUpperCase()),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        // Navigate to profile allowing back navigation
        context.pushNamed('profile');
      },
    );
  }
}
