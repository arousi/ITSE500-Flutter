import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

/// Shown by [GoRouter.errorBuilder] whenever the requested location doesn't
/// match any known route, so a stale/mistyped/unsupported deep link never
/// dead-ends on the framework's default gray error screen.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off, size: 64),
                const SizedBox(height: 16),
                Text(
                  l10n.pageNotFoundTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pageNotFoundMessage,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/chat'),
                  child: Text(l10n.goHome),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
