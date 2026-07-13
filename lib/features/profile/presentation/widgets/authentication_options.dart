import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/logic/auth_cubit.dart';
import '../../../auth/logic/auth_providers.dart';
import '../../../profile/logic/profile_cubit.dart';
import 'package:flutter_app_itse500/l10n/app_localizations.dart';

class AuthenticationOptions extends StatefulWidget {
  final bool isEditable;

  const AuthenticationOptions({
    super.key,
    required this.isEditable,
  });

  @override
  State<AuthenticationOptions> createState() => _AuthenticationOptionsState();
}

class _AuthenticationOptionsState extends State<AuthenticationOptions> {
  bool googleEnabled = false;
  bool msAuthEnabled = false;
  bool openRouterEnabled = false;
  bool biometricEnabled = false;
  bool biometricSupported = true;
  final BiometricAuthService _biometricService = BiometricAuthService();
  final Set<String> _loading = {};
  static const _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadAuthOptions();
  }

  Future<void> _loadAuthOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final supported = await _biometricService.canCheck();
    final biometricRaw =
        await _secureStorage.read(key: 'biometric_auth_enabled');
    setState(() {
      // Default OFF: user must enable and complete OAuth successfully.
      googleEnabled = prefs.getBool('google_auth_enabled') ?? false;
      msAuthEnabled = prefs.getBool('ms_auth_enabled') ?? false;
      openRouterEnabled = prefs.getBool('openrouter_auth_enabled') ?? false;
      biometricEnabled =
          biometricRaw == 'true'; // Biometric must be explicitly enabled.
      biometricSupported = supported;
    });
  }

  Future<void> _saveAuthOption(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _handleGoogleAuth(bool value) async {
    if (_loading.contains('google')) return;
    setState(() {
      _loading.add('google');
    });
    if (value) {
      // Start OAuth; only mark enabled on success via BlocListener.
      context
          .read<AuthCubit>()
          .startGoogleOAuth(redirectSchemeHost: 'prompeteer://oauth/google');
    } else {
      // Immediate disable
      if (!mounted) return;
      setState(() {
        googleEnabled = false;
        _loading.remove('google');
      });
      await _saveAuthOption('google_auth_enabled', false);
    }
  }

  void _handleMsAuth(bool value) async {
    if (_loading.contains('ms')) return;
    setState(() {
      _loading.add('ms');
    });
    if (value) {
      context.read<AuthCubit>().startMicrosoftOAuth(
          redirectSchemeHost: 'prompeteer://oauth/microsoft');
    } else {
      if (!mounted) return;
      setState(() {
        msAuthEnabled = false;
        _loading.remove('ms');
      });
      await _saveAuthOption('ms_auth_enabled', false);
    }
  }

  void _handleOpenRouterAuth(bool value) async {
    if (_loading.contains('openrouter')) return;
    setState(() {
      _loading.add('openrouter');
    });
    if (value) {
      context.read<AuthCubit>().startOpenRouterOAuth(
          redirectSchemeHost: 'prompeteer://oauth/openrouter');
    } else {
      if (!mounted) return;
      setState(() {
        openRouterEnabled = false;
        _loading.remove('openrouter');
      });
      await _saveAuthOption('openrouter_auth_enabled', false);
    }
  }

  void _handleBiometricAuth(bool value) async {
    if (_loading.contains('biometric')) return;
    setState(() {
      _loading.add('biometric');
    });
    bool success = true;
    if (value) {
      final can = await _biometricService.canCheck();
      final types = await _biometricService.availableTypes();
      if (!can) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context)!.biometricNotSupportedDevice)));
      } else if (types.isEmpty) {
        success = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context)!.noBiometricsEnrolled)));
      } else {
        success = await _biometricService.authenticate();
      }
    } else {
      await _biometricService.disable();
    }
    if (!mounted) return;
    setState(() {
      biometricEnabled = success ? value : biometricEnabled;
      _loading.remove('biometric');
    });
    if (success) {
      await _secureStorage.write(
          key: 'biometric_auth_enabled', value: value ? 'true' : 'false');
      // Inform AuthCubit about preference change.
      if (mounted) {
        context.read<AuthCubit>().applyBiometricPreferenceChanged(value);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(AppLocalizations.of(context)!.biometricAuthFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        // On OAuth success, enable and persist the specific provider toggle.
        if (state is AuthOAuthSuccess) {
          if (state.provider == 'google') {
            setState(() {
              googleEnabled = true;
              _loading.remove('google');
            });
            await _saveAuthOption('google_auth_enabled', true);
          } else if (state.provider == 'microsoft') {
            setState(() {
              msAuthEnabled = true;
              _loading.remove('ms');
            });
            await _saveAuthOption('ms_auth_enabled', true);
          } else if (state.provider == 'openrouter') {
            setState(() {
              openRouterEnabled = true;
              _loading.remove('openrouter');
            });
            await _saveAuthOption('openrouter_auth_enabled', true);
          }
          // Force a fresh profile load to reflect any server-side changes
          try {
            context.read<ProfileCubit>().loadProfile(force: true);
          } catch (_) {}
        } else if (state is AuthOAuthError) {
          // Revert toggles on failure and clear loading state
          if (state.provider == 'google') {
            setState(() {
              googleEnabled = false;
              _loading.remove('google');
            });
            await _saveAuthOption('google_auth_enabled', false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.googleSignInFailed)));
            }
          } else if (state.provider == 'microsoft') {
            setState(() {
              msAuthEnabled = false;
              _loading.remove('ms');
            });
            await _saveAuthOption('ms_auth_enabled', false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.microsoftSignInFailed)));
            }
          } else if (state.provider == 'openrouter') {
            setState(() {
              openRouterEnabled = false;
              _loading.remove('openrouter');
            });
            await _saveAuthOption('openrouter_auth_enabled', false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.openRouterSignInFailed)));
            }
          }
        } else if (state is AuthAuthenticated) {
          // After auth state settles, re-load flags from SharedPreferences in case listener missed success
          await _loadAuthOptions();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.authentication, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(l10n.oauthProviders,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Card(
            child: Column(
              children: [
                _AuthSwitch(
                  title: 'OpenRouter',
                  subtitle: l10n.enableOpenRouterSignIn,
                  value: openRouterEnabled,
                  loading: _loading.contains('openrouter'),
                  onChanged: widget.isEditable ? _handleOpenRouterAuth : null,
                ),
                _AuthSwitch(
                  title: 'Google',
                  subtitle: l10n.enableGoogleSignIn,
                  value: googleEnabled,
                  loading: _loading.contains('google'),
                  onChanged: widget.isEditable ? _handleGoogleAuth : null,
                ),
                _AuthSwitch(
                  title: 'Microsoft',
                  subtitle: l10n.enableMicrosoftSignIn,
                  value: msAuthEnabled,
                  loading: _loading.contains('ms'),
                  onChanged: widget.isEditable ? _handleMsAuth : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.deviceSecurity,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Card(
            child: Column(
              children: [
                if (!biometricSupported)
                  ListTile(
                    leading: const Icon(Icons.fingerprint, color: Colors.grey),
                    title: Text(l10n.biometricNotAvailable),
                    subtitle: Text(l10n.biometricNotSupportedBody),
                  )
                else
                  _AuthSwitch(
                    title: l10n.biometricAuthentication,
                    subtitle: l10n.requireBiometricUnlock,
                    value: biometricEnabled,
                    loading: _loading.contains('biometric'),
                    onChanged: widget.isEditable ? _handleBiometricAuth : null,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AuthSwitch extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final bool loading;
  final ValueChanged<bool>? onChanged;
  const _AuthSwitch(
      {required this.title,
      this.subtitle,
      required this.value,
      required this.loading,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      secondary: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2))
          : null,
      value: value,
      onChanged: loading ? null : onChanged,
    );
  }
}
