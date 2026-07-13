// auth_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_app_itse500/core/utils/default_api_base.dart';
import 'package:local_auth/local_auth.dart';

// removed duplicate import
import '../../../shared_preferences.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final dataRepo = DataRepository();
  final prefs = SharedPref();
  final logger = UnifiedLogger.instance;
  // Api calls via dataRepo facade
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  Timer? _inactivityTimer;
  Duration biometricInactivityTimeout = const Duration(minutes: 5);
  bool _biometricEnabled = false;

  /// Public method to set authenticated state from UI (e.g., after login)
  void setAuthenticated() {
    if (_biometricEnabled) {
      emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: 'startup'));
      attemptBiometricUnlock(reason: 'startup');
    } else {
      emit(AuthAuthenticated());
    }
    logger.i('AuthAuthenticated state emitted via setAuthenticated()');
  }

  /// Emits AuthGuest state for guest login (unified with CustomUser logic)
  void continueAsGuest(BuildContext context) async {
    logger.i('Starting offline visitor session (no server call)');
    emit(AuthLoading());
    try {
      // Persist storage mode default to local-only
      await prefs.saveString('storage_mode', 'local');
      // Ensure a local visitor ID exists
      String? localId = await prefs.getString('visitor_local_id');
      if (localId == null || localId.isEmpty) {
        // Generate a lightweight pseudo-UUID (no extra dependency)
        final rnd = Random();
        String fourHex() =>
            (rnd.nextInt(1 << 16)).toRadixString(16).padLeft(4, '0');
        localId =
            'v-${DateTime.now().millisecondsSinceEpoch.toRadixString(16)}${fourHex()}${fourHex()}';
        await prefs.saveString('visitor_local_id', localId);
      }
      // Clear any stale server tokens to truly stay offline until Mixed Storage is enabled
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      if (_biometricEnabled) {
        emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: 'startup'));
        attemptBiometricUnlock(reason: 'startup');
      } else {
        emit(AuthGuest());
      }
      logger.i('Offline visitor session ready (id=$localId)');
    } catch (e) {
      logger.e('Starting offline visitor session failed', error: e);
      emit(const AuthError('Failed to start visitor session locally.'));
    }
  }

  AuthCubit() : super(AuthInitial()) {
    _checkToken();
    _loadBiometricFlag();
    // Ensure deep links are initialized early so OAuth callbacks are captured
    // even if the Login screen hasn't built yet.
    initDeepLinks();
    logger.i('AuthCubit initialized; deep links listener starting.');
  }

  // ------------------ OpenRouter OAuth (PKCE via backend) ------------------
  StreamSubscription<Uri>? _linkSub;
  Uri? _initialLink;
  final AppLinks _appLinks = AppLinks();

  Future<void> initDeepLinks() async {
    try {
      // Get the initial uri (cold start)
      _initialLink = await _appLinks.getInitialLink();
      if (_initialLink != null) {
        logger.i('Initial deep link captured: ${_initialLink.toString()}');
        _handleIncomingUri(_initialLink!);
      }
      // Listen to subsequent links
      _linkSub ??= _appLinks.uriLinkStream.listen((uri) {
        logger.i('Deep link received: ${uri.toString()}');
        _handleIncomingUri(uri);
      }, onError: (err, st) {
        logger.e('Deep link error', error: err, stack: st);
      });
    } catch (e, st) {
      logger.e('initDeepLinks failed', error: e, stack: st);
    }
  }

  void dispose() {
    _linkSub?.cancel();
    super.close();
  }

  Future<void> startOpenRouterOAuth(
      {required String redirectSchemeHost}) async {
    // redirectSchemeHost like: prompeteer://oauth/openrouter
    emit(AuthOAuthInProgress('openrouter'));
    try {
      // Build authorize URL via backend JSON endpoint
      final base = _primaryApiBase();
      logger.i(
          'Starting OpenRouter OAuth; base=$base redirect=$redirectSchemeHost');
      final payload =
          await dataRepo.openRouterAuthorize(base, redirectSchemeHost);
      final authUrl = payload['authorize_url']?.toString();
      final state = payload['state']?.toString();
      logger.i('OpenRouter authorize payload: url=$authUrl state=$state');
      if (authUrl == null || state == null) {
        emit(const AuthOAuthError('openrouter', 'Malformed authorize payload'));
        return;
      }
      emit(AuthOAuthAwaitingRedirect(
          provider: 'openrouter',
          stateId: state,
          authorizeUri: Uri.parse(authUrl)));
      logger.i('Launching external browser for OpenRouter: $authUrl');
      final launched = await launchUrl(Uri.parse(authUrl),
          mode: LaunchMode.externalApplication);
      logger.i('launchUrl(OpenRouter) result=$launched');
      if (!launched) {
        emit(const AuthOAuthError('openrouter', 'Failed to launch browser'));
      }
    } catch (e) {
      emit(AuthOAuthError('openrouter', e.toString()));
    }
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    // Expect pattern: prompeteer://oauth/openrouter?code=...&state=...
    if (uri.host == 'oauth' && uri.pathSegments.isNotEmpty) {
      final first = uri.pathSegments.first;
      final bridge = uri.queryParameters['bridge'] == '1';
      final stateParam = uri.queryParameters['state'];
      if (bridge && stateParam != null) {
        await _finalizeBridgeResult(provider: first, stateParam: stateParam);
        return;
      }
      if (state is AuthOAuthInProgress ||
          state is AuthOAuthAwaitingRedirect ||
          state is AuthOAuthCompleting) {
        if (first == 'openrouter') {
          await completeOpenRouterOAuth(uri);
        } else if (first == 'google') {
          await completeGoogleOAuth(uri);
        } else if (first == 'microsoft') {
          await completeMicrosoftOAuth(uri);
        }
      }
    }
  }

  Future<void> _finalizeBridgeResult(
      {required String provider, required String stateParam}) async {
    emit(AuthOAuthCompleting(provider));
    try {
      final base = _primaryApiBase();
      final url = '${base}auth_api/oauth/result/$stateParam/';
      logger.i(
          'Finalizing OAuth via bridge; provider=$provider state=$stateParam url=$url');
      final payload = await dataRepo.getJson(url);
      final accessToken = payload['access_token']?.toString();
      final refreshToken = payload['refresh_token']?.toString();
      final providerAccess = payload['provider_access_token']?.toString();
      final idToken = payload['id_token']?.toString();
      if (accessToken != null) {
        await secureStorage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      if (providerAccess != null && providerAccess.isNotEmpty) {
        if (provider == 'openrouter') {
          await secureStorage.write(
              key: 'openrouter_key', value: providerAccess);
        }
      }
      if (idToken != null && provider == 'google') {
        await secureStorage.write(key: 'google_id_token', value: idToken);
      }
      // Persist toggle preference so UI can recover even if listener misses event
      try {
        if (provider == 'google') {
          await prefs.saveBool('google_auth_enabled', true);
        } else if (provider == 'openrouter') {
          await prefs.saveBool('openrouter_auth_enabled', true);
        } else if (provider == 'microsoft') {
          await prefs.saveBool('ms_auth_enabled', true);
        }
      } catch (_) {}
      emit(AuthOAuthSuccess(provider));
      emit(AuthAuthenticated());
    } catch (e) {
      emit(AuthOAuthError(provider, e.toString()));
    }
  }

  Future<void> completeOpenRouterOAuth(Uri returnUri) async {
    emit(const AuthOAuthCompleting('openrouter'));
    try {
      logger
          .i('Completing OpenRouter OAuth; returnUri=${returnUri.toString()}');
      final code = returnUri.queryParameters['code'];
      final stateParam = returnUri.queryParameters['state'];
      final error = returnUri.queryParameters['error'];
      if (error != null) {
        emit(AuthOAuthError('openrouter', error));
        return;
      }
      if (code == null || stateParam == null) {
        emit(const AuthOAuthError('openrouter', 'Missing code or state'));
        return;
      }
      final base = _primaryApiBase();
      logger.i('Exchanging OpenRouter code for tokens; state=$stateParam');
      final payload = await dataRepo.openRouterCallback(base,
          code: code, state: stateParam);
      final accessToken = payload['access_token']?.toString();
      final refreshToken = payload['refresh_token']?.toString();
      final providerAccess = payload['provider_access_token']?.toString();
      if (accessToken != null) {
        await secureStorage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      if (providerAccess != null && providerAccess.isNotEmpty) {
        await secureStorage.write(key: 'openrouter_key', value: providerAccess);
      }
      try {
        await prefs.saveBool('openrouter_auth_enabled', true);
      } catch (_) {}
      emit(const AuthOAuthSuccess('openrouter'));
      emit(AuthAuthenticated());
      logger
          .i('OpenRouter OAuth completed; tokens stored (jwt + provider key)');
    } catch (e) {
      emit(AuthOAuthError('openrouter', e.toString()));
    }
  }

  // ------------------ Google OAuth Flow ------------------
  Future<void> startGoogleOAuth({required String redirectSchemeHost}) async {
    emit(AuthOAuthInProgress('google'));
    try {
      final base = _primaryApiBase();
      // Ensure trailing slash for Google backend logic
      final redirectUri = redirectSchemeHost.endsWith('/')
          ? redirectSchemeHost
          : '$redirectSchemeHost/';
      // Load hotspot host if any
      await dataRepo.ensureHotspotHostLoaded();
      Map<String, dynamic> payload;
      final manual = dataRepo.manualHotspotHost;
      if (manual != null && manual.isNotEmpty) {
        payload = await dataRepo.googleAuthorizeWithHost(base,
            redirectUri: redirectUri, callbackHost: manual);
        logger
            .i('Google authorize requested with manual callback_host=$manual');
      } else {
        payload = await dataRepo.googleAuthorize(base, redirectUri);
      }
      final authUrl = payload['authorize_url']?.toString();
      final stateVal = payload['state']?.toString();
      logger.i(
          'Google authorize payload: url=$authUrl state=$stateVal redirectUri=$redirectUri');
      if (authUrl == null || stateVal == null) {
        emit(const AuthOAuthError('google', 'Malformed authorize payload'));
        return;
      }
      final patchedAuthUrl = _rewriteRedirectHostForEmulator(authUrl);
      emit(AuthOAuthAwaitingRedirect(
          provider: 'google',
          stateId: stateVal,
          authorizeUri: Uri.parse(authUrl)));
      logger.i('Launching external browser for Google: $patchedAuthUrl');
      final launched = await launchUrl(Uri.parse(patchedAuthUrl),
          mode: LaunchMode.externalApplication);
      logger.i('launchUrl(Google) result=$launched');
      if (!launched) {
        emit(const AuthOAuthError('google', 'Failed to launch browser'));
      }
    } catch (e) {
      emit(AuthOAuthError('google', e.toString()));
    }
  }

  Future<void> completeGoogleOAuth(Uri returnUri) async {
    emit(const AuthOAuthCompleting('google'));
    try {
      logger.i('Completing Google OAuth; returnUri=${returnUri.toString()}');
      final code = returnUri.queryParameters['code'];
      final stateParam = returnUri.queryParameters['state'];
      final error = returnUri.queryParameters['error'];
      if (error != null) {
        emit(AuthOAuthError('google', error));
        return;
      }
      if (code == null || stateParam == null) {
        emit(const AuthOAuthError('google', 'Missing code or state'));
        return;
      }
      final base = _primaryApiBase();
      final payload =
          await dataRepo.googleCallback(base, code: code, state: stateParam);
      final accessToken = payload['access_token']?.toString();
      final refreshToken = payload['refresh_token']?.toString();
      final idToken = payload['id_token']?.toString();
      final emailVerified = payload['email_verified'] == true;
      if (accessToken != null) {
        await secureStorage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      if (idToken != null) {
        await secureStorage.write(key: 'google_id_token', value: idToken);
      }
      if (emailVerified) await prefs.saveBool('email_verified', true);
      try {
        await prefs.saveBool('google_auth_enabled', true);
      } catch (_) {}
      emit(const AuthOAuthSuccess('google'));
      emit(AuthAuthenticated());
      logger.i(
          'Google OAuth completed; JWT stored. emailVerified=$emailVerified');
    } catch (e) {
      emit(AuthOAuthError('google', e.toString()));
    }
  }

  // ------------------ Microsoft OAuth Flow ------------------
  Future<void> startMicrosoftOAuth({required String redirectSchemeHost}) async {
    emit(AuthOAuthInProgress('microsoft'));
    try {
      final base = _primaryApiBase();
      final redirectUri = redirectSchemeHost.endsWith('/')
          ? redirectSchemeHost
          : '$redirectSchemeHost/';
      await dataRepo.ensureHotspotHostLoaded();
      final payload = await dataRepo.microsoftAuthorize(base, redirectUri);
      final authUrl = payload['authorize_url']?.toString();
      final stateVal = payload['state']?.toString();
      logger.i(
          'Microsoft authorize payload: url=$authUrl state=$stateVal redirectUri=$redirectUri');
      if (authUrl == null || stateVal == null) {
        emit(const AuthOAuthError('microsoft', 'Malformed authorize payload'));
        return;
      }
      final patchedAuthUrl = _rewriteRedirectHostForEmulator(authUrl);
      emit(AuthOAuthAwaitingRedirect(
          provider: 'microsoft',
          stateId: stateVal,
          authorizeUri: Uri.parse(authUrl)));
      logger.i('Launching external browser for Microsoft: $patchedAuthUrl');
      final launched = await launchUrl(Uri.parse(patchedAuthUrl),
          mode: LaunchMode.externalApplication);
      logger.i('launchUrl(Microsoft) result=$launched');
      if (!launched) {
        emit(const AuthOAuthError('microsoft', 'Failed to launch browser'));
      }
    } catch (e) {
      emit(AuthOAuthError('microsoft', e.toString()));
    }
  }

  Future<void> completeMicrosoftOAuth(Uri returnUri) async {
    emit(const AuthOAuthCompleting('microsoft'));
    try {
      logger.i('Completing Microsoft OAuth; returnUri=${returnUri.toString()}');
      final code = returnUri.queryParameters['code'];
      final stateParam = returnUri.queryParameters['state'];
      final error = returnUri.queryParameters['error'];
      if (error != null) {
        emit(AuthOAuthError('microsoft', error));
        return;
      }
      if (code == null || stateParam == null) {
        emit(const AuthOAuthError('microsoft', 'Missing code or state'));
        return;
      }
      final base = _primaryApiBase();
      final payload =
          await dataRepo.microsoftCallback(base, code: code, state: stateParam);
      final accessToken = payload['access_token']?.toString();
      final refreshToken = payload['refresh_token']?.toString();
      final idToken = payload['id_token']?.toString();
      if (accessToken != null) {
        await secureStorage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      if (idToken != null) {
        await secureStorage.write(key: 'microsoft_id_token', value: idToken);
      }
      try {
        await prefs.saveBool('ms_auth_enabled', true);
      } catch (_) {}
      emit(const AuthOAuthSuccess('microsoft'));
      emit(AuthAuthenticated());
      logger.i('Microsoft OAuth completed; tokens stored.');
    } catch (e) {
      emit(AuthOAuthError('microsoft', e.toString()));
    }
  }

  // Normalize Google's authorize_url redirect_uri: if backend returns localhost/10.0.2.2, rewrite to website domain
  String _rewriteRedirectHostForEmulator(String url) {
    try {
      if (!Platform.isAndroid) return url; // only needed for Android flows
      if (!url.contains('redirect_uri=')) return url;
      // Extract redirect_uri parameter
      final uri = Uri.parse(url);
      final params = Map<String, String>.from(uri.queryParameters);
      final rawRedirect = params['redirect_uri'];
      if (rawRedirect == null) return url;
      String decoded = Uri.decodeComponent(rawRedirect);
      final r = Uri.tryParse(decoded);
      if (r == null) return url;
      // If backend gave a local callback host, force it to use the production website which is authorized in Google console
      if (r.host == '127.0.0.1' ||
          r.host == 'localhost' ||
          r.host == '10.0.2.2') {
        // Keep the callback path; switch to https and website host; drop the port
        final newRedirectUri = Uri(
          scheme: 'https',
          host: 'www.itse500-ok.ly',
          path: r.path, // e.g., /api/v1/auth_api/google/callback/
          query: r.hasQuery ? r.query : null,
        ).toString();
        // Important: don't pre-encode here; Uri(queryParameters: ...) will encode once
        params['redirect_uri'] = newRedirectUri;
        final rebuilt = Uri(
          scheme: uri.scheme,
          host: uri.host,
          path: uri.path,
          queryParameters: params,
        );
        logger.i(
            'Rewrote redirect_uri host to production website for Google OAuth');
        return rebuilt.toString();
      }
      return url;
    } catch (e, st) {
      logger.w('Failed to rewrite redirect host', error: e, stack: st);
      return url;
    }
  }

  String _primaryApiBase() {
    // Prefer production website; DataRepository/ApiService will fallback to localhost and 192.x
    return defaultPrimaryApiBase();
  }

  /// Checks if JWT access token exists in secure storage
  Future<void> _checkToken() async {
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      if (_biometricEnabled) {
        emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: 'startup'));
        attemptBiometricUnlock(reason: 'startup');
      } else {
        emit(AuthAuthenticated());
      }
      return;
    }
    // Check for an existing local visitor session
    final localId = await prefs.getString('visitor_local_id');
    if (localId != null && localId.isNotEmpty) {
      if (_biometricEnabled) {
        emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: 'startup'));
        attemptBiometricUnlock(reason: 'startup');
      } else {
        emit(AuthGuest());
      }
      logger.i('Resuming offline visitor session (id=$localId)');
      return;
    }
    emit(AuthInitial());
  }

  void login(BuildContext context, String identifier, String password) async {
    logger.i(
        'Login attempt for identifier: $identifier'); // Do not log sensitive data
    emit(AuthLoading());
    try {
      final response = await dataRepo.login(identifier, password);
      final accessToken = response['access_token'] as String?;
      final refreshToken = response['refresh_token'] as String?;
      final emailVerified = response['email_verified'] == true;
      logger.i(
          'Login response received with access token: $accessToken and refresh token: $refreshToken');
      if (accessToken != null && refreshToken != null) {
        await secureStorage.write(key: 'access_token', value: accessToken);
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
        await prefs.saveBool('email_verified', emailVerified);
        // Enable syncing for registered users by default
        await prefs.saveString('storage_mode', 'mixed');
        emit(AuthAuthenticated());
        logger.i(
            'User authenticated (emailVerified=$emailVerified), tokens stored.');
        context.go('/home');
      } else {
        logger.e('Login failed: No tokens received');
        emit(const AuthError("Invalid credentials"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      logger.e('Login failed', error: e);
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      if (accessToken != null && accessToken.isNotEmpty) {
        final backendLogout = await dataRepo.logout(accessToken);
        if (!backendLogout) {
          logger.w(
              'Backend logout failed or token missing, but local tokens cleared.');
        }
      }
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'openrouter_key');
      await secureStorage.delete(key: 'google_id_token');
      await secureStorage.delete(key: 'custom_base_url');
      // Clear persisted auth provider toggles and biometric flag to avoid cross-account leakage
      try {
        await prefs.remove('google_auth_enabled');
        await prefs.remove('ms_auth_enabled');
        await prefs.remove('openrouter_auth_enabled');
        await secureStorage.delete(key: 'biometric_auth_enabled');
      } catch (_) {}
      // Also clear any cached manual hotspot host from repository secure storage key
      // (Repository method keeps in-memory cache; we intentionally do not clear that to allow re-login session decisions)
      logger.i('User logged out and tokens cleared from secure storage');
      emit(AuthInitial());
    } catch (e) {
      logger.e('Logout failed', error: e);
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'openrouter_key');
      await secureStorage.delete(key: 'google_id_token');
      try {
        await prefs.remove('google_auth_enabled');
        await prefs.remove('ms_auth_enabled');
        await prefs.remove('openrouter_auth_enabled');
        await secureStorage.delete(key: 'biometric_auth_enabled');
      } catch (_) {}
      emit(AuthInitial());
    }
  }

  /// Visitor logout: purge all local data and reset to initial state.
  Future<void> logoutVisitorAndPurge() async {
    emit(AuthLoading());
    try {
      // Clear secure storage tokens and provider keys if any
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'openrouter_key');
      await secureStorage.delete(key: 'google_id_token');
      await secureStorage.delete(key: 'custom_base_url');
      // Clear visitor ids and privacy mode to defaults
      try {
        await prefs.remove('visitor_local_id');
        await prefs.remove('visitor_server_uuid');
        await prefs.remove('last_registration_response');
        await prefs.saveString('storage_mode', 'local');
        await prefs.remove('google_auth_enabled');
        await prefs.remove('ms_auth_enabled');
        await prefs.remove('openrouter_auth_enabled');
        await secureStorage.delete(key: 'biometric_auth_enabled');
      } catch (_) {}
      // Purge local DB (users, conversations, messages, oauth tables)
      await dataRepo.deleteAllLocalData();
      emit(AuthInitial());
    } catch (e) {
      logger.e('Visitor purge failed', error: e);
      emit(AuthInitial());
    }
  }

  /// Sign Up method (server first, then local)
  void signUp({
    required String username,
    required String email,
    required String userId,
    String? password,
  }) async {
    logger.i(
        'Signup attempt for username: $username'); // Do not log sensitive data
    emit(AuthLoading());
    try {
      final resp = await dataRepo.signUp(username, email, password: password);
      logger.i('Server registration response received');
      try {
        // Cache enriched response so ProfileCubit can show fields immediately after signup
        final enriched = <String, dynamic>{}..addAll(resp);
        // Ensure username/email/user_id exist in cache even if backend omitted them
        enriched['username'] =
            (enriched['username']?.toString().isNotEmpty == true)
                ? enriched['username']
                : username;
        enriched['email'] = (enriched['email']?.toString().isNotEmpty == true)
            ? enriched['email']
            : email;
        if ((enriched['user_id']?.toString().isNotEmpty ?? false) == false &&
            userId.isNotEmpty) {
          enriched['user_id'] = userId;
        }
        await prefs.saveString(
            'last_registration_response', jsonEncode(enriched));
      } catch (_) {}
      // Store tokens if provided so profile can load immediately
      final accessToken = resp['access_token']?.toString();
      final refreshToken = resp['refresh_token']?.toString();
      if (accessToken != null && accessToken.isNotEmpty) {
        await secureStorage.write(key: 'access_token', value: accessToken);
      }
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await secureStorage.write(key: 'refresh_token', value: refreshToken);
      }
      // If tokens were issued, switch to mixed mode so ProfileCubit will fetch from server
      if ((accessToken != null && accessToken.isNotEmpty) ||
          (refreshToken != null && refreshToken.isNotEmpty)) {
        try {
          await prefs.saveString('storage_mode', 'mixed');
        } catch (_) {}
      }
      final serverUserId = resp['user_id']?.toString() ?? userId;
      try {
        await dataRepo.insertUser(username, email, serverUserId);
      } catch (e, st) {
        logger.w(
            'Local DB insert failed (web worker likely missing). Continuing.',
            error: e,
            stack: st);
      }
      emit(AuthRegistrationNoEmailVerification());
      logger.i('User registered locally (unverified)');
    } catch (e) {
      emit(AuthError(e.toString()));
      logger.e('Signup failed', error: e);
    }
  }

  // ------------------ Biometric Foreground Lock ------------------
  Future<void> _loadBiometricFlag() async {
    try {
      final raw = await secureStorage.read(key: 'biometric_auth_enabled');
      _biometricEnabled = raw == 'true';
    } catch (_) {
      _biometricEnabled = false;
    }
  }

  Future<void> refreshBiometricEnabled() async => _loadBiometricFlag();

  void applyBiometricPreferenceChanged(bool enabled) {
    _biometricEnabled = enabled;
    // If enabling while already authenticated/guest, lock then prompt.
    if (enabled && (state is AuthAuthenticated || state is AuthGuest)) {
      emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: 'enabled'));
      attemptBiometricUnlock(reason: 'enabled');
    } else if (!enabled && state is AuthBiometricLocked) {
      // Return to authenticated state when disabling during a lock.
      emit(AuthAuthenticated());
    }
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    if (!_biometricEnabled) return;
    _inactivityTimer = Timer(biometricInactivityTimeout, () {
      _relock(reason: 'inactivity');
    });
  }

  void userActivityPing() {
    // Call from UI interactions to keep session unlocked
    if (state is AuthAuthenticated) {
      _startInactivityTimer();
    }
  }

  Future<void> attemptBiometricUnlock({String reason = 'manual'}) async {
    if (!_biometricEnabled) {
      if (state is AuthBiometricLocked) {
        // If disabled while locked just go to authenticated
        emit(AuthAuthenticated());
      }
      return;
    }
    try {
      final supported = await _localAuth.isDeviceSupported();
      final hasBioApi = await _localAuth.canCheckBiometrics;
      final available = await _localAuth.getAvailableBiometrics();

      if (!(supported || hasBioApi) || available.isEmpty) {
        // No enrolled biometrics
        emit(AuthBiometricLocked(
            lockedAt: DateTime.now(), reason: 'unavailable'));
        return;
      }

      emit(AuthBiometricAuthenticating(
          startedAt: DateTime.now(), reason: reason));
      emit(AuthBiometricAuthenticating(
          startedAt: DateTime.now(), reason: reason));
      final ok = await _localAuth.authenticate(
        localizedReason: 'Unlock to continue',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      if (ok) {
        emit(AuthAuthenticated());
        _startInactivityTimer();
      } else {
        emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: reason));
      }
    } catch (e) {
      logger.w('Biometric auth failed', error: e);
      emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: 'error'));
    }
  }

  void _relock({String reason = 'manual'}) {
    if (_biometricEnabled) {
      emit(AuthBiometricLocked(lockedAt: DateTime.now(), reason: reason));
    }
  }

  void setBiometricInactivityTimeout(Duration d) {
    biometricInactivityTimeout = d;
    if (state is AuthAuthenticated) _startInactivityTimer();
  }

  @override
  Future<void> close() {
    _inactivityTimer?.cancel();
    return super.close();
  }
}
