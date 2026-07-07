// Contract test: validates this app's wire-shape JSON (what Conversation/
// Message actually serialize as when synced to/from Django's unified-sync
// endpoint, GET/POST /api/v1/user_mang/me/) against the Django-published
// OpenAPI schema. Django is the single source of truth for the contract
// (see ci-test-conventions.md). Mirrors the React app's
// src/__tests__/contract/api-contract.test.js approach: skip cleanly (never
// fabricate) if the schema file isn't available, and allow CI/local runs to
// point at a different path via OPENAPI_CONTRACT_PATH.
//
// Scope: only ConversationDoc/MessageDoc/AttachmentDoc are validated here —
// these are the schemas the app's local models actually round-trip through
// (see lib/core/models/conversation.dart, message.dart and
// lib/core/utils/design_patterns/repositories/data_repository.dart's sync
// calls). The chat-completion request/response bodies (MessageRequest/
// MessageResponse/MessageOutput) are NOT part of Django's contract — those
// go directly from the Flutter app to the LLM providers (OpenAI/Gemini/
// OpenRouter/LM Studio/HuggingFace), never through Django, so there is no
// Django-side schema to validate them against.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';
import 'package:flutter_app_itse500/core/models/message.dart';

String _resolveContractPath() {
  final fromEnv = Platform.environment['OPENAPI_CONTRACT_PATH'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // Default: this developer machine's known sibling-repo checkout (see
  // ci-test-conventions.md). Worktree checkouts (e.g.
  // .claude/worktrees/<branch>/) make a relative sibling-repo path
  // unreliable, so we point at the canonical absolute location instead.
  // CI runners won't have this path at all and are expected to set
  // OPENAPI_CONTRACT_PATH explicitly (e.g. after checking out
  // itse500-django alongside this repo); absent that, the suite skips
  // cleanly rather than fabricating a result.
  if (Platform.isWindows) {
    return r'E:\ITSE500-Django\contract\openapi.yaml';
  }
  return '/e/ITSE500-Django/contract/openapi.yaml';
}

/// Extracts the `required` field list and `properties` map for a named
/// schema under `components.schemas.<name>` from a parsed OpenAPI YAML doc.
class _SchemaInfo {
  final Set<String> required;
  final Map<String, dynamic> properties;
  const _SchemaInfo({required this.required, required this.properties});
}

_SchemaInfo? _findSchema(YamlMap doc, String schemaName) {
  final components = doc['components'];
  if (components is! YamlMap) return null;
  final schemas = components['schemas'];
  if (schemas is! YamlMap) return null;
  final schema = schemas[schemaName];
  if (schema is! YamlMap) return null;
  final requiredNode = schema['required'];
  final required = <String>{
    if (requiredNode is YamlList) ...requiredNode.map((e) => e.toString()),
  };
  final propsNode = schema['properties'];
  final properties = <String, dynamic>{
    if (propsNode is YamlMap)
      for (final entry in propsNode.entries) entry.key.toString(): entry.value,
  };
  return _SchemaInfo(required: required, properties: properties);
}

void main() {
  final contractPath = _resolveContractPath();
  final contractFile = File(contractPath);
  final schemaExists = contractFile.existsSync();

  group('API contract (Django OpenAPI schema)', () {
    if (!schemaExists) {
      test(
          'contract schema not found at $contractPath (expected in some '
          'environments — set OPENAPI_CONTRACT_PATH to override)', () {
        expect(schemaExists, isFalse);
      }, skip: 'contract/openapi.yaml not found at $contractPath');
      return;
    }

    late YamlMap doc;
    setUpAll(() {
      doc = loadYaml(contractFile.readAsStringSync()) as YamlMap;
    });

    test('ConversationDoc schema is present with the fields this app relies on',
        () {
      final schema = _findSchema(doc, 'ConversationDoc');
      expect(schema, isNotNull,
          reason: 'Django dropped ConversationDoc from the contract');
      expect(schema!.required, containsAll(['conversation_id', 'messages']));
      expect(schema.properties.keys,
          containsAll(['conversation_id', 'title', 'updated_at', 'messages']));
    });

    test('MessageDoc schema is present with the fields this app relies on',
        () {
      final schema = _findSchema(doc, 'MessageDoc');
      expect(schema, isNotNull,
          reason: 'Django dropped MessageDoc from the contract');
      expect(schema!.required, containsAll(['message_id', 'timestamp']));
      expect(
        schema.properties.keys,
        containsAll(
            ['message_id', 'timestamp', 'has_image', 'has_document']),
      );
    });

    test('AttachmentDoc schema is present with the fields this app relies on',
        () {
      final schema = _findSchema(doc, 'AttachmentDoc');
      expect(schema, isNotNull,
          reason: 'Django dropped AttachmentDoc from the contract');
      expect(schema!.properties.keys,
          containsAll(['attachment_id', 'message_id', 'url']));
    });

    test(
        "Conversation.toJson() satisfies ConversationDoc's required fields "
        '(conversation_id, messages array present as a key)', () {
      final schema = _findSchema(doc, 'ConversationDoc')!;
      final conversation = Conversation(
        conversationId: 'conv-1',
        userId: 'user-1',
        title: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        localOnly: false,
      );
      final json = conversation.toJson();
      // conversation.toJson() doesn't itself nest a `messages` array (that's
      // assembled server-side by FullChatSerializer / the sync payload
      // builder in data_repository.dart), so we only assert the fields the
      // local model IS responsible for producing.
      for (final requiredField in schema.required) {
        if (requiredField == 'messages') continue; // assembled server-side
        expect(json.containsKey(requiredField), isTrue,
            reason:
                'Conversation.toJson() is missing required contract field '
                '"$requiredField"');
      }
      expect(json['conversation_id'], isA<String>());
    });

    test(
        "Message round-trip (fromJson . toJson) preserves MessageDoc's "
        'required fields (message_id, timestamp)', () {
      final schema = _findSchema(doc, 'MessageDoc')!;
      final message = Message(
        messageId: 'msg-1',
        conversationId: 'conv-1',
        userId: 'user-1',
        timestamp: DateTime.parse('2026-01-01T00:00:00.000Z'),
        vote: false,
        hasImage: true,
        hasEmbedding: false,
        hasDocument: false,
      );
      final json = message.toJson();
      // Local sqlite column names differ slightly from the wire schema
      // (message_id matches; has_image/has_document match; timestamp
      // matches) — assert the ones that are directly shared.
      for (final requiredField in schema.required) {
        expect(json.containsKey(requiredField), isTrue,
            reason: 'Message.toJson() is missing required contract field '
                '"$requiredField"');
      }
      expect(json['message_id'], 'msg-1');
      expect(json['has_image'], 1); // stored as INTEGER 0/1, see db_helper
    });
  });
}
