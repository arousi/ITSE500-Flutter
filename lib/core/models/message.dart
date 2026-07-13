import 'dart:convert';

class Message {
  final String messageId;
  final String conversationId;
  final String userId;
  final String? requestId;
  final String? responseId;
  final String? outputId;
  final DateTime timestamp;
  final bool vote;
  final bool hasImage;
  final String? imgUrl;
  final Map<String, dynamic>? metadata;
  final bool hasEmbedding;
  final bool hasDocument;
  final String? docUrl;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.userId,
    this.requestId,
    this.responseId,
    this.outputId,
    required this.timestamp,
    required this.vote,
    required this.hasImage,
    this.imgUrl,
    this.metadata,
    required this.hasEmbedding,
    required this.hasDocument,
    this.docUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // metadata may be stored as a JSON string in DB; attempt decode if String
    dynamic meta = json['metadata'];
    if (meta is String) {
      try {
        meta =
            meta.isNotEmpty ? (jsonDecode(meta) as Map<String, dynamic>) : null;
      } catch (_) {
        meta = null; // fallback if corrupt
      }
    }
    // DB schema for 'messages' table doesn't include user_id/has_image/etc.
    // Be defensive and map to sensible defaults where columns are absent.
    bool asBool(dynamic raw, {bool fallback = false}) {
      if (raw is int) return raw != 0;
      if (raw is bool) return raw;
      return fallback;
    }

    return Message(
      messageId: json['message_id'] as String,
      conversationId: json['conversation_id'] as String,
      userId: (json['user_id'] as String?) ?? 'user',
      requestId: json['request_id'] as String?,
      responseId: json['response_id'] as String?,
      outputId: json['output_id'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      vote: asBool(json['vote']),
      hasImage: asBool(json['has_image']),
      imgUrl: (json['img_Url'] as String?) ?? (json['img'] as String?),
      metadata: meta is Map<String, dynamic> ? meta : null,
      hasEmbedding: asBool(json['has_embedding'],
          fallback: json['embedding'] != null),
      hasDocument:
          asBool(json['has_document'], fallback: json['doc'] != null),
      docUrl: (json['doc_url'] as String?) ?? (json['doc'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    String? metaString;
    if (metadata != null) {
      try {
        metaString = jsonEncode(metadata);
      } catch (_) {
        metaString = null;
      }
    }
    return {
      'message_id': messageId,
      'conversation_id': conversationId,
      'user_id': userId,
      'request_id': requestId,
      'response_id': responseId,
      'output_id': outputId,
      'timestamp': timestamp.toIso8601String(),
      // Stored as INTEGER (0/1) in sqlite; strict drivers (e.g. sqflite_common_ffi
      // used in tests) reject native Dart bool values.
      'vote': vote ? 1 : 0,
      'has_image': hasImage ? 1 : 0,
      'img_Url': imgUrl,
      'metadata': metaString,
      'has_embedding': hasEmbedding ? 1 : 0,
      'has_document': hasDocument ? 1 : 0,
      'doc_url': docUrl,
    };
  }
}
