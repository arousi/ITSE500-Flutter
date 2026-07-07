// AuthCubit is a god object: its constructor directly instantiates
// DataRepository/SharedPref/FlutterSecureStorage/LocalAuthentication and
// kicks off `_checkToken()` + `_loadBiometricFlag()` + `initDeepLinks()`
// (app_links), all hitting real platform channels with no DI seam. Rather
// than skip it outright (the brief explicitly asks for guest-login/logout/
// state coverage), we stub the platform channels it touches (secure
// storage, shared_preferences, app_links, local_auth) at the binary
// messenger level so the cubit constructs and its guest/logout paths run
// against fully in-memory fakes — no real network, no real device
// keychain. This is test infrastructure, not a production refactor.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app_itse500/features/auth/logic/auth_cubit.dart';

class _FakeSecureStorage {
  final Map<String, String> store = {};
}

// continueAsGuest(BuildContext) never actually reads/writes the context on
// its offline success path (see auth_cubit.dart) — it's accepted purely for
// signature parity with sibling methods that do navigate. A mocktail mock
// avoids needing a real, fully-pumped widget tree (which triggers unrelated
// hangs from AuthCubit's own undisposed app_links listener) just to obtain
// a throwaway BuildContext.
class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fakeSecureStorage = _FakeSecureStorage();
  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  const appLinksChannel = MethodChannel('com.llfbandit.app_links/messages');
  const appLinksEventChannel =
      EventChannel('com.llfbandit.app_links/events');
  const localAuthChannel = MethodChannel('plugin.baseflow.com/local_auth');

  setUp(() async {
    fakeSecureStorage.store.clear();
    SharedPreferences.setMockInitialValues({});

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      switch (call.method) {
        case 'read':
          final key = (call.arguments as Map)['key'] as String;
          return fakeSecureStorage.store[key];
        case 'write':
          final args = call.arguments as Map;
          fakeSecureStorage.store[args['key'] as String] =
              args['value'] as String;
          return null;
        case 'delete':
          final key = (call.arguments as Map)['key'] as String;
          fakeSecureStorage.store.remove(key);
          return null;
        case 'readAll':
          return fakeSecureStorage.store;
        case 'deleteAll':
          fakeSecureStorage.store.clear();
          return null;
        case 'containsKey':
          final key = (call.arguments as Map)['key'] as String;
          return fakeSecureStorage.store.containsKey(key);
        default:
          return null;
      }
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLinksChannel, (call) async {
      if (call.method == 'getInitialLink' ||
          call.method == 'getLatestLink') {
        return null;
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      appLinksEventChannel,
      MockStreamHandler.inline(
        onListen: (arguments, events) {},
      ),
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localAuthChannel, (call) async {
      switch (call.method) {
        case 'isDeviceSupported':
          return false;
        case 'getAvailableBiometrics':
          return <String>[];
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(appLinksChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(appLinksEventChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(localAuthChannel, null);
  });

  group('AuthCubit initial resolution', () {
    test('starts as AuthInitial when no token or visitor id is present',
        () async {
      final cubit = AuthCubit();
      // _checkToken() runs asynchronously in the constructor.
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state, isA<AuthInitial>());
      await cubit.close();
    });

    test('resolves to AuthGuest when a visitor id already exists in prefs',
        () async {
      SharedPreferences.setMockInitialValues({
        'visitor_local_id': 'v-existing-123',
      });
      final cubit = AuthCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state, isA<AuthGuest>());
      await cubit.close();
    });

    test('resolves to AuthAuthenticated when an access token is present',
        () async {
      fakeSecureStorage.store['access_token'] = 'jwt-abc';
      final cubit = AuthCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state, isA<AuthAuthenticated>());
      await cubit.close();
    });
  });

  group('AuthCubit.continueAsGuest', () {
    test('transitions AuthLoading -> AuthGuest and persists a visitor id',
        () async {
      final cubit = AuthCubit();
      await Future.delayed(const Duration(milliseconds: 50));

      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);

      cubit.continueAsGuest(_FakeBuildContext());
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states, contains(isA<AuthLoading>()));
      expect(cubit.state, isA<AuthGuest>());

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('storage_mode'), 'local');
      expect(fakeSecureStorage.store.containsKey('access_token'), isFalse);

      await sub.cancel();
      await cubit.close();
    });

    test('reuses an existing visitor id across guest sessions', () async {
      SharedPreferences.setMockInitialValues({
        'visitor_local_id': 'v-stable-id',
      });
      final cubit = AuthCubit();
      await Future.delayed(const Duration(milliseconds: 50));

      cubit.continueAsGuest(_FakeBuildContext());
      await Future.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('visitor_local_id'), 'v-stable-id');
      expect(cubit.state, isA<AuthGuest>());

      await cubit.close();
    });
  });

  group('AuthCubit.logout', () {
    test('clears tokens and provider toggles, emits AuthInitial', () async {
      fakeSecureStorage.store['access_token'] = 'jwt-abc';
      fakeSecureStorage.store['refresh_token'] = 'refresh-abc';
      fakeSecureStorage.store['openrouter_key'] = 'or-key';
      SharedPreferences.setMockInitialValues({
        'google_auth_enabled': true,
      });

      final cubit = AuthCubit();
      await Future.delayed(const Duration(milliseconds: 50));

      final states = <AuthState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.logout();

      expect(states, contains(isA<AuthLoading>()));
      expect(cubit.state, isA<AuthInitial>());
      expect(fakeSecureStorage.store.containsKey('access_token'), isFalse);
      expect(fakeSecureStorage.store.containsKey('refresh_token'), isFalse);
      expect(fakeSecureStorage.store.containsKey('openrouter_key'), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('google_auth_enabled'), isNull);

      await sub.cancel();
      await cubit.close();
    });
  });

  group('AuthCubit.setAuthenticated', () {
    test('emits AuthAuthenticated directly when biometric lock is disabled',
        () async {
      final cubit = AuthCubit();
      await Future.delayed(const Duration(milliseconds: 50));
      cubit.setAuthenticated();
      expect(cubit.state, isA<AuthAuthenticated>());
      await cubit.close();
    });
  });
}
