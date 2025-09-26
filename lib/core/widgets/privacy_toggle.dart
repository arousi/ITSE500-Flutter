import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/shared_preferences.dart';
import 'package:flutter_app_itse500/core/theme/app_theme.dart';

/// Reusable privacy toggle that controls global storage mode.
/// - local  => Private (on-device only)
/// - mixed  => Mixed (eligible for sync)
class PrivacyToggle extends StatefulWidget {
  final bool showLabel;
  final EdgeInsets labelPadding;
  final void Function(String mode)? onChanged;
  const PrivacyToggle(
      {super.key,
      this.showLabel = true,
      this.labelPadding = const EdgeInsets.only(right: 8),
      this.onChanged});

  @override
  State<PrivacyToggle> createState() => _PrivacyToggleState();
}

class _PrivacyToggleState extends State<PrivacyToggle> {
  String _mode = 'local';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SharedPref().getString('storage_mode');
    if (!mounted) return;
    setState(() => _mode = (v == 'mixed' || v == 'local') ? v! : 'local');
  }

  Future<void> _set(String m) async {
    await SharedPref().saveString('storage_mode', m);
    if (!mounted) return;
    setState(() => _mode = m);
    widget.onChanged?.call(m);
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = _mode == 'local';
    final icon = isPrivate ? Icons.lock_outline : Icons.cloud_outlined;
    final palette = Theme.of(context).extension<AppPalette>();
    final Color iconColor =
        palette?.primary ?? Theme.of(context).colorScheme.primary;
    final label = isPrivate ? 'Private' : 'Mixed';
    final bool onDark = Theme.of(context).appBarTheme.backgroundColor != null
        ? (Theme.of(context).appBarTheme.backgroundColor!.computeLuminance() <
            0.5)
        : Theme.of(context).brightness == Brightness.dark;
    final labelColor = onDark ? Colors.white : Colors.black87;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Icon(icon, color: iconColor),
        ),
        Switch.adaptive(
          value: isPrivate,
          onChanged: (v) => _set(v ? 'local' : 'mixed'),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: palette?.primary, // ON -> blue
          activeTrackColor:
              (palette?.primary ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.5),
        ),
        if (widget.showLabel)
          Padding(
            padding: widget.labelPadding,
            child:
                Text(label, style: TextStyle(fontSize: 12, color: labelColor)),
          ),
      ],
    );
  }
}
