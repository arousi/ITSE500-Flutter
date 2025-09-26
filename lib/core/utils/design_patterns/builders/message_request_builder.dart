import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/features/chat_inference/logic/inference_settings_cubit.dart';

/// Builds MessageRequest from UI state, including only fields supported by provider capabilities.
class ParamBounds {
  final double? temperatureMax;
  final int? topKMax;
  const ParamBounds({this.temperatureMax, this.topKMax});
}

class MessageRequestBuilder {
  const MessageRequestBuilder();

  MessageRequest build({
    required String requestId,
    String? model,
    required String userContent,
    List<Map<String, String>>? chatMessages,
    List<Map<String, dynamic>>? attachments,
    InferenceSettingsState? state,
    Set<Capability> capabilities = const {},
    bool stream = false,
    ParamBounds? paramLimits,
  }) {
    // Guard against null state with sensible defaults
    final s = state ?? const InferenceSettingsState();

    // Clamp helpers
    double clampDouble(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);
    int clampInt(num v, int min, int max) {
      final i = v.round();
      return i < min ? min : (i > max ? max : i);
    }

    double? temperature;
    double? topP;
    double? topK;
    double? minP;
    double? repeatPenalty;
    String? systemPrompt;
    bool? useStructuredOutput;
    String? structuredSchema;

    if (capabilities.contains(Capability.temperature) && s.useTemperature) {
      // Typical provider ranges: 0.0 .. 2.0; allow model-specific max if provided
      final maxT = paramLimits?.temperatureMax ?? 2.0;
      temperature = clampDouble(s.temperature, 0.0, maxT);
    }
    if (capabilities.contains(Capability.topP) && s.useTopP) {
      // 0.0 .. 1.0
      topP = clampDouble(s.topP, 0.0, 1.0);
    }
    if (capabilities.contains(Capability.topK) && s.useTopK) {
      // 1 .. 200 (safe generic) or model-specific cap if provided
      final maxK = paramLimits?.topKMax ?? 200;
      topK = clampInt(s.topK, 1, maxK).toDouble();
    }
    if (capabilities.contains(Capability.minP) && s.useMinP) {
      // 0.0 .. 1.0
      minP = clampDouble(s.minP, 0.0, 1.0);
    }
    if (capabilities.contains(Capability.repetitionPenalty) &&
        s.useRepeatPenalty) {
      // 0.0 .. 2.0 (provider specific, keep conservative)
      repeatPenalty = clampDouble(s.repeatPenalty, 0.0, 2.0);
    }
    if (capabilities.contains(Capability.systemPrompt) &&
        s.useSystemPrompt &&
        s.systemPrompt.trim().isNotEmpty) {
      systemPrompt = s.systemPrompt.trim();
    }
    if (capabilities.contains(Capability.structuredOutput) &&
        s.useStructuredOutput &&
        s.structuredSchema.trim().isNotEmpty) {
      useStructuredOutput = true;
      structuredSchema = s.structuredSchema.trim();
    }

    // If provider does not claim vision capability, strip attachments defensively.
    final filteredAttachments =
        capabilities.contains(Capability.vision) ? attachments : null;

    return MessageRequest(
      requestId: requestId,
      requestModel: model,
      requestUserRole: 'user',
      requestUserContent: userContent,
      requestChatMessages: chatMessages,
      requestAttachments: filteredAttachments,
      requestSystemPrompt: systemPrompt,
      requestUseStructuredOutput: useStructuredOutput,
      requestStructuredSchema: structuredSchema,
      requestTemperature: temperature,
      requestTopP: topP,
      requestTopK: topK?.toDouble(),
      requestMinP: minP,
      repeatPenalty: repeatPenalty,
      requestStream: stream,
    );
  }
}
