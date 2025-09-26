class MessageOutput {
  final String? outputType;
  final String? outputId;
  final String? outputStatus;
  final String? outputRole;
  final String? outputContentType;
  final String? outputContentText; // REAL OUTPUT OF LLM
  final String? outputContentAnnotations;

  MessageOutput({
    this.outputType,
    this.outputId,
    this.outputStatus,
    this.outputRole,
    this.outputContentType,
    this.outputContentText,
    this.outputContentAnnotations,
  });

  factory MessageOutput.fromJson(Map<String, dynamic> json) => MessageOutput(
        outputType: json['output_type'],
        outputId: json['output_id'],
        outputStatus: json['output_status'],
        outputRole: json['output_role'],
        outputContentType: json['output_content_type'],
        outputContentText: json['output_content_text'],
        outputContentAnnotations: json['output_content_annotations'],
      );

  Map<String, dynamic> toJson() => {
        'output_type': outputType,
        'output_id': outputId,
        'output_status': outputStatus,
        'output_role': outputRole,
        'output_content_type': outputContentType,
        'output_content_text': outputContentText,
        'output_content_annotations': outputContentAnnotations,
      };
}
