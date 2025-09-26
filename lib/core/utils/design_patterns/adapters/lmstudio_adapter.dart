import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_app_itse500/core/models/message_output.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';

class LMStudioAdapter implements ProviderAdapter {
  @override
  String get id => 'lmstudio';

  @override
  Set<Capability> get capabilities => {
        Capability.temperature,
        Capability.streaming,
        Capability.systemPrompt,
      };

  @override
  ProviderHttpRequest buildRequest(
      {required GenerationContext ctx, required bool stream}) {
    final req = ctx.request;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String base = (ctx.credential ?? '').trim();
    if (base.isEmpty) {
      base = 'http://10.0.2.2:1234/';
    }
    if (!base.endsWith('/')) base = '$base/';

    final bool openAiCompat = base.toLowerCase().contains('/v1/');
    final model = ctx.model ?? req.requestModel;

    if (openAiCompat) {
      final history = (req.requestChatMessages ?? const <Map<String, String>>[])
          .map((m) =>
              {'role': m['role'] ?? 'user', 'content': m['content'] ?? ''})
          .toList();
      final body = <String, dynamic>{
        'model': model,
        'messages': [
          if ((req.requestSystemPrompt ?? '').isNotEmpty)
            {'role': 'system', 'content': req.requestSystemPrompt},
          ...history,
          {
            'role': req.requestUserRole ?? 'user',
            'content': req.requestUserContent ?? ''
          },
        ],
        if (req.requestTemperature != null)
          'temperature': req.requestTemperature,
        if (req.requestTopP != null) 'top_p': req.requestTopP,
        if (req.requestMaxTokens != null) 'max_tokens': req.requestMaxTokens,
        'stream': stream,
      };
      return ProviderHttpRequest(
        url: '${base}chat/completions',
        headers: headers,
        body: body,
      );
    } else {
      // Legacy LM Studio: concatenate into a single prompt
      final buf = StringBuffer();
      if ((req.requestSystemPrompt ?? '').isNotEmpty) {
        buf.writeln('System: ${req.requestSystemPrompt}');
        buf.writeln();
      }
      for (final m
          in (req.requestChatMessages ?? const <Map<String, String>>[])) {
        final role = (m['role'] == 'assistant') ? 'Assistant' : 'User';
        final content = (m['content'] ?? '').trim();
        if (content.isEmpty) continue;
        buf.writeln('$role: $content');
      }
      final userText = req.requestUserContent ?? '';
      buf.writeln('User: $userText');

      final body = <String, dynamic>{
        'model': model,
        'prompt': buf.toString(),
        if (req.requestTemperature != null)
          'temperature': req.requestTemperature,
        if (req.requestMaxTokens != null) 'max_tokens': req.requestMaxTokens,
        'stream': stream,
      };
      return ProviderHttpRequest(
        url: '${base}api/v0/completions',
        headers: headers,
        body: body,
      );
    }
  }

  @override
  ProviderParsed parseResponse(
      Map<String, dynamic> json, GenerationContext ctx) {
    // Try multiple shapes
    String? text;

    // Legacy
    text = json['completion'] as String? ?? json['text'] as String?;
    // OpenAI chat
    if (text == null &&
        json['choices'] is List &&
        (json['choices'] as List).isNotEmpty) {
      final choice = (json['choices'] as List).first;
      text = (choice['text'] as String?) ??
          (choice['message'] is Map
              ? (choice['message']['content'] as String?)
              : null);
    }

    final response = MessageResponse(
      responseId: json['id']?.toString() ?? '',
      modelname: ctx.model ?? ctx.request.requestModel,
      createdAt: DateTime.now(),
      status: 'completed',
      error: null,
    );
    final output = MessageOutput(
      outputType: 'text',
      outputId: '',
      outputStatus: 'completed',
      outputRole: 'assistant',
      outputContentType: 'text',
      outputContentText:
          (text is String && text.isNotEmpty) ? text : 'No response',
    );
    return ProviderParsed(response: response, output: output);
  }

  @override
  Stream<ProviderChunk> streamParser(
      Stream<String> raw, GenerationContext ctx) async* {
    int idx = 0;
    await for (final chunk in raw) {
      for (final line in const LineSplitter().convert(chunk)) {
        final s = line.trim();
        if (s.isEmpty) continue;
        if (s == '[DONE]') {
          yield ProviderChunk(
              deltaText: null, index: idx, finishReason: 'stop');
          return;
        }
        final data = s.startsWith('data:') ? s.substring(5).trim() : s;
        try {
          final j = jsonDecode(data);
          if (j is Map) {
            // OpenAI chat delta
            if (j['choices'] is List && (j['choices'] as List).isNotEmpty) {
              final choice = (j['choices'] as List).first;
              final delta = (choice['delta'] as Map?) ?? {};
              final finish = choice['finish_reason'] as String?;
              final content =
                  (delta['content'] as String?) ?? (choice['text'] as String?);
              if (content != null && content.isNotEmpty) {
                yield ProviderChunk(deltaText: content, index: idx++);
              }
              if (finish != null && finish.isNotEmpty) {
                yield ProviderChunk(
                    deltaText: null, index: idx, finishReason: finish);
                return;
              }
              continue;
            }
            // Legacy text/completion key
            final t = j['text'] as String? ?? j['completion'] as String?;
            if (t != null && t.isNotEmpty) {
              yield ProviderChunk(deltaText: t, index: idx++);
            }
          }
        } catch (_) {
          // ignore malformed
        }
      }
    }
  }

  // Phase 0 stubs for artifact generation (local embeddings/images not yet implemented through LM Studio API here).
  @override
  Future<List<int>> generateEmbedding(
      {required String text,
      required String model,
      required String? credential}) async {
    final bytes = utf8.encode(text);
    const fixedLen = 64;
    final out = List<int>.filled(fixedLen * 4, 0);
    for (int i = 0; i < fixedLen; i++) {
      final b = i < bytes.length ? bytes[i] : (255 - (i & 0xFF));
      final val = b / 255.0;
      final bd = ByteData(4);
      bd.setFloat32(0, val, Endian.little);
      out.setRange(i * 4, i * 4 + 4, bd.buffer.asUint8List());
    }
    return out;
  }

  @override
  Future<List<int>> generateImagePng(
      {required String prompt,
      required String model,
      required String? credential}) async {
    return const <int>[
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      12,
      73,
      68,
      65,
      84,
      120,
      156,
      99,
      96,
      0,
      0,
      0,
      2,
      0,
      1,
      226,
      33,
      185,
      148,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130
    ];
  }
}
