import 'package:flutter/material.dart';
import '../../../../core/widgets/privacy_toggle.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class StorageOptionsCard extends StatelessWidget {
  final String initialMode; // 'local' | 'mixed'
  final ValueChanged<String> onChanged;
  const StorageOptionsCard(
      {super.key, required this.initialMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Text(AppLocalizations.of(context)!.storageOptions,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            const Spacer(),
            PrivacyToggle(showLabel: true, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
