import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStatusRow extends StatefulWidget {
  final bool
      showProviders; // if true show provider chips, else only biometric status
  const AuthStatusRow({super.key, this.showProviders = false});
  @override
  State<AuthStatusRow> createState() => _AuthStatusRowState();
}

class _AuthStatusRowState extends State<AuthStatusRow> {
  bool _google = false;
  bool _ms = false;
  bool _biometric = false;
  bool _openRouter = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _google = p.getBool('google_auth_enabled') ?? false;
      _ms = p.getBool('ms_auth_enabled') ?? false;
      _biometric = p.getBool('biometric_auth_enabled') ?? false;
      _openRouter = p.getBool('openrouter_auth_enabled') ?? false; // reserved
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (widget.showProviders)
          _capabilityChip('Google', _google, Icons.g_mobiledata),
        if (widget.showProviders)
          _capabilityChip('Microsoft', _ms, Icons.account_circle_outlined),
        if (widget.showProviders)
          _capabilityChip('OpenRouter', _openRouter, Icons.vpn_key),
        InputChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fingerprint, size: 16),
              const SizedBox(width: 4),
              Text(_biometric ? 'Biometric Enabled' : 'Biometric Disabled'),
            ],
          ),
          selected: _biometric,
          onPressed: null, // view-only here; toggle lives in profile screen
        ),
      ],
    );
  }

  Widget _capabilityChip(String label, bool enabled, IconData icon) {
    return InputChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: enabled,
      onPressed: null,
    );
  }
}
