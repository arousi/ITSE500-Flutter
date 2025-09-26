import 'dart:convert';
import 'dart:async';
// Removed unused io/typed_data imports after centralizing network calls in DataRepository

import 'package:flutter_app_itse500/core/models/message_output.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

class OpenAIAdapter implements ProviderAdapter {
  @override
  String get id => 'openai';

  @override
  Set<Capability> get capabilities => {
        Capability.temperature,
        Capability.topP,
        Capability.structuredOutput,
        Capability.systemPrompt,
        Capability.streaming,
      };

  @override
  ProviderHttpRequest buildRequest(
      {required GenerationContext ctx, required bool stream}) {
    final req = ctx.request;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (ctx.credential != null) 'Authorization': 'Bearer ${ctx.credential}',
    };
    final history = (req.requestChatMessages ?? const <Map<String, String>>[])
        .map(
            (m) => {'role': m['role'] ?? 'user', 'content': m['content'] ?? ''})
        .toList();

    // Compose multimodal user content if attachments exist
    dynamic userContent;
    final atts = req.requestAttachments ?? const [];
    if (atts.isNotEmpty) {
      final List<Map<String, dynamic>> parts = [];
      if ((req.requestUserContent ?? '').isNotEmpty) {
        parts.add({'type': 'text', 'text': req.requestUserContent});
      }
      for (final a in atts) {
        if (a['type'] == 'image') {
          final url = (a['dataUrl'] as String?) ?? 'file://${a['path']}';
          parts.add({
            'type': 'image_url',
            'image_url': {
              'url': url,
              if (a['mime'] != null) 'mime_type': a['mime']
            }
          });
        }
      }
      userContent = parts;
    } else {
      userContent = req.requestUserContent ?? '';
    }
    final body = <String, dynamic>{
      'model': ctx.model ?? req.requestModel,
      'messages': [
        if ((req.requestSystemPrompt ?? '').isNotEmpty)
          {'role': 'system', 'content': req.requestSystemPrompt},
        ...history,
        {'role': req.requestUserRole ?? 'user', 'content': userContent},
      ],
      if (req.requestTemperature != null) 'temperature': req.requestTemperature,
      if (req.requestTopP != null) 'top_p': req.requestTopP,
      if (req.requestMaxTokens != null) 'max_tokens': req.requestMaxTokens,
      if (req.requestUseStructuredOutput == true &&
          (req.requestStructuredSchema?.isNotEmpty ?? false))
        'response_format': {
          'type': 'json_schema',
          'json_schema': {
            'name': 'structured_output',
            'schema': _tryDecodeJson(req.requestStructuredSchema!),
            'strict': true,
          }
        },
      'stream': stream,
    };
    return ProviderHttpRequest(
      url: 'https://api.openai.com/v1/chat/completions',
      headers: headers,
      body: body,
    );
  }

  @override
  ProviderParsed parseResponse(
      Map<String, dynamic> json, GenerationContext ctx) {
    final choices = json['choices'];
    final first =
        (choices is List && choices.isNotEmpty) ? choices.first : null;
    final msg = first != null ? first['message'] : null;
    final content = msg != null ? msg['content'] : null;
    final response = MessageResponse(
      responseId: json['id'] ?? '',
      modelname: json['model'] ?? ctx.model ?? ctx.request.requestModel,
      createdAt: json['created'] != null
          ? DateTime.fromMillisecondsSinceEpoch((json['created'] as int) * 1000)
          : DateTime.now(),
      status: 'completed',
      error: null,
    );
    final output = MessageOutput(
      outputType: 'text',
      outputId: '',
      outputStatus: 'completed',
      outputRole: msg != null ? msg['role'] : 'assistant',
      outputContentType: 'text',
      outputContentText: content ?? 'No response',
    );
    return ProviderParsed(response: response, output: output);
  }

  @override
  Stream<ProviderChunk> streamParser(
      Stream<String> raw, GenerationContext ctx) async* {
    // OpenAI streams Server-Sent Events where each line may be: 'data: {json}' or 'data: [DONE]'
    int idx = 0;
    await for (final chunk in raw) {
      for (final line in const LineSplitter().convert(chunk)) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;
        if (!trimmed.startsWith('data:')) continue;
        final dataStr = trimmed.substring(5).trim();
        if (dataStr == '[DONE]') {
          yield ProviderChunk(
              deltaText: null, index: idx, finishReason: 'stop');
          return;
        }
        try {
          final json = jsonDecode(dataStr);
          final choices = json['choices'];
          if (choices is List && choices.isNotEmpty) {
            final delta = choices.first['delta'];
            final text = delta != null ? (delta['content'] as String?) : null;
            final finish = choices.first['finish_reason'] as String?;
            if (text != null && text.isNotEmpty) {
              yield ProviderChunk(deltaText: text, index: idx++);
            }
            if (finish != null && finish.isNotEmpty) {
              yield ProviderChunk(
                  deltaText: null, index: idx, finishReason: finish);
              return;
            }
          }
        } catch (_) {
          // ignore malformed lines
        }
      }
    }
  }

  Map<String, dynamic> _tryDecodeJson(String schema) {
    try {
      final decoded = jsonDecode(schema);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  @override
  Future<List<int>> generateEmbedding(
      {required String text,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing OpenAI credential for embedding');
    }
    return DataRepository.instance
        .openAIEmbeddingBytes(apiKey: credential, model: model, input: text);
  }

  @override
  Future<List<int>> generateImagePng(
      {required String prompt,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing OpenAI credential for image generation');
    }
    return DataRepository.instance
        .openAIImagePng(apiKey: credential, model: model, prompt: prompt);
  }
}
