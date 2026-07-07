part of '../provider_config_block.dart';

class ConnectionField extends StatefulWidget {
  final String displayName;
  final String providerKey;
  final bool enabled;
  final Color statusColor;
  final String statusText;
  final TextEditingController controller;
  final bool usesApiKey;
  final bool isEditable;
  final bool checking;
  final bool connected;
  final String fieldLabel;
  final String docsUrl;
  final ValueChanged<bool> onToggleEnabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onFieldSubmitted;

  const ConnectionField({
    super.key,
    required this.displayName,
    required this.providerKey,
    required this.enabled,
    required this.statusColor,
    required this.statusText,
    required this.controller,
    required this.usesApiKey,
    required this.isEditable,
    required this.checking,
    required this.connected,
    required this.fieldLabel,
    required this.docsUrl,
    required this.onToggleEnabled,
    required this.onChanged,
    required this.onFieldSubmitted,
  });

  @override
  State<ConnectionField> createState() => _ConnectionFieldState();
}

class _ConnectionFieldState extends State<ConnectionField> {
  // API key fields start obscured; the user must explicitly reveal them.
  // Kept per-widget (not persisted) so the key is masked again on rebuild
  // (e.g. navigating away and back) rather than staying revealed forever.
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final displayName = widget.displayName;
    final enabled = widget.enabled;
    final statusColor = widget.statusColor;
    final statusText = widget.statusText;
    final controller = widget.controller;
    final usesApiKey = widget.usesApiKey;
    final isEditable = widget.isEditable;
    final checking = widget.checking;
    final connected = widget.connected;
    final fieldLabel = widget.fieldLabel;
    final docsUrl = widget.docsUrl;
    final onToggleEnabled = widget.onToggleEnabled;
    final onChanged = widget.onChanged;
    final onFieldSubmitted = widget.onFieldSubmitted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(value: enabled, onChanged: onToggleEnabled),
            Text(displayName, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(width: 12),
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: statusColor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(statusText,
                style: TextStyle(color: statusColor, fontSize: 12)),
            const Spacer(),
            IconButton(
              tooltip: 'Docs',
              icon: const Icon(Icons.open_in_new, size: 18),
              onPressed: () => launchUrl(Uri.parse(docsUrl)),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: enabled
              ? Column(
                  children: [
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: controller,
                      enabled: isEditable && enabled,
                      obscureText: usesApiKey && !_revealed,
                      decoration: InputDecoration(
                        labelText: fieldLabel,
                        border: const OutlineInputBorder(),
                        suffixIcon: checking
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (usesApiKey)
                                    IconButton(
                                      tooltip:
                                          _revealed ? 'Hide key' : 'Show key',
                                      icon: Icon(
                                        _revealed
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                      ),
                                      onPressed: () => setState(
                                          () => _revealed = !_revealed),
                                    ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      connected
                                          ? Icons.lock_open
                                          : Icons.lock_outline,
                                      color: statusColor,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      onChanged: onChanged,
                      onFieldSubmitted: (_) {
                        // Re-mask the key once it has been submitted/saved so
                        // the plaintext value isn't left visible on screen
                        // longer than necessary.
                        if (usesApiKey && _revealed) {
                          setState(() => _revealed = false);
                        }
                        onFieldSubmitted();
                      },
                      onEditingComplete: onFieldSubmitted,
                      onTapOutside: (_) {
                        if (usesApiKey && _revealed) {
                          setState(() => _revealed = false);
                        }
                        onFieldSubmitted();
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
