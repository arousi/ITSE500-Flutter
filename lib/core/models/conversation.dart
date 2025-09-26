class Conversation {
  final String conversationId;
  final String? userId; // Matches server schema
  final String? visitorId; // Matches server schema
  final String? title; // Matches server schema
  final DateTime createdAt; // Matches server schema
  final DateTime updatedAt; // Matches server schema
  final bool localOnly; // Matches server schema

  Conversation({
    required this.conversationId,
    this.userId,
    this.visitorId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.localOnly,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final dynamic localOnlyRaw = json['local_only'];
    final bool localOnlyBool = localOnlyRaw is int
        ? localOnlyRaw != 0
        : (localOnlyRaw is bool ? localOnlyRaw : false);
    return Conversation(
      conversationId: json['conversation_id'],
      userId: json['user_id'],
      visitorId: json['visitor_id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      localOnly: localOnlyBool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'user_id': userId,
      'visitor_id': visitorId,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'local_only': localOnly,
    };
  }
}
