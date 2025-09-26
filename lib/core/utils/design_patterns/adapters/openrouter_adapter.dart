import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_app_itse500/core/models/message_output.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

class OpenRouterAdapter implements ProviderAdapter {
  @override
  String get id => 'openrouter';

  @override
  Set<Capability> get capabilities => {
        Capability.temperature,
        Capability.topP,
        Capability.systemPrompt,
        Capability.streaming,
      };

  @override
  ProviderHttpRequest buildRequest(
      {required GenerationContext ctx, required bool stream}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (ctx.credential != null) 'Authorization': 'Bearer ${ctx.credential}',
    };
    final req = ctx.request;
    final hist = (req.requestChatMessages ?? const <Map<String, String>>[])
        .map(
            (m) => {'role': m['role'] ?? 'user', 'content': m['content'] ?? ''})
        .toList();

    // Multimodal user content if attachments exist
    dynamic userContent;
    final atts = req.requestAttachments ?? const [];
    if (atts.isNotEmpty) {
      final parts = <Map<String, dynamic>>[];
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
        ...hist,
        {'role': req.requestUserRole ?? 'user', 'content': userContent},
      ],
      if (req.requestTemperature != null) 'temperature': req.requestTemperature,
      if (req.requestTopP != null) 'top_p': req.requestTopP,
      if (req.requestMaxTokens != null) 'max_tokens': req.requestMaxTokens,
      'stream': stream,
    };
    return ProviderHttpRequest(
      url: 'https://openrouter.ai/api/v1/chat/completions',
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
      createdAt: DateTime.now(),
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
    int idx = 0;
    await for (final chunk in raw) {
      for (final line in chunk.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) continue;
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
          // ignore
        }
      }
    }
  }

  // Phase 0 stub implementations for artifact generation. Replace with real OpenRouter endpoints if/when available.
  @override
  Future<List<int>> generateEmbedding(
      {required String text,
      required String model,
      required String? credential}) async {
    // Simple deterministic pseudo-embedding: UTF8 bytes truncated/padded.
    final bytes = utf8.encode(text);
    const fixedLen = 128;
    final out = List<int>.filled(fixedLen * 4, 0);
    for (int i = 0; i < fixedLen; i++) {
      final b = i < bytes.length ? bytes[i] : (i & 0xFF);
      // Write little-endian float (b / 255.0)
      final val = (b / 255.0);
      final byteData = ByteData(4);
      byteData.setFloat32(0, val, Endian.little);
      out.setRange(i * 4, i * 4 + 4, byteData.buffer.asUint8List());
    }
    return out;
  }

  @override
  Future<List<int>> generateImagePng(
      {required String prompt,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing OpenRouter credential for image generation');
    }
    // Use DataRepository -> ApiService unified generation endpoint
    // Temporarily using ApiService openRouterImagePng via repository (not yet added to adapter imports)
    // We'll import DataRepository above.
    final repo = DataRepository();
    final bytes = await repo.openRouterImagePng(
        apiKey: credential, model: model, prompt: prompt);
    return bytes;
  }
}
