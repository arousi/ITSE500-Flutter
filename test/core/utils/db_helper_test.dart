// Tests for DatabaseHelper using an in-memory sqflite database via
// sqflite_common_ffi. DatabaseHelper is a process-wide singleton (static
// `_database` field, no reset hook), so all tests in this file share a
// single opened database instance and use unique ids per test to avoid
// cross-test collisions rather than reopening per test.
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_app_itse500/core/models/conversation.dart';
import 'package:flutter_app_itse500/core/models/custom_user.dart';
import 'package:flutter_app_itse500/core/models/message.dart';
import 'package:flutter_app_itse500/core/utils/db_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // sqflite_common_ffi persists to a real file under .dart_tool/, unlike
    // the in-memory ":memory:" mode. Delete any leftover database from a
    // previous test run so each `flutter test` invocation starts fresh and
    // tests don't leak state across runs.
    final dbPath = p.join(
        await databaseFactoryFfi.getDatabasesPath(), 'app_database.db');
    await databaseFactoryFfi.deleteDatabase(dbPath);
  });

  final helper = DatabaseHelper();

  group('DatabaseHelper schema', () {
    test('opens the database at the current schema version (4)', () async {
      final db = await helper.database;
      expect(db.isOpen, isTrue);
      final version = await db.getVersion();
      expect(version, 4);
    });

    test('all expected tables exist after onCreate', () async {
      final db = await helper.database;
      final rows = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'");
      final names = rows.map((r) => r['name'] as String).toSet();
      expect(
        names.containsAll({
          'users',
          'conversations',
          'messages',
          'message_requests',
          'message_responses',
          'message_outputs',
          'attachments',
          'oauth_states',
          'provider_oauth_tokens',
        }),
        isTrue,
      );
    });
  });

  group('DatabaseHelper conversations CRUD', () {
    test('insertConversation + fetchConversationById round-trips fields',
        () async {
      final conv = Conversation(
        conversationId: 'conv-crud-1',
        userId: 'user-1',
        title: 'Test Conversation',
        createdAt: DateTime.parse('2026-01-01T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-01-02T00:00:00.000Z'),
        localOnly: true,
      );
      await helper.insertConversation(conv);

      final fetched = await helper.fetchConversationById('conv-crud-1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Test Conversation');
      expect(fetched.userId, 'user-1');
      expect(fetched.localOnly, isTrue);
    });

    test('updateConversationTitle persists the new title', () async {
      final conv = Conversation(
        conversationId: 'conv-crud-2',
        userId: 'user-1',
        title: 'Old title',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        localOnly: false,
      );
      await helper.insertConversation(conv);
      await helper.updateConversationTitle('conv-crud-2', 'New title');
      final fetched = await helper.fetchConversationById('conv-crud-2');
      expect(fetched!.title, 'New title');
    });

    test('updateConversationLocalOnly flips the privacy flag', () async {
      final conv = Conversation(
        conversationId: 'conv-crud-3',
        userId: 'user-1',
        title: 'Privacy test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        localOnly: false,
      );
      await helper.insertConversation(conv);
      await helper.updateConversationLocalOnly('conv-crud-3', true);
      final fetched = await helper.fetchConversationById('conv-crud-3');
      expect(fetched!.localOnly, isTrue);
    });

    test('deleteConversation removes the conversation and its messages',
        () async {
      final conv = Conversation(
        conversationId: 'conv-crud-4',
        userId: 'user-1',
        title: 'To delete',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        localOnly: false,
      );
      await helper.insertConversation(conv);
      final msg = Message(
        messageId: 'msg-crud-4',
        conversationId: 'conv-crud-4',
        userId: 'user-1',
        timestamp: DateTime.now(),
        vote: false,
        hasImage: false,
        hasEmbedding: false,
        hasDocument: false,
      );
      await helper.insertMessage(msg);

      await helper.deleteConversation('conv-crud-4');

      final fetched = await helper.fetchConversationById('conv-crud-4');
      expect(fetched, isNull);
      final messages = await helper.fetchMessages('conv-crud-4');
      expect(messages, isEmpty);
    });

    test('fetchConversationById returns null for unknown id', () async {
      final fetched = await helper.fetchConversationById('does-not-exist');
      expect(fetched, isNull);
    });
  });

  group('DatabaseHelper messages CRUD', () {
    test('insertMessage + fetchMessages + getMessageCount round-trip',
        () async {
      final conv = Conversation(
        conversationId: 'conv-msgs-1',
        userId: 'user-1',
        title: 'Msg conversation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        localOnly: false,
      );
      await helper.insertConversation(conv);

      final msg = Message(
        messageId: 'msg-1',
        conversationId: 'conv-msgs-1',
        userId: 'user-1',
        timestamp: DateTime.parse('2026-01-01T00:00:00.000Z'),
        vote: true,
        hasImage: false,
        hasEmbedding: false,
        hasDocument: false,
        metadata: {'output_text': 'hello world'},
      );
      await helper.insertMessage(msg);

      final count = await helper.getMessageCount('conv-msgs-1');
      expect(count, 1);

      final messages = await helper.fetchMessages('conv-msgs-1');
      expect(messages, hasLength(1));
      expect(messages.first.messageId, 'msg-1');
      expect(messages.first.vote, isTrue);
    });

    test('backfillConversationsFromMessages creates a conversation row for '
        'orphaned messages', () async {
      // Insert a message whose conversation was never explicitly created.
      final msg = Message(
        messageId: 'msg-orphan-1',
        conversationId: 'conv-orphan-1',
        userId: 'user-1',
        timestamp: DateTime.now(),
        vote: false,
        hasImage: false,
        hasEmbedding: false,
        hasDocument: false,
      );
      await helper.insertMessage(msg);

      expect(await helper.fetchConversationById('conv-orphan-1'), isNull);

      await helper.backfillConversationsFromMessages();

      final backfilled = await helper.fetchConversationById('conv-orphan-1');
      expect(backfilled, isNotNull);
      expect(backfilled!.title, 'Conversation');
    });
  });

  group('DatabaseHelper message request/response/output CRUD', () {
    test('inserts and fetches the latest request/response/output by message id',
        () async {
      const messageId = 'msg-io-1';
      await helper.insertMessageRequest({
        'message_id': messageId,
        'request_model': 'gpt-4o',
        'request_temperature': 0.7,
      });
      await helper.insertMessageResponse({
        'message_id': messageId,
        'response_id': 'resp-1',
        'status': 'completed',
      });
      await helper.insertMessageOutput({
        'message_id': messageId,
        'output_type': 'text',
        'output_content_text': 'Hi!',
      });

      final req = await helper.fetchLatestMessageRequest(messageId);
      final resp = await helper.fetchLatestMessageResponse(messageId);
      final out = await helper.fetchLatestMessageOutput(messageId);

      expect(req!['request_model'], 'gpt-4o');
      expect(resp!['status'], 'completed');
      expect(out!['output_content_text'], 'Hi!');
    });

    test('fetchLatestMessageRequest returns the most recently inserted row',
        () async {
      const messageId = 'msg-io-2';
      await helper.insertMessageRequest(
          {'message_id': messageId, 'request_model': 'v1'});
      await helper.insertMessageRequest(
          {'message_id': messageId, 'request_model': 'v2'});
      final latest = await helper.fetchLatestMessageRequest(messageId);
      expect(latest!['request_model'], 'v2');
    });
  });

  group('DatabaseHelper users CRUD', () {
    test('insertCustomUser + fetchCustomUserByEmail round-trips', () async {
      final user = CustomUser(
        userId: 'user-crud-1',
        username: 'tester',
        email: 'tester@example.com',
        isActive: true,
        isArchived: false,
      );
      await helper.insertCustomUser(user);
      final fetched = await helper.fetchCustomUserByEmail('tester@example.com');
      expect(fetched, isNotNull);
      expect(fetched!.userId, 'user-crud-1');
      expect(fetched.isActive, isTrue);
    });

    test('hashPassword/verifyPassword round-trip correctly', () {
      final hash = helper.hashPassword('s3cret');
      expect(helper.verifyPassword('s3cret', hash), isTrue);
      expect(helper.verifyPassword('wrong', hash), isFalse);
    });
  });

  group('DatabaseHelper bulk delete operations', () {
    test('deleteConversations removes multiple conversations and their data',
        () async {
      for (final id in ['bulk-1', 'bulk-2']) {
        await helper.insertConversation(Conversation(
          conversationId: id,
          userId: 'user-1',
          title: id,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          localOnly: false,
        ));
      }
      await helper.deleteConversations(['bulk-1', 'bulk-2']);
      expect(await helper.fetchConversationById('bulk-1'), isNull);
      expect(await helper.fetchConversationById('bulk-2'), isNull);
    });
  });
}
