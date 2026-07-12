import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class PolicyText extends StatelessWidget {
  const PolicyText({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        AppLocalizations.of(context)!.policyText,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
