import 'dart:convert';
import 'dart:async';
// Removed unused typed_data/io imports after refactor

import 'package:flutter_app_itse500/core/models/message_output.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

class GeminiAdapter implements ProviderAdapter {
  @override
  String get id => 'gemini';

  @override
  Set<Capability> get capabilities => {
        Capability.temperature,
        Capability.topP,
        Capability.topK,
        Capability.systemPrompt,
        Capability.structuredOutput,
        Capability.streaming,
        // Gemini generateContent supports multimodal (text+image) both input (vision) and output (image) when using
        // response modalities or image-gen models. Expose vision so attachments pass through builder.
        Capability.vision,
      };

  @override
  ProviderHttpRequest buildRequest(
      {required GenerationContext ctx, required bool stream}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (ctx.credential != null) 'x-goog-api-key': ctx.credential!,
    };
    final model = (ctx.model ?? ctx.request.requestModel ?? '')
        .replaceFirst('models/', '');
    final history =
        (ctx.request.requestChatMessages ?? const <Map<String, String>>[])
            .map((m) => {
                  'role': m['role'] == 'assistant' ? 'model' : 'user',
                  'parts': [
                    {'text': m['content'] ?? ''}
                  ]
                })
            .toList();
    // User message parts: text + optional images
    final userParts = <Map<String, dynamic>>[
      {'text': ctx.request.requestUserContent ?? ''}
    ];
    final atts = ctx.request.requestAttachments ?? const [];
    for (final a in atts) {
      if ((a['type'] == 'image') && (a['b64'] is String)) {
        userParts.add({
          'inline_data': {
            'mime_type': (a['mime'] as String?) ?? 'image/png',
            'data': a['b64']
          }
        });
      }
    }

    final isImageGenModel = model.toLowerCase().contains('image-generation');
    final body = <String, dynamic>{
      'contents': [
        ...history,
        {'role': 'user', 'parts': userParts}
      ],
      // NOTE: Preview image-generation models currently reject developer/system instructions.
      // Skip including systemInstruction for those to avoid 400: "Developer instruction is not enabled".
      if (!isImageGenModel &&
          (ctx.request.requestSystemPrompt ?? '').isNotEmpty)
        'system_instruction': {
          'parts': [
            {'text': ctx.request.requestSystemPrompt}
          ]
        },
      if (ctx.request.requestTemperature != null ||
          ctx.request.requestTopP != null ||
          ctx.request.requestTopK != null ||
          ctx.request.requestMaxTokens != null)
        'generationConfig': {
          if (ctx.request.requestTemperature != null)
            'temperature': ctx.request.requestTemperature,
          if (ctx.request.requestTopP != null) 'topP': ctx.request.requestTopP,
          if (ctx.request.requestTopK != null) 'topK': ctx.request.requestTopK,
          if (ctx.request.requestMaxTokens != null)
            'maxOutputTokens': ctx.request.requestMaxTokens,
        },
      if (ctx.request.requestUseStructuredOutput == true &&
          (ctx.request.requestStructuredSchema?.isNotEmpty ?? false))
        'response_mime_type': 'application/json',
      if (ctx.request.requestUseStructuredOutput == true &&
          (ctx.request.requestStructuredSchema?.isNotEmpty ?? false))
        'response_schema': _tryDecodeJson(ctx.request.requestStructuredSchema!),
    };
    // If model hints image generation (contains -image-generation) OR user explicitly included an image attachment
    // OR user text starts with an image directive, request TEXT+IMAGE modalities so Gemini can return inline image data.
    final lowerModel = model.toLowerCase();
    final contentL = (ctx.request.requestUserContent ?? '').toLowerCase();
    final promptImageHints = [
      '/img',
      '/image',
      'generate an image',
      'generate a picture',
      'create an image',
      'create a picture',
      'image of ',
      'picture of ',
      'render an image',
      'draw an image'
    ];
    bool hintMatch = promptImageHints.any((h) => contentL.contains(h));
    final wantsImageOut = lowerModel.contains('image-generation') ||
        lowerModel.contains('image_gen') ||
        lowerModel.contains('image-gen') ||
        hintMatch;
    // Vision input (image attachments) does NOT imply image output; leave response as TEXT unless explicitly image-gen.
    if (wantsImageOut) {
      body['generationConfig'] = {
        ...(body['generationConfig'] as Map<String, dynamic>? ?? const {}),
        'responseModalities': ['TEXT', 'IMAGE'],
      };
    }
    // Lightweight debug: log structure (sans API key) for image-gen requests to aid troubleshooting
    assert(() {
      if (isImageGenModel) {
        // ignore: avoid_print
        print('[GeminiAdapter] image-gen request body: ${jsonEncode({
              'contents': body['contents'],
              'generationConfig': body['generationConfig'],
              if (body.containsKey('system_instruction'))
                'system_instruction': body['system_instruction'],
            })}');
      }
      return true;
    }());
    // Also emit a non-assert debug line (asserts are stripped in release). Safe: omits API key.
    if (isImageGenModel) {
      // ignore: avoid_print
      print('[GeminiAdapter][debug] body(no-key) ${jsonEncode({
            'contents': body['contents'],
            'generationConfig': body['generationConfig'],
            if (body.containsKey('system_instruction'))
              'system_instruction': body['system_instruction'],
          })}');
    }
    // Use the streaming endpoint when stream is requested
    final endpoint = stream
        ? 'https://generativelanguage.googleapis.com/v1beta/models/$model:streamGenerateContent'
        : 'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent';
    return ProviderHttpRequest(url: endpoint, headers: headers, body: body);
  }

  @override
  ProviderParsed parseResponse(
      Map<String, dynamic> json, GenerationContext ctx) {
    final candidates = json['candidates'];
    final first =
        (candidates is List && candidates.isNotEmpty) ? candidates.first : null;
    String? text;
    List<Map<String, String>> images = [];
    if (first != null &&
        first['content'] != null &&
        first['content']['parts'] is List) {
      final parts = first['content']['parts'] as List;
      final buf = StringBuffer();
      for (final p in parts) {
        if (p is Map) {
          final t = p['text'];
          if (t is String) buf.write(t);
          // Support both snake_case (inline_data, mime_type) and camelCase (inlineData, mimeType)
          Map<String, dynamic>? inline = () {
            final snake = p['inline_data'];
            final camel = p['inlineData'];
            if (snake is Map<String, dynamic>)
              return Map<String, dynamic>.from(snake);
            if (camel is Map<String, dynamic>)
              return Map<String, dynamic>.from(camel);
            return null;
          }();
          if (inline != null) {
            // Some preview responses appear to nest another inlineData object (wrapper) – unwrap if present
            if (!inline.containsKey('data') && inline['inlineData'] is Map) {
              final nested = inline['inlineData'];
              if (nested is Map)
                inline = Map<String, dynamic>.from(
                    nested.map((k, v) => MapEntry(k.toString(), v)));
            }
            final mime =
                (inline['mime_type'] ?? inline['mimeType'])?.toString() ??
                    'image/png';
            final data = inline['data'];
            if (data is String && data.isNotEmpty) {
              images.add({'mime': mime, 'b64': data});
            }
          }
        }
      }
      text = buf.toString();
    }
    if (images.isNotEmpty) {
      // ignore: avoid_print
      print(
          '[GeminiAdapter][debug] parsed ${images.length} image(s) from response');
    }
    final response = MessageResponse(
      responseId: '',
      modelname: ctx.model ?? ctx.request.requestModel,
      createdAt: DateTime.now(),
      status: 'completed',
      error: null,
    );
    // If images were returned inline, append an annotation JSON listing them (UI can later decode & persist).
    final annotations =
        images.isNotEmpty ? jsonEncode({'images': images}) : null;
    final output = MessageOutput(
      outputType: images.isNotEmpty ? 'multimodal' : 'text',
      outputId: '',
      outputStatus: 'completed',
      outputRole: 'assistant',
      outputContentType: 'text',
      outputContentText:
          text ?? (images.isNotEmpty ? '[Image generated]' : 'No response'),
      outputContentAnnotations: annotations,
    );
    return ProviderParsed(response: response, output: output);
  }

  @override
  Stream<ProviderChunk> streamParser(
      Stream<String> raw, GenerationContext ctx) async* {
    // Gemini's streaming returns a sequence of JSON objects (server-streamed) that may
    // be separated by newlines or chunk boundaries. We'll implement a tolerant
    // object segmenter that extracts complete JSON objects and yields any text parts.
    int idx = 0;
    final StringBuffer buffer = StringBuffer();

    // Helper to drain complete JSON objects from buffer (brace-balanced, quote-aware)
    Iterable<Map<String, dynamic>> drainObjects() sync* {
      final s = buffer.toString();
      int depth = 0;
      bool inStr = false;
      bool esc = false;
      int start = -1;
      for (int i = 0; i < s.length; i++) {
        final c = s.codeUnitAt(i);
        if (inStr) {
          if (esc) {
            esc = false;
          } else if (c == 0x5C) {
            // '\\'
            esc = true;
          } else if (c == 0x22) {
            // '"'
            inStr = false;
          }
          continue;
        }
        if (c == 0x22) {
          // '"'
          inStr = true;
          continue;
        }
        if (c == 0x7B) {
          // '{'
          if (depth == 0) start = i;
          depth++;
        } else if (c == 0x7D) {
          // '}'
          depth--;
          if (depth == 0 && start != -1) {
            final objStr = s.substring(start, i + 1);
            try {
              final obj = jsonDecode(objStr);
              if (obj is Map<String, dynamic>) {
                yield obj;
              }
            } catch (_) {
              // ignore malformed slice
            }
            // Remove consumed part and restart scanning from beginning
            final remaining = s.substring(i + 1);
            buffer
              ..clear()
              ..write(remaining);
            // Re-run draining on the updated buffer
            yield* drainObjects();
            return;
          }
        }
      }
    }

    await for (final chunk in raw) {
      // Some backends prefix SSE-style lines with 'data:'. Strip those markers line-wise.
      final normalized = chunk
          .split('\n')
          .map((l) => l.trimLeft().startsWith('data:')
              ? l.trimLeft().substring(5).trimLeft()
              : l)
          .join('\n');
      buffer.write(normalized);
      for (final data in drainObjects()) {
        // Extract text from candidates[0].content.parts[].text
        try {
          if (data['candidates'] is List &&
              (data['candidates'] as List).isNotEmpty) {
            final cand = (data['candidates'] as List).first;
            String buf = '';
            if (cand is Map &&
                cand['content'] is Map &&
                cand['content']['parts'] is List) {
              for (final p in cand['content']['parts']) {
                if (p is Map && p['text'] is String) buf += p['text'] as String;
              }
            }
            if (buf.isNotEmpty) {
              yield ProviderChunk(deltaText: buf, index: idx++);
            }
          }
          // Optionally detect finish conditions if present
          if (data['promptFeedback'] != null) {
            // When promptFeedback arrives at end, signal finish
            yield ProviderChunk(
                deltaText: null, index: idx, finishReason: 'stop');
          }
        } catch (_) {
          // ignore per-object parse issues
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

  // Phase 0 stubs for embedding and image generation until real Gemini endpoints are wired.
  @override
  Future<List<int>> generateEmbedding(
      {required String text,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing Gemini credential for embedding');
    }
    return DataRepository.instance
        .geminiEmbeddingBytes(apiKey: credential, model: model, input: text);
  }

  @override
  Future<List<int>> generateImagePng(
      {required String prompt,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing Gemini credential for image generation');
    }
    final repo = DataRepository.instance;
    final bytes = await repo.geminiImagePng(
        apiKey: credential, model: model, prompt: prompt);
    return bytes;
  }
}
