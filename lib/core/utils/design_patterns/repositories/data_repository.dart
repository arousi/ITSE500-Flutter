import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter_app_itse500/core/models/conversation.dart';
import 'package:flutter_app_itse500/core/models/message.dart';
import 'package:flutter_app_itse500/core/models/custom_user.dart';
import 'package:flutter_app_itse500/core/models/provider_check_status.dart';
import 'package:flutter_app_itse500/core/utils/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_itse500/core/utils/db_helper.dart';
import 'package:flutter_app_itse500/shared_preferences.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';

/// Thin repository facade over DatabaseHelper and ApiService, with light caching.
class DataRepository {
  // Singleton
  DataRepository._internal();
  static final DataRepository instance = DataRepository._internal();
  factory DataRepository() => instance;
  final SharedPref _prefs = SharedPref();
  final DatabaseHelper _db = DatabaseHelper();
  final ApiService _api = ApiService();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final UnifiedLogger _logger = UnifiedLogger.instance;
  static const String _pendingSyncKey = 'pending_sync_queue_v1';
  bool _pendingSyncScheduled = false;

  // Cached environment flags
  bool? _isEmulatorCache;
  String? _cachedHotspotHost; // e.g., 192.168.22.99 provided by user / settings
  DateTime? _hotspotHostTs;
  static const _hotspotKey = 'manual_hotspot_host_v1';
  static const _hotspotTtl =
      Duration(hours: 12); // refresh after network changes

  // Simple event bus for UI to react to data changes (e.g., drawer refresh after sync)
  final StreamController<void> conversationsChanged =
      StreamController<void>.broadcast();
  void notifyConversationsChanged() {
    if (!conversationsChanged.isClosed) {
      conversationsChanged.add(null);
    }
  }

  // Simple in-memory caches
  static const Duration _modelsTtl = Duration(minutes: 10);
  static const Duration _healthTtl = Duration(seconds: 30);

  final Map<String, _Cached<List<String>>> _modelCache = {};
  final Map<String, _Cached<List<Map<String, dynamic>>>> _modelRawCache = {};
  final Map<String, _Cached<List<Map<String, dynamic>>>> _hfModelRawCache =
      {}; // separate to allow different ttl logic later
  _Cached<bool>? _healthCache;
  bool _isFresh(DateTime ts, Duration ttl) =>
      DateTime.now().difference(ts) < ttl;
  String _keySig(String ns, String id) => '$ns:${id.hashCode}';

  // ---------- Pending sync queue (offline) ----------
  Future<List<Map<String, dynamic>>> _loadPendingSyncs() async {
    try {
      final raw = await _prefs.getString(_pendingSyncKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _savePendingSyncs(List<Map<String, dynamic>> items) async {
    try {
      await _prefs.saveString(_pendingSyncKey, jsonEncode(items));
    } catch (_) {}
  }

  Future<void> enqueuePendingMessageSync(
      {required String conversationId, required String messageId}) async {
    final list = await _loadPendingSyncs();
    // de-dupe
    final exists = list.any((e) =>
        e['conversation_id'] == conversationId && e['message_id'] == messageId);
    if (!exists) {
      list.add({
        'conversation_id': conversationId,
        'message_id': messageId,
        'ts': DateTime.now().toIso8601String(),
      });
      await _savePendingSyncs(list);
      _logger.i('Enqueued pending sync for message',
          ctx: {'conv': conversationId, 'msg': messageId});
    }
  }

  Future<void> tryFlushPendingSyncs() async {
    // Respect privacy mode gating
    final mode = await _prefs.getString('storage_mode');
    if ((mode ?? 'local') == 'local') return; // don’t sync in strict local mode
    // Try posting each queued item
    final list = await _loadPendingSyncs();
    if (list.isEmpty) return;
    String? tempId;
    try {
      tempId = await _secure.read(key: 'temp_id');
    } catch (_) {}
    String? accessTok;
    try {
      accessTok = await _secure.read(key: 'access_token');
    } catch (_) {}
    final remaining = <Map<String, dynamic>>[];
    for (final item in list) {
      final cid = item['conversation_id']?.toString() ?? '';
      final mid = item['message_id']?.toString() ?? '';
      if (cid.isEmpty || mid.isEmpty) continue;
      try {
        // Skip localOnly conversations forever
        final conv = await fetchConversationById(cid);
        if (conv?.localOnly == true) {
          continue; // don’t requeue
        }
        final body = await buildSingleMessageUnifiedBody(
            conversationId: cid, messageId: mid, tempId: tempId);
        await unifiedPostMe(body: body, accessToken: accessTok);
        _logger.i('Flushed pending sync', ctx: {'conv': cid, 'msg': mid});
      } catch (_) {
        // Keep in queue for next attempt
        remaining.add(item);
      }
    }
    await _savePendingSyncs(remaining);
  }

  void schedulePendingSyncFlush({Duration delay = const Duration(hours: 1)}) {
    if (_pendingSyncScheduled) return;
    _pendingSyncScheduled = true;
    // Best-effort in-session retry; persistent queue ensures next app launch will try again too.
    Future.delayed(delay, () async {
      _pendingSyncScheduled = false;
      try {
        await tryFlushPendingSyncs();
      } catch (_) {}
    });
  }

  // Users
  Future<void> insertUser(String username, String email, String userId) =>
      _db.insertUser(userId, username, email);
  Future<void> insertUserFromServer(Map<String, dynamic> user) =>
      _db.insertUserFromServer(user);
  Future<CustomUser?> fetchCustomUserByEmail(String email) =>
      _db.fetchCustomUserByEmail(email);
  Future<Map<String, dynamic>?> getUser(String email, String password) =>
      _db.getUser(email, password);
  Future<Map<String, dynamic>?> fetchUserFromDatabase(String email) =>
      _db.fetchUserFromDatabase(email);
  Future<void> insertCustomUser(CustomUser user) => _db.insertCustomUser(user);
  String hashPassword(String password) => _db.hashPassword(password);
  bool verifyPassword(String password, String hashedPassword) =>
      _db.verifyPassword(password, hashedPassword);

  // Conversations
  Future<void> insertConversation(Conversation conversation) =>
      _db.insertConversation(conversation);
  Future<List<Conversation>> fetchConversations() => _db.fetchConversations();
  Future<void> backfillConversationsFromMessages() =>
      _db.backfillConversationsFromMessages();
  Future<void> updateConversationTitle(String conversationId, String title) =>
      _db.updateConversationTitle(conversationId, title);
  Future<void> updateConversationRelatedIds(String conversationId,
          {String? userId}) =>
      _db.updateConversationRelatedIds(conversationId, userId: userId);
  Future<void> updateConversationLocalOnly(
      String conversationId, bool localOnly) async {
    await _db.updateConversationLocalOnly(conversationId, localOnly);
    notifyConversationsChanged();
  }

  Future<void> deleteConversation(String conversationId) async {
    await _db.deleteConversation(conversationId);
    notifyConversationsChanged();
  }

  Future<void> deleteConversations(List<String> conversationIds) async {
    await _db.deleteConversations(conversationIds);
    notifyConversationsChanged();
  }

  Future<void> deleteAllConversations() async {
    await _db.deleteAllConversations();
    notifyConversationsChanged();
  }

  Future<void> deleteAllLocalData() async {
    await _db.deleteAllLocalData();
    notifyConversationsChanged();
  }

  Future<int> getMessageCount(String conversationId) =>
      _db.getMessageCount(conversationId);
  Future<Conversation?> fetchConversationById(String conversationId) =>
      _db.fetchConversationById(conversationId);

  // Messages
  Future<void> insertMessage(Message message) => _db.insertMessage(message);
  Future<void> insertMessageRaw(Map<String, Object?> msgDbMap) async {
    final db = await _db.database;
    await db.insert('messages', msgDbMap);
  }

  Future<void> updateMessageMetadata(
      String messageId, Map<String, dynamic> metadata) async {
    final db = await _db.database;
    await db.update('messages', {'metadata': jsonEncode(metadata)},
        where: 'message_id = ?', whereArgs: [messageId]);
  }

  Future<List<Message>> fetchMessages(String conversationId) =>
      _db.fetchMessages(conversationId);

  // Message IO triplets
  Future<int> insertMessageRequest(Map<String, dynamic> request) =>
      _db.insertMessageRequest(request);
  Future<int> insertMessageResponse(Map<String, dynamic> response) =>
      _db.insertMessageResponse(response);
  Future<int> insertMessageOutput(Map<String, dynamic> output) =>
      _db.insertMessageOutput(output);

  // Latest IO by message
  Future<Map<String, dynamic>?> fetchLatestMessageRequest(String messageId) =>
      _db.fetchLatestMessageRequest(messageId);
  Future<Map<String, dynamic>?> fetchLatestMessageResponse(String messageId) =>
      _db.fetchLatestMessageResponse(messageId);
  Future<Map<String, dynamic>?> fetchLatestMessageOutput(String messageId) =>
      _db.fetchLatestMessageOutput(messageId);

  // Attachments
  Future<int> insertAttachment(Map<String, dynamic> attachment) =>
      _db.insertAttachment(attachment);
  Future<List<Map<String, dynamic>>> fetchAttachmentsByMessage(
          String messageId) =>
      _db.fetchAttachmentsByMessage(messageId);
  Future<List<Map<String, dynamic>>> fetchAttachmentsByConversation(
          String conversationId) =>
      _db.fetchAttachmentsByConversation(conversationId);
  Future<List<Map<String, dynamic>>> fetchAttachmentsByUser(String userId) =>
      _db.fetchAttachmentsByUser(userId);
  Future<int> deleteAttachmentById(int id) => _db.deleteAttachmentById(id);

  // --------------------
  // API facade (delegates to ApiService)
  // --------------------

  // Health
  Future<bool> healthCheck({bool forceRefresh = false}) async {
    final cached = _healthCache;
    if (!forceRefresh && cached != null && _isFresh(cached.ts, _healthTtl)) {
      return cached.value;
    }
    final ok = await _api.healthCheck();
    _healthCache = _Cached(ok, DateTime.now());
    return ok;
  }

  // Provider key checks
  Future<bool> checkOpenAiKey(String apiKey) => _api.checkOpenAiKey(apiKey);
  Future<bool> checkOpenRouterKey(String apiKey) =>
      _api.checkOpenRouterKey(apiKey);
  Future<bool> checkGoogleKey(String apiKey) => _api.checkGoogleKey(apiKey);

  // Provider key checks (detailed): distinguish invalid key from a
  // transient/network failure so the UI can show "Invalid key" vs.
  // "Unreachable — retry" instead of one generic red state.
  Future<ProviderCheckStatus> checkOpenAiKeyDetailed(String apiKey) =>
      _api.checkOpenAiKeyDetailed(apiKey);
  Future<ProviderCheckStatus> checkOpenRouterKeyDetailed(String apiKey) =>
      _api.checkOpenRouterKeyDetailed(apiKey);
  Future<ProviderCheckStatus> checkGoogleKeyDetailed(String apiKey) =>
      _api.checkGoogleKeyDetailed(apiKey);

  // Provider model lists
  Future<List<String>> fetchOpenAIModels(String apiKey,
      {bool throwOnError = false, bool forceRefresh = false}) async {
    final sig = _keySig('openai', apiKey);
    final c = _modelCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list =
        await _api.fetchOpenAIModels(apiKey, throwOnError: throwOnError);
    _modelCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  Future<List<String>> fetchOpenRouterModels(String apiKey,
      {bool throwOnError = false, bool forceRefresh = false}) async {
    final sig = _keySig('openrouter', apiKey);
    final c = _modelCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list =
        await _api.fetchOpenRouterModels(apiKey, throwOnError: throwOnError);
    _modelCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchOpenRouterModelsRaw(String apiKey,
      {bool throwOnError = false, bool forceRefresh = false}) async {
    final sig = _keySig('openrouter.raw', apiKey);
    final c = _modelRawCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list =
        await _api.fetchOpenRouterModelsRaw(apiKey, throwOnError: throwOnError);
    _modelRawCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  // Build quick metadata map for tooltips/grouping from OpenRouter entry
  Map<String, String> openRouterMetaFrom(Map<String, dynamic> m) {
    String ctx =
        (m['context_length'] ?? m['top_provider']?['context_length'] ?? '')
            .toString();
    final arch = (m['architecture'] as Map?) ?? {};
    final modality = (arch['modality'] ?? '').toString();
    final inMods = (arch['input_modalities'] as List?)?.join(',') ?? '';
    final outMods = (arch['output_modalities'] as List?)?.join(',') ?? '';
    final pricing = (m['pricing'] as Map?) ?? {};
    final topProv = (m['top_provider'] as Map?) ?? {};
    final vendor = (topProv['provider'] ?? '').toString();
    final pPrompt = pricing['prompt']?.toString();
    final pComp = pricing['completion']?.toString();
    final parts = <String, String>{
      if (vendor.isNotEmpty) 'vendor': vendor,
      if (ctx.isNotEmpty) 'ctx': ctx,
      if (modality.isNotEmpty) 'modality': modality,
      if (inMods.isNotEmpty) 'in': inMods,
      if (outMods.isNotEmpty) 'out': outMods,
      if (pPrompt != null) 'prompt_price': pPrompt,
      if (pComp != null) 'completion_price': pComp,
    };
    return parts;
  }

  Future<List<String>> fetchGoogleGeminiModels(String apiKey,
      {bool throwOnError = false, bool forceRefresh = false}) async {
    final sig = _keySig('gemini', apiKey);
    final c = _modelCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list =
        await _api.fetchGoogleGeminiModels(apiKey, throwOnError: throwOnError);
    _modelCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchGoogleGeminiModelsRaw(String apiKey,
      {bool throwOnError = false, bool forceRefresh = false}) async {
    final sig = _keySig('gemini.raw', apiKey);
    final c = _modelRawCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list = await _api.fetchGoogleGeminiModelsRaw(apiKey,
        throwOnError: throwOnError);
    _modelRawCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  // Hugging Face models raw (downloads sorted)
  Future<List<Map<String, dynamic>>> fetchHuggingFaceModelsRaw(
      {String? apiKey, bool forceRefresh = false}) async {
    final key = apiKey ?? '__no_key__';
    final sig = _keySig('huggingface.raw', key);
    final c = _hfModelRawCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list = await _api.fetchHuggingFaceModelsRaw(apiKey: apiKey);
    _hfModelRawCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  // Hugging Face embeddings & images convenience wrappers
  Future<List<int>> huggingFaceEmbeddingBytes(
      {required String apiKey,
      required String model,
      required String input}) async {
    final bytes = await _api.huggingFaceEmbeddingBytes(
        apiKey: apiKey, model: model, input: input);
    return bytes;
  }

  Future<List<int>> huggingFaceImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    final bytes = await _api.huggingFaceImagePng(
        apiKey: apiKey, model: model, prompt: prompt, size: size);
    return bytes;
  }

  // Gemini quick meta
  Map<String, String> geminiMetaFrom(Map<String, dynamic> m) {
    final inputLimit = (m['inputTokenLimit'] ?? '').toString();
    final outputLimit = (m['outputTokenLimit'] ?? '').toString();
    final methods = (m['supportedGenerationMethods'] as List?)?.join(',') ?? '';
    final temp = (m['temperature'] ?? '').toString();
    final topP = (m['topP'] ?? '').toString();
    final topK = (m['topK'] ?? '').toString();
    final thinking = (m['thinking'] ?? '').toString();
    return {
      if (inputLimit.isNotEmpty) 'ctx_in': inputLimit,
      if (outputLimit.isNotEmpty) 'ctx_out': outputLimit,
      if (methods.isNotEmpty) 'methods': methods,
      if (temp.isNotEmpty) 'temperature': temp,
      if (topP.isNotEmpty) 'topP': topP,
      if (topK.isNotEmpty) 'topK': topK,
      if (thinking.isNotEmpty) 'thinking': thinking,
    };
  }

  // LM Studio utilities
  Future<String> checkLmStudioStatus([String? endpoint]) =>
      _api.checkLmStudioStatus(endpoint);
  Future<List<String>> fetchLmStudioModels(
      {String? baseUrl, bool forceRefresh = false}) async {
    final key = (baseUrl ?? '').trim();
    final sig = _keySig('lmstudio', key);
    final c = _modelCache[sig];
    if (!forceRefresh && c != null && _isFresh(c.ts, _modelsTtl)) {
      return c.value;
    }
    final list = await _api.fetchLmStudioModels(baseUrl: baseUrl);
    _modelCache[sig] = _Cached(list, DateTime.now());
    return list;
  }

  // Generic LLM request
  Future<Map<String, dynamic>> sendLlmRequest({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) =>
      _api.sendLlmRequest(url: url, headers: headers, body: body);
  Stream<String> sendLlmRequestStream({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) =>
      _api.sendLlmRequestStream(url: url, headers: headers, body: body);

  // Embedding & Image convenience wrappers (centralizing through ApiService for logging/failover)
  Future<List<int>> openAIEmbeddingBytes(
      {required String apiKey,
      required String model,
      required String input}) async {
    final bytes = await _api.openAIEmbeddingBytes(
        apiKey: apiKey, model: model, input: input);
    return bytes; // already float32 bytes
  }

  Future<List<int>> openAIImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    final bytes = await _api.openAIImagePng(
        apiKey: apiKey, model: model, prompt: prompt, size: size);
    return bytes;
  }

  Future<List<int>> geminiEmbeddingBytes(
      {required String apiKey,
      required String model,
      required String input}) async {
    final bytes = await _api.geminiEmbeddingBytes(
        apiKey: apiKey, model: model, input: input);
    return bytes;
  }

  Future<List<int>> geminiImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    final bytes = await _api.geminiImagePng(
        apiKey: apiKey, model: model, prompt: prompt, size: size);
    return bytes;
  }

  Future<List<int>> openRouterImagePng(
      {required String apiKey,
      required String model,
      required String prompt,
      String size = '512x512'}) async {
    final bytes = await _api.openRouterImagePng(
        apiKey: apiKey, model: model, prompt: prompt, size: size);
    return bytes;
  }

  // Auth
  Future<Map<String, dynamic>> login(String identifier, String password) =>
      _api.login(identifier, password);
  Future<bool> logout(String accessToken) => _api.logout(accessToken);
  Future<Map<String, dynamic>> createVisitorSession() =>
      _api.createVisitorSession();
  Future<Map<String, dynamic>> ensureServerVisitorIdentity() =>
      _api.ensureServerVisitorIdentity();
  Future<bool> serverUp() => _api.healthCheck();
  Future<Map<String, dynamic>> signUp(String username, String email,
          {String? password}) =>
      _api.signUp(username, email, password: password);

  // OAuth bootstrap & completion (delegating to generic http helpers for now)
  Future<Map<String, dynamic>> openRouterAuthorize(
      String base, String redirectUri) async {
    return _oauthGetFallback(
      pathWithQuery: 'auth_api/openrouter/authorize/?redirect_uri=$redirectUri',
      base: base,
      label: 'OpenRouter authorize',
    );
  }

  Future<Map<String, dynamic>> openRouterCallback(String base,
      {required String code, required String state}) async {
    return _oauthPostFallback(
      path: 'auth_api/openrouter/callback/',
      body: {'code': code, 'state': state},
      base: base,
      label: 'OpenRouter callback',
    );
  }

  Future<Map<String, dynamic>> googleAuthorize(
      String base, String redirectUri) async {
    return _oauthGetFallback(
      pathWithQuery: 'auth_api/google/authorize/?redirect_uri=$redirectUri',
      base: base,
      label: 'Google authorize',
    );
  }

  Future<Map<String, dynamic>> googleAuthorizeWithHost(String base,
      {required String redirectUri, required String callbackHost}) async {
    final safeHost = Uri.encodeQueryComponent(callbackHost);
    return _oauthGetFallback(
      pathWithQuery:
          'auth_api/google/authorize/?redirect_uri=$redirectUri&callback_host=$safeHost',
      base: base,
      label: 'Google authorize (cb host)',
    );
  }

  Future<Map<String, dynamic>> googleCallback(String base,
      {required String code, required String state}) async {
    return _oauthPostFallback(
      path: 'auth_api/google/callback/',
      body: {'code': code, 'state': state},
      base: base,
      label: 'Google callback',
    );
  }

  Future<Map<String, dynamic>> getJson(String url) async {
    // If absolute, attempt host substitution fallback; else delegate directly
    if (url.startsWith('http://') || url.startsWith('https://')) {
      final uri = Uri.parse(url);
      final rel = url.contains('/api/v1/')
          ? url.substring(url.indexOf('/api/v1/') + '/api/v1/'.length)
          : uri.path.replaceFirst('/', '');
      // Build a normalized base that respects scheme/host and avoids forcing ports
      String base = '${uri.scheme}://${uri.host}';
      if (uri.hasPort) {
        base = '$base:${uri.port}';
      }
      base = _normalizeApiBaseForRepo('$base/');
      return _oauthGetFallback(
        pathWithQuery: rel + (uri.hasQuery ? '?${uri.query}' : ''),
        base: base,
        label: 'Generic getJson',
      );
    }
    final resp = await _api.tryGet(url);
    if (resp.statusCode != 200) {
      throw Exception('GET failed ${resp.statusCode}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // ---------------- Host Fallback Helpers ----------------
  Future<Map<String, dynamic>> _oauthGetFallback(
      {required String pathWithQuery,
      required String base,
      required String label}) async {
    List<String> bases = _orderedHostBases(base);
    try {
      const storage = FlutterSecureStorage();
      final pinned = await storage.read(key: 'custom_base_url');
      if (pinned != null && pinned.isNotEmpty) {
        final norm = _normalizeApiBaseForRepo(pinned);
        bases = [norm];
        _logger.i('[$label] Using pinned base only for OAuth GET');
      }
    } catch (_) {}
    for (final b in bases) {
      final endpoint = '$b$pathWithQuery';
      _logger.i('[$label] GET -> $endpoint');
      http.Response resp;
      try {
        resp = await _api.tryGet(endpoint);
      } catch (_) {
        // Network/transport failure -> try next base
        continue;
      }
      _logger.i('[$label] GET <- ${resp.statusCode}');
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      // Retry only on typical transient/routing statuses
      if (resp.statusCode == 404 ||
          resp.statusCode == 502 ||
          resp.statusCode == 503) {
        continue; // try next base
      }
      // Non-retriable (e.g., 400/401/403/410/etc.) -> stop iteration and bubble up
      try {
        final m = jsonDecode(resp.body);
        final detail = (m is Map) ? (m['detail']?.toString() ?? '') : '';
        throw Exception(detail.isNotEmpty
            ? detail
            : '$_oauthErrorPrefix $endpoint (${resp.statusCode})');
      } catch (_) {
        throw Exception('$_oauthErrorPrefix $endpoint (${resp.statusCode})');
      }
    }
    throw Exception('$label failed across hosts');
  }

  Future<Map<String, dynamic>> _oauthPostFallback(
      {required String path,
      required Map<String, dynamic> body,
      required String base,
      required String label}) async {
    List<String> bases = _orderedHostBases(base);
    try {
      const storage = FlutterSecureStorage();
      final pinned = await storage.read(key: 'custom_base_url');
      if (pinned != null && pinned.isNotEmpty) {
        final norm = _normalizeApiBaseForRepo(pinned);
        bases = [norm];
        _logger.i('[$label] Using pinned base only for OAuth POST');
      }
    } catch (_) {}
    for (final b in bases) {
      final endpoint = '$b$path';
      _logger.i('[$label] POST -> $endpoint bodyKeys=${body.keys.join(',')}');
      http.Response resp;
      try {
        resp = await _api.tryPost(
          endpoint,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        );
      } catch (_) {
        // Transport failure -> try next base
        continue;
      }
      _logger.i('[$label] POST <- ${resp.statusCode}');
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
      if (resp.statusCode == 404 ||
          resp.statusCode == 502 ||
          resp.statusCode == 503) {
        continue;
      }
      try {
        final m = jsonDecode(resp.body);
        final detail = (m is Map) ? (m['detail']?.toString() ?? '') : '';
        throw Exception(detail.isNotEmpty
            ? detail
            : '$_oauthErrorPrefix $endpoint (${resp.statusCode})');
      } catch (_) {
        throw Exception('$_oauthErrorPrefix $endpoint (${resp.statusCode})');
      }
    }
    throw Exception('$label failed across hosts');
  }

  // Minimal base normalizer for repository helpers; mirrors ApiService._normalizeApiBase
  String _normalizeApiBaseForRepo(String v) {
    var out = (v).trim();
    if (out.isEmpty) return 'http://10.0.2.2:8000/api/v1/';
    if (!out.endsWith('/')) out = '$out/';
    final idxV1 = out.indexOf('/api/v1');
    if (idxV1 >= 0) {
      out = '${out.substring(0, idxV1)}/api/v1/';
    } else {
      final idxApi = out.indexOf('/api/');
      if (idxApi >= 0) {
        out = '${out.substring(0, idxApi)}/api/v1/';
      } else {
        out = '$out' 'api/v1/';
      }
    }
    try {
      final u = Uri.parse(out);
      final h = u.host.toLowerCase();
      if (h == 'www.itse500-ok.ly' ||
          h == 'itse500-ok.ly' ||
          h == 'itse500.swe.com.ly' ||
          h == 'www.itse500.swe.com.ly') {
        return 'https://${u.host}/api/v1/';
      }
    } catch (_) {}
    return out;
  }

  List<String> _orderedHostBases(String initialBase) {
    // Normalize provided base (expecting it ends with /api/v1/)
    String norm = initialBase.endsWith('/') ? initialBase : '$initialBase/';
    if (!norm.endsWith('/api/v1/')) {
      if (norm.contains('/api/v1')) {
        norm = '${norm.substring(0, norm.indexOf('/api/v1'))}/api/v1/';
      } else {
        norm = '$norm' 'api/v1/';
      }
    }
    final uri = Uri.tryParse(norm);

    // Desired priority: the actually-configured/same-origin base first (so web,
    // which always resolves to the real host, doesn't waste round-trips on
    // stale fallbacks) -> production website -> localhost (127) ->
    // emulator (10.0.2.2) -> 192.x -> manual -> legacy domain (kept as a
    // last-resort fallback during the itse500-ok.ly -> itse500.swe.com.ly
    // domain migration).
    final List<String> ordered = [];
    if (uri != null && uri.host.isNotEmpty) {
      final host = uri.host;
      final hasPort = uri.hasPort;
      final portPart = hasPort ? ':${uri.port}' : '';
      ordered.add('${uri.scheme}://$host$portPart/api/v1/');
    }
    ordered.addAll([
      'https://itse500.swe.com.ly/api/v1/',
      'https://www.itse500.swe.com.ly/api/v1/',
      'http://127.0.0.1:8000/api/v1/',
      'http://10.0.2.2:8000/api/v1/',
      'http://192.168.22.99:8000/api/v1/',
    ]);

    // Optional manual hotspot override
    final manual = _cachedHotspotHost;
    if (manual != null && manual.isNotEmpty) {
      ordered.add('http://$manual:8000/api/v1/');
    }

    // Legacy domain, kept as a last-resort fallback during migration.
    ordered.addAll([
      'https://www.itse500-ok.ly/api/v1/',
      'https://itse500-ok.ly/api/v1/',
    ]);

    // Deduplicate preserving order
    final seen = <String>{};
    final result = <String>[];
    for (final b in ordered) {
      if (seen.add(b)) result.add(b);
    }
    return result;
  }

  static const String _oauthErrorPrefix = 'OAuth request failed';

  /// Microsoft OAuth callback: exchanges code and state for tokens
  Future<Map<String, dynamic>> microsoftCallback(String base,
      {required String code, required String state}) async {
    // Replace with your actual API call logic
    final url =
        '${base}auth_api/oauth/microsoft/callback/?code=$code&state=$state';
    final response = await getJson(url);
    return response;
  }

  /// Microsoft OAuth authorize: gets the authorize URL and state from backend
  Future<Map<String, dynamic>> microsoftAuthorize(
      String base, String redirectUri) async {
    // Replace with your actual API call logic
    final url =
        '${base}auth_api/oauth/microsoft/authorize/?redirect_uri=${Uri.encodeComponent(redirectUri)}';
    final response = await getJson(url);
    return response;
  }

  // Public setter to allow UI to store hotspot IP (e.g., from a settings screen)
  Future<void> setManualHotspotHost(String host) async {
    _cachedHotspotHost = host;
    _hotspotHostTs = DateTime.now();
    await _secure.write(key: _hotspotKey, value: host);
  }

  String? get manualHotspotHost => _cachedHotspotHost;

  // Lazy load manual hotspot host
  Future<void> ensureHotspotHostLoaded() async {
    if (_cachedHotspotHost != null &&
        _hotspotHostTs != null &&
        DateTime.now().difference(_hotspotHostTs!) < _hotspotTtl) {
      return;
    }
    final v = await _secure.read(key: _hotspotKey);
    if (v != null && v.isNotEmpty) {
      _cachedHotspotHost = v;
      _hotspotHostTs = DateTime.now();
    }
  }

  // ignore: unused_element
  bool _isEmulatorSync() {
    if (_isEmulatorCache != null) return _isEmulatorCache!;
    // Quick heuristic without awaiting (fallback to false until async check updates it)
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // We cannot do async here; default false and let async refresher update
        return _isEmulatorCache ?? false;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> detectEmulator() async {
    if (_isEmulatorCache != null) return _isEmulatorCache!;
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        final isEmu = !(info.isPhysicalDevice);
        _isEmulatorCache = isEmu;
        return isEmu;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        final isEmu = !(info.isPhysicalDevice);
        _isEmulatorCache = isEmu;
        return isEmu;
      }
    } catch (_) {}
    _isEmulatorCache = false;
    return false;
  }

  // Profile
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    // Avoid sending bad Authorization headers (e.g., 'Bearer null') and support visitor bootstrap.
    try {
      String tok = (accessToken);
      final t = (tok).trim().toLowerCase();
      final invalid = tok.trim().isEmpty || t == 'null' || t == 'undefined';

      if (invalid) {
        final tempId = await _ensureStableTempId();
        // Try to obtain tokens via temp_id (no Authorization header)
        await ensureTokensViaTempId(tempId: tempId);
        tok = await _secure.read(key: 'access_token') ?? '';
      }

      // Use unified endpoint which can also refresh and return profile consistently
      final res = await _api.unifiedGetMe(
          profile: true,
          chat: false,
          accessToken: tok.trim().isEmpty ? null : tok.trim());
      // Prefer returning the profile map when available; else return the whole payload for caller flexibility
      final profile = res['profile'];
      if (profile is Map<String, dynamic>) {
        return profile;
      }
      // If unified returned tokens (visitor bootstrap) but no profile, retry once with the new token
      if (res['tokens'] is Map) {
        final tks = (res['tokens'] as Map).cast<String, dynamic>();
        final acc = tks['access']?.toString();
        if (acc != null && acc.isNotEmpty) {
          await _secure.write(key: 'access_token', value: acc);
          final res2 = await _api.unifiedGetMe(
              profile: true, chat: false, accessToken: acc);
          final profile2 = res2['profile'];
          if (profile2 is Map<String, dynamic>) return profile2;
          return res2;
        }
      }
      return res;
    } catch (e) {
      _logger.e('getProfile failed', error: e);
      rethrow;
    }
  }

  Future<void> updateProfile(String username, String email, String password) =>
      _api.updateProfile(username, email, password);
  Future<void> modifyAccount({required bool delete, String reason = ''}) =>
      _api.modifyAccount(delete: delete, reason: reason);

  // Unified sync wrappers
  Future<Map<String, dynamic>> unifiedGetMe({
    bool profile = true,
    bool chat = false,
    String? tempId,
    bool allowPublicUuid = false,
    String? deviceId,
    String? accessToken,
  }) =>
      _maybeAllowSync<Map<String, dynamic>>(() async {
        return _api.unifiedGetMe(
          profile: profile,
          chat: chat,
          tempId: tempId,
          allowPublicUuid: allowPublicUuid,
          deviceId: deviceId,
          accessToken: accessToken,
        );
      },
          fallback: () async =>
              {'skipped': true, 'reason': 'storage_mode_local'});

  Future<Map<String, dynamic>> unifiedPostMe({
    required Map<String, dynamic> body,
    String? accessToken,
  }) =>
      _maybeAllowSync<Map<String, dynamic>>(() async {
        return _api.unifiedPostMe(body: body, accessToken: accessToken);
      },
          fallback: () async =>
              {'skipped': true, 'reason': 'storage_mode_local'});

  Future<Map<String, dynamic>> unifiedPatchMe({
    required Map<String, dynamic> body,
    String? accessToken,
  }) =>
      _maybeAllowSync<Map<String, dynamic>>(() async {
        return _api.unifiedPatchMe(body: body, accessToken: accessToken);
      },
          fallback: () async =>
              {'skipped': true, 'reason': 'storage_mode_local'});

  Future<Map<String, dynamic>> unifiedDeleteMe({
    required String action, // 'delete' or 'archive'
    bool profile = true,
    bool chat = true,
    bool downloadNow = false,
    String? accessToken,
    String? reason,
  }) =>
      _maybeAllowSync<Map<String, dynamic>>(() async {
        return _api.unifiedDeleteMe(
          action: action,
          profile: profile,
          chat: chat,
          downloadNow: downloadNow,
          accessToken: accessToken,
          reason: reason,
        );
      },
          fallback: () async =>
              {'skipped': true, 'reason': 'storage_mode_local'});

  /// Helper: Ensure tokens via temp_id using unified GET if we have no JWT yet and not in strict local mode.
  Future<Map<String, String>?> ensureTokensViaTempId(
      {required String tempId}) async {
    try {
      // Skip if privacy is local
      final mode = await _prefs.getString('storage_mode');
      if ((mode ?? 'local') == 'local') return null;
      final result =
          await _api.unifiedGetMe(profile: true, chat: false, tempId: tempId);
      // Tokens may be at root or nested under 'tokens'
      String? access;
      String? refresh;
      if (result['tokens'] is Map) {
        final t = (result['tokens'] as Map).cast<String, dynamic>();
        access = t['access']?.toString();
        refresh = t['refresh']?.toString();
      } else {
        access = result['access']?.toString();
        refresh = result['refresh']?.toString();
      }
      if ((access != null && access.isNotEmpty) ||
          (refresh != null && refresh.isNotEmpty)) {
        if (access != null && access.isNotEmpty) {
          await _secure.write(key: 'access_token', value: access);
        }
        if (refresh != null && refresh.isNotEmpty) {
          await _secure.write(key: 'refresh_token', value: refresh);
        }
        return {
          if (access != null && access.isNotEmpty) 'access': access,
          if (refresh != null && refresh.isNotEmpty) 'refresh': refresh,
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Password reset flow
  Future<Map<String, dynamic>> requestEmailPin(String email) =>
      _api.requestEmailPin(email);
  Future<Map<String, dynamic>> verifyEmailPin(String email, String pin) =>
      _api.verifyEmailPin(email, pin);
  Future<Map<String, dynamic>> setPasswordAfterEmailVerify(
          String email, String password) =>
      _api.setPasswordAfterEmailVerify(email, password);
  Future<Map<String, dynamic>> syncOrRegisterVisitor(
          {required String tempId}) =>
      _api.syncOrRegisterVisitor(tempId: tempId);

  // Sync/associate
  Future<List<Conversation>> syncConversations(
          {String? anonId, String? userId}) =>
      _maybeAllowSync<List<Conversation>>(() async {
        return _api.syncConversations(anonId: anonId, userId: userId);
      }, fallback: () async {
        // Return local conversations when sync disabled
        return fetchConversations();
      });
  Future<Map<String, dynamic>> pushConversations({
    required List<Map<String, dynamic>> conversations,
    String? anonId,
    String? userId,
  }) =>
      _maybeAllowSync<Map<String, dynamic>>(() async {
        return _api.pushConversations(
            conversations: conversations, anonId: anonId, userId: userId);
      },
          fallback: () async =>
              {'skipped': true, 'reason': 'storage_mode_local'});

  /// Build a minimal sync payload for a single message inside its conversation.
  Future<Map<String, dynamic>> buildSingleMessageSyncPayload({
    required String conversationId,
    required String messageId,
  }) async {
    final conv = await fetchConversationById(conversationId);
    final msgList = await fetchMessages(conversationId);
    final msg = msgList.firstWhere((m) => m.messageId == messageId,
        orElse: () => Message(
              messageId: messageId,
              conversationId: conversationId,
              userId: 'user',
              timestamp: DateTime.now(),
              vote: false,
              hasImage: false,
              metadata: null,
              hasEmbedding: false,
              hasDocument: false,
            ));
    final req = await fetchLatestMessageRequest(messageId);
    final res = await fetchLatestMessageResponse(messageId);
    final out = await fetchLatestMessageOutput(messageId);
    final msgMap = msg.toJson();
    if (req != null) msgMap['request'] = req;
    if (res != null) msgMap['response'] = res;
    if (out != null) msgMap['output'] = out;
    return {
      'conversations': [
        {
          'id': conv?.conversationId ?? conversationId,
          'conversation_id': conv?.conversationId ?? conversationId,
          'title': conv?.title ?? 'Conversation',
          'created_at': (conv?.createdAt ?? DateTime.now()).toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'local_only': conv?.localOnly ?? true,
          'messages': [msgMap],
        }
      ],
    };
  }

  /// Build a UnifiedSyncView.post-compatible upsert body for a single message.
  ///
  /// Shape expected by backend (top-level lists + chat flag):
  /// {
  ///   "chat": true,
  ///   "temp_id": "..." (optional for visitors),
  ///   "device_id": "..." (optional),
  ///   "conversations": [...],
  ///   "messages": [...],
  ///   "message_requests": [...],
  ///   "message_responses": [...],
  ///   "message_outputs": [...],
  ///   "attachments": [...]
  /// }
  Future<Map<String, dynamic>> buildSingleMessageUnifiedBody({
    required String conversationId,
    required String messageId,
    String? tempId,
    String? deviceId,
  }) async {
    final conv = await fetchConversationById(conversationId);
    final msgList = await fetchMessages(conversationId);
    final msg = msgList.firstWhere(
      (m) => m.messageId == messageId,
      orElse: () => Message(
        messageId: messageId,
        conversationId: conversationId,
        userId: 'user',
        timestamp: DateTime.now(),
        vote: false,
        hasImage: false,
        metadata: null,
        hasEmbedding: false,
        hasDocument: false,
      ),
    );
    final req = await fetchLatestMessageRequest(messageId);
    final res = await fetchLatestMessageResponse(messageId);
    final out = await fetchLatestMessageOutput(messageId);
    final atts = await fetchAttachmentsByMessage(messageId);

    // Message map without nested IO (backend expects IO in their own lists)
    final messageMap = msg.toJson();
    messageMap.remove('request');
    messageMap.remove('response');
    messageMap.remove('output');

    final convMap = {
      'id': conv?.conversationId ?? conversationId,
      'conversation_id': conv?.conversationId ?? conversationId,
      'title': conv?.title ?? 'Conversation',
      'created_at': (conv?.createdAt ?? DateTime.now()).toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'local_only': conv?.localOnly ?? true,
    };

    return {
      'chat': true,
      if (tempId != null && tempId.isNotEmpty) 'temp_id': tempId,
      if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
      'conversations': [convMap],
      'messages': [messageMap],
      'message_requests': [if (req != null) req],
      'message_responses': [if (res != null) res],
      'message_outputs': [if (out != null) out],
      'attachments': atts,
    };
  }

  Future<void> associateDevice(
          {String? anonId, String? userId, String? deviceId}) =>
      _api.associateDevice(
          anonId: anonId, userId: userId, deviceId: deviceId ?? '');

  // Logging helper
  Future<void> logError(String message) => _api.logErrorToFile(message);

  // ---- Internal sync gating based on storage mode ----
  Future<T> _maybeAllowSync<T>(Future<T> Function() op,
      {required Future<T> Function() fallback}) async {
    try {
      final mode = await _prefs.getString('storage_mode');
      if ((mode ?? 'local') == 'local') {
        // Skip network sync in local-only privacy mode
        _logger.i('Sync operation skipped (storage_mode=local)');
        return await fallback();
      }
    } catch (_) {}
    return await op();
  }

  // --- Helper: ensure we have a stable temp_id persisted for visitor flows ---
  Future<String> _ensureStableTempId() async {
    try {
      final existing = await _secure.read(key: 'temp_id');
      if (existing != null && existing.isNotEmpty) return existing;
    } catch (_) {}
    String candidate = '';
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        candidate = info.id;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        candidate = info.identifierForVendor ?? '';
      }
    } catch (_) {}
    if (candidate.isEmpty) {
      // Fallback: timestamp-based id; sufficient for visitor bootstrap
      candidate = 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    }
    try {
      await _secure.write(key: 'temp_id', value: candidate);
    } catch (_) {}
    return candidate;
  }
}

class _Cached<T> {
  final T value;
  final DateTime ts;
  _Cached(this.value, this.ts);
}
