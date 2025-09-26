import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart' as c;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Simple UMK-based AES-GCM encryption helper (Phase 0: UMK stored directly client & server)
class ArtifactEncryptor {
  static const _umkKey = 'umk_base64_v1';
  static final ArtifactEncryptor instance = ArtifactEncryptor._();
  final _storage = const FlutterSecureStorage();
  final _algo = c.AesGcm.with256bits();
  ArtifactEncryptor._();

  /// Returns existing UMK or generates and stores a new one (32 bytes).
  Future<Uint8List> getOrCreateUmk() async {
    String? b64 = await _storage.read(key: _umkKey);
    if (b64 == null || b64.isEmpty) {
      final key = await _algo.newSecretKey();
      final bytes = await key.extractBytes();
      b64 = base64Encode(bytes);
      await _storage.write(key: _umkKey, value: b64);
    }
    return Uint8List.fromList(base64Decode(b64));
  }

  Future<bool> hasUmk() async {
    final b64 = await _storage.read(key: _umkKey);
    return b64 != null && b64.isNotEmpty;
  }

  Future<Map<String, dynamic>> encryptBytes(Uint8List data,
      {String keyRef = 'umk_v1'}) async {
    final umk = await getOrCreateUmk();
    final secretKey = c.SecretKey(umk);
    final nonce = _algo.newNonce();
    final box = await _algo.encrypt(data, secretKey: secretKey, nonce: nonce);
    return {
      'ciphertext': box.cipherText,
      'mac': box.mac.bytes,
      'nonce_b64': base64Encode(nonce),
      'algo': 'aes-256-gcm',
      'key_ref': keyRef,
    };
  }

  Future<Uint8List> decryptToBytes(
      {required List<int> ciphertext,
      required List<int> mac,
      required String nonceB64}) async {
    final umk = await getOrCreateUmk();
    final secretKey = c.SecretKey(umk);
    final nonce = base64Decode(nonceB64);
    final box = c.SecretBox(ciphertext, nonce: nonce, mac: c.Mac(mac));
    final clear = await _algo.decrypt(box, secretKey: secretKey);
    return Uint8List.fromList(clear);
  }

  /// Encrypt file in place -> writes new .enc file, original remains (caller may delete original).
  Future<Map<String, dynamic>> encryptFile(String path) async {
    final bytes = await File(path).readAsBytes();
    final enc = await encryptBytes(Uint8List.fromList(bytes));
    final outPath = '$path.enc';
    final combined = <int>[...enc['ciphertext'] as List<int>]
      ..addAll(enc['mac'] as List<int>);
    await File(outPath).writeAsBytes(combined, flush: true);
    return {
      'outPath': outPath,
      'nonce_b64': enc['nonce_b64'],
      'algo': enc['algo'],
      'key_ref': enc['key_ref'],
    };
  }
}
