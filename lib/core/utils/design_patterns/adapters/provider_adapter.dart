import 'dart:async';

import 'package:flutter_app_itse500/core/models/message_request.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/models/message_output.dart';

/// Provider identifiers supported by the app.
enum ProviderId { openai, openrouter, gemini, lmstudio, huggingface }

/// Capability flags used by UI to enable/disable inference controls.
enum Capability {
  temperature,
  topP,
  topK,
  minP,
  repetitionPenalty,
  structuredOutput,
  streaming,
  systemPrompt,
  vision, // indicates provider/model can accept image attachments in requests
}

/// Context passed to adapters to build requests and parse responses.
class GenerationContext {
  final ProviderId providerId;
  final String? model; // selected model id/name
  final MessageRequest request; // normalized request from UI/Cubit
  final String? conversationId;
  final String requestId;
  final String? credential; // API key or LM Studio endpoint (for local)

  const GenerationContext({
    required this.providerId,
    required this.request,
    required this.requestId,
    this.model,
    this.conversationId,
    this.credential,
  });
}

/// HTTP request envelope produced by adapters.
class ProviderHttpRequest {
  final String url;
  final Map<String, String> headers;
  final Map<String, dynamic> body;
  final Duration? timeout;

  const ProviderHttpRequest({
    required this.url,
    required this.headers,
    required this.body,
    this.timeout,
  });
}

/// Parsed response normalized to our internal models.
class ProviderParsed {
  final MessageResponse response;
  final MessageOutput output;
  const ProviderParsed({required this.response, required this.output});
}

/// Streaming chunk payload (future use).
class ProviderChunk {
  final String? deltaText;
  final int index;
  final String? finishReason;
  const ProviderChunk({this.deltaText, required this.index, this.finishReason});
}

/// Adapter contract each provider implements.
abstract class ProviderAdapter {
  String get id;
  Set<Capability> get capabilities;

  ProviderHttpRequest buildRequest(
      {required GenerationContext ctx, required bool stream});
  ProviderParsed parseResponse(
      Map<String, dynamic> json, GenerationContext ctx);
  Stream<ProviderChunk> streamParser(
      Stream<String> raw, GenerationContext ctx) {
    throw UnimplementedError('Streaming not implemented for $id');
  }

  // Optional artifact generation APIs (Phase 0 stubs). Implement in concrete adapters as needed.
  Future<List<int>> generateEmbedding(
      {required String text,
      required String model,
      required String? credential}) async {
    throw UnimplementedError('Embedding generation not implemented for $id');
  }

  Future<List<int>> generateImagePng(
      {required String prompt,
      required String model,
      required String? credential}) async {
    throw UnimplementedError('Image generation not implemented for $id');
  }
}
