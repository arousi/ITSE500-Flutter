import 'package:flutter_app_itse500/core/models/custom_user.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_app_itse500/features/profile/logic/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:flutter_app_itse500/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final DataRepository dataRepo;
  final UnifiedLogger logger;
  final SharedPref _prefs = SharedPref();

  ProfileCubit({required this.dataRepo, UnifiedLogger? logger})
      : logger = logger ?? UnifiedLogger.instance,
        super(ProfileInitial()) {
    loadProfile();
  }

  void loadProfile({bool force = false}) async {
    final current = state;
    // Only show a blocking loader if we have no data at all
    if (current is! ProfileLoaded &&
        current is! ProfileLoadedError &&
        current is! ProfileUnverified) {
      emit(ProfileLoading());
    }
    try {
      // Respect privacy mode: if local-only, don't hit server
      final mode = await _prefs.getString('storage_mode');
      final localOnly = (mode ?? 'local') == 'local';
      final accessToken = await secureStorage.read(key: 'access_token');
      // Private mode: prefer cached/local profile even if a token exists
      if (localOnly) {
        // Try cached profile first
        final cache = await _prefs.getString('last_profile_cache');
        if (cache != null && cache.isNotEmpty) {
          try {
            final profileMap = jsonDecode(cache) as Map<String, dynamic>;
            final user = CustomUser.fromJson(profileMap);
            emit(ProfileLoaded(
              username: user.username ?? '',
              email: user.email ?? '',
              firstName: user.firstName ?? '',
              lastName: user.lastName ?? '',
              phoneNumber: user.phoneNumber ?? '',
              emailVerified: user.emailVerified ?? false,
              profileEmailVerified: user.profileEmailVerified ?? false,
              userId: user.userId ?? '',
            ));
            return;
          } catch (e) {
            logger.w('Private mode: failed to parse last_profile_cache: $e');
          }
        }
        // Next, check recent registration response to at least show unverified identity
        try {
          final regJson = await _prefs.getString('last_registration_response');
          if (regJson != null && regJson.isNotEmpty) {
            final decoded = jsonDecode(regJson) as Map<String, dynamic>;
            final username = decoded['username']?.toString() ?? '';
            final email = decoded['email']?.toString() ?? '';
            final userId = decoded['user_id']?.toString() ?? '';
            if (email.isNotEmpty) {
              // Try local DB for richer details, otherwise emit unverified placeholder
              try {
                final custom = await dataRepo.fetchCustomUserByEmail(email);
                if (custom != null) {
                  final user = custom;
                  emit(ProfileLoaded(
                    username: user.username ?? username,
                    email: user.email ?? email,
                    firstName: user.firstName ?? '',
                    lastName: user.lastName ?? '',
                    phoneNumber: user.phoneNumber ?? '',
                    emailVerified: user.emailVerified ?? false,
                    profileEmailVerified: user.profileEmailVerified ?? false,
                    userId: user.userId ?? userId,
                  ));
                  return;
                }
              } catch (_) {}
              emit(ProfileUnverified(
                  username: username, email: email, userId: userId));
              return;
            }
          }
        } catch (e) {
          logger
              .w('Private mode: failed to use last_registration_response: $e');
        }
        // Nothing else: show visitor state rather than hard error
        logger
            .i('Private mode: no cached profile found; showing visitor state');
        emit(ProfileVisitor());
        return;
      }
      if (accessToken == null || accessToken.isEmpty) {
        // Check if we have a recent registration response (unverified user)
        final regJson = await _prefs.getString('last_registration_response');
        if (regJson != null && regJson.isNotEmpty) {
          try {
            final decoded = jsonDecode(regJson) as Map<String, dynamic>;
            final username = decoded['username']?.toString() ?? '';
            final email = decoded['email']?.toString() ?? '';
            final phone = decoded['phone_number']?.toString() ?? '';
            if (username.isNotEmpty || email.isNotEmpty) {
              logger.i(
                  'Emitting unverified profile from cached registration response');
              emit(ProfileUnverified(
                  username: username,
                  email: email,
                  phoneNumber: phone,
                  userId: decoded['user_id']?.toString() ?? ''));
              return;
            }
          } catch (e) {
            logger.w('Failed parsing last_registration_response: $e');
          }
        }
        // No token — check for offline visitor mode and attempt temp_id bootstrap only if not local-only
        final localId = await _prefs.getString('visitor_local_id');
        if (localId != null && localId.isNotEmpty) {
          if (!localOnly) {
            // Try to exchange local temp_id for tokens via unified GET
            final tokens =
                await dataRepo.ensureTokensViaTempId(tempId: localId);
            if (tokens != null && (tokens['access']?.isNotEmpty == true)) {
              logger.i(
                  'Obtained tokens via temp_id; proceeding to fetch profile');
            } else {
              logger.i(
                  'Visitor mode without tokens; staying offline (mixed disabled or server unreachable)');
            }
          }
          // In any case, show visitor state without blocking
          emit(ProfileVisitor());
          return;
        }
        logger.w(
            'Access token missing, no offline visitor id, and no registration cache.');
        emit(ProfileError('Access token is missing. Please log in again.'));
        return;
      }
      // Fetch full user profile from backend via unified GET (profile only)
      Map<String, dynamic> profileMap = <String, dynamic>{};
      if (localOnly) {
        // Skip network if local-only; try cached profile
        final cache = await _prefs.getString('last_profile_cache');
        if (cache != null && cache.isNotEmpty) {
          profileMap = jsonDecode(cache) as Map<String, dynamic>;
        } else {
          // fallback to legacy path (will error into catch)
          throw Exception('Local-only mode without cached profile');
        }
      } else {
        bool usedCacheDueToThrottle = false;
        try {
          final lastSyncStr = await _prefs.getString('last_profile_sync_at');
          if (!force && lastSyncStr != null && lastSyncStr.isNotEmpty) {
            final lastSync = DateTime.tryParse(lastSyncStr);
            if (lastSync != null &&
                DateTime.now().difference(lastSync) <
                    const Duration(hours: 1)) {
              final cache = await _prefs.getString('last_profile_cache');
              if (cache != null && cache.isNotEmpty) {
                logger.i('Profile sync throttled (<1h); using cached profile');
                profileMap = jsonDecode(cache) as Map<String, dynamic>;
                usedCacheDueToThrottle = true;
              }
            }
          }
        } catch (_) {
          // Ignore throttle parsing issues; fall through to network fetch
        }
        if (!usedCacheDueToThrottle) {
          final unified = await dataRepo.unifiedGetMe(
              profile: true, chat: false, accessToken: accessToken);
          // Preferred modern shape under 'profile'; fallback to 'user' then root
          if (unified['profile'] is Map) {
            profileMap = (unified['profile'] as Map).cast<String, dynamic>();
          } else if (unified['user'] is Map) {
            profileMap = (unified['user'] as Map).cast<String, dynamic>();
          } else {
            profileMap = unified.cast<String, dynamic>();
          }
          // Record last successful sync time
          await _prefs.saveString(
              'last_profile_sync_at', DateTime.now().toIso8601String());
        }
        // If throttle used cache and cache was missing, profileMap may still be empty; make a best-effort fetch
        if (profileMap.isEmpty) {
          final unified = await dataRepo.unifiedGetMe(
              profile: true, chat: false, accessToken: accessToken);
          if (unified['profile'] is Map) {
            profileMap = (unified['profile'] as Map).cast<String, dynamic>();
          } else if (unified['user'] is Map) {
            profileMap = (unified['user'] as Map).cast<String, dynamic>();
          } else {
            profileMap = unified.cast<String, dynamic>();
          }
          await _prefs.saveString(
              'last_profile_sync_at', DateTime.now().toIso8601String());
        }
      }

      // Use CustomUser model for parsing
      final user = CustomUser.fromJson(profileMap);
      // Cache successful profile for offline usage
      try {
        final cache = jsonEncode(profileMap);
        await _prefs.saveString('last_profile_cache', cache);
      } catch (e) {
        logger.w('Failed caching profile: $e');
      }
      emit(ProfileLoaded(
        username: user.username ?? '',
        email: user.email ?? '',
        firstName: user.firstName ?? '',
        lastName: user.lastName ?? '',
        phoneNumber: user.phoneNumber ?? '',
        emailVerified: user.emailVerified ?? false,
        profileEmailVerified: user.profileEmailVerified ?? false,
        userId: user.userId ?? '',
      ));
    } catch (e) {
      logger.e('Failed to load profile', error: e);
      // Fallback: keep current data if we have it, or load from cache
      if (current is ProfileLoaded || current is ProfileLoadedError) {
        final preserved =
            current is ProfileLoadedError ? current : current as ProfileLoaded;
        emit(ProfileLoadedError(
          errorMessage: (await _prefs.getString('storage_mode')) == 'local'
              ? 'Private mode: server profile fetch skipped (showing cached data if available)'
              : 'Could not reach server (showing cached data)',
          username: preserved.username,
          email: preserved.email,
          firstName: preserved.firstName,
          lastName: preserved.lastName,
          phoneNumber: preserved.phoneNumber,
          emailVerified: preserved.emailVerified,
          profileEmailVerified: preserved.profileEmailVerified,
          userId: preserved.userId,
        ));
      } else {
        // Try cached profile
        final cache = await _prefs.getString('last_profile_cache');
        if (cache != null && cache.isNotEmpty) {
          try {
            final decoded = jsonDecode(cache) as Map<String, dynamic>;
            emit(ProfileLoadedError(
              errorMessage: (await _prefs.getString('storage_mode')) == 'local'
                  ? 'Private mode (cached profile)'
                  : 'Offline mode (cached profile)',
              username: (decoded['username'] ?? '') as String,
              email: (decoded['email'] ?? '') as String,
              firstName: (decoded['first_name'] ?? '') as String,
              lastName: (decoded['last_name'] ?? '') as String,
              phoneNumber: (decoded['phone_number'] ?? '') as String,
              emailVerified: (decoded['email_verified'] ?? false) as bool,
              profileEmailVerified:
                  (decoded['profile_email_verified'] ?? false) as bool,
              userId: (decoded['user_id'] ?? '') as String,
            ));
            return;
          } catch (e2) {
            logger.w('Failed parsing cached profile: $e2');
          }
        }
        emit(ProfileError('Failed to load profile'));
      }
    }
  }

  void updateProfile(String username, String email, String password) async {
    final current = state;
    try {
      // If we have access token and mixed mode, use unified PATCH partial update
      final mode = await _prefs.getString('storage_mode');
      final localOnly = (mode ?? 'local') == 'local';
      final access = await secureStorage.read(key: 'access_token');
      if (!localOnly && access != null && access.isNotEmpty) {
        // Only update safe profile fields here. Do NOT send password via unified PATCH.
        await dataRepo.unifiedPatchMe(body: {
          'profile': {
            if (username.isNotEmpty) 'username': username,
            if (email.isNotEmpty) 'email': email,
          }
        }, accessToken: access);
      }
      // Always update local state
      if (current is ProfileLoaded) {
        emit(current.copyWith(username: username, email: email));
      } else {
        emit(ProfileLoaded(username: username, email: email));
      }
    } catch (e) {
      logger.e('Failed to update profile', error: e);
      if (current is ProfileLoaded) {
        emit(ProfileLoadedError(
          errorMessage: 'Failed to update profile',
          username: current.username,
          email: current.email,
          firstName: current.firstName,
          lastName: current.lastName,
          phoneNumber: current.phoneNumber,
          emailVerified: current.emailVerified,
          profileEmailVerified: current.profileEmailVerified,
          userId: current.userId,
        ));
      } else {
        emit(ProfileError('Failed to update profile'));
      }
    }
  }

  Future<void> verifyEmail({required String email, required String pin}) async {
    final current = state;
    try {
      await dataRepo.verifyEmailPin(email, pin);
      if (current is ProfileLoaded) {
        emit(current.copyWith(emailVerified: true));
      } else if (current is ProfileUnverified) {
        emit(ProfileLoaded(
            username: current.username,
            email: current.email,
            userId: current.userId,
            emailVerified: true));
      } else {
        loadProfile();
      }
    } catch (e) {
      logger.e('Email verification failed', error: e);
      if (current is ProfileLoaded) {
        emit(ProfileLoadedError(
          errorMessage: 'Email verification failed',
          username: current.username,
          email: current.email,
          firstName: current.firstName,
          lastName: current.lastName,
          phoneNumber: current.phoneNumber,
          emailVerified: current.emailVerified,
          profileEmailVerified: current.profileEmailVerified,
          userId: current.userId,
        ));
      } else if (current is ProfileUnverified) {
        emit(ProfileLoadedError(
          errorMessage: 'Email verification failed',
          username: current.username,
          email: current.email,
          phoneNumber: current.phoneNumber,
          userId: current.userId,
        ));
      } else {
        emit(ProfileError('Email verification failed'));
      }
    }
  }

  void sendFeedback() async {
    emit(ProfileLoading());
    try {
      // Use your real support emails here
      const recipients = <String>['sanad.arousi@outlook.com'];
      const subject = 'Feedback for the App';
      final deviceInfo =
          'OS=${Platform.operatingSystem} ${Platform.operatingSystemVersion}';

      // Preferred: compose an email with the structured log file attached (mail-only composer)
      final logFile = await _getTodayLogFile();
      if (logFile != null && await logFile.exists()) {
        try {
          final email = Email(
            subject: subject,
            recipients: recipients,
            body: 'Please describe your feedback above.\n\n$deviceInfo',
            attachmentPaths: [logFile.path],
            isHTML: false,
          );
          await FlutterEmailSender.send(email);
          logger.i('Opened mail composer with log attachment');
          emit(ProfileInitial());
          return;
        } on PlatformException catch (pe) {
          // Some devices/emulators have no mail client. Fallback to share sheet with attachment.
          logger.w('No email client available; falling back to share sheet',
              ctx: {'code': pe.code});
          await Share.shareXFiles(
            [XFile(logFile.path)],
            subject: subject,
            text:
                'To: ${recipients.join(', ')}\n\nPlease describe your feedback above.\n$deviceInfo',
          );
          emit(ProfileInitial());
          return;
        }
      }

      // Fallback: open default mail app (no attachment possible with mailto)
      final emailUri = Uri(
        scheme: 'mailto',
        path: recipients.join(','),
        queryParameters: {
          'subject': subject,
          'body': 'Please describe your feedback below.\n\n$deviceInfo',
        },
      );
      final launched =
          await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (launched) {
        logger.w('No log file found; opened plain email composer');
        emit(ProfileInitial());
        return;
      }

      // Last resort: Gmail web compose
      final gmailUri = Uri(
        scheme: 'https',
        host: 'mail.google.com',
        path: '/mail/',
        queryParameters: {
          'view': 'cm',
          'fs': '1',
          'to': recipients.join(','),
          'su': subject,
          'body': 'Please describe your feedback below.\n\n$deviceInfo',
        },
      );
      final webLaunched =
          await launchUrl(gmailUri, mode: LaunchMode.externalApplication);
      if (webLaunched) {
        logger.w('Mail app unavailable; opened Gmail web compose');
        emit(ProfileInitial());
        return;
      }

      await Clipboard.setData(ClipboardData(text: recipients.join(',')));
      throw Exception('Could not launch any email composer');
    } catch (e) {
      logger.e('Failed to send feedback with logs', error: e);
      emit(ProfileError(
          'Could not open mail/share. Support email copied to clipboard.'));
    }
  }

  // Locate today's structured log file written by StructuredLogger
  Future<File?> _getTodayLogFile() async {
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final y = now.year.toString().padLeft(4, '0');
      final m = now.month.toString().padLeft(2, '0');
      final d = now.day.toString().padLeft(2, '0');
      final path = '${dir.path}/app-telemetry-$y-$m-$d.jsonl';
      final f = File(path);
      if (await f.exists()) return f;
      return null;
    } catch (_) {
      return null;
    }
  }

  // Read a safe tail of the log to avoid oversized mailto URLs
  Future<String> _readLogTail(File file,
      {int maxLines = 100, int maxChars = 8000}) async {
    try {
      final lines = await file.readAsLines();
      final tail = lines.length > maxLines
          ? lines.sublist(lines.length - maxLines)
          : lines;
      var text = tail.join('\n');
      if (text.length > maxChars) {
        text = text.substring(text.length - maxChars);
      }
      return text;
    } catch (_) {
      return '';
    }
  }

  Future<void> logout() async {
    emit(ProfileLoading());
    try {
      final accessToken = await secureStorage.read(key: 'access_token');
      bool backendLogout = false;
      if (accessToken != null && accessToken.isNotEmpty) {
        backendLogout = await dataRepo.logout(accessToken);
      }
      // Clear tokens and any pinned base/ids
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'custom_base_url');
      await secureStorage.delete(key: 'openrouter_key');
      await secureStorage.delete(key: 'google_id_token');
      // Clear cached profile/registration/visitor info from SharedPreferences
      try {
        await _prefs.remove('last_profile_cache');
        await _prefs.remove('last_registration_response');
        await _prefs.remove('last_profile_sync_at');
        await _prefs.remove('visitor_local_id');
        await _prefs.remove('visitor_server_uuid');
        // Also clear OAuth/biometric preference toggles so new users don't inherit them
        await _prefs.remove('google_auth_enabled');
        await _prefs.remove('ms_auth_enabled');
        await _prefs.remove('openrouter_auth_enabled');
        await _prefs.remove('biometric_auth_enabled');
      } catch (_) {}
      // Purge local DB so next user starts clean
      try {
        await dataRepo.deleteAllLocalData();
      } catch (_) {}
      // Reset chat cubit ephemeral state if available in context via BlocProvider in UI layer
      // Cannot access BuildContext here; consumers should call ChatCubit.resetForLogout() on logout listener.
      if (!backendLogout) {
        logger.w(
            'Backend logout failed or token missing, but local tokens cleared.');
      }
      emit(ProfileLoggedOut());
    } catch (e) {
      logger.e('Logout failed', error: e);
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      try {
        await dataRepo.deleteAllLocalData();
      } catch (_) {}
      emit(ProfileLoggedOut());
    }
  }

  /// Archive or delete account with optional reason feedback.
  Future<void> modifyAccount({required bool delete, String? reason}) async {
    emit(ProfileLoading());
    bool serverOk = false;
    try {
      // Prefer unifiedDeleteMe with action param to match backend contract
      final access = await secureStorage.read(key: 'access_token');
      // If no access token is present, skip server call; proceed to local unauthentication
      if (access == null || access.isEmpty) {
        logger.w(
            'modifyAccount called without access token; skipping server request');
        throw Exception('no_token');
      }
      await dataRepo.unifiedDeleteMe(
        action: delete ? 'delete' : 'archive',
        profile: true,
        chat: true,
        accessToken: access,
        reason: (reason ?? '').trim().isNotEmpty ? reason!.trim() : null,
      );
      serverOk = true;
    } catch (e) {
      final action = delete ? 'delete' : 'archive';
      logger.e(
          'Server $action request failed (will still unauthenticate locally)',
          error: e);
    } finally {
      // Always clear sensitive local data and unauthenticate
      await secureStorage.delete(key: 'access_token');
      await secureStorage.delete(key: 'refresh_token');
      await secureStorage.delete(key: 'custom_base_url');
      await secureStorage.delete(key: 'openrouter_key');
      await secureStorage.delete(key: 'google_id_token');
      try {
        await _prefs.remove('last_profile_cache');
        await _prefs.remove('last_registration_response');
        await _prefs.remove('last_profile_sync_at');
        await _prefs.remove('visitor_local_id');
        await _prefs.remove('visitor_server_uuid');
        await _prefs.remove('google_auth_enabled');
        await _prefs.remove('ms_auth_enabled');
        await _prefs.remove('openrouter_auth_enabled');
        await _prefs.remove('biometric_auth_enabled');
      } catch (_) {}
      try {
        await dataRepo.deleteAllLocalData();
      } catch (_) {}

      if (serverOk) {
        final action = delete ? 'deleted' : 'archived';
        logger.i('Account $action successfully');
        emit(delete ? ProfileDeleted() : ProfileArchived());
      } else {
        // Fall back to logged-out state to ensure no stale session remains
        emit(ProfileLoggedOut());
      }
    }
  }

  Future<bool> requestEmailPin(String email) async {
    try {
      await dataRepo.requestEmailPin(email);
      return true;
    } catch (e) {
      logger.e('Failed to request email pin', error: e);
      emit(ProfileError('Failed to request email verification code'));
      return false;
    }
  }

  Future<bool> setPasswordAfterVerify(String email, String password) async {
    try {
      await dataRepo.setPasswordAfterEmailVerify(email, password);
      return true;
    } catch (e) {
      logger.e('Failed to set password after verify', error: e);
      emit(ProfileError('Failed to set password'));
      return false;
    }
  }
}
