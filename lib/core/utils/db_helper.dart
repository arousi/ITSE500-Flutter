import 'dart:developer';
import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_app_itse500/core/models/oauth_state.dart';
import 'package:flutter_app_itse500/core/models/provider_oauth_token.dart';
import 'package:flutter_app_itse500/core/utils/unified_logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/custom_user.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DatabaseHelper {
  static const String _dbFileName = 'app_database.db';
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;
  final UnifiedLogger _logger = UnifiedLogger.instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Create DB
    String path = join(await getDatabasesPath(), _dbFileName);
    return await openDatabase(
      path,

      /// The onCreate callback initializes the database by creating the 'users' table,
      version: 4,
      onCreate: (db, version) async {
        log('Creating users, conversations, and messages tables');
        await db.execute(
          'CREATE TABLE users('
          'user_id TEXT PRIMARY KEY, '
          'username TEXT, '
          'first_name TEXT, '
          'last_name TEXT, '
          'email TEXT UNIQUE, '
          'user_password TEXT, '
          'phone_number TEXT, '
          'biometric_enabled INTEGER, '
          'last_modified TEXT, '
          'email_pin INTEGER, '
          'email_pin_created TEXT, '
          'email_verified INTEGER, '
          'is_archived INTEGER, '
          'is_visitor INTEGER, '
          'profile_email_verified INTEGER, '
          'profile_email_pin TEXT, '
          'profile_email_pin_created TEXT, '
          'is_staff INTEGER, '
          'is_superuser INTEGER, '
          'is_active INTEGER, '
          'date_joined TEXT, '
          'device_id TEXT, '
          'temp_id TEXT, '
          'related_devices TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE conversations('
          'conversation_id TEXT PRIMARY KEY, '
          'user_id TEXT, '
          'title TEXT, '
          'created_at TEXT, '
          'updated_at TEXT, '
          'local_only INTEGER, '
          'FOREIGN KEY(user_id) REFERENCES users(user_id)'
          ')',
        );
        await db.execute(
          'CREATE TABLE messages('
          'message_id TEXT PRIMARY KEY, '
          'conversation_id TEXT, '
          'img TEXT, '
          'timestamp TEXT, '
          'vote INTEGER, '
          'metadata TEXT, '
          'embedding TEXT, '
          'doc TEXT, '
          'FOREIGN KEY(conversation_id) REFERENCES conversations(conversation_id)'
          ')',
        );
        await db.execute(
          'CREATE TABLE message_requests('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'message_id TEXT, '
          'request_model TEXT, '
          'request_messages_role TEXT, '
          'request_messages_content TEXT, '
          'request_temperature REAL, '
          'request_top_p REAL, '
          'request_n INTEGER, '
          'request_stream INTEGER, '
          'request_stop TEXT, '
          'request_max_tokens INTEGER, '
          'top_k INTEGER, '
          'repeat_penalty REAL, '
          'min_p REAL, '
          'FOREIGN KEY(message_id) REFERENCES messages(message_id)'
          ')',
        );
        await db.execute(
          'CREATE TABLE message_responses('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'message_id TEXT, '
          'response_id TEXT, '
          'model TEXT, '
          'created_at TEXT, '
          'status TEXT, '
          'error TEXT, '
          'incomplete_details TEXT, '
          'instructions TEXT, '
          'max_output_tokens INTEGER, '
          'parallel_tool_calls INTEGER, '
          'previous_response_id TEXT, '
          'reasoning_effort TEXT, '
          'reasoning_summary TEXT, '
          'store INTEGER, '
          'temperature REAL, '
          'top_p REAL, '
          'truncation TEXT, '
          'tool_choice TEXT, '
          'tools TEXT, '
          'usage_input_tokens INTEGER, '
          'usage_output_tokens INTEGER, '
          'usage_total_tokens INTEGER, '
          'FOREIGN KEY(message_id) REFERENCES messages(message_id)'
          ')',
        );
        await db.execute(
          'CREATE TABLE message_outputs('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'message_id TEXT, '
          'output_type TEXT, '
          'output_id TEXT, '
          'output_status TEXT, '
          'output_role TEXT, '
          'output_content_type TEXT, '
          'output_content_text TEXT, '
          'output_content_annotations TEXT, '
          'FOREIGN KEY(message_id) REFERENCES messages(message_id)'
          ')',
        );
        // v2: attachments table (linked to messages and users)
        await db.execute(
          'CREATE TABLE attachments('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'message_id TEXT, '
          'conversation_id TEXT, '
          'user_id TEXT, '
          'type TEXT, '
          'mime_type TEXT, '
          'file_path TEXT, '
          'size_bytes INTEGER, '
          'width INTEGER, '
          'height INTEGER, '
          'sha256 TEXT, '
          'is_encrypted INTEGER, '
          'enc_algo TEXT, '
          'iv_base64 TEXT, '
          'key_ref TEXT, '
          'created_at TEXT, '
          'FOREIGN KEY(message_id) REFERENCES messages(message_id), '
          'FOREIGN KEY(conversation_id) REFERENCES conversations(conversation_id), '
          'FOREIGN KEY(user_id) REFERENCES users(user_id)'
          ')',
        );
        await db.execute(
          'CREATE TABLE oauth_states('
          'id TEXT PRIMARY KEY, '
          'provider TEXT, '
          'state TEXT, '
          'code_challenge TEXT, '
          'code_verifier TEXT, '
          'redirect_uri TEXT, '
          'mobile_redirect TEXT, '
          'result_payload TEXT, '
          'result_retrieved INTEGER, '
          'scope TEXT, '
          'user_id TEXT, '
          'created_at TEXT, '
          'expires_at TEXT, '
          'used INTEGER'
          ')',
        );
        await db.execute(
          'CREATE TABLE provider_oauth_tokens('
          'id TEXT PRIMARY KEY, '
          'user_id TEXT, '
          'provider TEXT, '
          'access_token TEXT, '
          'refresh_token TEXT, '
          'token_type TEXT, '
          'scope TEXT, '
          'expires_at TEXT, '
          'created_at TEXT, '
          'updated_at TEXT'
          ')',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Create attachments table
          await db.execute(
            'CREATE TABLE IF NOT EXISTS attachments('
            'id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'message_id TEXT, '
            'conversation_id TEXT, '
            'user_id TEXT, '
            'type TEXT, '
            'mime_type TEXT, '
            'file_path TEXT, '
            'size_bytes INTEGER, '
            'width INTEGER, '
            'height INTEGER, '
            'sha256 TEXT, '
            'is_encrypted INTEGER, '
            'enc_algo TEXT, '
            'iv_base64 TEXT, '
            'key_ref TEXT, '
            'created_at TEXT, '
            'FOREIGN KEY(message_id) REFERENCES messages(message_id), '
            'FOREIGN KEY(conversation_id) REFERENCES conversations(conversation_id), '
            'FOREIGN KEY(user_id) REFERENCES users(user_id)'
            ')',
          );
        }
        if (oldVersion < 3) {
          // Bridge from very early schema: add basic user columns
          try {
            await db.execute('ALTER TABLE users ADD COLUMN first_name TEXT');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE users ADD COLUMN last_name TEXT');
          } catch (_) {}
          try {
            await db
                .execute('ALTER TABLE users ADD COLUMN is_archived INTEGER');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE users ADD COLUMN is_active INTEGER');
          } catch (_) {}
          try {
            await db.execute('ALTER TABLE users ADD COLUMN date_joined TEXT');
          } catch (_) {}
        }
        if (oldVersion < 4) {
          // Unify with Django Custom_User superset — add any missing columns (best-effort)
          final additions = <String, String>{
            'first_name': 'TEXT',
            'last_name': 'TEXT',
            'user_password': 'TEXT',
            'email_pin': 'INTEGER',
            'email_pin_created': 'TEXT',
            'email_verified': 'INTEGER',
            'is_archived': 'INTEGER',
            'is_visitor': 'INTEGER',
            'profile_email_verified': 'INTEGER',
            'profile_email_pin': 'TEXT',
            'profile_email_pin_created': 'TEXT',
            'is_staff': 'INTEGER',
            'is_superuser': 'INTEGER',
            'is_active': 'INTEGER',
            'date_joined': 'TEXT',
            'device_id': 'TEXT',
            'temp_id': 'TEXT',
            'related_devices': 'TEXT',
          };
          for (final e in additions.entries) {
            try {
              await db
                  .execute('ALTER TABLE users ADD COLUMN ${e.key} ${e.value}');
            } catch (_) {}
          }
        }
      },
    );
  }

  Future<void> insertUser(String userId, String username, String email,
      {String? userPassword,
      String? phoneNumber,
      bool? biometricEnabled,
      String? lastModified,
      int? profileEmailPin,
      String? profileEmailPinCreated,
      bool? profileEmailVerified,
      bool? isArchived}) async {
    final user = CustomUser(
      userId: userId,
      username: username,
      firstName: null,
      lastName: null,
      email: email,
      phoneNumber: phoneNumber,
      biometricEnabled: biometricEnabled ?? false,
      lastModified: lastModified,
      isArchived: isArchived ?? false,
      isActive: true,
      dateJoined: DateTime.now().toIso8601String(),
    );
    await insertCustomUser(user);
  }

  Future<void> insertUserFromServer(Map<String, dynamic> user) async {
    final customUser = CustomUser.fromJson(user);
    await insertCustomUser(customUser);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final user = await fetchCustomUserByEmail(email);
    if (user != null &&
        verifyPassword(password, user.toJson()['user_password'])) {
      return user.toJson();
    }
    return null;
  }

  String hashPassword(String password) {
    // Do not log sensitive data
    final salt = BCrypt.gensalt();
    return BCrypt.hashpw(password, salt);
  }

  bool verifyPassword(String password, String hashedPassword) {
    // Do not log sensitive data
    return BCrypt.checkpw(password, hashedPassword);
  }

  Future<Map<String, dynamic>?> fetchUserFromDatabase(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return null;
    }
  }

  Future<void> insertOAuthState(OAuthState state) async {
    final db = await database;
    await db.insert('oauth_states', state.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Fetch OAuthState by state string
  Future<OAuthState?> fetchOAuthStateByState(String stateValue) async {
    final db = await database;
    final rows = await db
        .query('oauth_states', where: 'state = ?', whereArgs: [stateValue]);
    if (rows.isNotEmpty) {
      return OAuthState.fromJson(rows.first);
    }
    return null;
  }

// Insert ProviderOAuthToken
  Future<void> insertProviderOAuthToken(ProviderOAuthToken token) async {
    final db = await database;
    await db.insert('provider_oauth_tokens', token.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Fetch ProviderOAuthToken by user and provider
  Future<ProviderOAuthToken?> fetchProviderOAuthToken(
      String userId, String provider) async {
    final db = await database;
    final rows = await db.query(
      'provider_oauth_tokens',
      where: 'user_id = ? AND provider = ?',
      whereArgs: [userId, provider],
    );
    if (rows.isNotEmpty) {
      return ProviderOAuthToken.fromJson(rows.first);
    }
    return null;
  }

  Future<void> insertCustomUser(CustomUser user) async {
    final db = await database;
    _logger.i('Inserting CustomUser into database');
    final data = user.toJson();
    // Only pass columns that exist in our users schema to avoid runtime errors
    final filtered = <String, dynamic>{};
    const allowed = {
      'user_id',
      'username',
      'first_name',
      'last_name',
      'email',
      'user_password',
      'phone_number',
      'biometric_enabled',
      'last_modified',
      'email_pin',
      'email_pin_created',
      'email_verified',
      'is_archived',
      'is_visitor',
      'profile_email_verified',
      'profile_email_pin',
      'profile_email_pin_created',
      'is_staff',
      'is_superuser',
      'is_active',
      'date_joined',
      'device_id',
      'temp_id',
      'related_devices'
    };
    for (final entry in data.entries) {
      if (allowed.contains(entry.key)) filtered[entry.key] = entry.value;
    }
    try {
      await db.insert('users', filtered,
          conflictAlgorithm: ConflictAlgorithm.replace);
    } on DatabaseException catch (e) {
      _logger.e('Insert users failed: $e');
      // Best-effort: add missing columns and retry once
      await _addUserColumnsIfMissing(db);
      await db.insert('users', filtered,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _addUserColumnsIfMissing(Database db) async {
    final additions = <String, String>{
      'first_name': 'TEXT',
      'last_name': 'TEXT',
      'user_password': 'TEXT',
      'email_pin': 'INTEGER',
      'email_pin_created': 'TEXT',
      'email_verified': 'INTEGER',
      'is_archived': 'INTEGER',
      'is_visitor': 'INTEGER',
      'profile_email_verified': 'INTEGER',
      'profile_email_pin': 'TEXT',
      'profile_email_pin_created': 'TEXT',
      'is_staff': 'INTEGER',
      'is_superuser': 'INTEGER',
      'is_active': 'INTEGER',
      'date_joined': 'TEXT',
      'device_id': 'TEXT',
      'temp_id': 'TEXT',
      'related_devices': 'TEXT',
    };
    for (final e in additions.entries) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN ${e.key} ${e.value}');
      } catch (_) {}
    }
  }

  Future<CustomUser?> fetchCustomUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return CustomUser.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<void> insertConversation(Conversation conversation) async {
    final db = await database;
    // Map only known columns to avoid failures (e.g., visitor_id isn't in schema)
    final map = {
      'conversation_id': conversation.conversationId,
      'user_id': conversation.userId,
      'title': conversation.title,
      'created_at': conversation.createdAt.toIso8601String(),
      'updated_at': conversation.updatedAt.toIso8601String(),
      'local_only': conversation.localOnly ? 1 : 0,
    };
    await db.insert(
      'conversations',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMessage(Message message) async {
    final db = await database;
    final msgMap = message.toJson();
    await db.insert(
      'messages',
      msgMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Conversation>> fetchConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('conversations');

    return List.generate(maps.length, (i) {
      return Conversation.fromJson(maps[i]);
    });
  }

  Future<List<Message>> fetchMessages(String conversationId) async {
    final db = await database;
    // Join with latest request/output rows per message to enrich metadata for rendering
    // We select base message fields and attach output_role/content when available.
    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT m.message_id, m.conversation_id, m.img, m.timestamp, m.vote, m.metadata, m.embedding, m.doc,
             mo.output_role AS join_output_role,
             mo.output_content_text AS join_output_text
        FROM messages m
   LEFT JOIN (
          SELECT o.*
            FROM message_outputs o
           WHERE o.id IN (
                 SELECT MAX(id) FROM message_outputs GROUP BY message_id
           )
        ) mo ON mo.message_id = m.message_id
       WHERE m.conversation_id = ?
    ''', [conversationId]);

    final List<Message> messages = [];
    for (final row in rows) {
      // Inflate metadata with joined output if original metadata lacks it
      final meta = row['metadata'];
      Map<String, dynamic> metaMap = {};
      if (meta is String && meta.isNotEmpty) {
        try {
          metaMap = jsonDecode(meta) as Map<String, dynamic>;
        } catch (_) {}
      } else if (meta is Map<String, dynamic>) {
        metaMap = Map<String, dynamic>.from(meta);
      }
      if ((metaMap['output_text'] == null ||
              (metaMap['output_text'] as String?)?.isEmpty == true) &&
          row['join_output_text'] != null) {
        metaMap['output_text'] = row['join_output_text'];
      }
      if ((metaMap['output_role'] == null ||
              (metaMap['output_role'] as String?)?.isEmpty == true) &&
          row['join_output_role'] != null) {
        metaMap['output_role'] = row['join_output_role'];
      }
      // Recompose a map compatible with Message.fromJson
      final msgMap = {
        'message_id': row['message_id'],
        'conversation_id': row['conversation_id'],
        'img': row['img'],
        'timestamp': row['timestamp'],
        'vote': row['vote'],
        'metadata': jsonEncode(metaMap),
        'embedding': row['embedding'],
        'doc': row['doc'],
      };
      messages.add(Message.fromJson(msgMap));
    }
    return messages;
  }

  /// Returns the number of messages for a given conversation.
  Future<int> getMessageCount(String conversationId) async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM messages WHERE conversation_id = ?',
      [conversationId],
    ));
    return count ?? 0;
  }

  /// Fetch a single conversation by id, or null if not found.
  Future<Conversation?> fetchConversationById(String conversationId) async {
    final db = await database;
    final rows = await db.query(
      'conversations',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Conversation.fromJson(rows.first);
  }

  /// Backfill conversations for any conversation_id present in messages
  /// but missing from the conversations table. Titles are auto-generated.
  Future<void> backfillConversationsFromMessages() async {
    final db = await database;
    // Get distinct conversation_ids from messages
    final msgRows =
        await db.rawQuery('SELECT DISTINCT conversation_id FROM messages');
    final convRows =
        await db.rawQuery('SELECT conversation_id FROM conversations');
    final existing =
        convRows.map((e) => e['conversation_id']).whereType<String>().toSet();
    final missing = msgRows
        .map((e) => e['conversation_id'])
        .whereType<String>()
        .where((id) => !existing.contains(id))
        .toSet();
    final now = DateTime.now().toIso8601String();
    for (final id in missing) {
      await db.insert(
        'conversations',
        {
          'conversation_id': id,
          'user_id': 'user',
          'title': 'Conversation',
          'created_at': now,
          'updated_at': now,
          'local_only': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<int> insertMessageRequest(Map<String, dynamic> request) async {
    final db = await database;
    return await db.insert('message_requests', request,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMessageResponse(Map<String, dynamic> response) async {
    final db = await database;
    return await db.insert('message_responses', response,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> insertMessageOutput(Map<String, dynamic> output) async {
    final db = await database;
    return await db.insert('message_outputs', output,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ------ Fetch latest IO triplets by message_id ------
  Future<Map<String, dynamic>?> fetchLatestMessageRequest(
      String messageId) async {
    final db = await database;
    final rows = await db.query(
      'message_requests',
      where: 'message_id = ?',
      whereArgs: [messageId],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Map<String, dynamic>?> fetchLatestMessageResponse(
      String messageId) async {
    final db = await database;
    final rows = await db.query(
      'message_responses',
      where: 'message_id = ?',
      whereArgs: [messageId],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<Map<String, dynamic>?> fetchLatestMessageOutput(
      String messageId) async {
    final db = await database;
    final rows = await db.query(
      'message_outputs',
      where: 'message_id = ?',
      whereArgs: [messageId],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  // ---------- Attachments CRUD ----------
  Future<int> insertAttachment(Map<String, dynamic> attachment) async {
    final db = await database;
    return await db.insert('attachments', attachment,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> fetchAttachmentsByMessage(
      String messageId) async {
    final db = await database;
    return await db
        .query('attachments', where: 'message_id = ?', whereArgs: [messageId]);
  }

  Future<List<Map<String, dynamic>>> fetchAttachmentsByConversation(
      String conversationId) async {
    final db = await database;
    return await db.query('attachments',
        where: 'conversation_id = ?', whereArgs: [conversationId]);
  }

  Future<List<Map<String, dynamic>>> fetchAttachmentsByUser(
      String userId) async {
    final db = await database;
    return await db
        .query('attachments', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteAttachmentById(int id) async {
    final db = await database;
    return await db.delete('attachments', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateConversationTitle(
      String conversationId, String newTitle) async {
    final db = await database;
    await db.update(
      'conversations',
      {'title': newTitle},
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  Future<void> updateConversationRelatedIds(String conversationId,
      {String? userId}) async {
    final db = await database;
    Map<String, dynamic> updateFields = {};
    if (userId != null) updateFields['user_id'] = userId;
    if (updateFields.isNotEmpty) {
      await db.update(
        'conversations',
        updateFields,
        where: 'conversation_id = ?',
        whereArgs: [conversationId],
      );
    }
  }

  /// Update the privacy (local_only) flag for a conversation.
  Future<void> updateConversationLocalOnly(
      String conversationId, bool localOnly) async {
    final db = await database;
    await db.update(
      'conversations',
      {
        'local_only': localOnly ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String()
      },
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Delete a single conversation and all related rows (messages, requests, responses, outputs, attachments).
  Future<void> deleteConversation(String conversationId) async {
    final db = await database;
    // Delete dependents first (no FK cascade defined)
    // Use subqueries to target rows for this conversation.
    await db.delete('attachments',
        where: 'conversation_id = ?', whereArgs: [conversationId]);
    // Collect message ids to ensure thorough cleanup
    final msgRows = await db.query('messages',
        columns: ['message_id'],
        where: 'conversation_id = ?',
        whereArgs: [conversationId]);
    final ids =
        msgRows.map((e) => e['message_id']).whereType<String>().toList();
    if (ids.isNotEmpty) {
      final whereIn =
          'message_id IN (${List.filled(ids.length, '?').join(',')})';
      await db.delete('message_outputs', where: whereIn, whereArgs: ids);
      await db.delete('message_responses', where: whereIn, whereArgs: ids);
      await db.delete('message_requests', where: whereIn, whereArgs: ids);
    }
    await db.delete('messages',
        where: 'conversation_id = ?', whereArgs: [conversationId]);
    await db.delete('conversations',
        where: 'conversation_id = ?', whereArgs: [conversationId]);
  }

  /// Bulk delete multiple conversations.
  Future<void> deleteConversations(List<String> conversationIds) async {
    if (conversationIds.isEmpty) return;
    final db = await database;
    // Fetch message ids for all conversations
    final placeholders = List.filled(conversationIds.length, '?').join(',');
    final msgRows = await db.rawQuery(
      'SELECT message_id FROM messages WHERE conversation_id IN ($placeholders)',
      conversationIds,
    );
    final msgIds =
        msgRows.map((e) => e['message_id']).whereType<String>().toList();
    if (msgIds.isNotEmpty) {
      final whereInMsgs =
          'message_id IN (${List.filled(msgIds.length, '?').join(',')})';
      await db.delete('message_outputs', where: whereInMsgs, whereArgs: msgIds);
      await db.delete('message_responses',
          where: whereInMsgs, whereArgs: msgIds);
      await db.delete('message_requests',
          where: whereInMsgs, whereArgs: msgIds);
    }
    await db.delete('attachments',
        where: 'conversation_id IN ($placeholders)',
        whereArgs: conversationIds);
    await db.delete('messages',
        where: 'conversation_id IN ($placeholders)',
        whereArgs: conversationIds);
    await db.delete('conversations',
        where: 'conversation_id IN ($placeholders)',
        whereArgs: conversationIds);
  }

  /// Delete all conversations (dangerous operation) and related data.
  Future<void> deleteAllConversations() async {
    final db = await database;
    await db.delete('attachments');
    await db.delete('message_outputs');
    await db.delete('message_responses');
    await db.delete('message_requests');
    await db.delete('messages');
    await db.delete('conversations');
  }

  /// Danger: Wipes all local data including users, OAuth state/tokens, conversations, and messages.
  /// Intended for visitor logout/purge only. Do not call for normal logout of authenticated users.
  Future<void> deleteAllLocalData() async {
    final db = await database;
    // Drop dependents first
    await db.delete('attachments');
    await db.delete('message_outputs');
    await db.delete('message_responses');
    await db.delete('message_requests');
    await db.delete('messages');
    await db.delete('conversations');
    // OAuth artifacts
    try {
      await db.delete('provider_oauth_tokens');
    } catch (_) {}
    try {
      await db.delete('oauth_states');
    } catch (_) {}
    // Finally users
    await db.delete('users');
  }
}
