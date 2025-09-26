class MessageRequest {
  final String requestId;
  final String? requestModel;

  //!"doesn't exist in erd"
  final String? requestInput;

  final String? requestSystemRole;
  final String? requestSystemContent;

  //!"doesn't exist in erd"
  final String?
      requestSystemPrompt; // consolidated system prompt (alternative to role/content pair)
  //!"doesn't exist in erd"
  final bool? requestUseStructuredOutput;
  //!"doesn't exist in erd"
  final String? requestStructuredSchema;

  final String? requestUserRole;

  //!"doesn't exist in erd"
  final String? requestUserContent;
  //!"doesn't exist in erd"
  // Ordered chat history prior to this turn, as role/content maps
  final List<Map<String, String>>? requestChatMessages;
  // Attachments descriptors for this turn (e.g., images). Each map should contain at least: { 'type': 'image', 'mime': 'image/png', 'path': 'abs/path', 'size': 1234 }
  //!"doesn't exist in erd"
  final List<Map<String, dynamic>>? requestAttachments;

  final double? requestMinP;
  final double? requestTemperature;
  final double? requestTopP;
  final int? requestN;
  final double? requestTopK;

  final bool? requestStream;
  final String? requestStop;
  final int? requestMaxTokens;
  final double? repeatPenalty;

  MessageRequest({
    required this.requestId,
    this.requestModel,
    this.requestInput,
    this.requestSystemRole,
    this.requestSystemContent,
    this.requestSystemPrompt,
    this.requestUseStructuredOutput,
    this.requestStructuredSchema,
    this.requestUserRole,
    this.requestUserContent,
    this.requestChatMessages,
    this.requestAttachments,
    this.requestMinP,
    this.requestTemperature,
    this.requestTopP,
    this.requestN,
    this.requestTopK,
    this.requestStream,
    this.requestStop,
    this.requestMaxTokens,
    this.repeatPenalty,
  });

  factory MessageRequest.fromJson(Map<String, dynamic> json) => MessageRequest(
        requestId: json['request_id'],
        requestModel: json['request_model'],
        requestInput: json['request_input'],
        requestSystemRole: json['request_system_role'],
        requestSystemContent: json['request_system_content'],
        requestSystemPrompt: json['request_system_prompt'],
        requestUseStructuredOutput: json['request_use_structured_output'],
        requestStructuredSchema: json['request_structured_schema'],
        requestUserRole: json['request_user_role'],
        requestUserContent: json['request_user_content'],
        requestChatMessages: (json['request_chat_messages'] as List?)
            ?.whereType<Map>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v.toString())))
            .toList(),
        requestAttachments: (json['request_attachments'] as List?)
            ?.whereType<Map>()
            .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
            .toList(),
        requestMinP: json['request_min_p'],
        requestTemperature: json['request_temperature'],
        requestTopP: json['request_top_p'],
        requestN: json['request_n'],
        requestTopK: json['request_top_k'],
        requestStream: json['request_stream'],
        requestStop: json['request_stop'],
        requestMaxTokens: json['request_max_tokens'],
        repeatPenalty: json['repeat_penalty'],
      );

  get conversationId => null;

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
        'request_model': requestModel,
        'request_input': requestInput,
        'request_system_role': requestSystemRole,
        'request_system_content': requestSystemContent,
        'request_system_prompt': requestSystemPrompt,
        'request_use_structured_output': requestUseStructuredOutput,
        'request_structured_schema': requestStructuredSchema,
        'request_user_role': requestUserRole,
        'request_user_content': requestUserContent,
        'request_chat_messages': requestChatMessages,
        'request_attachments': requestAttachments,
        'request_min_p': requestMinP,
        'request_temperature': requestTemperature,
        'request_top_p': requestTopP,
        'request_n': requestN,
        'request_top_k': requestTopK,
        'request_stream': requestStream,
        'request_stop': requestStop,
        'request_max_tokens': requestMaxTokens,
        'repeat_penalty': repeatPenalty,
      };
}
