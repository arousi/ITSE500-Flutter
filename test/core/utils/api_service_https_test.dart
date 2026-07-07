import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_itse500/core/utils/api_service.dart';

void main() {
  group('ApiService HTTPS enforcement for known production hosts', () {
    test('upgrades plaintext http:// to https:// for the primary prod host',
        () {
      final result = ApiService.enforceHttpsForKnownProdHostsForTest(
          'http://www.itse500-ok.ly/api/v1/user_mang/me/');
      expect(result, 'https://www.itse500-ok.ly/api/v1/user_mang/me/');
    });

    test('upgrades plaintext http:// for the bare (non-www) prod host', () {
      final result = ApiService.enforceHttpsForKnownProdHostsForTest(
          'http://itse500-ok.ly/api/v1/auth_api/login/');
      expect(result, 'https://itse500-ok.ly/api/v1/auth_api/login/');
    });

    test('leaves an already-https prod URL untouched', () {
      const url = 'https://www.itse500-ok.ly/api/v1/auth_api/login/';
      expect(ApiService.enforceHttpsForKnownProdHostsForTest(url), url);
    });

    test('leaves localhost dev URLs on http://', () {
      const url = 'http://127.0.0.1:8000/api/v1/auth_api/login/';
      expect(ApiService.enforceHttpsForKnownProdHostsForTest(url), url);
    });

    test('leaves the Android emulator loopback host on http://', () {
      const url = 'http://10.0.2.2:8000/api/v1/auth_api/login/';
      expect(ApiService.enforceHttpsForKnownProdHostsForTest(url), url);
    });

    test('leaves LAN (192.168.x.x) hosts on http://', () {
      const url = 'http://192.168.22.99:8000/api/v1/auth_api/login/';
      expect(ApiService.enforceHttpsForKnownProdHostsForTest(url), url);
    });

    test('leaves the LM Studio localhost dev endpoint on http://', () {
      const url = 'http://localhost:1234/v1/chat/completions';
      expect(ApiService.enforceHttpsForKnownProdHostsForTest(url), url);
    });

    test('leaves unrelated third-party hosts untouched', () {
      const url = 'http://example.com/some/path';
      expect(ApiService.enforceHttpsForKnownProdHostsForTest(url), url);
    });
  });

  group('ApiService._normalizeApiBase HTTPS enforcement (base URL builder)',
      () {
    test('normalizes and forces https for a plaintext prod base URL', () {
      final result = ApiService.normalizeApiBaseForTest(
          'http://www.itse500-ok.ly/api/v1/');
      expect(result, 'https://www.itse500-ok.ly/api/v1/');
    });

    test('keeps a localhost dev base on http', () {
      final result =
          ApiService.normalizeApiBaseForTest('http://127.0.0.1:8000/');
      expect(result, 'http://127.0.0.1:8000/api/v1/');
    });

    test('keeps a LAN dev base on http', () {
      final result =
          ApiService.normalizeApiBaseForTest('http://192.168.22.99:8000/');
      expect(result, 'http://192.168.22.99:8000/api/v1/');
    });
  });
}
