import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';
import 'package:flutter_app_itse500/core/models/message.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_app_itse500/core/utils/structured_logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/custom_user.dart';
// import '../models/visitor_user.dart'; // unused

/// ApiService: Handles all Django API interactions securely and efficiently.
class ApiService {
  final UnifiedLogger _logger = UnifiedLogger.instance;

  // Debug flag (set APP_DEBUG=true in .env for verbose provider/model logs)
  static bool get debug =>
      (dotenv.env['APP_DEBUG'] ?? 'false').toLowerCase() == 'true';

  // Base URLs loaded from environment (.env) with sensible fallbacks
  // Always normalized to end with /api/v1/
  // Order intent: website (prod) first -> localhost group -> 192.x LAN
  static String get _baseUrl => _normalizeApiBase(
      dotenv.env['PRIMARY_API_BASE'] ?? 'https://www.itse500-ok.ly/api/v1/');
  static String get _secondaryBaseUrl => _normalizeApiBase(
      dotenv.env['SECONDARY_API_BASE'] ?? 'http://127.0.0.1:8000/api/v1/');
  static String get _tertiaryBaseUrl => _normalizeApiBase(
      dotenv.env['TERTIARY_API_BASE'] ?? 'http://192.168.22.99:8000/api/v1/');

  // Explicit emulator localhost mapping (Android). Included as part of the "localhost group" fallback.
  static String get _emulatorBaseUrl => _normalizeApiBase(
      dotenv.env['EMULATOR_API_BASE'] ?? 'http://10.0.2.2:8000/api/v1/');

  // Ensure an API base URL has a trailing /api/v1/
  static String _normalizeApiBase(String v) {
    var out = (v).trim();
    if (out.isEmpty) return 'http://10.0.2.2:8000/api/v1/';
    // Ensure trailing slash for simpler checks
    if (!out.endsWith('/')) out = '$out/';
    final idxV1 = out.indexOf('/api/v1');
    if (idxV1 >= 0) {
      // Truncate to exactly /api/v1/
      out = '${out.substring(0, idxV1)}/api/v1/';
    } else {
      final idxApi = out.indexOf('/api/');
      if (idxApi >= 0) {
        out = '${out.substring(0, idxApi)}/api/v1/';
      } else {
        // No /api segment at all -> append it
        out = '$out' 'api/v1/';
      }
    }
    // Force HTTPS for production hosts to avoid mixed content and redirect/CORS issues
    try {
      final u = Uri.parse(out);
      final h = u.host.toLowerCase();
      if (h == 'www.itse500-ok.ly' || h == 'itse500-ok.ly') {
        return 'https://${u.host}/api/v1/';
      }
    } catch (_) {}
    return out;
  }

  // API prefix for auth endpoints
  static const String _authApiPrefix = "auth_api/";

  // API prefix for user management endpoints
  static const String _userMangPrefix = "user_mang/";

  // Endpoints (relative to /api/)
  static const String _registerEndpoint = "${_authApiPrefix}register/";
  static const String _loginEndpoint = "${_authApiPrefix}login/";
  static const String _logoutEndpoint = "${_authApiPrefix}logout/";
  static const String _refreshEndpoint =
      "${_authApiPrefix}token/refresh/"; // SimpleJWT refresh
  static const String _healthCheck = "${_authApiPrefix}health/";
  static const String _verifyEmailPinEndpoint =
      "${_authApiPrefix}verify-email-pin/";
  static const String _setPasswordAfterEmailVerifyEndpoint =
      "${_authApiPrefix}set-password-after-email-verify/";

  // User management endpoints
  static const String _userMeEndpoint = "${_userMangPrefix}me/";
  // Unified Sync via user_mang/me/ in this deployment
  // Visitor endpoints
  // static const String _visitorLoginEndpoint = "${_authApiPrefix}visitor-login/"; // unused currently
  //static const String _adminUserDetailEndpoint = "${_userMangPrefix}admin/user/"; // Usage: admin/user/<uuid:user_id>/

  // Chat API endpoints
  static const String syncConversationsEndpoint = "sync-conversations/";
  static const String _associateDeviceEndpoint = "associate-device/";
  static const String _syncOrRegisterEndpoint = "sync-or-register/";

  // LLM Provider API Endpoints
  static String get lmStudioBaseEndpoint =>
      dotenv.env['LMSTUDIO_BASE'] ?? "http://localhost:1234/v1/";
  static String get lmStudioSecondaryBasepoint =>
      dotenv.env['LMSTUDIO_EMULATOR_BASE'] ?? "http://10.0.2.2:1234/v1/";

  static String get lmStudioChatCompletions =>
      "${lmStudioBaseEndpoint}chat/completions";
  static String get lmStudioModelsEndpoint =>
      "${lmStudioBaseEndpoint}models"; // Some LM Studio builds may expose /models

  static String get googleGeminiBaseEndpoint =>
      dotenv.env['GOOGLE_GEMINI_BASE'] ??
      "https://generativelanguage.googleapis.com/v1beta/";
  static String get googleGeminiChatCompletions =>
      "${googleGeminiBaseEndpoint}models/gemini-pro:generateContent";

  static String get openAIBaseEndpoint =>
      dotenv.env['OPENAI_BASE'] ?? "https://api.openai.com/v1/";
  static String get openAIChatCompletions =>
      "${openAIBaseEndpoint}chat/completions";
  static String get openAIEmbeddings => "${openAIBaseEndpoint}embeddings";
  static String get openAIImagesGenerations =>
      "${openAIBaseEndpoint}images/generations";
  static String get _openRouterBaseEndpoint =>
      dotenv.env['OPENROUTER_BASE'] ?? "https://openrouter.ai/api/v1/";
  static String get openRouterChatCompletions =>
      "${_openRouterBaseEndpoint}chat/completions";
  // Model listing endpoints
  static String get openAIModelsEndpoint =>
      "${openAIBaseEndpoint}models"; // GET
  static String get openRouterModelsEndpoint =>
      "${_openRouterBaseEndpoint}models"; // GET
  static String get googleGeminiModelsEndpoint =>
      "${googleGeminiBaseEndpoint}models"; // GET (requires key via query)
  static String get huggingFaceHubModelsEndpoint =>
      'https://huggingface.co/api/models'; // GET list (query params)
  static String get huggingFaceInferenceBase =>
      'https://api-inference.huggingface.co/models/';

  static const String chatCompletions = "chat/completions";

  // Helper: identify our backend hosts only (not third-party providers)
  static bool _isBackendHostName(String host) {
    final h = host.toLowerCase();
    if (h == 'www.itse500-ok.ly' ||
        h == 'itse500-ok.ly' ||
        h == '127.0.0.1' ||
        h == 'localhost' ||
        h == '10.0.2.2') {
      return true;
    }
    if (RegExp(r'^192\.168\.\d{1,3}\.\d{1,3}$').hasMatch(h)) return true;
    return false;
  }

  /// Checks OpenAI key using GET /models (preferred lightweight validation)
  Future<bool> checkOpenAiKey(String apiKey) async {
    try {
      final response = await tryGet(
        openAIModelsEndpoint,
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      if (debug)
        _logger.d(
            '[DEBUG] OpenAI key validation status=${response.statusCode} len=${response.body.length}');
      if (response.statusCode == 200) return true;
      await logErrorToFile(
          'OpenAI key check failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      _logger.e('OpenAI key check exception', error: e);
      await logErrorToFile('OpenAI key check exception: $e');
      return false;
    }
  }

  /// Checks OpenRouter key using GET /models
  Future<bool> checkOpenRouterKey(String apiKey) async {
    try {
      final response = await tryGet(
        openRouterModelsEndpoint,
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      if (debug)
        _logger.d(
            '[DEBUG] OpenRouter key validation status=${response.statusCode}');
      if (response.statusCode == 200) return true;
      await logErrorToFile(
          'OpenRouter key check failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      _logger.e('OpenRouter key check exception', error: e);
      await logErrorToFile('OpenRouter key check exception: $e');
      return false;
    }
  }

  /// Checks Google Gemini key using GET a single model descriptor (gemini-pro)
  Future<bool> checkGoogleKey(String apiKey) async {
    // Strategy:
    // 1. Try listing models with header auth (preferred modern style)
    // 2. If non-200, retry with query param (?key=) – some environments still expect this.
    // 3. Consider key valid if we get a 200 and at least one model containing 'gemini'.
    try {
      http.Response? resp;
      try {
        resp = await tryGet(
          googleGeminiModelsEndpoint,
          headers: {'x-goog-api-key': apiKey},
        );
      } catch (e) {
        if (debug)
          _logger.w(
              '[DEBUG] Primary Gemini models list attempt (header auth) threw',
              error: e);
      }

      if (resp == null || resp.statusCode != 200) {
        // Fallback with query param style
        final urlWithQuery = '$googleGeminiModelsEndpoint?key=$apiKey';
        if (debug)
          _logger.d(
              '[DEBUG] Gemini header auth list failed (status=${resp?.statusCode}); retrying with query param: $urlWithQuery');
        try {
          resp = await tryGet(urlWithQuery);
        } catch (e) {
          if (debug)
            _logger.w('[DEBUG] Gemini query param attempt threw', error: e);
        }
      }

      if (resp != null && resp.statusCode == 200) {
        try {
          final decoded = jsonDecode(resp.body);
          final models = _parseModelList(decoded)
              .where((m) => m.toLowerCase().contains('gemini'))
              .toList();
          if (debug)
            _logger.d(
                '[DEBUG] Gemini key validation succeeded; modelsFound=${models.length} sample=${models.take(3).toList()}');
          return models
              .isNotEmpty; // treat as valid only if we actually saw gemini models
        } catch (e) {
          await logErrorToFile('Gemini key check JSON parse error: $e');
          return false;
        }
      }

      await logErrorToFile(
          'Google Gemini key check failed: status=${resp?.statusCode} body=${resp?.body.substring(0, resp.body.length.clamp(0, 500))}');
      return false;
    } catch (e) {
      _logger.e('Google Gemini key check exception', error: e);
      await logErrorToFile('Google Gemini key check exception: $e');
      return false;
    }
  }

  /// Generic helper to extract model id list from various provider payloads
  List<String> _parseModelList(dynamic decoded) {
    final List<String> models = [];
    if (decoded == null) return models;
    // OpenAI & OpenRouter style: { data: [ {id: 'gpt-4o'}, ... ] }
    if (decoded is Map && decoded['data'] is List) {
      for (final m in decoded['data']) {
        if (m is Map && m['id'] is String) models.add(m['id']);
      }
    }
    // Gemini style: { models: [ {name: 'models/gemini-pro'}, ... ] }
    if (decoded is Map && decoded['models'] is List) {
      for (final m in decoded['models']) {
        if (m is Map && m['name'] is String) models.add(m['name']);
      }
    }
    // LM Studio style: list of strings maybe
    if (decoded is List) {
      for (final m in decoded) {
        if (m is String) models.add(m);
        if (m is Map && m['id'] is String) models.add(m['id']);
        if (m is Map && m['name'] is String) models.add(m['name']);
      }
    }
    return models.toSet().toList(); // dedupe
  }

  /// Fetch Hugging Face models raw (limited subset). We pull most downloaded first and filter later.
  Future<List<Map<String, dynamic>>> fetchHuggingFaceModelsRaw(
      {String? apiKey, int limit = 100}) async {
    try {
      final url = '$huggingFaceHubModelsEndpoint?sort=downloads&limit=$limit';
      final resp = await tryGet(url, headers: {
        if (apiKey != null && apiKey.isNotEmpty)
          'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json'
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is List) {
          // Each entry is a model card snippet
          return decoded
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        }
      } else {
        await logErrorToFile(
            'HF models fetch failed ${resp.statusCode}: ${resp.body.substring(0, resp.body.length.clamp(0, 400))}');
      }
    } catch (e) {
      await logErrorToFile('HF models fetch exception: $e');
    }
    return const [];
  }

  /// Hugging Face text generation (basic). Returns JSON map from provider.
  Future<Map<String, dynamic>> huggingFaceTextGenerate(
      {required String apiKey,
      required String model,
      required String prompt,
      double? temperature,
      double? topP,
      int? maxTokens}) async {
    final url = '$huggingFaceInferenceBase$model';
    final body = {
      'inputs': prompt,
      'parameters': {
        if (temperature != null) 'temperature': temperature,
        if (topP != null) 'top_p': topP,
        if (maxTokens != null) 'max_new_tokens': maxTokens,
        'return_full_text': false,
      }
    };
    try {
      final resp = await tryPost(url,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(body));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      await logErrorToFile(
          'HF text gen error ${resp.statusCode}: ${resp.body}');
      throw Exception('HF text generation failed');
    } catch (e) {
      await logErrorToFile('HF text gen exception: $e');
      rethrow;
    }
  }

  /// Hugging Face embeddings. Response is typically List<List<float>> or List<float>.
  Future<Uint8List> huggingFaceEmbeddingBytes(
      {required String apiKey,
      required String model,
      required String input}) async {
    final url = '$huggingFaceInferenceBase$model';
    final body = {'inputs': input};
    final resp = await tryPost(url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body));
    if (resp.statusCode != 200) {
      await logErrorToFile(
          'HF embedding error ${resp.statusCode}: ${resp.body}');
      throw Exception('HF embedding failed');
    }
    final decoded = jsonDecode(resp.body);
    List<dynamic>? vec;
    if (decoded is List) {
      if (decoded.isNotEmpty && decoded.first is List) {
        vec = (decoded.first as List); // Assume single input
      } else {
        vec = decoded; // Already flat
      }
    }
    if (vec == null) throw Exception('HF embedding response malformed');
    final floats = vec.map((e) {
      if (e is num) return e.toDouble();
      return double.tryParse(e.toString()) ?? 0.0;
    }).toList();
    final bd = ByteData(floats.length * 4);
    for (int i = 0; i < floats.length; i++) {
      bd.setFloat32(i * 4, floats[i]);
    }
    return bd.buffer.asUint8List();
  }

  /// Hugging Face image generation (PNG). Many SD models return binary bytes if we request image/png.
  Future<Uint8List> huggingFaceImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    final url = '$huggingFaceInferenceBase$model';
    // HF does not support size param uniformly via inference API; include as meta inside inputs for some forks.
    final body = {
      'inputs': prompt,
      'parameters': {
        'width': int.tryParse(size.split('x').first) ?? 512,
        'height': int.tryParse(size.split('x').last) ?? 512
      }
    };
    final resp = await tryPost(url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'Accept': 'image/png'
        },
        body: jsonEncode(body));
    if (resp.statusCode == 200) {
      // Response should be raw PNG bytes
      return resp.bodyBytes;
    }
    // Some models might return JSON with b64 in 'images'
    if (resp.headers['content-type']?.contains('application/json') == true) {
      try {
        final decoded = jsonDecode(utf8.decode(resp.bodyBytes));
        if (decoded is Map &&
            decoded['images'] is List &&
            decoded['images'].isNotEmpty) {
          final b64 = decoded['images'].first;
          if (b64 is String) {
            return Uint8List.fromList(base64Decode(b64));
          }
        }
      } catch (_) {}
    }
    await logErrorToFile(
        'HF image error ${resp.statusCode}: ${resp.body.substring(0, resp.body.length.clamp(0, 400))}');
    throw Exception('HF image generation failed');
  }

  /// Fetch OpenAI models (requires Bearer key). Returns list of model ids.
  Future<List<String>> fetchOpenAIModels(String apiKey,
      {bool throwOnError = false}) async {
    try {
      final resp = await tryGet(openAIModelsEndpoint, headers: {
        'Authorization': 'Bearer $apiKey',
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final list = _parseModelList(decoded);
        if (debug)
          _logger.d(
              '[DEBUG] OpenAI models fetched count=${list.length} sample=${list.take(5).toList()}');
        return list;
      }
      final msg =
          'OpenAI models fetch failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      if (throwOnError) throw Exception(msg);
    } catch (e) {
      await logErrorToFile('OpenAI models fetch exception: $e');
      if (throwOnError) rethrow;
    }
    return [];
  }

  /// Fetch OpenRouter models (Bearer key).
  Future<List<String>> fetchOpenRouterModels(String apiKey,
      {bool throwOnError = false}) async {
    try {
      final resp = await tryGet(openRouterModelsEndpoint, headers: {
        'Authorization': 'Bearer $apiKey',
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final list = _parseModelList(decoded);
        if (debug)
          _logger.d(
              '[DEBUG] OpenRouter models fetched count=${list.length} sample=${list.take(5).toList()}');
        return list;
      }
      final msg =
          'OpenRouter models fetch failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      if (throwOnError) throw Exception(msg);
    } catch (e) {
      await logErrorToFile('OpenRouter models fetch exception: $e');
      if (throwOnError) rethrow;
    }
    return [];
  }

  /// Fetch OpenRouter models raw payload (Bearer key) for rich metadata/grouping.
  /// Returns the 'data' array entries as a List<Map<String, dynamic>>.
  Future<List<Map<String, dynamic>>> fetchOpenRouterModelsRaw(String apiKey,
      {bool throwOnError = false}) async {
    try {
      final resp = await tryGet(openRouterModelsEndpoint, headers: {
        'Authorization': 'Bearer $apiKey',
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && decoded['data'] is List) {
          final List list = decoded['data'];
          return list
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        }
        return const [];
      }
      final msg =
          'OpenRouter raw models fetch failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      if (throwOnError) throw Exception(msg);
    } catch (e) {
      await logErrorToFile('OpenRouter raw models fetch exception: $e');
      if (throwOnError) rethrow;
    }
    return const [];
  }

  /// Fetch Google Gemini models (key passed in query). Returns list of model names.
  Future<List<String>> fetchGoogleGeminiModels(String apiKey,
      {bool throwOnError = false}) async {
    try {
      final resp = await tryGet(googleGeminiModelsEndpoint, headers: {
        'x-goog-api-key': apiKey,
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final list = _parseModelList(decoded)
            .where((m) => m.contains('gemini'))
            .toList();
        if (debug)
          _logger.d(
              '[DEBUG] Gemini models fetched count=${list.length} sample=${list.take(5).toList()}');
        return list;
      }
      final msg =
          'Google Gemini models fetch failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      if (throwOnError) throw Exception(msg);
    } catch (e) {
      await logErrorToFile('Google Gemini models fetch exception: $e');
      if (throwOnError) rethrow;
    }
    return [];
  }

  /// Fetch Google Gemini models raw payload for rich metadata/grouping.
  /// Returns the 'models' array entries as a List<Map<String, dynamic>>.
  Future<List<Map<String, dynamic>>> fetchGoogleGeminiModelsRaw(String apiKey,
      {bool throwOnError = false}) async {
    try {
      final resp = await tryGet(googleGeminiModelsEndpoint, headers: {
        'x-goog-api-key': apiKey,
      });
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && decoded['models'] is List) {
          final List list = decoded['models'];
          return list
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList();
        }
        return const [];
      }
      final msg =
          'Google Gemini raw models fetch failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      if (throwOnError) throw Exception(msg);
    } catch (e) {
      await logErrorToFile('Google Gemini raw models fetch exception: $e');
      if (throwOnError) rethrow;
    }
    return const [];
  }

  /// Request email PIN for password reset
  Future<Map<String, dynamic>> requestEmailPin(String email) async {
    try {
      final response = await tryPost(
        _verifyEmailPinEndpoint,
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'email': email}),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _logger.i('PIN sent to email: $email');
        return responseBody;
      } else {
        final errorMessage =
            'PIN API Error: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception(responseBody['detail'] ?? 'PIN request failed.');
      }
    } catch (e) {
      final errorMessage = 'PIN Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Sends a request to an LLM provider (OpenAI/OpenRouter/Gemini) and returns the parsed response.
  Future<Map<String, dynamic>> sendLlmRequest({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async {
    try {
      final t0 = DateTime.now();
      final model = body['model']?.toString();
      await StructuredLogger.instance.log(
        'http.request',
        {
          'headers': headers,
          'body_keys': body.keys.toList(),
          if (model != null) 'model': model,
        },
        category: 'http',
        className: 'ApiService',
        methodName: 'sendLlmRequest',
        url: url,
      );
      _logger.i('Sending LLM request to $url');
      // Use tryPost to leverage failover logic
      final response = await tryPost(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      final dt = DateTime.now().difference(t0).inMilliseconds;
      _logger.i('LLM response status: ${response.statusCode}');
      await StructuredLogger.instance.log(
        'http.response',
        {
          'status': response.statusCode,
          'len': response.body.length,
        },
        category: 'http',
        className: 'ApiService',
        methodName: 'sendLlmRequest',
        httpStatus: response.statusCode,
        durationMs: dt,
        url: url,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'data': data};
      } else {
        final classified =
            _classifyLlmError(response.statusCode, response.body);
        final errorMessage =
            'LLM API Error: ${response.statusCode} - ${response.body}\n$classified';
        _logger.e(errorMessage);
        await StructuredLogger.instance.log(
          'http.error',
          {
            'error': data,
            'status': response.statusCode,
            'classified': classified,
          },
          category: 'http',
          className: 'ApiService',
          methodName: 'sendLlmRequest',
          httpStatus: response.statusCode,
          url: url,
          status: 'error',
        );
        await logErrorToFile(errorMessage);
        throw Exception(classified.isNotEmpty
            ? classified
            : (data['error']?['message'] ?? 'LLM API error'));
      }
    } catch (e) {
      final errorMessage = 'sendLlmRequest Exception: $e';
      _logger.e(errorMessage);
      await StructuredLogger.instance.log(
        'http.exception',
        {
          'error': e.toString(),
        },
        category: 'http',
        className: 'ApiService',
        methodName: 'sendLlmRequest',
        status: 'error',
        url: url,
      );
      await logErrorToFile(errorMessage);
      throw Exception('Failed to send LLM request: $e');
    }
  }

  /// Streams an LLM request (SSE or chunked) and yields decoded UTF-8 chunks.
  /// Caller is responsible for parsing provider-specific streaming formats.
  Stream<String> sendLlmRequestStream({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async* {
    final client = http.Client();
    try {
      final t0 = DateTime.now();
      final model = body['model']?.toString();
      await StructuredLogger.instance.log(
        'http.stream.start',
        {
          'headers': headers,
          'body_keys': body.keys.toList(),
          if (model != null) 'model': model,
        },
        category: 'http',
        className: 'ApiService',
        methodName: 'sendLlmRequestStream',
        url: url,
      );
      _logger.i('Streaming LLM request to $url');
      final req = http.Request('POST', Uri.parse(url));
      req.headers.addAll(headers);
      req.headers.putIfAbsent('Content-Type', () => 'application/json');
      req.body = jsonEncode(body);
      final streamed = await client.send(req);
      if (streamed.statusCode != 200 && streamed.statusCode != 201) {
        final bytes = await streamed.stream.toBytes();
        final bodyStr = utf8.decode(bytes);
        final classified = _classifyLlmError(streamed.statusCode, bodyStr);
        final errorMessage =
            'LLM stream error: ${streamed.statusCode} - $bodyStr\n$classified';
        _logger.e(errorMessage);
        await StructuredLogger.instance.log(
          'http.stream.error',
          {
            'status': streamed.statusCode,
            'body': bodyStr,
            'classified': classified,
          },
          category: 'http',
          className: 'ApiService',
          methodName: 'sendLlmRequestStream',
          httpStatus: streamed.statusCode,
          url: url,
          status: 'error',
        );
        await logErrorToFile(errorMessage);
        throw Exception(classified.isNotEmpty ? classified : errorMessage);
      }
      final dt = DateTime.now().difference(t0).inMilliseconds;
      await StructuredLogger.instance.log(
        'http.stream.open',
        {},
        category: 'http',
        className: 'ApiService',
        methodName: 'sendLlmRequestStream',
        httpStatus: streamed.statusCode,
        durationMs: dt,
        url: url,
      );
      yield* streamed.stream.transform(utf8.decoder);
    } catch (e) {
      final errorMessage = 'sendLlmRequestStream Exception: $e';
      _logger.e(errorMessage);
      await StructuredLogger.instance.log(
        'http.stream.exception',
        {
          'error': e.toString(),
        },
        category: 'http',
        className: 'ApiService',
        methodName: 'sendLlmRequestStream',
        status: 'error',
        url: url,
      );
      await logErrorToFile(errorMessage);
      rethrow;
    } finally {
      client.close();
    }
  }

  // ---------------- LLM Error Classification Helpers ----------------
  String _classifyLlmError(int statusCode, String rawBody) {
    final lower = rawBody.toLowerCase();
    // Attempt to extract provider-specific signals
    bool containsAll(Iterable<String> parts) =>
        parts.every((p) => lower.contains(p));

    // OpenAI / OpenRouter style quota vs rate limit vs auth
    if (statusCode == 429) {
      if (lower.contains('quota') || lower.contains('billing')) {
        return 'Quota exceeded or billing inactive: Add payment method / increase spending limit for this provider, then retry.';
      }
      if (lower.contains('rate limit') || lower.contains('too many requests')) {
        return 'Rate limit reached: Slow down requests or apply backoff. Retry after a short delay.';
      }
      if (lower.contains('resource_exhausted')) {
        // Gemini 429 code
        return 'Gemini rate limit reached (RESOURCE_EXHAUSTED): Reduce frequency or request higher quota in Google AI Studio.';
      }
      return 'Request throttled (HTTP 429): Reduce request rate or upgrade plan.';
    }
    if (statusCode == 400) {
      if (containsAll(['enable billing']) ||
          containsAll(['free tier', 'not available'])) {
        return 'Billing required for this Gemini model: Enable billing on your Google AI Studio project.';
      }
      if (lower.contains('invalid') && lower.contains('argument')) {
        return 'Invalid request: Check parameters (model name, max tokens, etc.).';
      }
    }
    if (statusCode == 403) {
      if (lower.contains('not supported')) {
        return 'Access from this region is not supported by the provider.';
      }
      if (lower.contains('permission') || lower.contains('denied')) {
        return 'Permission denied: Verify API key scope and organization/project access.';
      }
    }
    if (statusCode == 401) {
      if (lower.contains('incorrect api key') ||
          lower.contains('invalid authentication')) {
        return 'Authentication failed: Verify API key and organization ID.';
      }
      return 'Unauthorized (401): Check API credentials.';
    }
    if (statusCode == 503) {
      if (lower.contains('overloaded') ||
          lower.contains('try again later') ||
          lower.contains('slow down')) {
        return 'Service overloaded: Wait and retry with backoff; optionally switch to a lighter model.';
      }
      return 'Service unavailable (503): Temporary provider issue.';
    }
    if (statusCode == 500) {
      return 'Provider internal error (500): Retry after brief delay; report if persistent.';
    }
    return '';
  }

  // ---------------- Embeddings & Images (Centralized) ----------------
  Future<Uint8List> openAIImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    final body = {
      'model': model,
      'prompt': prompt,
      'n': 1,
      'size': size,
      'response_format': 'b64_json',
    };
    final resp = await tryPost(
      openAIImagesGenerations,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      await logErrorToFile(
          'OpenAI image error ${resp.statusCode}: ${resp.body}');
      throw Exception('OpenAI image generation failed');
    }
    final decoded = jsonDecode(resp.body);
    final data = decoded['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      final b64 = first['b64_json'];
      if (b64 is String && b64.isNotEmpty) {
        return Uint8List.fromList(base64Decode(b64));
      }
    }
    throw Exception('OpenAI image response missing data');
  }

  Future<Uint8List> openAIEmbeddingBytes(
      {required String apiKey,
      required String model,
      required String input}) async {
    final body = {'model': model, 'input': input};
    final resp = await tryPost(
      openAIEmbeddings,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) {
      await logErrorToFile(
          'OpenAI embedding error ${resp.statusCode}: ${resp.body}');
      throw Exception('OpenAI embedding failed');
    }
    final decoded = jsonDecode(resp.body);
    final data = decoded['data'];
    if (data is List && data.isNotEmpty) {
      final emb = data.first['embedding'];
      if (emb is List) {
        final vec = emb.cast<num>().map((e) => e.toDouble()).toList();
        final bd = ByteData(vec.length * 4);
        for (int i = 0; i < vec.length; i++) {
          bd.setFloat32(i * 4, vec[i]);
        }
        return bd.buffer.asUint8List();
      }
    }
    throw Exception('OpenAI embedding response missing data');
  }

  Future<Uint8List> geminiImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    // Google Gemini OpenAI-compatible image generation endpoint
    final cleanModel =
        model.startsWith('models/') ? model.replaceFirst('models/', '') : model;
    const endpoint =
        'https://generativelanguage.googleapis.com/v1beta/openai/images/generations';
    final body = {
      'model': cleanModel,
      'prompt': prompt,
      'n': 1,
      'size': size,
      'response_format': 'b64_json',
    };
    final resp = await tryPost(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      await logErrorToFile(
          'Gemini image error ${resp.statusCode}: ${resp.body}');
      throw Exception('Gemini image generation failed');
    }
    final decoded = jsonDecode(resp.body);
    final data = decoded['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      final b64 = first['b64_json'];
      if (b64 is String && b64.isNotEmpty) {
        return Uint8List.fromList(base64Decode(b64));
      }
    }
    throw Exception('Gemini image response missing data');
  }

  // Native Gemini generateContent image (models ending with -image-generation). Supports mixed TEXT+IMAGE response.
  Future<Uint8List> geminiNativeImagePng(
      {required String apiKey,
      required String model,
      required String prompt}) async {
    final cleanModel = model.startsWith('models/') ? model : 'models/$model';
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/$cleanModel:generateContent';
    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['TEXT', 'IMAGE']
      }
    };
    final resp = await tryPost(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      await logErrorToFile(
          'Gemini native image error ${resp.statusCode}: ${resp.body}');
      throw Exception('Gemini native image generation failed');
    }
    try {
      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final candidates = decoded['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        for (final cand in candidates) {
          final content = (cand as Map?)?['content'];
          if (content is Map && content['parts'] is List) {
            for (final p in content['parts']) {
              if (p is Map && p['inline_data'] is Map) {
                final inline = p['inline_data'] as Map;
                final data = inline['data'];
                // final mime = inline['mime_type']?.toString() ?? '';
                if (data is String && data.isNotEmpty) {
                  // Only accept PNG/JPEG; otherwise attempt decode anyway.
                  return Uint8List.fromList(base64Decode(data));
                }
              }
            }
          }
        }
      }
    } catch (e) {
      await logErrorToFile('Gemini native image parse error: $e');
      rethrow;
    }
    throw Exception('Gemini native image response missing inline_data');
  }

  Future<Uint8List> openRouterImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    // OpenRouter unified generation endpoint. Use OpenAI-like body & expect OpenAI-like image response.
    const endpoint = 'https://openrouter.ai/api/v1/generation';
    final body = {
      'model': model,
      'prompt': prompt,
      'n': 1,
      'size': size,
      'response_format': 'b64_json',
    };
    final resp = await tryPost(
      endpoint,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      await logErrorToFile(
          'OpenRouter image error ${resp.statusCode}: ${resp.body}');
      throw Exception('OpenRouter image generation failed');
    }
    final decoded = jsonDecode(resp.body);
    // Attempt OpenAI style first
    final data = decoded['data'];
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      final b64 = first['b64_json'] ?? first['b64'];
      if (b64 is String && b64.isNotEmpty) {
        return Uint8List.fromList(base64Decode(b64));
      }
    }
    // Some providers may nest image in choices[0].data etc; fallback scanning for any b64_json
    String? findB64(dynamic node) {
      if (node is Map) {
        if (node['b64_json'] is String) return node['b64_json'];
        for (final v in node.values) {
          final r = findB64(v);
          if (r != null) return r;
        }
      } else if (node is List) {
        for (final v in node) {
          final r = findB64(v);
          if (r != null) return r;
        }
      }
      return null;
    }

    final fallbackB64 = findB64(decoded);
    if (fallbackB64 != null) {
      return Uint8List.fromList(base64Decode(fallbackB64));
    }
    throw Exception('OpenRouter image response missing data');
  }

  Future<Uint8List> geminiEmbeddingBytes(
      {required String apiKey,
      required String model,
      required String input}) async {
    final cleanModel = model.startsWith('models/') ? model : 'models/$model';
    final endpoint = '$googleGeminiBaseEndpoint$cleanModel:embedContent';
    final body = {
      'content': {
        'parts': [
          {'text': input}
        ]
      }
    };
    final resp = await tryPost(
      endpoint,
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) {
      await logErrorToFile(
          'Gemini embedding error ${resp.statusCode}: ${resp.body}');
      throw Exception('Gemini embedding failed');
    }
    final decoded = jsonDecode(resp.body);
    final emb = decoded['embedding'];
    final values = emb is Map ? emb['values'] : null;
    if (values is List) {
      final vec = values.cast<num>().map((e) => e.toDouble()).toList();
      final bd = ByteData(vec.length * 4);
      for (int i = 0; i < vec.length; i++) {
        bd.setFloat32(i * 4, vec[i]);
      }
      return bd.buffer.asUint8List();
    }
    throw Exception('Gemini embedding response missing values');
  }

  /// Verify email PIN
  Future<Map<String, dynamic>> verifyEmailPin(String email, String pin) async {
    try {
      final payload = <String, String>{'email': email, 'pin': pin};
      _logger.i('verifyEmailPin payload=$payload');
      // Read JWT access token from secure storage
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      http.Response response = await tryPost(
        _verifyEmailPinEndpoint,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      // Persist any refreshed tokens from headers (server may auto-refresh)
      final hdrAccess = response.headers['x-new-access-token'];
      final hdrRefresh = response.headers['x-new-refresh-token'];
      if (hdrAccess != null && hdrAccess.isNotEmpty) {
        await storage.write(key: 'access_token', value: hdrAccess);
        _logger.i('Stored X-New-Access-Token from verifyEmailPin response');
      }
      if (hdrRefresh != null && hdrRefresh.isNotEmpty) {
        await storage.write(key: 'refresh_token', value: hdrRefresh);
        _logger.i('Stored X-New-Refresh-Token from verifyEmailPin response');
      }
      Map<String, dynamic> responseBody = {};
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {}
      // If unauthorized due to expired token, refresh once and retry
      if (response.statusCode == 401) {
        final detail = (responseBody['detail'] ?? responseBody['code'] ?? '')
            .toString()
            .toLowerCase();
        if (detail.contains('token')) {
          _logger.w(
              'verifyEmailPin received 401 token issue; attempting refresh then retry');
          final newAccess = await _attemptRefresh();
          if (newAccess != null) {
            response = await tryPost(
              _verifyEmailPinEndpoint,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $newAccess',
              },
              body: jsonEncode(payload),
            );
            try {
              responseBody = jsonDecode(response.body);
            } catch (_) {}
          }
        }
      }

      if (response.statusCode == 200) {
        _logger.i('PIN verified for email: $email');
        return responseBody;
      } else {
        final errorMessage =
            'PIN Verify Error: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception(responseBody['detail'] ?? 'PIN verification failed.');
      }
    } catch (e) {
      final errorMessage = 'PIN Verify Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Set new password after email verification
  Future<Map<String, dynamic>> setPasswordAfterEmailVerify(
      String email, String password) async {
    try {
      // Read JWT access token from secure storage
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      http.Response response = await tryPost(
        _setPasswordAfterEmailVerifyEndpoint,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}),
      );
      // Persist any refreshed tokens from headers (server may auto-refresh)
      final hdrAccess = response.headers['x-new-access-token'];
      final hdrRefresh = response.headers['x-new-refresh-token'];
      if (hdrAccess != null && hdrAccess.isNotEmpty) {
        await storage.write(key: 'access_token', value: hdrAccess);
        _logger.i(
            'Stored X-New-Access-Token from setPasswordAfterEmailVerify response');
      }
      if (hdrRefresh != null && hdrRefresh.isNotEmpty) {
        await storage.write(key: 'refresh_token', value: hdrRefresh);
        _logger.i(
            'Stored X-New-Refresh-Token from setPasswordAfterEmailVerify response');
      }
      Map<String, dynamic> responseBody = {};
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {}
      // If unauthorized due to expired token, refresh once and retry
      if (response.statusCode == 401) {
        final detail = (responseBody['detail'] ?? responseBody['code'] ?? '')
            .toString()
            .toLowerCase();
        if (detail.contains('token')) {
          _logger.w(
              'setPasswordAfterEmailVerify received 401 token issue; attempting refresh then retry');
          final newAccess = await _attemptRefresh();
          if (newAccess != null) {
            response = await tryPost(
              _setPasswordAfterEmailVerifyEndpoint,
              headers: {
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': 'Bearer $newAccess',
              },
              body: jsonEncode(
                  <String, String>{'email': email, 'password': password}),
            );
            try {
              responseBody = jsonDecode(response.body);
            } catch (_) {}
          }
        }
      }
      if (response.statusCode == 200) {
        _logger.i('Password set for email: $email');
        return responseBody;
      } else {
        final errorMessage =
            'Set Password Error: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception(responseBody['detail'] ?? 'Password reset failed.');
      }
    } catch (e) {
      final errorMessage = 'Set Password Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Login with username method: authenticates user and returns a CustomUser object
  Future<CustomUser> loginWithUsername(String username, String password) async {
    try {
      // Attempt 1: send raw password (covers accounts created via registration)
      http.Response response = await tryPost(
        _loginEndpoint,
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'username': username,
          'user_password': password,
        }),
      );
      Map<String, dynamic> responseBody = {};
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {}
      if (!(response.headers['content-type']?.contains('application/json') ??
          false)) {
        final prev =
            response.body.substring(0, response.body.length.clamp(0, 200));
        final msg =
            'Non-JSON response for loginWithUsername: status=${response.statusCode} ct=${response.headers['content-type']} bodyPreview=${prev.replaceAll('\n', ' ')}';
        _logger.w(msg);
      }
      if (response.statusCode == 200 && responseBody['access_token'] != null) {
        _logger.i('Login successful: $username');
        return CustomUser.fromJson(responseBody['user']);
      }
      // If invalid credentials, retry with frontend-hashed password to cover reset flow
      final detail = (responseBody['detail'] ?? '').toString().toLowerCase();
      if (response.statusCode == 401 && detail.contains('invalid')) {
        final hashed = sha256.convert(utf8.encode(password)).toString();
        response = await tryPost(
          _loginEndpoint,
          headers: const {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, String>{
            'username': username,
            'user_password': hashed,
          }),
        );
        try {
          responseBody = jsonDecode(response.body);
        } catch (_) {}
        if (response.statusCode == 200 &&
            responseBody['access_token'] != null) {
          _logger.i('Login successful (hashed fallback): $username');
          return CustomUser.fromJson(responseBody['user']);
        }
      }
      final errorMessage =
          'Login API Error: ${response.statusCode} - ${response.body}';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(responseBody['detail'] ?? 'Login failed.');
    } catch (e) {
      final errorMessage = 'Login Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Legacy helper retained for compatibility: routes to UnifiedLogger structured event.
  Future<void> logErrorToFile(String error) async {
    await _logger.event(
      'error.log',
      payload: {'message': error},
      category: 'error',
      className: 'ApiService',
    );
  }

  /// Helper to POST to one or more endpoints with smart handling of absolute vs relative URLs.
  /// If [endpointOrUrl] is absolute (starts with http/https) it is used directly.
  /// Otherwise it is treated as a relative API path and expanded across the configured base URLs
  /// (custom runtime base + primary + secondary + tertiary).
  /// Optional [extraEndpoints] may include additional absolute or relative endpoints to try (in order).
  Future<http.Response> tryPost(
    String endpointOrUrl, {
    Map<String, String>? headers,
    Object? body,
    List<String>? extraEndpoints,
  }) async {
    bool isAbsolute(String v) =>
        v.startsWith('http://') || v.startsWith('https://');
    Future<void> pinBaseFromUrl(Uri url) async {
      try {
        // On web, always stick to production base; skip pinning
        if (kIsWeb) return;
        // Only pin bases for our backend hosts to avoid hijacking by provider URLs (e.g., openrouter.ai/api/v1/).
        if (!url.path.contains('/api/v1/')) return;
        final host = url.host.toLowerCase();
        if (!_isBackendHostName(host)) {
          _logger.i('Skipping API base pin for non-backend host: $host');
          return;
        }
        final s = url.toString();
        final idx = s.indexOf('/api/v1/');
        if (idx > 0) {
          var base = s.substring(0, idx + '/api/v1/'.length);
          // Prefer HTTPS scheme for production domains
          if (host == 'www.itse500-ok.ly' || host == 'itse500-ok.ly') {
            base = 'https://$host/api/v1/';
          }
          const storage = FlutterSecureStorage();
          await storage.write(key: 'custom_base_url', value: base);
          _logger.i('Pinned API base to $base');
        }
      } catch (_) {}
    }

    // Collect candidate endpoint strings (not yet parsed to Uri)
    final List<String> candidateStrings = [];

    if (isAbsolute(endpointOrUrl)) {
      candidateStrings.add(endpointOrUrl);
    } else {
      // Relative: on web, include full fallback chain but keep production first; pinning is still disabled on web
      bool useOnlyPinned = false;
      if (!kIsWeb) {
        String? customBaseUrl;
        try {
          const storage = FlutterSecureStorage();
          customBaseUrl = await storage.read(key: 'custom_base_url');
        } catch (_) {}
        if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
          final norm = _normalizeApiBase(customBaseUrl);
          try {
            final u = Uri.parse(norm);
            if (_isBackendHostName(u.host)) {
              candidateStrings.add('$norm$endpointOrUrl');
              useOnlyPinned = true;
              _logger.i('Pinned API base active; skipping fallback candidates');
            } else {
              // Clear bad pin to avoid future misroutes
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'custom_base_url');
              _logger.w(
                  'Ignoring and clearing non-backend custom_base_url host=${u.host}');
            }
          } catch (_) {
            // ignore invalid custom base
          }
        }
      }
      // If no pinned base, include fallbacks: Website -> localhost (127) -> emulator (10.0.2.2) -> 192.x
      if (!useOnlyPinned) {
        candidateStrings.addAll([
          '$_baseUrl$endpointOrUrl',
          '$_secondaryBaseUrl$endpointOrUrl',
          '$_emulatorBaseUrl$endpointOrUrl',
          '$_tertiaryBaseUrl$endpointOrUrl',
        ]);
      }
    }

    // Append any extra endpoints provided
    if (extraEndpoints != null && extraEndpoints.isNotEmpty) {
      for (final ep in extraEndpoints) {
        if (isAbsolute(ep)) {
          candidateStrings.add(ep);
        } else {
          candidateStrings.add('$_baseUrl$ep');
        }
      }
    }

    // Deduplicate while preserving order to avoid redundant attempts
    final seen = <String>{};
    final urls =
        candidateStrings.where((s) => seen.add(s)).map(Uri.parse).toList();
    _logger.i(
        'Trying POST endpoints for $endpointOrUrl: ${urls.map((u) => u.toString()).join(", ")}');

    for (final url in urls) {
      // Per-URL retry with exponential backoff on network exceptions (ClientException/Failed to fetch)
      Future<http.Response?> attemptWithRetries(Uri target) async {
        const maxRetries = 2; // total attempts = 1 + retries
        Duration delay = const Duration(milliseconds: 300);
        for (int attempt = 0; attempt <= maxRetries; attempt++) {
          try {
            final r = await http.post(target, headers: headers, body: body);
            return r;
          } catch (e) {
            // only backoff on network-layer errors; skip if last attempt
            _logger.w(
                'POST to $target threw (attempt ${attempt + 1}/${maxRetries + 1}): $e');
            if (attempt == maxRetries) return null;
            await Future.delayed(delay);
            delay *= 2;
          }
        }
        return null;
      }

      try {
        _logger.i('Attempting POST to $url');
        final response = await attemptWithRetries(url) ??
            (throw Exception('Network error after retries'));
        _logger.i('POST to $url responded with status ${response.statusCode}');
        // Handle redirects explicitly (one hop)
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final loc = response.headers['location'];
          if (loc != null && loc.isNotEmpty) {
            Uri redirectUri;
            try {
              final parsed = Uri.parse(loc);
              redirectUri = parsed.hasScheme ? parsed : url.resolveUri(parsed);
            } catch (_) {
              _logger.w('Invalid redirect location: $loc');
              continue; // try next candidate
            }
            _logger.i('Following redirect to $redirectUri');
            try {
              final r2 =
                  await http.post(redirectUri, headers: headers, body: body);
              _logger.i('Redirect POST to $redirectUri -> ${r2.statusCode}');
              if (r2.statusCode >= 200 && r2.statusCode < 300) {
                await pinBaseFromUrl(redirectUri);
                return r2;
              }
              if (r2.statusCode == 404 ||
                  r2.statusCode == 502 ||
                  r2.statusCode == 503) {
                _logger
                    .w('Redirect POST ${r2.statusCode}, trying next candidate');
                continue;
              }
              return r2; // return other errors to caller
            } catch (e) {
              _logger.w('Redirect POST failed: $e');
              continue; // try next candidate
            }
          } else {
            _logger.w('3xx without Location header, trying next candidate');
            continue;
          }
        }
        // Accept 2xx immediately
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _logger.i(
              'POST to $url accepted (status ${response.statusCode}), returning response');
          await pinBaseFromUrl(url);
          return response;
        }
        // Retry on typical network/route errors
        if (response.statusCode == 404 ||
            response.statusCode == 502 ||
            response.statusCode == 503) {
          _logger.w(
              'POST to $url returned status ${response.statusCode}, will try next if available');
          continue;
        }
        // Return other statuses (4xx/5xx) to caller for proper handling
        return response;
      } catch (e) {
        _logger.w('POST to $url failed: $e');
      }
    }
    _logger.e('All endpoints failed for POST $endpointOrUrl');
    throw Exception('All endpoints failed for POST $endpointOrUrl');
  }

  /// Helper to GET from one or more endpoints with smart handling like [tryPost].
  Future<http.Response> tryGet(
    String endpointOrUrl, {
    Map<String, String>? headers,
    List<String>? extraEndpoints,
  }) async {
    bool isAbsolute(String v) =>
        v.startsWith('http://') || v.startsWith('https://');
    Future<void> pinBaseFromUrl(Uri url) async {
      try {
        if (kIsWeb) return;
        if (!url.path.contains('/api/v1/')) return;
        final host = url.host.toLowerCase();
        if (!_isBackendHostName(host)) {
          _logger.i('Skipping API base pin for non-backend host: $host');
          return;
        }
        final s = url.toString();
        final idx = s.indexOf('/api/v1/');
        if (idx > 0) {
          var base = s.substring(0, idx + '/api/v1/'.length);
          if (host == 'www.itse500-ok.ly' || host == 'itse500-ok.ly') {
            base = 'https://$host/api/v1/';
          }
          const storage = FlutterSecureStorage();
          await storage.write(key: 'custom_base_url', value: base);
          _logger.i('Pinned API base to $base');
        }
      } catch (_) {}
    }

    final List<String> candidateStrings = [];
    if (isAbsolute(endpointOrUrl)) {
      candidateStrings.add(endpointOrUrl);
    } else {
      bool useOnlyPinned = false;
      if (!kIsWeb) {
        String? customBaseUrl;
        try {
          const storage = FlutterSecureStorage();
          customBaseUrl = await storage.read(key: 'custom_base_url');
        } catch (_) {}
        if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
          final norm = _normalizeApiBase(customBaseUrl);
          try {
            final u = Uri.parse(norm);
            if (_isBackendHostName(u.host)) {
              candidateStrings.add('$norm$endpointOrUrl');
              useOnlyPinned = true;
              _logger.i('Pinned API base active; skipping fallback candidates');
            } else {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'custom_base_url');
              _logger.w(
                  'Ignoring and clearing non-backend custom_base_url host=${u.host}');
            }
          } catch (_) {}
        }
      }
      if (!useOnlyPinned) {
        candidateStrings.addAll([
          '$_baseUrl$endpointOrUrl',
          '$_secondaryBaseUrl$endpointOrUrl',
          '$_emulatorBaseUrl$endpointOrUrl',
          '$_tertiaryBaseUrl$endpointOrUrl',
        ]);
      }
    }
    if (extraEndpoints != null && extraEndpoints.isNotEmpty) {
      for (final ep in extraEndpoints) {
        if (isAbsolute(ep)) {
          candidateStrings.add(ep);
        } else {
          candidateStrings.add('$_baseUrl$ep');
        }
      }
    }

    final seen = <String>{};
    final urls =
        candidateStrings.where((s) => seen.add(s)).map(Uri.parse).toList();
    _logger.i(
        'Trying GET endpoints for $endpointOrUrl: ${urls.map((u) => u.toString()).join(", ")}');
    http.Response? first401;
    final hasAuthHeader = headers?.containsKey('Authorization') == true;
    for (final url in urls) {
      Future<http.Response?> attemptWithRetries(Uri target) async {
        const maxRetries = 2;
        Duration delay = const Duration(milliseconds: 300);
        for (int attempt = 0; attempt <= maxRetries; attempt++) {
          try {
            final r = await http.get(target, headers: headers);
            return r;
          } catch (e) {
            _logger.w(
                'GET to $target threw (attempt ${attempt + 1}/${maxRetries + 1}): $e');
            if (attempt == maxRetries) return null;
            await Future.delayed(delay);
            delay *= 2;
          }
        }
        return null;
      }

      try {
        _logger.i(
            'Attempting GET to $url | authHeader=${hasAuthHeader ? 'yes' : 'no'}');
        final response = await attemptWithRetries(url) ??
            (throw Exception('Network error after retries'));
        _logger.i('GET to $url responded with status ${response.statusCode}');
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final loc = response.headers['location'];
          if (loc != null && loc.isNotEmpty) {
            Uri redirectUri;
            try {
              final parsed = Uri.parse(loc);
              redirectUri = parsed.hasScheme ? parsed : url.resolveUri(parsed);
            } catch (_) {
              _logger.w('Invalid redirect location: $loc');
              continue;
            }
            _logger.i('Following redirect to $redirectUri');
            try {
              final r2 = await http.get(redirectUri, headers: headers);
              _logger.i('Redirect GET to $redirectUri -> ${r2.statusCode}');
              if (r2.statusCode >= 200 && r2.statusCode < 300) {
                await pinBaseFromUrl(redirectUri);
                return r2;
              }
              if (r2.statusCode == 404 ||
                  r2.statusCode == 502 ||
                  r2.statusCode == 503) {
                continue;
              }
              return r2;
            } catch (e) {
              _logger.w('Redirect GET failed: $e');
              continue;
            }
          } else {
            _logger.w('3xx without Location header, trying next candidate');
            continue;
          }
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _logger.i(
              'GET to $url accepted (status ${response.statusCode}), returning response');
          await pinBaseFromUrl(url);
          return response;
        }
        // If authorized request hit 401, try next candidate (JWT issuer mismatch across hosts)
        if (response.statusCode == 401 && hasAuthHeader) {
          first401 ??= response;
          _logger.w(
              'GET to $url returned 401 with auth header; trying next candidate');
          continue;
        }
        if (response.statusCode == 404 ||
            response.statusCode == 502 ||
            response.statusCode == 503) {
          _logger.w(
              'GET to $url returned status ${response.statusCode}, will try next if available');
          continue;
        }
        return response;
      } catch (e) {
        _logger.w('GET to $url failed: $e');
      }
    }
    if (first401 != null) return first401;
    _logger.e('All endpoints failed for GET $endpointOrUrl');
    throw Exception('All endpoints failed for GET $endpointOrUrl');
  }

  /// Helper to PATCH to one or more endpoints with smart handling like [tryPost].
  Future<http.Response> tryPatch(
    String endpointOrUrl, {
    Map<String, String>? headers,
    Object? body,
    List<String>? extraEndpoints,
  }) async {
    bool isAbsolute(String v) =>
        v.startsWith('http://') || v.startsWith('https://');
    Future<void> pinBaseFromUrl(Uri url) async {
      try {
        if (kIsWeb) return;
        if (!url.path.contains('/api/v1/')) return;
        final host = url.host.toLowerCase();
        if (!_isBackendHostName(host)) {
          _logger.i('Skipping API base pin for non-backend host: $host');
          return;
        }
        final s = url.toString();
        final idx = s.indexOf('/api/v1/');
        if (idx > 0) {
          var base = s.substring(0, idx + '/api/v1/'.length);
          if (host == 'www.itse500-ok.ly' || host == 'itse500-ok.ly') {
            base = 'https://$host/api/v1/';
          }
          const storage = FlutterSecureStorage();
          await storage.write(key: 'custom_base_url', value: base);
          _logger.i('Pinned API base to $base');
        }
      } catch (_) {}
    }

    final List<String> candidateStrings = [];
    if (isAbsolute(endpointOrUrl)) {
      candidateStrings.add(endpointOrUrl);
    } else {
      bool useOnlyPinned = false;
      if (!kIsWeb) {
        String? customBaseUrl;
        try {
          const storage = FlutterSecureStorage();
          customBaseUrl = await storage.read(key: 'custom_base_url');
        } catch (_) {}
        if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
          final norm = _normalizeApiBase(customBaseUrl);
          try {
            final u = Uri.parse(norm);
            if (_isBackendHostName(u.host)) {
              candidateStrings.add('$norm$endpointOrUrl');
              useOnlyPinned = true;
              _logger.i('Pinned API base active; skipping fallback candidates');
            } else {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'custom_base_url');
              _logger.w(
                  'Ignoring and clearing non-backend custom_base_url host=${u.host}');
            }
          } catch (_) {}
        }
      }
      if (!useOnlyPinned) {
        candidateStrings.addAll([
          '$_baseUrl$endpointOrUrl',
          '$_secondaryBaseUrl$endpointOrUrl',
          '$_emulatorBaseUrl$endpointOrUrl',
          '$_tertiaryBaseUrl$endpointOrUrl',
        ]);
      }
    }
    if (extraEndpoints != null && extraEndpoints.isNotEmpty) {
      for (final ep in extraEndpoints) {
        if (isAbsolute(ep)) {
          candidateStrings.add(ep);
        } else {
          candidateStrings.add('$_baseUrl$ep');
        }
      }
    }

    final seen = <String>{};
    final urls =
        candidateStrings.where((s) => seen.add(s)).map(Uri.parse).toList();
    _logger.i(
        'Trying PATCH endpoints for $endpointOrUrl: ${urls.map((u) => u.toString()).join(", ")}');
    for (final url in urls) {
      Future<http.Response?> attemptWithRetries(Uri target) async {
        const maxRetries = 2;
        Duration delay = const Duration(milliseconds: 300);
        for (int attempt = 0; attempt <= maxRetries; attempt++) {
          try {
            final r = await http.patch(target, headers: headers, body: body);
            return r;
          } catch (e) {
            _logger.w(
                'PATCH to $target threw (attempt ${attempt + 1}/${maxRetries + 1}): $e');
            if (attempt == maxRetries) return null;
            await Future.delayed(delay);
            delay *= 2;
          }
        }
        return null;
      }

      try {
        _logger.i('Attempting PATCH to $url');
        final response = await attemptWithRetries(url) ??
            (throw Exception('Network error after retries'));
        _logger.i('PATCH to $url responded with status ${response.statusCode}');
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final loc = response.headers['location'];
          if (loc != null && loc.isNotEmpty) {
            Uri redirectUri;
            try {
              final parsed = Uri.parse(loc);
              redirectUri = parsed.hasScheme ? parsed : url.resolveUri(parsed);
            } catch (_) {
              _logger.w('Invalid redirect location: $loc');
              continue;
            }
            _logger.i('Following redirect to $redirectUri');
            try {
              final r2 =
                  await http.patch(redirectUri, headers: headers, body: body);
              _logger.i('Redirect PATCH to $redirectUri -> ${r2.statusCode}');
              if (r2.statusCode >= 200 && r2.statusCode < 300) {
                await pinBaseFromUrl(redirectUri);
                return r2;
              }
              if (r2.statusCode == 404 ||
                  r2.statusCode == 502 ||
                  r2.statusCode == 503) {
                continue;
              }
              return r2;
            } catch (e) {
              _logger.w('Redirect PATCH failed: $e');
              continue;
            }
          } else {
            _logger.w('3xx without Location header, trying next candidate');
            continue;
          }
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _logger.i(
              'PATCH to $url accepted (status ${response.statusCode}), returning response');
          await pinBaseFromUrl(url);
          return response;
        }
        if (response.statusCode == 404 ||
            response.statusCode == 502 ||
            response.statusCode == 503) {
          _logger.w(
              'PATCH to $url returned status ${response.statusCode}, will try next if available');
          continue;
        }
        return response;
      } catch (e) {
        _logger.w('PATCH to $url failed: $e');
      }
    }
    _logger.e('All endpoints failed for PATCH $endpointOrUrl');
    throw Exception('All endpoints failed for PATCH $endpointOrUrl');
  }

  /// Helper to DELETE from one or more endpoints with smart handling like
  Future<http.Response> tryDelete(
    String endpointOrUrl, {
    Map<String, String>? headers,
    Object? body,
    List<String>? extraEndpoints,
  }) async {
    bool isAbsolute(String v) =>
        v.startsWith('http://') || v.startsWith('https://');
    Future<void> pinBaseFromUrl(Uri url) async {
      try {
        if (kIsWeb) return;
        if (!url.path.contains('/api/v1/')) return;
        final host = url.host.toLowerCase();
        bool isBackendHost = host == 'www.itse500-ok.ly' ||
            host == 'itse500-ok.ly' ||
            host == '127.0.0.1' ||
            host == 'localhost' ||
            host == '10.0.2.2' ||
            RegExp(r'^192\.168\.[0-9]{1,3}\.[0-9]{1,3}$').hasMatch(host);
        if (!isBackendHost) {
          _logger.i('Skipping API base pin for non-backend host: $host');
          return;
        }
        final s = url.toString();
        final idx = s.indexOf('/api/v1/');
        if (idx > 0) {
          var base = s.substring(0, idx + '/api/v1/'.length);
          if (host == 'www.itse500-ok.ly' || host == 'itse500-ok.ly') {
            base = 'https://$host/api/v1/';
          }
          const storage = FlutterSecureStorage();
          await storage.write(key: 'custom_base_url', value: base);
          _logger.i('Pinned API base to $base');
        }
      } catch (_) {}
    }

    final List<String> candidateStrings = [];
    if (isAbsolute(endpointOrUrl)) {
      candidateStrings.add(endpointOrUrl);
    } else {
      bool useOnlyPinned = false;
      if (!kIsWeb) {
        String? customBaseUrl;
        try {
          const storage = FlutterSecureStorage();
          customBaseUrl = await storage.read(key: 'custom_base_url');
        } catch (_) {}
        if (customBaseUrl != null && customBaseUrl.isNotEmpty) {
          final norm = _normalizeApiBase(customBaseUrl);
          try {
            final u = Uri.parse(norm);
            if (_isBackendHostName(u.host)) {
              candidateStrings.add('$norm$endpointOrUrl');
              useOnlyPinned = true;
              _logger.i('Pinned API base active; skipping fallback candidates');
            } else {
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'custom_base_url');
              _logger.w(
                  'Ignoring and clearing non-backend custom_base_url host=${u.host}');
            }
          } catch (_) {}
        }
      }
      if (!useOnlyPinned) {
        candidateStrings.addAll([
          '$_baseUrl$endpointOrUrl',
          '$_secondaryBaseUrl$endpointOrUrl',
          '$_emulatorBaseUrl$endpointOrUrl',
          '$_tertiaryBaseUrl$endpointOrUrl',
        ]);
      }
    }
    if (extraEndpoints != null && extraEndpoints.isNotEmpty) {
      for (final ep in extraEndpoints) {
        if (isAbsolute(ep)) {
          candidateStrings.add(ep);
        } else {
          candidateStrings.add('$_baseUrl$ep');
        }
      }
    }

    final seen = <String>{};
    final urls =
        candidateStrings.where((s) => seen.add(s)).map(Uri.parse).toList();
    _logger.i(
        'Trying DELETE endpoints for $endpointOrUrl: ${urls.map((u) => u.toString()).join(", ")}');
    http.Response? first401;
    final hasAuthHeader = headers?.containsKey('Authorization') == true;
    for (final url in urls) {
      Future<http.Response?> attemptWithRetries(Uri target) async {
        const maxRetries = 2;
        Duration delay = const Duration(milliseconds: 300);
        for (int attempt = 0; attempt <= maxRetries; attempt++) {
          try {
            final r = await http.delete(target, headers: headers, body: body);
            return r;
          } catch (e) {
            _logger.w(
                'DELETE to $target threw (attempt ${attempt + 1}/${maxRetries + 1}): $e');
            if (attempt == maxRetries) return null;
            await Future.delayed(delay);
            delay *= 2;
          }
        }
        return null;
      }

      try {
        _logger.i('Attempting DELETE to $url');
        final response = await attemptWithRetries(url) ??
            (throw Exception('Network error after retries'));
        _logger
            .i('DELETE to $url responded with status ${response.statusCode}');
        if (response.statusCode >= 300 && response.statusCode < 400) {
          final loc = response.headers['location'];
          if (loc != null && loc.isNotEmpty) {
            Uri redirectUri;
            try {
              final parsed = Uri.parse(loc);
              redirectUri = parsed.hasScheme ? parsed : url.resolveUri(parsed);
            } catch (_) {
              _logger.w('Invalid redirect location: $loc');
              continue;
            }
            _logger.i('Following redirect to $redirectUri');
            try {
              final r2 =
                  await http.delete(redirectUri, headers: headers, body: body);
              _logger.i('Redirect DELETE to $redirectUri -> ${r2.statusCode}');
              if (r2.statusCode >= 200 && r2.statusCode < 300) {
                await pinBaseFromUrl(redirectUri);
                return r2;
              }
              if (r2.statusCode == 404 ||
                  r2.statusCode == 502 ||
                  r2.statusCode == 503) {
                continue;
              }
              return r2;
            } catch (e) {
              _logger.w('Redirect DELETE failed: $e');
              continue;
            }
          } else {
            _logger.w('3xx without Location header, trying next candidate');
            continue;
          }
        }
        if (response.statusCode >= 200 && response.statusCode < 300) {
          _logger.i(
              'DELETE to $url accepted (status ${response.statusCode}), returning response');
          await pinBaseFromUrl(url);
          return response;
        }
        // If authorized request hit 401, try next candidate (JWT issuer/host mismatch)
        if (response.statusCode == 401 && hasAuthHeader) {
          first401 ??= response;
          _logger.w(
              'DELETE to $url returned 401 with auth header; trying next candidate');
          continue;
        }
        if (response.statusCode == 404 ||
            response.statusCode == 502 ||
            response.statusCode == 503) {
          _logger.w(
              'DELETE to $url returned status ${response.statusCode}, will try next if available');
          continue;
        }
        return response;
      } catch (e) {
        _logger.w('DELETE to $url failed: $e');
      }
    }
    if (first401 != null) return first401;
    _logger.e('All endpoints failed for DELETE $endpointOrUrl');
    throw Exception('All endpoints failed for DELETE $endpointOrUrl');
  }

  /// Signs up a user with username and email.
  /// Returns the server response on success.
  /// Throws an exception with a user-friendly message on failure.
  Future<Map<String, dynamic>> signUp(String username, String email,
      {String? password}) async {
    try {
      final trimmedUsername = username.trim();
      final trimmedEmail = email.trim();
      _logger.i(
          'Attempting to register user: $trimmedUsername with email: $trimmedEmail');
      final payload = {
        'username': trimmedUsername,
        'email': trimmedEmail,
        if (password != null && password.isNotEmpty) 'user_password': password,
      };
      final response = await tryPost(
        _registerEndpoint,
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(payload),
      );
      if (!(response.headers['content-type']?.contains('application/json') ??
          false)) {
        final prev =
            response.body.substring(0, response.body.length.clamp(0, 200));
        final msg =
            'Non-JSON response for register: status=${response.statusCode} ct=${response.headers['content-type']} bodyPreview=${prev.replaceAll('\n', ' ')}';
        _logger.w(msg);
        await logErrorToFile(msg);
        throw Exception(
            'Server returned unexpected response. Please try again later.');
      }
      final responseBody = jsonDecode(response.body);
      // Never log sensitive data (passwords/tokens)
      // Some deployments may return 200 instead of 201 for successful registration
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i('User registered successfully: $trimmedEmail');
        return responseBody;
      } else {
        final errorMessage = 'API Error: ${response.statusCode}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        // Prefer explicit message from response if available
        final msg = () {
          if (responseBody is Map) {
            if (responseBody['email'] is List &&
                (responseBody['email'] as List).isNotEmpty) {
              return (responseBody['email'] as List).first.toString();
            }
            if (responseBody['detail'] is String &&
                (responseBody['detail'] as String).isNotEmpty) {
              return responseBody['detail'] as String;
            }
          }
          return 'Registration failed.';
        }();
        throw Exception(msg);
      }
    } catch (e) {
      final errorMessage = 'SignUp Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Login method: authenticates user and returns JWT tokens
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      // Attempt 1: raw password
      http.Response response = await tryPost(
        _loginEndpoint,
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{
          'identifier': identifier,
          'user_password': password,
        }),
      );
      Map<String, dynamic> responseBody = {};
      if (!(response.headers['content-type']?.contains('application/json') ??
          false)) {
        final prev =
            response.body.substring(0, response.body.length.clamp(0, 200));
        final msg =
            'Non-JSON response for login: status=${response.statusCode} ct=${response.headers['content-type']} bodyPreview=${prev.replaceAll('\n', ' ')}';
        _logger.w(msg);
        await logErrorToFile(msg);
      }
      try {
        responseBody = jsonDecode(response.body);
      } catch (_) {}
      if (response.statusCode == 200 && responseBody['access_token'] != null) {
        _logger.i('Login successful for identifier: $identifier');
        return responseBody;
      }
      final detail = (responseBody['detail'] ?? '').toString().toLowerCase();
      if (response.statusCode == 401 && detail.contains('invalid')) {
        // Attempt 2: frontend-hashed password (covers reset flow storage)
        final hashed = sha256.convert(utf8.encode(password)).toString();
        response = await tryPost(
          _loginEndpoint,
          headers: const {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(<String, String>{
            'identifier': identifier,
            'user_password': hashed,
          }),
        );
        try {
          responseBody = jsonDecode(response.body);
        } catch (_) {}
        if (response.statusCode == 200 &&
            responseBody['access_token'] != null) {
          _logger.i(
              'Login successful (hashed fallback) for identifier: $identifier');
          return responseBody;
        }
      }
      final errorMessage = 'Login API Error: ${response.statusCode}';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(responseBody['detail'] ?? 'Login failed.');
    } catch (e) {
      final errorMessage = 'Login Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Logout method: invalidates the user's session/token on the Django server
  Future<bool> logout(String accessToken) async {
    try {
      final response = await tryPost(
        _logoutEndpoint,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );
      if (response.statusCode == 200) {
        _logger.i('Logout successful.');
        return true;
      } else {
        final errorMessage =
            'Logout API Error: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        return false;
      }
    } catch (e) {
      final errorMessage = 'Logout Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      return false;
    }
  }

  /// Health check method: checks if the Django server is up
  Future<bool> healthCheck() async {
    try {
      final response = await tryGet(_healthCheck);
      if (response.statusCode == 200) {
        _logger.i('Health check successful. Server is up.');
        return true;
      } else {
        _logger.w('Health check failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Health check exception', error: e);
      return false;
    }
  }

  /// Fetches the current user's data (GET /user_mang/me/)
  Future<CustomUser> getUserMe(String accessToken) async {
    try {
      final response = await tryGet(
        _userMeEndpoint,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return CustomUser.fromJson(responseBody);
      } else {
        final errorMessage =
            'Failed to fetch user data: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception('Failed to fetch user data.');
      }
    } catch (e) {
      final errorMessage = 'Exception in getUserMe: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Updates the current user's data (PATCH /user_mang/me/)
  Future<CustomUser> updateUserMe(String accessToken, CustomUser user) async {
    try {
      // Prefer PATCH semantics; keep body as user json
      final response = await tryPatch(
        _userMeEndpoint,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return CustomUser.fromJson(responseBody);
      } else {
        final errorMessage =
            'Failed to update user data: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception('Failed to update user data.');
      }
    } catch (e) {
      final errorMessage = 'Exception in updateUserMe: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  // Continue as guest: creates a guest session and returns the response (now uses CustomUser logic)
  Future<void> continueAsGuest(BuildContext context) async {
    final logger = UnifiedLogger.instance;
    try {
      logger.i('Attempting guest login');
      final response = await createVisitorSession();
      logger.i('Guest login successful: access_token received');
      // Store tokens in secure storage for session persistence
      const FlutterSecureStorage secureStorage = FlutterSecureStorage();
      await secureStorage.write(
          key: 'access_token', value: response['access_token']);
      if (response['refresh_token'] != null) {
        await secureStorage.write(
            key: 'refresh_token', value: response['refresh_token']);
      }
      // Optionally store user info if returned
      if (response['user'] != null) {
        final dataRepo = DataRepository();
        await dataRepo.insertUserFromServer(response['user']);
      }
      // ignore: use_build_context_synchronously
      GoRouter.of(context).go('/home');
    } catch (e) {
      logger.e('Guest login failed', error: e);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest login failed: $e')),
      );
    }
  }

  /// Creates a visitor session (guest login) and returns JWT tokens as Map<String, dynamic>
  Future<Map<String, dynamic>> createVisitorSession() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceId = '';
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }

    final now = DateTime.now().toIso8601String();
    final response = await tryPost(
      _loginEndpoint,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'device_id': deviceId,
        'timestamp': now,
      }),
    );

    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200 && responseBody['access_token'] != null) {
      return responseBody;
    } else {
      throw Exception(
          responseBody['detail'] ?? 'Failed to create visitor session.');
    }
  }

  /// Attempts to request a server-backed visitor UUID by calling login with device_id only.
  /// Returns a map with potential fields: access_token, refresh_token, user, user_id.
  Future<Map<String, dynamic>> ensureServerVisitorIdentity() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    String deviceId = '';
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
    }
    final now = DateTime.now().toIso8601String();
    final response = await tryPost(
      _loginEndpoint,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'device_id': deviceId, 'timestamp': now}),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    }
    throw Exception(
        responseBody['detail'] ?? 'Server identity request failed.');
  }

  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    try {
      _logger.i(
          'Sending GET request to $_userMeEndpoint with Authorization: Bearer $accessToken');
      final response = await tryGet(
        _userMeEndpoint,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      _logger.i('Received response: ${response.statusCode} - ${response.body}');
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _logger.i('Profile data retrieved successfully.');
        return responseBody;
      } else {
        // If unauthorized, attempt token refresh once
        if (response.statusCode == 401) {
          final detail = (responseBody is Map)
              ? (responseBody['detail'] ?? responseBody['code'])
              : null;
          if (detail != null &&
              detail.toString().toLowerCase().contains('token')) {
            _logger.w('Access token likely expired. Attempting refresh...');
            final newAccess = await _attemptRefresh();
            if (newAccess != null) {
              _logger.i('Retrying profile fetch with refreshed access token');
              final retryResp = await tryGet(
                _userMeEndpoint,
                headers: {'Authorization': 'Bearer $newAccess'},
              );
              final retryBody = jsonDecode(retryResp.body);
              if (retryResp.statusCode == 200) {
                return retryBody;
              }
              final retryErr =
                  'Profile retry after refresh failed: ${retryResp.statusCode} - ${retryResp.body}';
              _logger.e(retryErr);
              await logErrorToFile(retryErr);
              throw Exception(retryBody['detail'] ??
                  'Failed to fetch profile after refresh.');
            } else {
              _logger.w(
                  'Token refresh attempt failed; will surface original 401.');
            }
          }
        }
        final errorMessage =
            'Get Profile Error: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception(responseBody['detail'] ?? 'Failed to fetch profile.');
      }
    } catch (e) {
      final errorMessage = 'Get Profile Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  // ---------------- Unified Sync (/user_mang/me/) ----------------
  /// GET /user_mang/me/ with flexible flags. Supports temp_id flow (no auth) and JWT auth.
  /// Returns the decoded JSON map; may include tokens (access/refresh) and/or user/profile payloads.
  Future<Map<String, dynamic>> unifiedGetMe({
    bool profile = true,
    bool chat = false,
    String? tempId,
    bool allowPublicUuid = false,
    String? deviceId,
    String? accessToken,
  }) async {
    try {
      // Build query params
      final qp = <String, String>{
        if (profile) 'profile': 'true',
        if (chat) 'chat': 'true',
        if (allowPublicUuid) 'allow_public_uuid': 'true',
        if (tempId != null && tempId.isNotEmpty) 'temp_id': tempId,
      };
      String devId = (deviceId ?? '').trim();
      if (devId.isEmpty) {
        try {
          final info = DeviceInfoPlugin();
          if (Platform.isAndroid) {
            final a = await info.androidInfo;
            devId = a.id;
          } else if (Platform.isIOS) {
            final i = await info.iosInfo;
            devId = i.identifierForVendor ?? '';
          }
        } catch (_) {}
      }
      if (devId.isNotEmpty) qp['device_id'] = devId;
      final endpoint = _userMeEndpoint +
          (qp.isEmpty ? '' : ('?${Uri(queryParameters: qp).query}'));

      Map<String, String> headers = {
        'Accept': 'application/json',
      };
      if (accessToken != null && accessToken.isNotEmpty)
        headers['Authorization'] = 'Bearer $accessToken';

      // Safe diagnostic: do not log token, only presence and length
      final hasAuth = headers.containsKey('Authorization');
      final authLen = hasAuth ? (headers['Authorization']?.length ?? 0) : 0;
      _logger.i(
          'Unified GET -> $endpoint | authHeader=${hasAuth ? 'yes' : 'no'} len=$authLen');
      final resp = await tryGet(endpoint, headers: headers);
      final ct = resp.headers['content-type'] ?? '';
      if (!ct.contains('application/json')) {
        final prev = resp.body.substring(0, resp.body.length.clamp(0, 200));
        final msg =
            'Unified GET non-JSON: status=${resp.statusCode} ct=$ct bodyPreview=${prev.replaceAll('\n', ' ')}';
        await logErrorToFile(msg);
        throw Exception('Server returned unexpected response.');
      }
      final decoded = jsonDecode(resp.body);
      if (resp.statusCode == 200)
        return decoded is Map
            ? decoded.cast<String, dynamic>()
            : <String, dynamic>{'data': decoded};

      // If 401 with access token, attempt refresh once
      if (resp.statusCode == 401 &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        _logger.w(
            'Unified GET 401; attempting refresh if refresh_token is available');
        final newAccess = await _attemptRefresh();
        if (newAccess != null) {
          headers['Authorization'] = 'Bearer $newAccess';
          _logger.i('Unified GET retry with refreshed token');
          final retry = await tryGet(endpoint, headers: headers);
          final ct2 = retry.headers['content-type'] ?? '';
          if (!ct2.contains('application/json')) {
            final prev =
                retry.body.substring(0, retry.body.length.clamp(0, 200));
            final msg =
                'Unified GET retry non-JSON: status=${retry.statusCode} ct=$ct2 bodyPreview=${prev.replaceAll('\n', ' ')}';
            await logErrorToFile(msg);
            throw Exception('Server returned unexpected response.');
          }
          final rj = jsonDecode(retry.body);
          if (retry.statusCode == 200)
            return rj is Map
                ? rj.cast<String, dynamic>()
                : <String, dynamic>{'data': rj};
        }
        // Final fallback: try public GET by UUID (backend allows this only with explicit flag)
        try {
          final uid = _extractUserIdFromJwt(accessToken);
          if (uid != null && uid.isNotEmpty) {
            final pubQ = Map<String, String>.from(qp);
            pubQ['allow_public_uuid'] = 'true';
            pubQ['user_id'] = uid;
            final publicEndpoint = _userMeEndpoint +
                (pubQ.isEmpty ? '' : ('?${Uri(queryParameters: pubQ).query}'));
            final pubHeaders = {
              'Accept': 'application/json'
            }; // no Authorization on purpose
            _logger.w('Unified GET public-by-uuid fallback -> $publicEndpoint');
            final pubResp = await tryGet(publicEndpoint, headers: pubHeaders);
            final ct3 = pubResp.headers['content-type'] ?? '';
            if (pubResp.statusCode == 200 && ct3.contains('application/json')) {
              final pj = jsonDecode(pubResp.body);
              return pj is Map
                  ? pj.cast<String, dynamic>()
                  : <String, dynamic>{'data': pj};
            }
          }
        } catch (e) {
          await logErrorToFile('Unified public fallback failed: $e');
        }
      }
      final msg = 'Unified GET failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      throw Exception(
          (decoded is Map ? decoded['detail'] : null) ?? 'Unified GET failed');
    } catch (e) {
      await logErrorToFile('Unified GET exception: $e');
      rethrow;
    }
  }

  // Decode user_id from a JWT without verifying signature (client-side convenience)
  String? _extractUserIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length < 2) return null;
      String normalize(String s) {
        // Base64URL pad
        final mod = s.length % 4;
        return s + (mod == 0 ? '' : '=' * (4 - mod));
      }

      final payload = utf8.decode(base64Url.decode(normalize(parts[1])));
      final map = jsonDecode(payload);
      final id = (map is Map) ? map['user_id']?.toString() : null;
      return (id is String && id.isNotEmpty) ? id : null;
    } catch (_) {
      return null;
    }
  }

  /// POST /user_mang/me/ to upsert profile and/or chat payloads.
  Future<Map<String, dynamic>> unifiedPostMe({
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };
      final resp = await tryPost(_userMeEndpoint,
          headers: headers, body: jsonEncode(body));
      final decoded = jsonDecode(resp.body);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return decoded is Map
            ? decoded.cast<String, dynamic>()
            : <String, dynamic>{'data': decoded};
      }
      final msg = 'Unified POST failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      throw Exception(
          (decoded is Map ? decoded['detail'] : null) ?? 'Unified POST failed');
    } catch (e) {
      await logErrorToFile('Unified POST exception: $e');
      rethrow;
    }
  }

  /// PATCH /user_mang/me/ for partial profile update.
  Future<Map<String, dynamic>> unifiedPatchMe({
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };
      final resp = await tryPatch(_userMeEndpoint,
          headers: headers, body: jsonEncode(body));
      final decoded = jsonDecode(resp.body);
      if (resp.statusCode == 200) {
        return decoded is Map
            ? decoded.cast<String, dynamic>()
            : <String, dynamic>{'data': decoded};
      }
      final msg = 'Unified PATCH failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      throw Exception((decoded is Map ? decoded['detail'] : null) ??
          'Unified PATCH failed');
    } catch (e) {
      await logErrorToFile('Unified PATCH exception: $e');
      rethrow;
    }
  }

  /// DELETE /user_mang/me/ with action and options.
  /// Backend expects: action=delete|archive and optional flags profile/chat/download_now.
  /// Optional reason can be supplied in the JSON body.
  Future<Map<String, dynamic>> unifiedDeleteMe({
    required String action, // 'delete' or 'archive'
    bool profile = true,
    bool chat = true,
    bool downloadNow = false,
    String? accessToken,
    String? reason,
  }) async {
    try {
      final qp = <String, String>{
        'action': action,
        if (profile) 'profile': 'true',
        if (chat) 'chat': 'true',
        if (downloadNow) 'download_now': 'true',
      };
      final endpoint = '$_userMeEndpoint?${Uri(queryParameters: qp).query}';
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (accessToken != null && accessToken.isNotEmpty)
          'Authorization': 'Bearer $accessToken',
      };
      final Object? body = (reason != null && reason.trim().isNotEmpty)
          ? jsonEncode({'reason': reason.trim()})
          : null;
      // Safe diagnostic about auth header
      final hasAuth = headers.containsKey('Authorization');
      final authLen = hasAuth ? (headers['Authorization']?.length ?? 0) : 0;
      _logger.i(
          'Unified DELETE -> $endpoint | authHeader=${hasAuth ? 'yes' : 'no'} len=$authLen');

      http.Response resp =
          await tryDelete(endpoint, headers: headers, body: body);
      dynamic decoded;
      try {
        decoded = jsonDecode(resp.body);
      } catch (_) {
        // keep decoded as raw body string on non-JSON bodies
        decoded = resp.body;
      }
      // If unauthorized and we had an access token, try one refresh+retry
      if (resp.statusCode == 401 &&
          accessToken != null &&
          accessToken.isNotEmpty) {
        _logger
            .w('Unified DELETE 401; attempting token refresh then retry once');
        final newAccess = await _attemptRefresh();
        if (newAccess != null && newAccess.isNotEmpty) {
          headers['Authorization'] = 'Bearer $newAccess';
          resp = await tryDelete(endpoint, headers: headers, body: body);
          try {
            decoded = jsonDecode(resp.body);
          } catch (_) {
            decoded = resp.body;
          }
        }
      }
      if (resp.statusCode == 200) {
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return decoded.cast<String, dynamic>();
        return <String, dynamic>{'data': decoded};
      }
      final msg = 'Unified DELETE failed: ${resp.statusCode} - ${resp.body}';
      await logErrorToFile(msg);
      if (decoded is Map && decoded['detail'] != null) {
        throw Exception(decoded['detail']);
      }
      throw Exception('Unified DELETE failed');
    } catch (e) {
      await logErrorToFile('Unified DELETE exception: $e');
      rethrow;
    }
  }

  /// Attempts to refresh the access token using stored refresh_token.
  /// Returns new access token on success, else null.
  Future<String?> _attemptRefresh() async {
    try {
      const storage = FlutterSecureStorage();
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('No refresh token present; cannot refresh.');
        return null;
      }
      final resp = await tryPost(
        _refreshEndpoint,
        headers: const {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      if (resp.statusCode == 200) {
        final decoded = jsonDecode(resp.body);
        final newAccess = decoded['access'];
        if (newAccess is String && newAccess.isNotEmpty) {
          await storage.write(key: 'access_token', value: newAccess);
          _logger.i('Access token refreshed successfully.');
          return newAccess;
        }
        _logger
            .w('Refresh response lacked access token field. Body=${resp.body}');
        return null;
      }
      _logger.w('Refresh failed status=${resp.statusCode} body=${resp.body}');
      return null;
    } catch (e) {
      _logger.e('Refresh attempt exception: $e');
      return null;
    }
  }

  Future<void> updateProfile(
      String username, String email, String password) async {
    try {
      _logger.i(
          'Sending PATCH request to $_userMeEndpoint with safe profile fields');
      final payload = {
        if (username.isNotEmpty) 'username': username,
        if (email.isNotEmpty) 'email': email,
      };
      if (password.isNotEmpty) {
        _logger.w(
            'updateProfile called with password; ignoring. Use setPasswordAfterEmailVerify endpoint instead.');
      }
      // Read access token for auth
      const storage = FlutterSecureStorage();
      final access = await storage.read(key: 'access_token');
      final headers = <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        if (access != null && access.isNotEmpty)
          'Authorization': 'Bearer $access',
      };
      final response = await tryPatch(
        _userMeEndpoint,
        headers: headers,
        body: jsonEncode(payload),
      );
      _logger.i('Received response: ${response.statusCode} - ${response.body}');
      if (response.statusCode != 200) {
        final errorMessage =
            'Update Profile Error: ${response.statusCode} - ${response.body}';
        _logger.e(errorMessage);
        await logErrorToFile(errorMessage);
        throw Exception('Failed to update profile.');
      }
    } catch (e) {
      final errorMessage = 'Update Profile Exception: $e';
      _logger.e(errorMessage);
      await logErrorToFile(errorMessage);
      throw Exception(
          'Could not connect to the server. Please try again later.');
    }
  }

  /// Handles account deletion or archiving.
  /// Sends DELETE /user_mang/me/?action=delete|archive with optional JSON body {reason}.
  Future<void> modifyAccount({required bool delete, String reason = ''}) async {
    const storage = FlutterSecureStorage();
    final access = await storage.read(key: 'access_token');
    final action = delete ? 'delete' : 'archive';
    // Route through unifiedDeleteMe for consistent handling
    await unifiedDeleteMe(
      action: action,
      profile: true,
      chat: true,
      accessToken: access,
      reason: reason.isNotEmpty ? reason : null,
    );
    _logger.i('Account $action request processed via unifiedDeleteMe.');
  }

  /// Sync conversations and messages for a visitor (user or anonymous)
  Future<List<Conversation>> syncConversations(
      {String? anonId, String? userId}) async {
    String endpoint;
    if (anonId != null) {
      endpoint = "$syncConversationsEndpoint$anonId/";
    } else if (userId != null) {
      endpoint = "$syncConversationsEndpoint$userId/";
    } else {
      throw Exception('Either anonId or userId must be provided');
    }
    final response = await tryGet(
      endpoint,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return (responseBody['conversations'] as List)
          .map((conv) => Conversation.fromJson(conv))
          .toList();
    } else {
      throw Exception('Failed to sync conversations.');
    }
  }

  /// Push conversations and messages for a visitor (user or anonymous)
  Future<Map<String, dynamic>> pushConversations({
    required List<Map<String, dynamic>> conversations,
    String? anonId,
    String? userId,
  }) async {
    String endpoint;
    if (anonId != null) {
      endpoint = "$syncConversationsEndpoint$anonId/";
    } else if (userId != null) {
      endpoint = "$syncConversationsEndpoint$userId/";
    } else {
      throw Exception('Either anonId or userId must be provided');
    }
    final response = await tryPost(
      endpoint,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"conversations": conversations}),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return responseBody;
    } else {
      throw Exception(responseBody['error'] ?? 'Failed to push conversations.');
    }
  }

  /// Associate a device with a visitor (by anon_id or user_id)
  Future<void> associateDevice(
      {String? anonId, String? userId, String? deviceId}) async {
    // Compute deviceId if not provided
    String devId = (deviceId ?? '').trim();
    if (devId.isEmpty) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfoPlugin.androidInfo;
          devId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfoPlugin.iosInfo;
          devId = iosInfo.identifierForVendor ?? '';
        }
      } catch (_) {}
    }
    final Map<String, dynamic> body = {'device_id': devId};
    if (anonId != null) {
      body['anon_id'] = anonId;
    }
    if (userId != null) {
      body['user_id'] = userId;
    }
    final response = await tryPost(
      _associateDeviceEndpoint,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(body),
    );
    final responseBody = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(responseBody['error'] ?? 'Failed to associate device.');
    }
  }

  /// Link a visitor by temp_id and device_id; create if not exists and return { user_id, is_new, conversations }
  Future<Map<String, dynamic>> syncOrRegisterVisitor(
      {required String tempId}) async {
    // Compute device id
    String devId = '';
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        devId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        devId = iosInfo.identifierForVendor ?? '';
      }
    } catch (_) {}
    final resp = await tryPost(
      _syncOrRegisterEndpoint,
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'temp_id': tempId,
        'device_id': devId,
      }),
    );
    final body = jsonDecode(resp.body);
    if (resp.statusCode == 200) return body as Map<String, dynamic>;
    throw Exception(body['error'] ?? 'Sync or register failed');
  }

  /// Sends a message request to the LLM provider, receives the response, extracts output, and updates local DB.
  Future<void> sendMessageAndStore({
    required Map<String, dynamic> messageRequest,
    required String conversationId,
    required String userId,
    required String providerUrl,
    required Map<String, String> headers,
  }) async {
    final dataRepo = DataRepository();
    // 1. Send request to provider (do not insert locally yet)
    final response = await tryPost(providerUrl,
        headers: headers, body: jsonEncode(messageRequest));
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      // 2. Parse and insert MessageRequest (from response if present, else use sent)
      final reqData = responseBody['request'] ?? messageRequest;
      final reqId = reqData['request_id'] ??
          reqData['id'] ??
          messageRequest['request_id'];
      await dataRepo.insertMessageRequest(reqData);
      // 3. Parse and insert MessageResponse
      final resData = responseBody['response'] ?? responseBody;
      final resId = resData['response_id'] ??
          resData['id'] ??
          responseBody['response_id'];
      await dataRepo.insertMessageResponse(resData);
      // 4. Parse and insert MessageOutput(s)
      String? outputId;
      if (responseBody['output'] is List && responseBody['output'].isNotEmpty) {
        for (final out in responseBody['output']) {
          await dataRepo.insertMessageOutput(out);
        }
        outputId = responseBody['output'][0]['output_id'] ??
            responseBody['output'][0]['id'];
      } else if (responseBody['output'] != null) {
        await dataRepo.insertMessageOutput(responseBody['output']);
        outputId =
            responseBody['output']['output_id'] ?? responseBody['output']['id'];
      }
      // 5. Create Message object using IDs from response
      final message = Message(
        messageId: responseBody['message_id'] ?? UniqueKey().toString(),
        conversationId: conversationId,
        userId: userId,
        requestId: reqId,
        responseId: resId,
        outputId: outputId,
        timestamp: DateTime.now(),
        vote: false,
        hasImage: false,
        imgUrl: null,
        metadata: null,
        hasEmbedding: false,
        hasDocument: false,
        docUrl: null,
      );
      await dataRepo.insertMessage(message);
      // 6. Optionally update conversation title or related ids
      if (responseBody['conversation_title'] != null) {
        await dataRepo.updateConversationTitle(
            conversationId, responseBody['conversation_title']);
      }
      // 7. Optionally update conversation with user id if present
      if (responseBody['user_id'] != null) {
        await dataRepo.updateConversationRelatedIds(
          conversationId,
          userId: responseBody['user_id'],
        );
      }
    } else {
      throw Exception(
          'Failed to send message to provider: ${response.statusCode}');
    }
  }

  // Use emulator-friendly IPs for LM-Studio endpoints
  static const String _lmStudioEndpoint =
      'http://10.0.2.2:1234/'; // Android emulator -> host
  static const String _secondarylmStudioEndpoint =
      'http://127.0.0.1:1234/'; // Fallback for local

  /// Checks LM-Studio health by hitting /models only. If /models returns 200 and a non-empty list, LM-Studio is up. No need to hit /chat/completions if /models is healthy.
  /// If /models returns 200 but empty, optionally try /chat/completions with a realistic model name.
  Future<String> checkLmStudioStatus([String? endpoint]) async {
    final List<String> baseUrls = [
      if (endpoint != null && endpoint.trim().isNotEmpty) endpoint.trim(),
      _lmStudioEndpoint.trim(),
      _secondarylmStudioEndpoint.trim(),
    ];
    for (final baseUrl in baseUrls) {
      if (baseUrl.isEmpty) continue;
      try {
        _logger.i('LM-Studio health: Trying $baseUrl');
        // 1. Check /models endpoint directly
        final modelsUrl =
            baseUrl.endsWith('/') ? '${baseUrl}models' : '$baseUrl/models';
        final modelsResp = await http
            .get(Uri.parse(modelsUrl))
            .timeout(const Duration(seconds: 2));
        _logger.i(
            'LM-Studio /models [$modelsUrl] status: ${modelsResp.statusCode}');
        if (modelsResp.statusCode == 200) {
          final models = jsonDecode(modelsResp.body);
          if (models is List && models.isNotEmpty) {
            _logger.i('LM-Studio /models returned non-empty list.');
            return 'up';
          } else {
            _logger.w('LM-Studio /models returned empty list.');
            // Optionally, try /chat/completions with a realistic model name
            final chatUrl = baseUrl.endsWith('/')
                ? '${baseUrl}chat/completions'
                : '$baseUrl/chat/completions';
            final body = {
              "model":
                  "TheBloke_Mistral-7B-Instruct-v0.1-GGUF", // Example model name, should match a loaded model
              "messages": [
                {"role": "user", "content": "Hello"}
              ],
              "temperature": 0.7,
              "stream": false
            };
            final chatResp = await http
                .post(
                  Uri.parse(chatUrl),
                  headers: {"Content-Type": "application/json"},
                  body: jsonEncode(body),
                )
                .timeout(const Duration(seconds: 3));
            _logger.i(
                'LM-Studio /chat/completions [$chatUrl] status: ${chatResp.statusCode}');
            if (chatResp.statusCode == 200) {
              _logger.i('LM-Studio /chat/completions responded OK.');
              return 'up';
            }
          }
        }
      } catch (e) {
        _logger.w('LM-Studio health check failed for $baseUrl', error: e);
        continue;
      }
    }
    _logger.w('LM-Studio health check: all endpoints failed.');
    return 'down';
  }

  /// Fetch LM Studio models list (if endpoint exposes /models). Returns empty list on failure.
  Future<List<String>> fetchLmStudioModels({String? baseUrl}) async {
    final List<String> bases = [
      if (baseUrl != null && baseUrl.isNotEmpty) baseUrl,
      lmStudioBaseEndpoint,
      lmStudioSecondaryBasepoint,
    ];
    for (final b in bases) {
      try {
        final modelsUrl = b.endsWith('/') ? '${b}models' : '$b/models';
        final resp = await http
            .get(Uri.parse(modelsUrl))
            .timeout(const Duration(seconds: 2));
        if (resp.statusCode == 200) {
          final decoded = jsonDecode(resp.body);
          final list = _parseModelList(decoded);
          if (list.isNotEmpty) return list;
        }
      } catch (_) {
        continue;
      }
    }
    return [];
  }
}
