import 'dart:convert';
import 'package:bloc/bloc.dart';
// import 'package:flutter/material.dart';
import 'package:flutter_app_itse500/features/chat/logic/chat_state.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_app_itse500/core/models/message.dart';
import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/models/message_output.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:uuid/uuid.dart';
// duplicate removed: file_picker already imported above
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/chat_repository.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/model_resolver.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/builders/message_request_builder.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';
import 'dart:io';
import 'package:crypto/crypto.dart' as crypto;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_app_itse500/core/models/attachment.dart';
import 'package:file_picker/file_picker.dart';

//import 'package:cryptography/cryptography.dart' as c;
// Encryption helper retained for future reactivation (currently disabled)
// import 'package:flutter_app_itse500/core/utils/crypto/artifact_encryptor.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/factories/provider_adapter_factory.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/model_repository.dart';
import 'package:flutter_app_itse500/core/models/model_category.dart';
import 'package:flutter_app_itse500/core/models/model_descriptor.dart';
import 'package:flutter_app_itse500/shared_preferences.dart';

class ChatCubit extends Cubit<ChatState> {
  // Persistent configuration and API key state
  Map<String, String> providerApiKeys = {};
  Map<String, List<String>> providerLLMs = {};
  Map<String, List<String>> selectedProviderLLMs = {};
  Map<String, bool> providerConnected = {};
  Map<String, bool> providerEnabled = {};
  // User-defined routing priority lists per provider (ordered fallback models)
  Map<String, List<String>> providerModelPriority = {};
  final List<String> supportedProviders = [
    'openai',
    'openrouter',
    'gemini',
    'lmstudio',
    'huggingface'
  ];
  final Set<String> chatHiddenProviders = {
    'huggingface'
  }; // hide HF in chat (Alpha)
  final DataRepository _dataRepo = DataRepository();
  // API access centralized via DataRepository
  final UnifiedLogger _logger = UnifiedLogger.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final ChatRepository _repo = ChatRepository();
  final ModelResolver _modelResolver = const ModelResolver();
  final ProviderAdapterFactory _adapterFactory = ProviderAdapterFactory();
  final ModelRepository _modelRepo = ModelRepository.I;
  String? activeConversationId;
  String? activeProvider;
  String? activeModel;
  // Cached lists for UI when emitting non-loaded states (e.g., config changes)
  List<Message> cachedMessages = [];
  List<Conversation> cachedConversations = [];
  // Pending attachments queued by user before send
  final List<PlatformFile> _pendingAttachments = [];
  List<PlatformFile> get pendingAttachments =>
      List.unmodifiable(_pendingAttachments);

  void removePendingAttachmentAt(int index) {
    if (index >= 0 && index < _pendingAttachments.length) {
      _pendingAttachments.removeAt(index);
      emit(ChatConfigChanged());
    }
  }

  void clearPendingAttachments() {
    if (_pendingAttachments.isNotEmpty) {
      _pendingAttachments.clear();
      emit(ChatConfigChanged());
    }
  }

  ChatCubit() : super(ChatInitial()) {
    for (final p in supportedProviders) {
      providerApiKeys[p] = '';
      providerLLMs[p] = [];
      selectedProviderLLMs[p] = [];
      providerConnected[p] = false;
      providerEnabled[p] = false;
      providerModelPriority[p] = [];
    }
    // Hydrate cached models and selections from secure storage
    _hydrateFromStorage();
  }

  /// Reset ephemeral chat state on logout/delete to avoid stale UI data.
  /// Does not clear provider API keys or model lists; focuses on conversations/messages caches.
  void resetForLogout({bool clearSelections = false}) {
    try {
      activeConversationId = null;
      activeProvider = null;
      activeModel = null;
      _pendingAttachments.clear();
      cachedMessages = [];
      cachedConversations = [];
      if (clearSelections) {
        for (final p in supportedProviders) {
          selectedProviderLLMs[p] = [];
          providerModelPriority[p] = [];
        }
      }
      emit(ChatConfigChanged());
    } catch (e) {
      _logger.w('resetForLogout failed', error: e);
      // still emit to force UI refresh away from any lingering state
      emit(ChatConfigChanged());
    }
  }

  /// Deep cleanup: remove provider API keys, selected models, and priorities from
  /// both memory and secure storage. Useful for full account logout/delete.
  Future<void> purgeProviderCredentialsAndSelections() async {
    try {
      for (final p in supportedProviders) {
        // Clear in-memory
        providerApiKeys[p] = '';
        selectedProviderLLMs[p] = [];
        providerModelPriority[p] = [];
        providerConnected[p] = false;
        providerEnabled[p] = false;
        // Clear persisted secure storage keys used across app
        await _secureStorage.delete(key: '${p}_api_key');
        await _secureStorage.delete(key: '${p}_key');
        await _secureStorage.delete(key: '${p}_models');
        await _secureStorage.delete(key: '${p}_models_selected');
        await _secureStorage.delete(key: '${p}_priority');
      }
      // Also remove any known OAuth bridge artifacts
      await _secureStorage.delete(key: 'openrouter_key');
      await _secureStorage.delete(key: 'google_id_token');
      emit(ChatConfigChanged());
    } catch (e) {
      _logger.e('purgeProviderCredentialsAndSelections failed', error: e);
      emit(ChatConfigChanged());
    }
  }

  Future<void> _hydrateFromStorage() async {
    try {
      final storage = _secureStorage;
      for (final p in supportedProviders) {
        final modelsStr = await storage.read(key: '${p}_models');
        final selectedStr = await storage.read(key: '${p}_models_selected');
        final priorityStr = await storage.read(key: '${p}_priority');
        if (modelsStr != null && modelsStr.isNotEmpty) {
          providerLLMs[p] =
              modelsStr.split('|').where((e) => e.isNotEmpty).toList();
        }
        if (selectedStr != null && selectedStr.isNotEmpty) {
          final raw = selectedStr.split('|').where((e) => e.isNotEmpty).toSet();
          // Normalize: ensure both prefixed and unprefixed forms present for matching.
          final norm = <String>{};
          for (final m in raw) {
            norm.add(m);
            if (m.startsWith('models/')) {
              norm.add(m.replaceFirst('models/', ''));
            } else {
              norm.add('models/$m');
            }
          }
          selectedProviderLLMs[p] = norm.toList();
        }
        if (priorityStr != null && priorityStr.isNotEmpty) {
          // Stored as canonical unprefixed list; hydrate directly preserving order, remove dups
          final seen = <String>{};
          final ordered = <String>[];
          for (final m in priorityStr.split('|')) {
            final id =
                m.startsWith('models/') ? m.replaceFirst('models/', '') : m;
            if (id.isEmpty) continue;
            if (seen.add(id)) ordered.add(id);
          }
          providerModelPriority[p] = ordered;
        }
      }
      _sanitizePriorities(logPrefix: 'hydrate');
      emit(ChatConfigChanged());
    } catch (e) {
      _logger.w('Hydration from storage failed', error: e);
    }
  }

  // ---------- Configuration helpers (added to satisfy UI calls) ----------
  void setApiKey(String provider, String apiKey) {
    providerApiKeys[provider] = apiKey;
    emit(ChatConfigChanged());
  }

  Future<String?> getApiKey(String provider) async {
    // prefer cached then secure storage
    final cached = providerApiKeys[provider];
    if (cached != null && cached.isNotEmpty) return cached;
    final key = await _secureStorage.read(key: '${provider}_api_key') ??
        await _secureStorage.read(key: '${provider}_key');
    if (key != null) providerApiKeys[provider] = key;
    return key;
  }

  void setProviderLLMs(String provider, List<String> llms) {
    // Canonicalize ids (strip optional 'models/' prefix) and de-duplicate while preserving order
    String canon(String m) =>
        m.startsWith('models/') ? m.replaceFirst('models/', '') : m;
    final seen = <String>{};
    final out = <String>[];
    for (var m in llms) {
      if (m.isEmpty) continue;
      final key = canon(m);
      if (seen.add(key)) {
        out.add(key); // store canonical unprefixed form for display/use
      }
    }
    providerLLMs[provider] = out;
    emit(ChatConfigChanged());
  }

  void setSelectedProviderLLMs(String provider, List<String> llms) {
    final norm = <String>{};
    for (final m in llms) {
      if (m.isEmpty) continue;
      norm.add(m);
      if (m.startsWith('models/')) {
        norm.add(m.replaceFirst('models/', ''));
      } else {
        norm.add('models/$m');
      }
    }
    selectedProviderLLMs[provider] = norm.toList();
    emit(ChatConfigChanged());
  }

  void setProviderConnected(String provider, bool connected) {
    providerConnected[provider] = connected;
    emit(ChatConfigChanged());
  }

  void setProviderEnabled(String provider, bool enabled) {
    providerEnabled[provider] = enabled;
    emit(ChatConfigChanged());
  }

  void setProviderModelPriority(String provider, List<String> orderedModels) {
    // Keep the exact ordered list (canonical unprefixed) for user intent.
    final ordered = <String>[];
    final seen = <String>{};
    for (var m in orderedModels) {
      if (m.isEmpty) continue;
      if (m.startsWith('models/')) m = m.replaceFirst('models/', '');
      if (seen.add(m)) ordered.add(m);
    }
    providerModelPriority[provider] = ordered;
    // Persist canonical list
    _secureStorage.write(key: '${provider}_priority', value: ordered.join('|'));
    _logger.event('router.priority.set',
        payload: {
          'provider': provider,
          'order': providerModelPriority[provider]
        },
        category: 'router',
        className: 'ChatCubit',
        methodName: 'setProviderModelPriority');
    _sanitizePriorities(logPrefix: 'set');
    emit(ChatConfigChanged());
  }

  void setActiveConversationId(String id) {
    activeConversationId = id;
    emit(ChatConfigChanged());
  }

  // --- Priority Hardening & Logging ---
  void _sanitizePriorities({String logPrefix = 'sanitize'}) {
    for (final provider in supportedProviders) {
      final avail = (providerLLMs[provider] ?? const <String>[])
          .map((m) =>
              m.startsWith('models/') ? m.replaceFirst('models/', '') : m)
          .toSet();
      final current = providerModelPriority[provider] ?? const <String>[];
      if (current.isEmpty) continue;
      final cleaned = <String>[];
      final removed = <String>[];
      final seen = <String>{};
      for (final m in current) {
        if (!avail.contains(m)) {
          removed.add(m);
          continue;
        }
        if (seen.add(m)) cleaned.add(m);
      }
      if (removed.isNotEmpty || cleaned.length != current.length) {
        providerModelPriority[provider] = cleaned;
        _secureStorage.write(
            key: '${provider}_priority', value: cleaned.join('|'));
        _logger.event('router.priority.sanitized',
            payload: {
              'provider': provider,
              'removed': removed,
              'final': cleaned,
              'original_len': current.length
            },
            category: 'router',
            className: 'ChatCubit',
            methodName: '_sanitizePriorities',
            phase: logPrefix);
      }
    }
  }

  /// Always start a new conversation and make it active.
  Future<String> startNewConversation({String? title}) async {
    final id = const Uuid().v4();
    // Do NOT insert into DB yet; only set active id. We will create
    // the conversation row lazily when the first message is sent.
    activeConversationId = id;
    emit(ChatConfigChanged());
    return id;
  }

  String ensureConversation() {
    if (activeConversationId != null) return activeConversationId!;
    final id = const Uuid().v4();
    // Do NOT insert into DB yet; only set active id. We will create
    // the conversation row lazily when the first message is sent.
    activeConversationId = id;
    return id;
  }

  void setActiveProviderModel(String provider, String? model) {
    activeProvider = provider;
    activeModel = model;
    // notify UI so dropdowns and capability gating refresh
    emit(ChatConfigChanged());
  }

  // Attachment picking (basic implementation). Emits AttachmentPicked state without altering existing messages state caches.
  Future<void> pickAttachment(
      {bool withData = false, List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: false,
        withData: withData,
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );
      if (result != null && result.files.isNotEmpty) {
        _pendingAttachments.add(result.files.first);
        final f = result.files.first;
        await _logger.event(
          'attachment.picked',
          payload: {
            'name': f.name,
            'size': f.size,
            'ext': (f.extension ?? '').toLowerCase(),
            'hasPath': f.path != null,
          },
          category: 'chat',
          className: 'ChatCubit',
          methodName: 'pickAttachment',
        );
        emit(AttachmentPicked(result.files.first));
      }
    } catch (e) {
      _logger.e('pickAttachment error', error: e);
      // Do not override current loaded view with error unless critical.
    }
  }

  // Compute sha256 for a file, helper for attachments
  Future<String> _sha256OfFile(String absPath) async {
    final file = File(absPath);
    final bytes = await file.readAsBytes();
    return crypto.sha256.convert(bytes).toString();
  }

  // Validate per-message size cap (5 MB)
  bool _enforceMessageSizeCap(List<int> bytesList,
      {int capBytes = 5 * 1024 * 1024}) {
    int total = 0;
    for (final b in bytesList) {
      total += b;
      if (total > capBytes) return false;
    }
    return true;
  }

  // Save picked attachments for a message: copy to app dir, encrypt (TBD), and persist rows
  Future<List<Attachment>> persistAttachmentsForMessage({
    required String messageId,
    required String conversationId,
    required String userId,
    required List<PlatformFile> files,
  }) async {
    final saved = <Attachment>[];
    // Enforce 5 MB per message cap
    final sizes = files.map((f) => f.size).toList();
    if (!_enforceMessageSizeCap(sizes)) {
      throw Exception('Attachments exceed 5 MB limit per message');
    }
    final appDir = await getApplicationSupportDirectory();
    final attachDir =
        Directory('${appDir.path}${Platform.pathSeparator}attachments');
    if (!await attachDir.exists()) {
      await attachDir.create(recursive: true);
    }
    for (final f in files) {
      if (f.path == null) continue;
      final src = File(f.path!);
      if (!await src.exists()) continue;
      final ext = src.path.split('.').last.toLowerCase();
      final now = DateTime.now();
      final destPath =
          '${attachDir.path}${Platform.pathSeparator}${messageId}_${now.millisecondsSinceEpoch}.$ext';
      await src.copy(destPath);
      final sha = await _sha256OfFile(destPath);
      final attType = _classifyAttachmentType(ext: ext);
      final map = {
        'message_id': messageId,
        'conversation_id': conversationId,
        'user_id': userId,
        'type': attType,
        'mime_type': _guessMimeFromExt(ext),
        'file_path': destPath,
        'size_bytes': f.size,
        'width': null,
        'height': null,
        'sha256': sha,
        'is_encrypted': 0,
        'enc_algo': null,
        'iv_base64': null,
        'key_ref': null,
        'created_at': now.toIso8601String(),
      };
      final id = await _dataRepo.insertAttachment(map);
      final att = Attachment.fromJson({...map, 'id': id});
      await _logger.event('attachment.persisted',
          payload: {
            'id': id,
            'type': att.type,
            'mime': att.mimeType,
            'size': att.sizeBytes,
            'sha256': att.sha256,
            'path': att.filePath
          },
          category: 'db',
          className: 'ChatCubit',
          methodName: 'persistAttachmentsForMessage',
          conversationId: conversationId,
          messageId: messageId);
      saved.add(att);
    }
    await _logger.event('attachment.persisted.summary',
        payload: {
          'count': saved.length,
          'totalBytes': saved.fold<int>(0, (s, a) => s + a.sizeBytes),
          'types': saved.map((a) => a.type).toSet().toList(),
        },
        category: 'db',
        className: 'ChatCubit',
        methodName: 'persistAttachmentsForMessage',
        conversationId: conversationId,
        messageId: messageId);
    return saved;
  }

  String _classifyAttachmentType({required String ext, String? mime}) {
    final e = ext.toLowerCase();
    if (['png', 'jpg', 'jpeg', 'webp', 'gif', 'bmp', 'heic'].contains(e)) {
      return 'image';
    }
    if (e == 'pdf') return 'pdf';
    if (['xls', 'xlsx', 'csv'].contains(e)) return 'excel';
    if (e == 'json') return 'json';
    if (e == 'md' || e == 'markdown') return 'md';
    // try mime fallback
    if ((mime ?? '').startsWith('image/')) return 'image';
    return 'other';
  }

  String _guessMimeFromExt(String ext) {
    final e = ext.toLowerCase();
    switch (e) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'heic':
        return 'image/heic';
      case 'pdf':
        return 'application/pdf';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'csv':
        return 'text/csv';
      case 'json':
        return 'application/json';
      case 'md':
      case 'markdown':
        return 'text/markdown';
      default:
        return 'application/octet-stream';
    }
  }

  // === Artifact Generation & Commands Phase 0 ===
  Future<void> generateImageCommand(String prompt) async {
    // Route through normal chat pipeline; choose image-capable model and disable fallback to plain text-only models.
    final providerModel = await _findProviderAndModelForCapability('image');
    if (providerModel == null) {
      emit(ChatError(error: 'No image-capable model.'));
      return;
    }
    String modelId = providerModel
        .item2; // e.g. models/gemini-2.0-flash-exp-image-generation
    if (providerModel.item1 == 'gemini') {
      final lower = modelId.toLowerCase();
      // Avoid Imagen billing-only models; prefer Gemini *image-generation* variants.
      if (lower.startsWith('models/')) {
        modelId = modelId.replaceFirst('models/', '');
      }
      if (lower.startsWith('imagen-')) {
        final alts = (selectedProviderLLMs['gemini'] ?? const <String>[])
            .where((m) => m.toLowerCase().contains('image-generation'))
            .toList();
        if (alts.isNotEmpty) {
          modelId = alts.first;
          await _logger.event('image.model.override',
              payload: {'reason': 'avoid_imagen', 'chosen': modelId});
        } else {
          emit(ChatError(
              error:
                  'Only Imagen models detected (billing). Select a Gemini 2.0 flash exp image-generation model.'));
          return;
        }
      }
      // Only force-switch to image-generation models when the prompt explicitly requests image generation (avoid accidental 400s on vision-in chat).
      if (!lower.contains('image-generation')) {
        final alts = <String>{
          ...(selectedProviderLLMs['gemini'] ?? const <String>[]),
          // include fallback catalog list for safety
          'models/gemini-2.0-flash-preview-image-generation',
        }.where((m) => m.toLowerCase().contains('image-generation')).toList();
        if (alts.isNotEmpty) {
          modelId = alts.first.startsWith('models/')
              ? alts.first
              : 'models/${alts.first}';
          await _logger.event('image.model.override', payload: {
            'reason': 'coerce_image_generation',
            'chosen': modelId
          });
        }
      }
      // Normalize to catalog id with models/ prefix if missing
      if (!modelId.startsWith('models/')) modelId = 'models/$modelId';
    }
    await _logger.event('image.command.start', payload: {
      'model': modelId,
      'provider': providerModel.item1,
      'promptLen': prompt.length
    });
    final req = MessageRequest(
      requestId: const Uuid().v4(),
      requestModel: modelId,
      requestUserRole: 'user',
      requestUserContent: prompt,
      requestStream: false,
    );
    await sendMessage(
      request: req,
      multiProvider: false,
      singleProviderOverride: providerModel.item1,
    );
    await _logger.event('image.command.sent',
        payload: {'model': modelId, 'provider': providerModel.item1});
  }

  Future<void> generateEmbeddingCommand(String text) async {
    emit(ChatGeneratingEmbedding(text));
    try {
      // Insert a user-side message echoing the text so it appears on the right.
      await _insertUserTextMessageForEmbedding(text);
      final startedAt = DateTime.now();
      // Diagnostic: log currently selected models & categories for providers
      for (final p in supportedProviders) {
        final sels = selectedProviderLLMs[p] ?? const <String>[];
        if (sels.isEmpty) continue;
        final pid = _toProviderId(p);
        final ptype = switch (pid) {
          ProviderId.openai => ProviderType.openai,
          ProviderId.openrouter => ProviderType.openrouter,
          ProviderId.gemini => ProviderType.gemini,
          ProviderId.lmstudio => ProviderType.lmstudio,
          ProviderId.huggingface => ProviderType.huggingface
        };
        final descs = _modelRepo.getCached(ptype);
        final byId = {for (final d in descs) d.id: d};
        final catMap = {
          for (final s in sels)
            s: (byId[s]?.categories.map((c) => c.name).toList() ?? [])
        };
        await _logger.event('embed.precheck',
            payload: {'provider': p, 'selected': sels, 'cats': catMap});
      }
      _logger.event('artifact.request',
          category: 'artifact',
          className: 'ChatCubit',
          methodName: 'generateEmbeddingCommand',
          phase: 'start',
          status: 'pending',
          payload: {
            'kind': 'embedding',
            'text_len': text.length,
          });
      final tuple = await _findProviderAndModelForCapability('embedding');
      if (tuple == null) {
        emit(ChatError(error: 'No embedding-capable provider/model found.'));
        return;
      }
      final providerKey = tuple.item1;
      final model = tuple.item2;
      final credential = await _getCredentialForProvider(providerKey);
      if (credential == null || credential.isEmpty) {
        emit(ChatError(error: 'Missing credentials for $providerKey'));
        return;
      }
      final adapter = _adapterFactory.forProvider(_toProviderId(providerKey));
      List<int> bytes;
      try {
        bytes = await adapter.generateEmbedding(
            text: text, model: model, credential: credential);
      } catch (e) {
        emit(ChatError(error: 'Embedding generation failed: $e'));
        return;
      }
      final dims = bytes.length ~/ 4; // float32 count
      final attachment = await _persistGeneratedBytesInternal(
        bytes: bytes,
        logicalName: 'embedding_${DateTime.now().millisecondsSinceEpoch}.bin',
        type: 'embedding',
        mime: 'application/octet-stream',
        meta: {
          'model': model,
          'dims': dims,
          'sha256': crypto.sha256.convert(bytes).toString()
        },
        asAssistant: true,
      );
      emit(ChatEmbeddingGenerated(dims));
      _logger.event('artifact.success',
          category: 'artifact',
          className: 'ChatCubit',
          methodName: 'generateEmbeddingCommand',
          phase: 'complete',
          status: 'ok',
          durationMs: DateTime.now().difference(startedAt).inMilliseconds,
          providerId: providerKey,
          model: model,
          payload: {
            'kind': 'embedding',
            'dims': dims,
            'size_bytes': bytes.length,
          });
      await _insertSystemMessageForAttachment(
          prompt: text, attachment: attachment, kind: 'embedding');
    } catch (e) {
      emit(ChatError(error: 'Embedding generation failed: $e'));
      _logger.event('artifact.error',
          category: 'artifact',
          className: 'ChatCubit',
          methodName: 'generateEmbeddingCommand',
          phase: 'outer',
          status: 'error',
          payload: {'kind': 'embedding', 'error': e.toString()});
    }
  }

  Future<void> shareAttachmentPath(String path) async {
    emit(ChatSharePreparing(path));
    try {
      await Share.shareXFiles([XFile(path)]);
    } catch (e) {
      emit(ChatShareFailed('Share failed: $e'));
    }
  }

  String? _autoSelectModelForCapability(String cap) {
    // Simple heuristic: scan selectedProviderLLMs for keywords
    final keyword = cap == 'image'
        ? ['img', 'image', 'dall', 'vision']
        : ['embed', 'embedding'];
    for (final provider in supportedProviders) {
      final models = selectedProviderLLMs[provider] ?? const [];
      for (final m in models) {
        final lower = m.toLowerCase();
        if (keyword.any((k) => lower.contains(k))) {
          return m; // return first match
        }
      }
    }
    return null;
  }

  Future<Attachment> _persistGeneratedBytes(
      {required List<int> bytes,
      required String logicalName,
      required String type,
      required String mime,
      Map<String, dynamic>? meta}) async {
    return _persistGeneratedBytesInternal(
        bytes: bytes,
        logicalName: logicalName,
        type: type,
        mime: mime,
        meta: meta,
        asAssistant: false);
  }

  Future<Attachment> _persistGeneratedBytesInternal(
      {required List<int> bytes,
      required String logicalName,
      required String type,
      required String mime,
      Map<String, dynamic>? meta,
      required bool asAssistant}) async {
    final cid = ensureConversation();
    final mid = const Uuid().v4();
    final appDir = await getApplicationSupportDirectory();
    final attachDir =
        Directory('${appDir.path}${Platform.pathSeparator}attachments');
    if (!await attachDir.exists()) await attachDir.create(recursive: true);
    final filePath = '${attachDir.path}${Platform.pathSeparator}$logicalName';
    await File(filePath).writeAsBytes(bytes, flush: true);
    final sha = crypto.sha256.convert(bytes).toString();
    // Encryption temporarily disabled: we keep plaintext file path.
    // (Original encryption code retained below for future reactivation.)
    // final encHelper = ArtifactEncryptor.instance;
    // final encInfo = await encHelper.encryptFile(filePath);
    // final encPath = encInfo['outPath'] as String;
    // final stat = await File(encPath).stat();
    final stat = await File(filePath).stat();
    final map = {
      'message_id': mid,
      'conversation_id': cid,
      'user_id': 'local_user',
      'type': type,
      'mime_type': mime,
      'file_path': filePath,
      'size_bytes': stat.size,
      'width': null,
      'height': null,
      'sha256': sha,
      'is_encrypted': 0,
      'enc_algo': null,
      'iv_base64': null,
      'key_ref': null,
      'created_at': DateTime.now().toIso8601String(),
    };
    final id = await _dataRepo.insertAttachment(map);
    final att = Attachment.fromJson({...map, 'id': id});
    // augment meta if provided
    final m = meta != null
        ? {
            ...meta,
            'path': att.filePath,
            'type': type,
            'mime': mime,
            'size': att.sizeBytes
          }
        : {
            'path': att.filePath,
            'type': type,
            'mime': mime,
            'size': att.sizeBytes
          };
    m['is_encrypted'] = 0; // legacy fields retained for backward compatibility
    // embed attachment only metadata message now
    cachedMessages.add(Message(
      messageId: mid,
      conversationId: cid,
      userId: asAssistant ? 'assistant' : 'local_user',
      requestId: null,
      responseId: null,
      outputId: null,
      timestamp: DateTime.now(),
      vote: false,
      hasImage: type == 'image',
      imgUrl: null,
      metadata: {
        'attachments': [m],
        'role': asAssistant ? 'assistant' : 'user'
      },
      hasEmbedding: type == 'embedding',
      hasDocument: type == 'pdf',
      docUrl: null,
    ));
    emit(ChatLoaded(
        conversations: cachedConversations, messages: cachedMessages));
    return att;
  }

  Future<void> _insertUserTextMessageForEmbedding(String text) async {
    final cid = ensureConversation();
    final mid = const Uuid().v4();
    final msg = Message(
      messageId: mid,
      conversationId: cid,
      userId: 'local_user',
      requestId: null,
      responseId: null,
      outputId: null,
      timestamp: DateTime.now(),
      vote: false,
      hasImage: false,
      imgUrl: null,
      metadata: {'user_content': text, 'role': 'user'},
      hasEmbedding: false,
      hasDocument: false,
      docUrl: null,
    );
    cachedMessages.add(msg);
    emit(ChatLoaded(
        conversations: cachedConversations, messages: cachedMessages));
  }

  Future<void> _insertSystemMessageForAttachment(
      {required String prompt,
      required Attachment attachment,
      required String kind}) async {
    // Optionally add a small system echo message referencing the generated artifact
    // For now we skip adding an assistant message; UI already shows attachment via message created.
  }
/* 
  List<int> _stubPngBytes(String prompt) {
    // Minimal 1x1 transparent PNG; placeholder. Real implementation will call provider.
    return const [137,80,78,71,13,10,26,10,0,0,0,13,73,72,68,82,0,0,0,1,0,0,0,1,8,6,0,0,0,31,21,196,137,0,0,0,12,73,68,65,84,120,156,99,96,0,0,0,2,0,1,226,33,188,33,0,0,0,0,73,69,78,68,174,66,96,130];
  }

  List<double> _stubEmbedding(String text, {int dims = 64}) {
    final h = crypto.sha256.convert(utf8.encode(text)).bytes;
    final out = List<double>.generate(dims, (i) => (h[i % h.length] / 255.0) * 2 - 1);
    return out;
  }
  // Tuple helper (simple) for returning provider-model pair without importing external libs
  // Capability-aware model selection using catalog categories.
   */
  Future<({String item1, String item2})?> _findProviderAndModelForCapability(
      String cap) async {
    final requiredCat = switch (cap) {
      'embedding' => ModelCategory.embeddings,
      'image' => ModelCategory.image,
      _ => ModelCategory.chat,
    };
    // 1. Active provider + active model fast-path
    if (activeProvider != null && activeModel != null) {
      try {
        final pType = _toProviderId(activeProvider!);
        final providerType = switch (pType) {
          ProviderId.openai => ProviderType.openai,
          ProviderId.openrouter => ProviderType.openrouter,
          ProviderId.gemini => ProviderType.gemini,
          ProviderId.lmstudio => ProviderType.lmstudio,
          ProviderId.huggingface => ProviderType.huggingface,
        };
        if (_modelRepo.getCached(providerType).isEmpty) {
          try {
            await _modelRepo.getModels(
                provider: providerType,
                apiKeyOrEndpoint: await getApiKey(activeProvider!));
          } catch (_) {}
        }
        final descriptors = _modelRepo.getCached(providerType);
        final byId = {for (final d in descriptors) d.id: d};
        final variants = <String>{
          activeModel!,
          if (activeModel!.startsWith('models/'))
            activeModel!.replaceFirst('models/', ''),
          if (!activeModel!.startsWith('models/')) 'models/${activeModel!}',
        };
        for (final v in variants) {
          final d = byId[v];
          if (d != null && d.categories.contains(requiredCat)) {
            await _logger.event('cap.resolve', payload: {
              'cap': cap,
              'strategy': 'activeModel',
              'provider': activeProvider,
              'model': d.id
            });
            return (item1: activeProvider!, item2: d.id);
          }
        }
      } catch (_) {}
    }
    // 1b. Heuristic among selected lists
    final heuristic = _autoSelectModelForCapability(cap);
    if (heuristic != null) {
      for (final entry in selectedProviderLLMs.entries) {
        if (!entry.value.contains(heuristic)) continue;
        final provider = entry.key;
        final pType = _toProviderId(provider);
        final providerType = switch (pType) {
          ProviderId.openai => ProviderType.openai,
          ProviderId.openrouter => ProviderType.openrouter,
          ProviderId.gemini => ProviderType.gemini,
          ProviderId.lmstudio => ProviderType.lmstudio,
          ProviderId.huggingface => ProviderType.huggingface,
        };
        if (_modelRepo.getCached(providerType).isEmpty) {
          try {
            await _modelRepo.getModels(
                provider: providerType,
                apiKeyOrEndpoint: await getApiKey(provider));
          } catch (_) {}
        }
        final descs = _modelRepo.getCached(providerType);
        final d = descs.firstWhere(
          (m) =>
              m.id == heuristic ||
              m.id == 'models/$heuristic' ||
              'models/${m.id}' == heuristic,
          orElse: () => const ModelDescriptor(
              provider: ProviderType.openai,
              id: '',
              displayName: '',
              categories: {}),
        );
        if (d.id.isNotEmpty && d.categories.contains(requiredCat)) {
          await _logger.event('cap.resolve', payload: {
            'cap': cap,
            'strategy': 'heuristic',
            'provider': provider,
            'model': d.id
          });
          return (item1: provider, item2: d.id);
        }
      }
    }
    // 2. Iterate providers (selected models first)
    final orderedProviders = [
      if (activeProvider != null) activeProvider!,
      ...supportedProviders.where((p) => p != activeProvider)
    ];
    for (final provider in orderedProviders) {
      final sel = selectedProviderLLMs[provider] ?? const <String>[];
      final pType = _toProviderId(provider);
      final providerType = switch (pType) {
        ProviderId.openai => ProviderType.openai,
        ProviderId.openrouter => ProviderType.openrouter,
        ProviderId.gemini => ProviderType.gemini,
        ProviderId.lmstudio => ProviderType.lmstudio,
        ProviderId.huggingface => ProviderType.huggingface,
      };
      if (_modelRepo.getCached(providerType).isEmpty) {
        try {
          await _modelRepo.getModels(
              provider: providerType,
              apiKeyOrEndpoint: await getApiKey(provider));
        } catch (_) {}
      }
      final descriptors = _modelRepo.getCached(providerType);
      final byId = {for (final d in descriptors) d.id: d};
      if (sel.isNotEmpty) {
        for (final modelId in sel) {
          final variants = <String>{
            modelId,
            if (modelId.startsWith('models/'))
              modelId.replaceFirst('models/', ''),
            if (!modelId.startsWith('models/')) 'models/$modelId',
          };
          for (final v in variants) {
            final d = byId[v];
            if (d != null && d.categories.contains(requiredCat)) {
              await _logger.event('cap.resolve', payload: {
                'cap': cap,
                'strategy': 'selectedModels',
                'provider': provider,
                'model': d.id
              });
              return (item1: provider, item2: d.id);
            }
          }
        }
      }
      // Catalog-wide fallback
      final anyMatch = descriptors.firstWhere(
        (d) => d.categories.contains(requiredCat),
        orElse: () => const ModelDescriptor(
            provider: ProviderType.openai,
            id: '',
            displayName: '',
            categories: {}),
      );
      if (anyMatch.id.isNotEmpty) {
        await _logger.event('cap.resolve', payload: {
          'cap': cap,
          'strategy': 'catalogFallback',
          'provider': provider,
          'model': anyMatch.id
        });
        return (item1: provider, item2: anyMatch.id);
      }
    }
    // Diagnostics
    final diag = <String, dynamic>{};
    for (final p in supportedProviders) {
      final pType = _toProviderId(p);
      final providerType = switch (pType) {
        ProviderId.openai => ProviderType.openai,
        ProviderId.openrouter => ProviderType.openrouter,
        ProviderId.gemini => ProviderType.gemini,
        ProviderId.lmstudio => ProviderType.lmstudio,
        ProviderId.huggingface => ProviderType.huggingface,
      };
      final descs = _modelRepo.getCached(providerType);
      diag[p] = descs
          .where((d) => d.categories.contains(requiredCat))
          .map((d) => d.id)
          .toList();
    }
    await _logger.event('cap.resolve.failed',
        payload: {'cap': cap, 'diagnostics': diag});
    return null;
  }

  Future<String?> _getCredentialForProvider(String providerKey) async {
    if (providerKey == 'lmstudio') {
      return await _secureStorage.read(key: 'lmstudio_endpoint') ?? '';
    }
    return await _secureStorage.read(key: '${providerKey}_api_key') ??
        await _secureStorage.read(key: '${providerKey}_key');
  }

/* 
  List<int> _float32ListToBytes(List<double> values) {
  final b = BytesBuilder();
  final bd = ByteData(values.length * 4);
    for (int i = 0; i < values.length; i++) {
      bd.setFloat32(i * 4, values[i]);
    }
    b.add(bd.buffer.asUint8List());
    return b.takeBytes();
  }
   */
  Future<void> sendMessage({
    required MessageRequest request,
    String? conversationId,
    bool multiProvider = true,
    String? singleProviderOverride,
    InferenceSettingsState? inferenceSettings,
  }) async {
    final cid = conversationId ?? activeConversationId ?? ensureConversation();
    final baseMessageId = const Uuid().v4();
    bool anySuccess =
        false; // track at least one provider succeeded to suppress global error

    // Enforce 5MB per message cap across all pending attachments
    if (_pendingAttachments.isNotEmpty) {
      final ok = _enforceMessageSizeCap(
          _pendingAttachments.map((f) => f.size).toList());
      if (!ok) {
        emit(ChatError(error: 'Attachments exceed 5 MB limit per message'));
        return;
      }
    }

    // Determine target providers
    List<String> targets;
    if (!multiProvider || singleProviderOverride != null) {
      final sp =
          singleProviderOverride ?? activeProvider ?? supportedProviders.first;
      targets = [sp];
    } else {
      targets = supportedProviders
          .where((p) => !chatHiddenProviders.contains(p))
          .where((p) =>
              (providerEnabled[p] ?? false) && (providerConnected[p] ?? false))
          .toList();
    }
    if (targets.isEmpty) {
      _logger.w('No providers selected or enabled.');
      emit(ChatError(error: 'No providers enabled / connected'));
      return;
    }

    final errors = <String, String>{};

    for (final providerKey in targets) {
      try {
        // Credentials
        String? credential;
        if (providerKey == 'lmstudio') {
          credential = await _secureStorage.read(key: 'lmstudio_endpoint');
          // For LM Studio, allow fallback when endpoint not provided. Adapter decides defaults (host/route).
          if (credential == null || credential.isEmpty) {
            await _logger.event(
              'provider.credential',
              payload: {
                'provider': providerKey,
                'status': 'missing',
                'action': 'fallback',
                'message':
                    'No lmstudio_endpoint set; will use adapter defaults (e.g., 10.0.2.2 or 127.0.0.1)',
              },
              category: 'provider',
              className: 'ChatCubit',
              methodName: 'sendMessage',
            );
            credential = '';
          }
        } else {
          credential =
              await _secureStorage.read(key: '${providerKey}_api_key') ??
                  await _secureStorage.read(key: '${providerKey}_key');
          if (credential == null || credential.isEmpty) {
            errors[providerKey] = 'Missing credentials';
            continue;
          }
        }

        // Insert base message row (DB schema limited; store metadata JSON only)
        final messageId = '$baseMessageId::$providerKey';
        // Resolve base requested model (user-specified) and prepare routing candidates
        final providerId = _toProviderId(providerKey);
        // Resolve requested model canonically but also consider the UI's activeModel as highest priority
        final baseRequested =
            _modelResolver.resolve(providerId, request.requestModel);
        final priorityList =
            providerModelPriority[providerKey] ?? const <String>[];
        // Preserve order deterministically: baseRequested -> priority list -> selected models
        final candidates = <String>[];
        final seenCand = <String>{};
        void addIf(String? m) {
          if (m == null || m.isEmpty) return;
          if (m.startsWith('models/')) m = m.replaceFirst('models/', '');
          if (seenCand.add(m)) candidates.add(m);
        }

        // Highest: the explicit active model if set for this provider
        if (activeProvider == providerKey && activeModel != null) {
          addIf(activeModel);
        }
        addIf(baseRequested);
        for (final m in priorityList) {
          addIf(m);
        }
        for (final m
            in (selectedProviderLLMs[providerKey] ?? const <String>[])) {
          addIf(m);
        }
        if (candidates.isEmpty) {
          candidates.add(baseRequested ?? '');
        }
        _logger.event('router.selection.start',
            payload: {
              'provider': providerKey,
              'activeModel': activeModel,
              'requestedModel': request.requestModel,
              'resolvedBase': baseRequested,
              'candidates': candidates
            },
            category: 'router',
            className: 'ChatCubit',
            methodName: 'sendMessage');
        String? effectiveModel;
        Object? lastError;
        // Attempt each candidate until one succeeds in request build stage (network errors handled later)
        for (final cand in candidates.where((e) => e.isNotEmpty)) {
          try {
            effectiveModel = cand;
            _logger.event('router.selection.attempt',
                payload: {'provider': providerKey, 'model': cand},
                category: 'router',
                className: 'ChatCubit',
                methodName: 'sendMessage');
            break; // For now we just pick first; fallback happens if send fails later.
          } catch (e) {
            lastError = e;
            continue;
          }
        }
        if (effectiveModel == null || effectiveModel.isEmpty) {
          _logger.event('router.selection.failed',
              payload: {
                'provider': providerKey,
                'error': lastError?.toString()
              },
              category: 'router',
              className: 'ChatCubit',
              methodName: 'sendMessage');
          errors[providerKey] = 'No model candidates';
          continue;
        }
        _logger.event('router.selection.success',
            payload: {'provider': providerKey, 'model': effectiveModel},
            category: 'router',
            className: 'ChatCubit',
            methodName: 'sendMessage');

        final message = Message(
          messageId: messageId,
          conversationId: cid,
          userId: 'user',
          requestId: request.requestId,
          responseId: null,
          outputId: null,
          timestamp: DateTime.now(),
          vote: false,
          hasImage: false,
          imgUrl: null,
          metadata: {
            'provider': providerKey,
            'user_content': request.requestUserContent,
            'model': effectiveModel,
          },
          hasEmbedding: false,
          hasDocument: false,
          docUrl: null,
        );
        // Custom DB map to avoid unknown columns
        final msgDbMap = {
          'message_id': message.messageId,
          'conversation_id': message.conversationId,
          'img': null,
          'timestamp': message.timestamp.toIso8601String(),
          'vote': message.vote ? 1 : 0,
          'metadata': jsonEncode(message.metadata),
          'embedding': null,
          'doc': null,
        };
        final tPersistMsgStart = DateTime.now();
        await _dataRepo.insertMessageRaw(msgDbMap);
        final tPersistMsgDur =
            DateTime.now().difference(tPersistMsgStart).inMilliseconds;
        await _logger.event(
          'db.persist',
          payload: {'table': 'messages'},
          category: 'db',
          className: 'ChatCubit',
          methodName: 'sendMessage',
          conversationId: cid,
          messageId: messageId,
          requestId: request.requestId,
          providerId: providerKey,
          model: effectiveModel,
          phase: 'persist-message',
          status: 'ok',
          durationMs: tPersistMsgDur,
        );

        // Track evolving metadata locally so subsequent updates don't clobber earlier fields (e.g., attachments)
        Map<String, dynamic> currentMeta = {...?message.metadata};
        // Preflight billing flag so UI can warn before network call
        try {
          final desc = _lookupDescriptor(providerKey, effectiveModel);
          if (desc != null && desc.requiresBilling) {
            final withBilling = {...currentMeta, 'billing_required': true};
            await _dataRepo.updateMessageMetadata(messageId, withBilling);
            currentMeta = withBilling;
            await _logger.event('billing.flag',
                payload: {'provider': providerKey, 'model': effectiveModel},
                category: 'billing',
                className: 'ChatCubit',
                methodName: 'sendMessage',
                conversationId: cid,
                messageId: messageId,
                providerId: providerKey,
                model: effectiveModel);
          }
        } catch (_) {}

        // Persist any pending attachments for this message
        List<Attachment> atts = const [];
        if (_pendingAttachments.isNotEmpty) {
          try {
            atts = await persistAttachmentsForMessage(
              messageId: messageId,
              conversationId: cid,
              userId: 'user',
              files: List<PlatformFile>.from(_pendingAttachments),
            );
            // Store lightweight descriptors into metadata
            final metaWithAtts = {
              ...currentMeta,
              'attachments': atts
                  .map((a) => {
                        'id': a.id,
                        'type': a.type,
                        'mime': a.mimeType,
                        'path': a.filePath,
                        'size': a.sizeBytes,
                      })
                  .toList(),
            };
            await _dataRepo.updateMessageMetadata(messageId, metaWithAtts);
            currentMeta = metaWithAtts;
            await _logger.event(
              'message.metadata.attachments',
              payload: {
                'count': atts.length,
                'ids': atts.map((a) => a.id).toList(),
              },
              category: 'db',
              className: 'ChatCubit',
              methodName: 'sendMessage',
              conversationId: cid,
              messageId: messageId,
              providerId: providerKey,
            );
          } catch (e) {
            _logger.w('Persisting attachments failed', error: e);
          }
        }

        // Lazily create conversation row if missing (first message just inserted)
        try {
          final existing = await _dataRepo.fetchConversationById(cid);
          if (existing == null) {
            // Determine storage mode to set localOnly flag
            bool localOnly = true;
            try {
              final prefs = SharedPref();
              final mode = await prefs.getString('storage_mode');
              localOnly = (mode ?? 'local') == 'local';
            } catch (_) {}
            final conv = Conversation(
              conversationId: cid,
              userId: 'user',
              visitorId: null,
              title: 'Conversation',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              localOnly: localOnly,
            );
            await _dataRepo.insertConversation(conv);
          }
        } catch (e) {
          _logger.w('Lazy conversation create failed', error: e);
        }

        // Title generation will be done after assistant output is finalized using the LLM itself.

        // Build request via MessageRequestBuilder considering adapter capabilities
        // Compose chat history for this provider from cachedMessages (prior turns only)
        List<Map<String, String>> historyFor(String p, String convId) {
          final hist = <Map<String, String>>[];
          final msgs = cachedMessages
              .where((m) => m.conversationId == convId)
              .where((m) => (m.metadata?['provider'] as String?) == p)
              .toList()
            ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          for (final m in msgs) {
            final meta = m.metadata ?? const {};
            final user = (meta['user_content'] as String?)?.trim();
            final out = (meta['output_text'] as String?)?.trim();
            final outRole =
                (meta['output_role'] as String?)?.trim() ?? 'assistant';
            if (user != null && user.isNotEmpty) {
              hist.add({'role': 'user', 'content': user});
            }
            if (out != null && out.isNotEmpty) {
              hist.add({'role': outRole, 'content': out});
            }
          }
          // Limit history depth to keep prompt/context reasonable (last 20 messages)
          const maxMsgs = 20;
          if (hist.length > maxMsgs) {
            return hist.sublist(hist.length - maxMsgs);
          }
          return hist;
        }

        final chatHistory = historyFor(providerKey, cid);
        // Determine base capabilities advertised by adapter
        final provId = _toProviderId(providerKey);
        var capabilities = _capabilitiesFor(provId);
        // Per-model provider metadata: constrain capabilities and bounds
        ParamBounds? bounds;
        if (providerKey == 'openrouter' && (baseRequested ?? '').isNotEmpty) {
          try {
            final key = await getApiKey('openrouter') ?? '';
            final raw = await _dataRepo.fetchOpenRouterModelsRaw(key);
            final m = raw.firstWhere(
              (e) => (e['id'] ?? '').toString() == effectiveModel,
              orElse: () => const {},
            );
            if (m.isNotEmpty) {
              // supported_parameters gate
              final sp = (m['supported_parameters'] as List?)
                      ?.map((e) => e.toString())
                      .toSet() ??
                  const <String>{};
              Capability? capFor(String p) {
                switch (p) {
                  case 'temperature':
                    return Capability.temperature;
                  case 'top_p':
                    return Capability.topP;
                  case 'top_k':
                    return Capability.topK;
                  case 'min_p':
                    return Capability.minP;
                  case 'repeat_penalty':
                    return Capability.repetitionPenalty;
                  default:
                    return null;
                }
              }

              // Retain only caps present in supported_parameters when applicable
              if (sp.isNotEmpty) {
                final mapped = sp.map(capFor).whereType<Capability>().toSet();
                capabilities = capabilities.intersection(mapped)
                  ..addAll({
                    Capability.systemPrompt,
                    Capability.streaming,
                    Capability.structuredOutput
                  });
              }
              // crude per-model bounds via provider hints if present
              // OpenRouter does not standardize ranges here; leave defaults unless we later add mapping table per vendor
              bounds = const ParamBounds();
            }
          } catch (_) {}
        }
        if (providerKey == 'gemini' && (baseRequested ?? '').isNotEmpty) {
          try {
            final key =
                await getApiKey('gemini') ?? (await getApiKey('google')) ?? '';
            final raw = await _dataRepo.fetchGoogleGeminiModelsRaw(key);
            Map<String, dynamic> m = const {};
            // Gemini "name" field usually matches ids we store (e.g., models/gemini-1.5-pro)
            for (final e in raw) {
              final name = (e['name'] ?? '').toString();
              if (name == effectiveModel) {
                m = e;
                break;
              }
            }
            if (m.isNotEmpty) {
              // Determine which params are supported based on presence of fields
              final supportsTemp = m.containsKey('temperature') ||
                  m.containsKey('maxTemperature');
              final supportsTopP = m.containsKey('topP');
              final supportsTopK = m.containsKey('topK');
              final baseKeep = <Capability>{
                Capability.systemPrompt,
                Capability.streaming,
                Capability.structuredOutput
              };
              final allowed = <Capability>{}
                ..addAll(baseKeep)
                ..addAll({
                  if (supportsTemp) Capability.temperature,
                  if (supportsTopP) Capability.topP,
                  if (supportsTopK) Capability.topK,
                });
              capabilities = capabilities.intersection(allowed).union(baseKeep);
              // Bounds
              final maxT = (m['maxTemperature'] is num)
                  ? (m['maxTemperature'] as num).toDouble()
                  : null;
              final kMax =
                  (m['topK'] is num) ? (m['topK'] as num).toInt() : null;
              bounds = ParamBounds(temperatureMax: maxT, topKMax: kMax);
            }
          } catch (_) {}
        }
        // Prepare attachment descriptors for request (images only for now),
        // but only when the chosen model likely supports vision.
        final supportsVision =
            _supportsVision(providerKey, (baseRequested ?? activeModel));
        final reqAtts = <Map<String, dynamic>>[];
        if (supportsVision) {
          for (final a in atts) {
            if (a.type == 'image') {
              final mime =
                  a.mimeType ?? _guessMimeFromExt(a.filePath.split('.').last);
              try {
                final bytes = await File(a.filePath).readAsBytes();
                final b64 = base64Encode(bytes);
                final dataUrl = 'data:$mime;base64,$b64';
                reqAtts.add({
                  'type': 'image',
                  'mime': mime,
                  'path': a.filePath,
                  'size': a.sizeBytes,
                  'b64': b64,
                  'dataUrl': dataUrl,
                });
              } catch (e) {
                _logger.w('Failed to read attachment for request', error: e);
              }
            }
          }
        } else if (atts.isNotEmpty) {
          await _logger.event(
            'request.attachments.skipped',
            payload: {
              'reason': 'model-no-vision',
              'provider': providerKey,
              'model': effectiveModel,
              'count': atts.length,
            },
            category: 'chat',
            className: 'ChatCubit',
            methodName: 'sendMessage',
            conversationId: cid,
            messageId: messageId,
            providerId: providerKey,
          );
        }
        if (reqAtts.isNotEmpty) {
          await _logger.event(
            'request.attachments.prepared',
            payload: {
              'count': reqAtts.length,
              'types': reqAtts.map((a) => a['type']).toList(),
              'mimes': reqAtts.map((a) => a['mime']).toList(),
              'totalBytes':
                  reqAtts.fold<int>(0, (s, a) => s + (a['size'] as int? ?? 0)),
            },
            category: 'chat',
            className: 'ChatCubit',
            methodName: 'sendMessage',
            conversationId: cid,
            messageId: messageId,
            providerId: providerKey,
          );
        }

        final built = const MessageRequestBuilder().build(
          requestId: request.requestId,
          model: effectiveModel,
          userContent: request.requestUserContent ?? '',
          chatMessages: chatHistory,
          attachments: reqAtts.isEmpty ? null : reqAtts,
          state:
              inferenceSettings, // wired from caller; falls back to defaults if null
          capabilities: capabilities,
          stream: request.requestStream ?? false,
          paramLimits: bounds,
        );

        // Persist message_request row
        final tPersistReqStart = DateTime.now();
        await _dataRepo.insertMessageRequest({
          'message_id': messageId,
          'request_model': built.requestModel,
          'request_messages_role': built.requestUserRole ?? 'user',
          'request_messages_content': built.requestUserContent,
          'request_temperature': built.requestTemperature,
          'request_top_p': built.requestTopP,
          'request_n': built.requestN,
          'request_stream': (built.requestStream ?? false) ? 1 : 0,
          'request_stop': built.requestStop,
          'request_max_tokens': built.requestMaxTokens,
          'top_k': built.requestTopK,
          'repeat_penalty': built.repeatPenalty,
          'min_p': built.requestMinP,
        });
        final tPersistReqDur =
            DateTime.now().difference(tPersistReqStart).inMilliseconds;
        await _logger.event(
          'db.persist',
          payload: {'table': 'message_requests'},
          category: 'db',
          className: 'ChatCubit',
          methodName: 'sendMessage',
          conversationId: cid,
          messageId: messageId,
          requestId: request.requestId,
          providerId: providerKey,
          model: effectiveModel,
          phase: 'persist-request',
          status: 'ok',
          durationMs: tPersistReqDur,
        );

        // Sync after request persisted (user message)
        try {
          // Skip sync if conversation is localOnly
          final convMeta = await _dataRepo.fetchConversationById(cid);
          if (convMeta?.localOnly == true) {
            await _logger.i('Per-turn sync skipped (localOnly conversation)',
                ctx: {'conv': cid, 'message': messageId});
            // No server call, continue flow
          } else {
            // Build UnifiedSyncView.post-compatible body
            String? tempId;
            try {
              tempId = await _secureStorage.read(key: 'temp_id');
            } catch (_) {}
            final payloadReq = await _dataRepo.buildSingleMessageUnifiedBody(
              conversationId: cid,
              messageId: messageId,
              tempId: tempId,
            );
            // Try unified POST first
            try {
              final accessTok = await _secureStorage.read(key: 'access_token');
              await _dataRepo.unifiedPostMe(
                  body: payloadReq, accessToken: accessTok);
            } catch (_) {
              // Fallback to legacy sync-conversations route
              String? userId;
              String? anonId;
              try {
                final access = await _secureStorage.read(key: 'access_token');
                if (access != null && access.isNotEmpty) {
                  final prof = await _dataRepo.getProfile(access);
                  userId = (prof['user_id'] ?? prof['id'] ?? prof['uuid'] ?? '')
                      .toString();
                  if (userId.isEmpty) userId = null;
                }
              } catch (_) {}
              if (userId == null) {
                try {
                  final temp = await _secureStorage.read(key: 'temp_id');
                  if (temp != null && temp.isNotEmpty) anonId = temp;
                } catch (_) {}
              }
              await _dataRepo.pushConversations(
                conversations: (payloadReq['conversations'] as List)
                    .cast<Map<String, dynamic>>(),
                anonId: userId == null ? anonId : null,
                userId: userId,
              );
            }
            await _logger.event('sync.post.request.success',
                payload: {
                  'conv': cid,
                  'message': messageId,
                  'route': 'unified-or-fallback',
                },
                category: 'sync',
                className: 'ChatCubit',
                methodName: 'sendMessage');
          }
        } catch (e) {
          // Network/server down: enqueue and schedule retry
          await _dataRepo.enqueuePendingMessageSync(
              conversationId: cid, messageId: messageId);
          _dataRepo.schedulePendingSyncFlush();
          await _logger.w('Server unavailable; will retry in ~1h',
              error: e, ctx: {'conv': cid, 'message': messageId});
          await _logger.event('sync.post.request.error',
              payload: {
                'conv': cid,
                'message': messageId,
                'error': e.toString(),
              },
              category: 'sync',
              className: 'ChatCubit',
              methodName: 'sendMessage',
              status: 'error');
        }

        // If streaming requested and supported, stream; else send once.
        // Force disable streaming for image-generation models because our streaming parser currently only accumulates text
        // and would drop inline image data.
        final isImageGenModel =
            effectiveModel.toLowerCase().contains('image-generation');
        final supportsStreaming = !isImageGenModel &&
            capabilities.contains(Capability.streaming) &&
            (built.requestStream == true);
        if (isImageGenModel && (built.requestStream == true)) {
          await _logger.event('image.stream.disabled', payload: {
            'reason': 'force_non_stream_for_image_generation',
            'model': effectiveModel
          });
        }
        MessageResponse? finalResp;
        MessageOutput? finalOut;
        if (supportsStreaming) {
          String acc = '';
          bool success = false;
          for (final modelCandidate in candidates) {
            try {
              effectiveModel = modelCandidate;
              final streamingMeta = {
                ...currentMeta,
                'streaming': true,
                'model': modelCandidate,
                'streaming_text': '',
              };
              await _dataRepo.updateMessageMetadata(messageId, streamingMeta);
              currentMeta = streamingMeta;
              await loadConversation(cid, emitLoaded: true);
              acc = '';
              await for (final ev in _repo.sendStream(
                providerId: providerId,
                ctx: GenerationContext(
                  providerId: providerId,
                  request: const MessageRequestBuilder().build(
                    requestId: request.requestId,
                    model: modelCandidate,
                    userContent: request.requestUserContent ?? '',
                    chatMessages: chatHistory,
                    attachments: reqAtts.isEmpty ? null : reqAtts,
                    state: inferenceSettings,
                    capabilities: capabilities,
                    stream: true,
                    paramLimits: bounds,
                  ),
                  requestId: request.requestId,
                  model: modelCandidate,
                  conversationId: cid,
                  credential: credential,
                ),
              )) {
                if (ev.deltaText != null && ev.deltaText!.isNotEmpty) {
                  acc += ev.deltaText!;
                  final stepMeta = {
                    ...currentMeta,
                    'streaming_text': acc,
                  };
                  await _dataRepo.updateMessageMetadata(messageId, stepMeta);
                  currentMeta = stepMeta;
                  await loadConversation(cid, emitLoaded: true);
                }
                if (ev.finishReason != null) {
                  success = true;
                  break;
                }
              }
              // If provider never supplies finishReason but text arrived, treat as success.
              if (!success && acc.isNotEmpty) {
                success = true;
              }
              if (success) break;
            } catch (e) {
              _logger.event('router.model.fail',
                  payload: {
                    'provider': providerKey,
                    'model': modelCandidate,
                    'error': e.toString(),
                    'phase': 'stream'
                  },
                  category: 'router',
                  className: 'ChatCubit',
                  methodName: 'sendMessage');
              continue;
            }
          }
          if (!success) {
            throw Exception('All streaming candidates failed');
          }
          // Clear streaming flags in metadata before building final response objects
          if (currentMeta['streaming'] == true) {
            final cleared = {
              ...currentMeta,
              'streaming': false,
              'streaming_text': null,
              'output_text': acc,
              'output_role': 'assistant',
            };
            await _dataRepo.updateMessageMetadata(messageId, cleared);
            currentMeta = cleared;
          }
          finalResp = MessageResponse(
            responseId: '',
            modelname: effectiveModel,
            createdAt: DateTime.now(),
            status: 'completed',
            error: null,
          );
          finalOut = MessageOutput(
            outputType: 'text',
            outputId: '',
            outputStatus: 'completed',
            outputRole: 'assistant',
            outputContentType: 'text',
            outputContentText: acc,
          );
        } else {
          // Delegate send to repository/adapters (non-streaming)
          ProviderParsed? parsed; // from ChatRepository / ProviderAdapter
          Object? lastSendError;
          // Try fallback route chain upon failures
          for (final modelCandidate in candidates) {
            try {
              final candidateBuilt = const MessageRequestBuilder().build(
                requestId: request.requestId,
                model: modelCandidate,
                userContent: request.requestUserContent ?? '',
                chatMessages: chatHistory,
                attachments: reqAtts.isEmpty ? null : reqAtts,
                state: inferenceSettings,
                capabilities: capabilities,
                stream: request.requestStream ?? false,
                paramLimits: bounds,
              );
              _logger.event('router.model.attempt',
                  payload: {'provider': providerKey, 'model': modelCandidate},
                  category: 'router',
                  className: 'ChatCubit',
                  methodName: 'sendMessage');
              parsed = await _repo.sendOnce(
                providerId: providerId,
                ctx: GenerationContext(
                  providerId: providerId,
                  request: candidateBuilt,
                  requestId: request.requestId,
                  model: modelCandidate,
                  conversationId: cid,
                  credential: credential,
                ),
              );
              effectiveModel = modelCandidate; // record final used
              _logger.event('router.model.success',
                  payload: {'provider': providerKey, 'model': modelCandidate},
                  category: 'router',
                  className: 'ChatCubit',
                  methodName: 'sendMessage');
              break;
            } catch (e) {
              lastSendError = e;
              _logger.event('router.model.fail',
                  payload: {
                    'provider': providerKey,
                    'model': modelCandidate,
                    'error': e.toString()
                  },
                  category: 'router',
                  className: 'ChatCubit',
                  methodName: 'sendMessage');
              continue;
            }
          }
          if (effectiveModel == null || parsed == null) {
            throw Exception('All routing candidates failed: $lastSendError');
          }
          // At this point 'parsed' holds the final result (guaranteed by loop break)
          finalResp = parsed.response;
          finalOut = parsed.output;
        }

        // Persist response/output rows with message_id (FK) and schema-friendly maps
        final responseMap = {
          ...finalResp.toJson(),
          'message_id': messageId,
        };
        final responseRowId = finalResp.responseId.isNotEmpty
            ? finalResp.responseId
            : (await _dataRepo.insertMessageResponse(responseMap)).toString();
        final outputMap = {
          ...finalOut.toJson(),
          'message_id': messageId,
        };
        final outputRowId =
            (finalOut.outputId != null && finalOut.outputId!.isNotEmpty)
                ? finalOut.outputId!
                : (await _dataRepo.insertMessageOutput(outputMap)).toString();

        // Update message metadata with output
        final updatedMeta = {
          ...currentMeta,
          if (supportsStreaming) 'streaming': false,
          if (supportsStreaming) 'streaming_text': null,
          'output_text': finalOut.outputContentText,
          'output_role': finalOut.outputRole,
          'response_id_link': responseRowId,
          'output_id_link': outputRowId,
          if (finalOut.outputContentAnnotations != null)
            'output_annotations': finalOut.outputContentAnnotations,
        };
        final tUpdateMsgStart = DateTime.now();
        await _dataRepo.updateMessageMetadata(messageId, updatedMeta);
        final tUpdateMsgDur =
            DateTime.now().difference(tUpdateMsgStart).inMilliseconds;
        await _logger.event(
          'db.update',
          payload: {
            'table': 'messages',
            'columns': ['metadata']
          },
          category: 'db',
          className: 'ChatCubit',
          methodName: 'sendMessage',
          conversationId: cid,
          messageId: messageId,
          requestId: request.requestId,
          responseId: responseRowId,
          outputId: outputRowId,
          providerId: providerKey,
          model: effectiveModel,
          phase: 'persist-update',
          status: 'ok',
          durationMs: tUpdateMsgDur,
        );

        // Post-sync to server: unified sync single message to cloud
        try {
          // Skip sync if conversation is localOnly
          final convMeta = await _dataRepo.fetchConversationById(cid);
          if (convMeta?.localOnly == true) {
            await _logger.i('Per-turn sync skipped (localOnly conversation)',
                ctx: {'conv': cid, 'message': messageId});
          } else {
            // Skip if privacy mode is local-only (DataRepository gating used by pushConversations)
            String? tempId;
            try {
              tempId = await _secureStorage.read(key: 'temp_id');
            } catch (_) {}
            final payload = await _dataRepo.buildSingleMessageUnifiedBody(
              conversationId: cid,
              messageId: messageId,
              tempId: tempId,
            );
            try {
              final accessTok = await _secureStorage.read(key: 'access_token');
              await _dataRepo.unifiedPostMe(
                  body: payload, accessToken: accessTok);
            } catch (_) {
              // Fallback to legacy sync-conversations
              String? userId;
              String? anonId;
              try {
                final access = await _secureStorage.read(key: 'access_token');
                if (access != null && access.isNotEmpty) {
                  final prof = await _dataRepo.getProfile(access);
                  userId = (prof['user_id'] ?? prof['id'] ?? prof['uuid'] ?? '')
                      .toString();
                  if (userId.isEmpty) userId = null;
                }
              } catch (_) {}
              if (userId == null) {
                try {
                  final temp = await _secureStorage.read(key: 'temp_id');
                  if (temp != null && temp.isNotEmpty) anonId = temp;
                } catch (_) {}
              }
              await _dataRepo.pushConversations(
                conversations: (payload['conversations'] as List)
                    .cast<Map<String, dynamic>>(),
                anonId: userId == null ? anonId : null,
                userId: userId,
              );
            }
            await _logger.event('sync.post.success',
                payload: {
                  'conv': cid,
                  'message': messageId,
                  'route': 'unified-or-fallback',
                },
                category: 'sync',
                className: 'ChatCubit',
                methodName: 'sendMessage');
          }
        } catch (e) {
          // Network/server down: enqueue and schedule retry
          await _dataRepo.enqueuePendingMessageSync(
              conversationId: cid, messageId: messageId);
          _dataRepo.schedulePendingSyncFlush();
          await _logger.w('Server unavailable; will retry in ~1h',
              error: e, ctx: {'conv': cid, 'message': messageId});
          await _logger.event('sync.post.error',
              payload: {
                'conv': cid,
                'message': messageId,
                'error': e.toString(),
              },
              category: 'sync',
              className: 'ChatCubit',
              methodName: 'sendMessage',
              status: 'error');
        }

        // Persist any inline images embedded in annotations (e.g., Gemini responseModalities)
        if (finalOut.outputContentAnnotations != null &&
            finalOut.outputContentAnnotations!.contains('images')) {
          try {
            final decodedAnn = jsonDecode(finalOut.outputContentAnnotations!);
            if (decodedAnn is Map && decodedAnn['images'] is List) {
              for (final img in (decodedAnn['images'] as List)) {
                if (img is Map) {
                  final b64 = img['b64'];
                  final mime = img['mime']?.toString() ?? 'image/png';
                  if (b64 is String && b64.isNotEmpty) {
                    final bytes = base64Decode(b64);
                    final ext = mime.contains('png')
                        ? 'png'
                        : (mime.contains('jpeg') || mime.contains('jpg')
                            ? 'jpg'
                            : 'bin');
                    final attachment = await _persistGeneratedBytes(
                      bytes: bytes,
                      logicalName:
                          'inline_${DateTime.now().millisecondsSinceEpoch}.$ext',
                      type: 'image',
                      mime: mime,
                      meta: {
                        'provider': providerKey,
                        'model': effectiveModel,
                        'source': 'inline_response',
                      },
                    );
                    // Append to message metadata list
                    // Re-read current metadata (message fetch API missing; reuse updatedMeta reference)
                    final meta = updatedMeta;
                    final existing = (meta['generated_attachments'] as List?)
                            ?.whereType<Map>()
                            .toList() ??
                        [];
                    existing.add({
                      'path': attachment.filePath,
                      'mime': mime,
                      'size': attachment.sizeBytes
                    });
                    await _dataRepo.updateMessageMetadata(messageId, {
                      ...meta,
                      'generated_attachments': existing,
                    });
                  }
                }
              }
            }
          } catch (e) {
            _logger.event('inline.image.persist.fail',
                category: 'artifact',
                className: 'ChatCubit',
                methodName: 'sendMessage',
                status: 'error',
                payload: {'error': e.toString()});
          }
        }

        // Mark global success (used to decide whether to emit ChatError at end)
        anySuccess = true;

        // Title generation policy:
        // - Provisional title after first exchange (>= 2 messages) if current title is weak/default
        // - Improve/refine once there's more context (>= 6 messages), still only if title is weak
        try {
          final count = await _dataRepo.getMessageCount(cid);
          final existing = await _dataRepo.fetchConversationById(cid);
          final currentTitle = existing?.title?.trim() ?? '';
          final isWeak = _isWeakTitle(currentTitle);

          if (isWeak && count >= 2 && count < 6) {
            final title = await _generateTitleWithLlm(
              providerKey: providerKey,
              model: effectiveModel,
              credential: credential,
              conversationId: cid,
              minMessages: 2,
              maxHistory: 12,
            );
            if (title != null && !_isWeakTitle(title)) {
              await _dataRepo.updateConversationTitle(cid, title);
              await _logger.event('conversation.title.set',
                  payload: {'title': title, 'phase': 'provisional'},
                  category: 'chat',
                  className: 'ChatCubit',
                  methodName: 'sendMessage',
                  conversationId: cid,
                  providerId: providerKey,
                  model: effectiveModel);
            }
          } else if (isWeak && count >= 6) {
            final title = await _generateTitleWithLlm(
              providerKey: providerKey,
              model: effectiveModel,
              credential: credential,
              conversationId: cid,
              minMessages: 6,
              maxHistory: 20,
            );
            if (title != null && !_isWeakTitle(title)) {
              await _dataRepo.updateConversationTitle(cid, title);
              await _logger.event('conversation.title.set',
                  payload: {'title': title, 'phase': 'refined'},
                  category: 'chat',
                  className: 'ChatCubit',
                  methodName: 'sendMessage',
                  conversationId: cid,
                  providerId: providerKey,
                  model: effectiveModel);
            }
          }
        } catch (e) {
          _logger.w('LLM title generation failed', error: e);
        }
      } catch (e) {
        _logger.e('Provider $providerKey send failure', error: e);
        errors[providerKey] = e.toString();
        // Classify error for user-facing guidance (quota, billing, rate limit, etc.)
        try {
          final advice = _deriveUserFacingAdvice(e.toString());
          if (advice != null) {
            // Update metadata with advisory (best-effort without re-fetching model id variable scope)
            await _dataRepo
                .updateMessageMetadata('$baseMessageId::$providerKey', {
              'provider': providerKey,
              'error_kind': advice['kind'],
              'error_text': advice['message'],
            });
            await _logger.event('billing.advice',
                payload: {
                  'provider': providerKey,
                  'kind': advice['kind'],
                  'message': advice['message']
                },
                category: 'billing',
                className: 'ChatCubit',
                methodName: 'sendMessage',
                conversationId: cid,
                messageId: '$baseMessageId::$providerKey',
                providerId: providerKey,
                status: 'error');
          }
        } catch (_) {}
        await _logger.event(
          'send.error',
          payload: {'error': e.toString()},
          category: 'llm',
          className: 'ChatCubit',
          methodName: 'sendMessage',
          conversationId: cid,
          messageId: '$baseMessageId::$providerKey',
          requestId: request.requestId,
          providerId: providerKey,
          model: _modelResolver.resolve(
              _toProviderId(providerKey), request.requestModel),
          phase: 'error',
          status: 'error',
        );
      }
    }

    await loadConversation(cid, emitLoaded: true);
    // Clear pending attachments after send completes (regardless of provider success)
    _pendingAttachments.clear();
    // Emit error only if *all* providers failed.
    if (!anySuccess && errors.isNotEmpty) {
      emit(ChatError(error: 'All providers failed: ${errors.keys.join(', ')}'));
    }
  }

  // Obtain capability set for a provider; adapters advertise capabilities.
  Set<Capability> _capabilitiesFor(ProviderId id) {
    switch (id) {
      case ProviderId.openai:
        return {
          Capability.temperature,
          Capability.topP,
          Capability.systemPrompt,
          Capability.structuredOutput,
          Capability.streaming,
          Capability.vision
        };
      case ProviderId.openrouter:
        return {
          Capability.temperature,
          Capability.topP,
          Capability.repetitionPenalty,
          Capability.systemPrompt,
          Capability.structuredOutput,
          Capability.streaming,
          Capability.vision
        };
      case ProviderId.gemini:
        return {
          Capability.temperature,
          Capability.topP,
          Capability.systemPrompt,
          Capability.structuredOutput,
          Capability.streaming,
          Capability.vision
        };
      case ProviderId.lmstudio:
        return {
          Capability.temperature,
          Capability.topP,
          Capability.topK,
          Capability.minP,
          Capability.repetitionPenalty,
          Capability.systemPrompt
        };
      case ProviderId.huggingface:
        // Hugging Face Inference API (current endpoint used) does not support streaming tokens in our unified format.
        // Omit Capability.streaming so we always use non-stream path until SSE/WS support added.
        return {
          Capability.temperature,
          Capability.topP,
          Capability.systemPrompt
        };
    }
  }

  ProviderId _toProviderId(String key) {
    switch (key) {
      case 'openai':
        return ProviderId.openai;
      case 'openrouter':
        return ProviderId.openrouter;
      case 'gemini':
        return ProviderId.gemini;
      case 'lmstudio':
        return ProviderId.lmstudio;
      case 'huggingface':
        return ProviderId.huggingface;
      default:
        return ProviderId.openai;
    }
  }

  // Heuristic vision support detector until full ModelDescriptor wiring:
  // - OpenAI: models containing "4o", "gpt-4-vision", or "omni" often support images.
  // - OpenRouter: many upstream models vary; use presence of "vision", "vl", or "multimodal".
  // - Gemini: generateContent generally supports text+images; ids starting with "gemini-" are multimodal.
  bool _supportsVision(String providerKey, String? modelId) {
    final id = (modelId ?? '').toLowerCase();
    if (id.isEmpty) return false;
    switch (providerKey) {
      case 'openai':
        return id.contains('4o') ||
            id.contains('omni') ||
            id.contains('vision');
      case 'openrouter':
        return id.contains('vision') ||
            id.contains('-vl') ||
            id.contains('multimodal') ||
            id.contains('gpt-4o');
      case 'gemini':
        return id.startsWith('gemini-') || id.contains('generate');
      case 'lmstudio':
        // Most local instruct models are text-only
        return false;
      default:
        return false;
    }
  }

  // Syncs all conversations/messages to backend
  // ignore: unused_element
  Future<void> syncConversations({String? anonId, String? userId}) async {
    try {
      final conversations = await _dataRepo.fetchConversations();
      // Hybrid privacy: in local mode skip entirely (DataRepository already gates); in mixed filter out localOnly
      try {
        final mode = await SharedPref().getString('storage_mode');
        if ((mode ?? 'local') == 'mixed') {
          conversations.removeWhere((c) => c.localOnly == true);
        } else {
          // local-only mode: abort early
          _logger.i('Global storage_mode=local; aborting sync (0 sent)');
          return;
        }
      } catch (_) {}
      final List<Map<String, dynamic>> conversationsPayload = [];
      for (final conv in conversations) {
        final messages = await _dataRepo.fetchMessages(conv.conversationId);
        final messagesPayload = messages.map((msg) {
          final msgMap = msg.toJson();
          // Only include IDs, not full objects
          // msgMap['requestId'], msgMap['responseId'], msgMap['outputId'] are already present
          return msgMap;
        }).toList();
        final convMap = conv.toJson();
        convMap['messages'] = messagesPayload;
        conversationsPayload.add(convMap);
      }
      _logger.i(
          'Syncing ${conversations.length} conversations to backend (filtered privacy)');
      // Use anonId or userId as needed
      if (anonId != null) {
        await _dataRepo.pushConversations(
            conversations: conversationsPayload, anonId: anonId);
      } else if (userId != null) {
        await _dataRepo.pushConversations(
            conversations: conversationsPayload, userId: userId);
      } else {
        await _dataRepo.pushConversations(conversations: conversationsPayload);
      }
      _logger.i('Sync successful');
    } catch (e) {
      _logger.e('Error syncing conversations', error: e);
    }
  }

  bool _isWeakTitle(String? t) {
    if (t == null) return true;
    final s = t.trim();
    if (s.isEmpty) return true;
    // Reject generic/placeholder or clearly unhelpful outputs
    const bad = {
      'conversation',
      'no response',
      'untitled',
      'chat',
      'title',
    };
    if (bad.contains(s.toLowerCase())) return true;
    // If it's only 1-2 words of common stop-words, consider weak
    final words = s.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length <= 2) {
      const stop = {'hello', 'hi', 'assist', 'help'};
      if (words.every((w) => stop.contains(w.toLowerCase()))) return true;
    }
    return false;
  }

  // Loads messages for a conversation and optionally emits ChatLoaded
  Future<void> loadConversation(String conversationId,
      {bool emitLoaded = true}) async {
    try {
      final msgs = await _dataRepo.fetchMessages(conversationId);
      cachedMessages = msgs..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      // refresh conversations list (simple full fetch for now)
      cachedConversations = await _dataRepo.fetchConversations();
      // update updated_at of active conversation if messages added
      if (cachedMessages.isNotEmpty) {
        final index = cachedConversations
            .indexWhere((c) => c.conversationId == conversationId);
        if (index != -1) {
          final old = cachedConversations[index];
          cachedConversations[index] = Conversation(
            conversationId: old.conversationId,
            userId: old.userId,
            visitorId: old.visitorId,
            title: old.title,
            createdAt: old.createdAt,
            updatedAt: DateTime.now(),
            localOnly: old.localOnly,
          );
        }
      }
      // (Conversations list placeholder: could be enhanced to fetch all)
      if (emitLoaded) {
        emit(ChatLoaded(
            conversations: cachedConversations, messages: cachedMessages));
      }
    } catch (e) {
      _logger.e('loadConversation error', error: e);
      if (emitLoaded) emit(ChatError(error: 'Failed to load conversation'));
    }
  }

  // Ask the chosen LLM to produce a short title for the conversation using history.
  // Returns a one-line, <= 60 chars title without quotes or punctuation noise.
  Future<String?> _generateTitleWithLlm({
    required String providerKey,
    required String? model,
    required String credential,
    required String conversationId,
    int minMessages = 6,
    int maxHistory = 20,
  }) async {
    try {
      final providerId = _toProviderId(providerKey);
      final caps = _capabilitiesFor(providerId);
      // Build history from stored messages (role/content pairs)
      final msgs = await _dataRepo.fetchMessages(conversationId);
      if (msgs.length < minMessages) return null;
      msgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final history = <Map<String, String>>[];
      for (final m in msgs) {
        final meta = m.metadata ?? const {};
        final userT = (meta['user_content'] as String?)?.trim();
        final outT = (meta['output_text'] as String?)?.trim();
        final outRole = (meta['output_role'] as String?)?.trim() ?? 'assistant';
        if (userT != null && userT.isNotEmpty) {
          history.add({'role': 'user', 'content': userT});
        }
        if (outT != null && outT.isNotEmpty) {
          history.add({'role': outRole, 'content': outT});
        }
      }
      if (history.length > maxHistory) {
        // Keep the last maxHistory entries to summarize recent context
        history.removeRange(0, history.length - maxHistory);
      }
      // Instruction for title generation
      const prompt =
          'Based on the conversation so far, produce a concise, descriptive title (<= 60 chars). '
          'Return only the title, no quotes or extra punctuation.';
      // Build a request with a minimal inference settings that carries a system prompt.
      final built = const MessageRequestBuilder().build(
        requestId: const Uuid().v4(),
        model: model,
        userContent: prompt,
        chatMessages: history,
        state: const InferenceSettingsState(
          useSystemPrompt: true,
          systemPrompt:
              'You are a helpful assistant that writes short, descriptive conversation titles.',
          useTemperature: false,
          useTopP: false,
          useTopK: false,
          useMinP: false,
          useRepeatPenalty: false,
          useStructuredOutput: false,
        ),
        capabilities: caps,
        stream: false,
      );
      final parsed = await _repo.sendOnce(
        providerId: providerId,
        ctx: GenerationContext(
          providerId: providerId,
          request: built,
          requestId: built.requestId,
          model: model,
          conversationId: conversationId,
          credential: credential,
        ),
        stream: false,
      );
      var title = (parsed.output.outputContentText ?? '').trim();
      if (title.isEmpty) return null;
      // Clean up quotes and enforce length
      if (title.startsWith('"') && title.endsWith('"') && title.length >= 2) {
        title = title.substring(1, title.length - 1);
      }
      // Remove leading/trailing punctuation and newlines
      title = title.replaceAll('\n', ' ').trim();
      if (title.length > 60) title = title.substring(0, 60).trimRight();
      return title;
    } catch (e) {
      _logger.w('Title generation call failed', error: e);
      return null;
    }
  }

/* 
  Future<_EncResult> _encryptFileAtPath(String srcPath) async {
    final algo = c.AesGcm.with256bits();
    final keyBytes = await _getOrCreateAttachmentKey();
    final secretKey = c.SecretKey(keyBytes);
    final nonce = algo.newNonce();
    final data = await File(srcPath).readAsBytes();
    final box = await algo.encrypt(data, secretKey: secretKey, nonce: nonce);
    final encPath = '$srcPath.enc';
    // File layout: [ciphertext][mac]
    final outBytes = <int>[]
      ..addAll(box.cipherText)
      ..addAll(box.mac.bytes);
    await File(encPath).writeAsBytes(outBytes, flush: true);
    return _EncResult(
      path: encPath,
      algo: 'aes-256-gcm',
      ivBase64: base64Encode(nonce),
      keyRef: 'k-v1',
    );
  }

  Future<List<int>> _getOrCreateAttachmentKey() async {
    const keyName = 'attachments_aes_key_base64_v1';
    String? b64 = await _secureStorage.read(key: keyName);
    if (b64 == null || b64.isEmpty) {
      // Generate a 32-byte key securely
      final algo = c.AesGcm.with256bits();
      final secretKey = await algo.newSecretKey();
      final bytes = await secretKey.extractBytes();
      b64 = base64Encode(bytes);
      await _secureStorage.write(key: keyName, value: b64);
    }
    return base64Decode(b64);
  }
 */
  // ---------- Pricing / Billing Helpers (for UI labels) ----------
  ModelDescriptor? _lookupDescriptor(String providerKey, String modelId) {
    try {
      final pid = _toProviderId(providerKey);
      final providerType = switch (pid) {
        ProviderId.openai => ProviderType.openai,
        ProviderId.openrouter => ProviderType.openrouter,
        ProviderId.gemini => ProviderType.gemini,
        ProviderId.lmstudio => ProviderType.lmstudio,
        ProviderId.huggingface => ProviderType.huggingface,
      };
      final cached = _modelRepo.getCached(providerType);
      if (cached.isEmpty) {
        return null; // Only synchronous lookups to avoid rebuild churn
      }
      final variants = <String>{
        modelId,
        if (modelId.startsWith('models/')) modelId.replaceFirst('models/', ''),
        if (!modelId.startsWith('models/')) 'models/$modelId',
      };
      for (final v in variants) {
        final d = cached.firstWhere(
          (m) => m.id == v,
          orElse: () => const ModelDescriptor(
              provider: ProviderType.openai,
              id: '__none__',
              displayName: '',
              categories: {}),
        );
        if (d.id != '__none__') return d;
      }
    } catch (_) {}
    return null;
  }

  String? pricingLabelFor(String providerKey, String modelId) {
    final d = _lookupDescriptor(providerKey, modelId);
    if (d == null) return null;
    final p = d.promptPrice;
    final c = d.completionPrice;
    final paid = d.requiresBilling || ((p ?? 0) > 0) || ((c ?? 0) > 0);
    if (!paid) return null;
    String fmtPerM(double per1k) {
      final perM = per1k * 1000.0; // convert per 1K -> per 1M
      String s;
      if (perM >= 100) {
        s = perM.toStringAsFixed(0);
      } else if (perM >= 10) {
        s = perM.toStringAsFixed(1);
      } else if (perM >= 1) {
        s = perM.toStringAsFixed(2);
      } else if (perM >= 0.1) {
        s = perM.toStringAsFixed(3);
      } else {
        s = perM.toStringAsFixed(4);
      }
      while (s.contains('.') && s.endsWith('0')) {
        s = s.substring(0, s.length - 1);
      }
      if (s.endsWith('.')) s = s.substring(0, s.length - 1);
      return s;
    }

    if (p != null && c != null) {
      return 'USD ${fmtPerM(p)}/${fmtPerM(c)} · 1M tok';
    }
    if (p != null) return 'USD ${fmtPerM(p)} · 1M tok (in)';
    if (c != null) return 'USD ${fmtPerM(c)} · 1M tok (out)';
    return 'USD · 1M tok';
  }

  // Classify raw error string to user-facing advice map.
  Map<String, String>? _deriveUserFacingAdvice(String err) {
    final lower = err.toLowerCase();
    if ((lower.contains('quota') && lower.contains('exceed')) ||
        lower.contains('quota exceeded') ||
        (lower.contains('quota') && lower.contains('billing'))) {
      return {
        'kind': 'quota',
        'message':
            'Quota exceeded or billing inactive. Enable billing or raise limits then retry.'
      };
    }
    if (lower.contains('billing required') ||
        lower.contains('enable billing')) {
      return {
        'kind': 'billing',
        'message':
            'Billing required for this model. Enable billing on provider dashboard.'
      };
    }
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('resource_exhausted')) {
      return {
        'kind': 'rate_limit',
        'message': 'Rate limit reached. Slow down or wait and retry.'
      };
    }
    if (lower.contains('permission denied') ||
        (lower.contains('permission') && lower.contains('denied'))) {
      return {
        'kind': 'permission',
        'message': 'Permission denied. Check API key scope and project access.'
      };
    }
    if (lower.contains('unauthorized') ||
        lower.contains('invalid authentication') ||
        lower.contains('incorrect api key')) {
      return {
        'kind': 'auth',
        'message':
            'Authentication failed. Verify API key and organization/project.'
      };
    }
    return null;
  }
}
/* 
class _EncResult {
  final String path;
  final String algo;
  final String ivBase64;
  final String keyRef;
  _EncResult({required this.path, required this.algo, required this.ivBase64, required this.keyRef});
} */
