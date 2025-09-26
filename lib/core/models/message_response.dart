class MessageResponse {
  final String responseId;
  final String? object;
  final DateTime? createdAt;
  final String? status;
  final String? error;

  // Canonical field name aligned with Django models
  final String? modelname; // nullable for backward compatibility
  final bool? parallelToolCalls;
  final String? previousResponseId;
  final String? instructions;
  final String? reasoningEffort;
  final String? reasoningSummary;
  final bool? store;
  final double? temperature;
  final String? textFormatType;
  final String? toolChoice;
  final String? tools;
  final double? topP;
  final String? truncation;
  final int? usageInputTokens;
  final int? usageOutputTokens;
  final int? usageTotalTokens;
  final String? user;
  final Map<String, dynamic>? metadata;
  final String? incompleteDetails;
  final int? maxOutputTokens;
  MessageResponse({
    required this.responseId,
    this.object,
    this.createdAt,
    this.status,
    this.error,
    this.incompleteDetails,
    this.maxOutputTokens,
    this.modelname,
    this.parallelToolCalls,
    this.previousResponseId,
    this.instructions,
    this.reasoningEffort,
    this.reasoningSummary,
    this.store,
    this.temperature,
    this.textFormatType,
    this.toolChoice,
    this.tools,
    this.topP,
    this.truncation,
    this.usageInputTokens,
    this.usageOutputTokens,
    this.usageTotalTokens,
    this.user,
    this.metadata,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) =>
      MessageResponse(
        responseId: json['response_id'],
        object: json['object'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        status: json['status'],
        error: json['error'],
        incompleteDetails: json['incomplete_details'],
        maxOutputTokens: json['max_output_tokens'],
        // Accept both keys; prefer explicit modelname
        modelname: json['modelname'] ?? json['model'],
        parallelToolCalls: json['parallel_tool_calls'],
        previousResponseId: json['previous_response_id'],
        instructions: json['instructions'],
        reasoningEffort: json['reasoning_effort'],
        reasoningSummary: json['reasoning_summary'],
        store: json['store'],
        temperature: json['temperature'] is num
            ? (json['temperature'] as num).toDouble()
            : json['temperature'],
        textFormatType: json['text_format_type'],
        toolChoice: json['tool_choice'],
        tools: json['tools'],
        topP: json['top_p'] is num
            ? (json['top_p'] as num).toDouble()
            : json['top_p'],
        truncation: json['truncation'],
        usageInputTokens: json['usage_input_tokens'],
        usageOutputTokens: json['usage_output_tokens'],
        usageTotalTokens: json['usage_total_tokens'],
        user: json['user'],
        metadata: json['metadata'] != null
            ? Map<String, dynamic>.from(json['metadata'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        // Columns present in message_responses table; extra fields are omitted.
        'response_id': responseId,
        'created_at': createdAt?.toIso8601String(),
        'status': status,
        'error': error,
        'incomplete_details': incompleteDetails,
        'max_output_tokens': maxOutputTokens,
        if (modelname != null)
          'model':
              modelname, // Persist under legacy 'model' column for DB compatibility
        // Store booleans as ints (0/1) where schema uses INTEGER
        'parallel_tool_calls':
            parallelToolCalls == null ? null : (parallelToolCalls! ? 1 : 0),
        'previous_response_id': previousResponseId,
        'instructions': instructions,
        'reasoning_effort': reasoningEffort,
        'reasoning_summary': reasoningSummary,
        'store': store == null ? null : (store! ? 1 : 0),
        'temperature': temperature,
        'tool_choice': toolChoice,
        'tools': tools,
        'top_p': topP,
        'truncation': truncation,
        'usage_input_tokens': usageInputTokens,
        'usage_output_tokens': usageOutputTokens,
        'usage_total_tokens': usageTotalTokens,
      };
}
