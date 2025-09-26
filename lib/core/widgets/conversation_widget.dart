import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';

class ConversationWidget extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;

  const ConversationWidget({
    super.key,
    required this.conversation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPrivate = conversation.localOnly;
    return ListTile(
      leading: isPrivate
          ? SizedBox(
              width: 28,
              height: 28,
              child: Image.asset(
                // Fixed filename casing to match pubspec & actual asset to avoid fallback icon.
                'assets/imgs/inPrivate-Avatar.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.lock),
              ),
            )
          : null,
      title: Text(conversation.title ?? 'Untitled'),
      onTap: onTap,
    );
  }
}
