import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';

/// ModelsApiService: isolated provider model + key verification endpoints.
/// (Refactored out of monolithic ApiService for readability.)
class ModelsApiService {
  final UnifiedLogger _logger = UnifiedLogger.instance;
  static bool get debug =>
      (dotenv.env['APP_DEBUG'] ?? 'false').toLowerCase() == 'true';

  // Base endpoints
  static String get openAIBase =>
      dotenv.env['OPENAI_BASE'] ?? 'https://api.openai.com/v1/';
  static String get openRouterBase =>
      dotenv.env['OPENROUTER_BASE'] ?? 'https://openrouter.ai/api/v1/';
  static String get geminiBase =>
      dotenv.env['GOOGLE_GEMINI_BASE'] ??
      'https://generativelanguage.googleapis.com/v1beta/';
  static String get hfHubBase => 'https://huggingface.co/api/models';

  static String get openAIModels => '${openAIBase}models';
  static String get openRouterModels => '${openRouterBase}models';
  static String get geminiModels => '${geminiBase}models';

  Future<bool> checkOpenAiKey(String apiKey) async {
    try {
      final r = await http.get(Uri.parse(openAIModels),
          headers: {'Authorization': 'Bearer $apiKey'});
      if (debug) _logger.d('[models] OpenAI key status=${r.statusCode}');
      return r.statusCode == 200;
    } catch (e) {
      _logger.w('OpenAI key check exception', error: e);
      return false;
    }
  }

  Future<bool> checkOpenRouterKey(String apiKey) async {
    try {
      final r = await http.get(Uri.parse(openRouterModels),
          headers: {'Authorization': 'Bearer $apiKey'});
      if (debug) _logger.d('[models] OpenRouter key status=${r.statusCode}');
      return r.statusCode == 200;
    } catch (e) {
      _logger.w('OpenRouter key check exception', error: e);
      return false;
    }
  }

  Future<bool> checkGoogleKey(String apiKey) async {
    try {
      final r = await http
          .get(Uri.parse(geminiModels), headers: {'x-goog-api-key': apiKey});
      if (r.statusCode == 200) {
        final decoded = jsonDecode(r.body);
        final list = _parse(decoded)
            .where((m) => m.toLowerCase().contains('gemini'))
            .toList();
        return list.isNotEmpty;
      }
      return false;
    } catch (e) {
      _logger.w('Gemini key check exception', error: e);
      return false;
    }
  }

  Future<List<String>> fetchOpenAIModels(String apiKey) async {
    final r = await http.get(Uri.parse(openAIModels),
        headers: {'Authorization': 'Bearer $apiKey'});
    if (r.statusCode != 200) return [];
    return _parse(jsonDecode(r.body));
  }

  Future<List<String>> fetchOpenRouterModels(String apiKey) async {
    final r = await http.get(Uri.parse(openRouterModels),
        headers: {'Authorization': 'Bearer $apiKey'});
    if (r.statusCode != 200) return [];
    return _parse(jsonDecode(r.body));
  }

  Future<List<Map<String, dynamic>>> fetchOpenRouterModelsRaw(
      String apiKey) async {
    final r = await http.get(Uri.parse(openRouterModels),
        headers: {'Authorization': 'Bearer $apiKey'});
    if (r.statusCode != 200) return const [];
    final decoded = jsonDecode(r.body);
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  Future<List<String>> fetchGoogleGeminiModels(String apiKey) async {
    final r = await http
        .get(Uri.parse(geminiModels), headers: {'x-goog-api-key': apiKey});
    if (r.statusCode != 200) return [];
    final decoded = jsonDecode(r.body);
    return _parse(decoded).where((m) => m.contains('gemini')).toList();
  }

  Future<List<Map<String, dynamic>>> fetchGoogleGeminiModelsRaw(
      String apiKey) async {
    final r = await http
        .get(Uri.parse(geminiModels), headers: {'x-goog-api-key': apiKey});
    if (r.statusCode != 200) return const [];
    final decoded = jsonDecode(r.body);
    if (decoded is Map && decoded['models'] is List) {
      return (decoded['models'] as List)
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  Future<List<Map<String, dynamic>>> fetchHuggingFaceModelsRaw(
      {String? apiKey, int limit = 100}) async {
    final url = '$hfHubBase?sort=downloads&limit=$limit';
    final r = await http.get(Uri.parse(url), headers: {
      if (apiKey != null && apiKey.isNotEmpty)
        'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json'
    });
    if (r.statusCode != 200) return const [];
    final decoded = jsonDecode(r.body);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
    return const [];
  }

  List<String> _parse(dynamic decoded) {
    final out = <String>[];
    if (decoded is Map && decoded['data'] is List) {
      for (final m in decoded['data']) {
        if (m is Map && m['id'] is String) out.add(m['id']);
      }
    }
    if (decoded is Map && decoded['models'] is List) {
      for (final m in decoded['models']) {
        if (m is Map && m['name'] is String) out.add(m['name']);
      }
    }
    if (decoded is List) {
      for (final m in decoded) {
        if (m is String) out.add(m);
        if (m is Map && m['id'] is String) out.add(m['id']);
        if (m is Map && m['name'] is String) out.add(m['name']);
      }
    }
    return out.toSet().toList();
  }
}
