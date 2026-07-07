import 'dart:convert';

import 'package:flutter_app_itse500/core/models/message_output.dart';
import 'package:flutter_app_itse500/core/models/message_response.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';

class HuggingFaceAdapter implements ProviderAdapter {
  @override
  String get id => 'huggingface';

  @override
  Set<Capability> get capabilities => {
        Capability.temperature,
        Capability.topP,
        Capability.systemPrompt,
      };

  @override
  ProviderHttpRequest buildRequest(
      {required GenerationContext ctx, required bool stream}) {
    // Switch to Hugging Face chat/completions style endpoint for chat-capable models.
    // We intentionally do NOT yet support image URL / inline image parts for HF VLM here
    // (attachments are ignored) per current implementation scope.
    final req = ctx.request;
    final rawModel = (ctx.model ?? req.requestModel) ?? '';
    final encodedModel =
        rawModel.split('/').map((seg) => Uri.encodeComponent(seg)).join('/');

    // History: convert existing stored messages to HF chat format
    final history = (req.requestChatMessages ??
            const <Map<String, String>>[]) // prior turns
        .where((m) => (m['content'] ?? '').trim().isNotEmpty)
        .map((m) => {
              'role': (m['role'] ?? 'user'),
              // HF chat/completions accepts simple string content OR structured parts
              'content': (m['content'] ?? '').trim(),
            })
        .toList();

    // System prompt (if any) goes first
    if ((req.requestSystemPrompt ?? '').trim().isNotEmpty) {
      history.insert(0, {
        'role': 'system',
        'content': req.requestSystemPrompt!.trim(),
      });
    }

    // Current user message
    final userContent = (req.requestUserContent ?? '').trim();
    history.add({
      'role': req.requestUserRole ?? 'user',
      'content': userContent.isEmpty ? 'Hello' : userContent,
    });

    final body = <String, dynamic>{
      'model': rawModel, // some HF examples include model field; safe to echo
      'messages': history,
      if (req.requestTemperature != null) 'temperature': req.requestTemperature,
      if (req.requestTopP != null) 'top_p': req.requestTopP,
      if (req.requestMaxTokens != null) 'max_tokens': req.requestMaxTokens,
      'stream': false, // streaming disabled for HF in current integration
    };

    return ProviderHttpRequest(
      url:
          'https://api-inference.huggingface.co/models/$encodedModel/chat/completions',
      headers: {
        'Content-Type': 'application/json',
        if (ctx.credential != null && ctx.credential!.isNotEmpty)
          'Authorization': 'Bearer ${ctx.credential}',
      },
      body: body,
      timeout: const Duration(seconds: 60),
    );
  }

  @override
  ProviderParsed parseResponse(
      Map<String, dynamic> json, GenerationContext ctx) {
    String content = '';
    // Chat/completions shape: choices -> message -> content
    if (json['choices'] is List && (json['choices'] as List).isNotEmpty) {
      final first = (json['choices'] as List).first;
      if (first is Map) {
        final msg = first['message'];
        if (msg is Map && msg['content'] is String) {
          content = msg['content'];
        } else if (first['text'] is String) {
          // fallback older text field
          content = first['text'];
        }
      }
    }
    // Legacy /models response fallbacks
    if (content.isEmpty && json['generated_text'] is String) {
      content = json['generated_text'];
    } else if (content.isEmpty && json['outputs'] is List) {
      final first = (json['outputs'] as List).firstOrNull;
      if (first is Map && first['generated_text'] is String) {
        content = first['generated_text'];
      }
    } else if (content.isEmpty && json['data'] is List) {
      final first = (json['data'] as List).firstOrNull;
      if (first is Map && first['generated_text'] is String) {
        content = first['generated_text'];
      }
    }
    if (content.isEmpty && json['raw'] is String) {
      try {
        final parsed = jsonDecode(json['raw']);
        if (parsed is List && parsed.isNotEmpty) {
          final first = parsed.first;
          if (first is Map && first['generated_text'] is String) {
            content = first['generated_text'];
          }
        }
      } catch (_) {}
    }
    if (content.isEmpty && json.isNotEmpty) content = json.toString();
    final response = MessageResponse(
      responseId: json['id']?.toString() ?? ctx.requestId,
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
          content.trim().isEmpty ? 'No response' : content.trim(),
    );
    return ProviderParsed(response: response, output: output);
  }

  @override
  Future<List<int>> generateEmbedding(
      {required String text,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing HuggingFace credential for embedding');
    }
    return DataRepository.instance.huggingFaceEmbeddingBytes(
        apiKey: credential, model: model, input: text);
  }

  @override
  Future<List<int>> generateImagePng(
      {required String prompt,
      required String model,
      required String? credential}) async {
    if (credential == null || credential.isEmpty) {
      throw Exception('Missing HuggingFace credential for image generation');
    }
    return DataRepository.instance
        .huggingFaceImagePng(apiKey: credential, model: model, prompt: prompt);
  }

  // Hugging Face Inference API doesn't currently support our unified token streaming format
  // for the generic /models endpoint we use here. Some enterprise endpoints or future
  // Hugging Face streaming variants may emit JSON lines or partial objects. We implement
  // a tolerant parser that:
  // 1. Accepts SSE style lines beginning with 'data:' (ignores others).
  // 2. Buffers text until full JSON objects (maps or lists) are balanced (brace counting).
  // 3. Extracts 'generated_text' fields from maps or from first element in lists.
  // 4. Emits incremental deltas (difference since last emission) so downstream UI behaves
  //    similarly to OpenAI/Gemini adapters.
  // 5. On stream close, emits finishReason=stop if not already signaled.
  @override
  Stream<ProviderChunk> streamParser(
      Stream<String> raw, GenerationContext ctx) async* {
    int idx = 0;
    final buffer = StringBuffer();
    String accumulated = '';

    bool balanced(String s) {
      int depth = 0;
      bool inStr = false;
      bool esc = false;
      for (int i = 0; i < s.length; i++) {
        final c = s.codeUnitAt(i);
        if (inStr) {
          if (esc) {
            esc = false;
          } else if (c == 0x5C) {
            esc = true;
          } // '\\'
          else if (c == 0x22) {
            inStr = false;
          }
          continue;
        }
        if (c == 0x22) {
          inStr = true;
          continue;
        } // '"'
        if (c == 0x7B) {
          depth++;
        } // '{'
        else if (c == 0x7D) {
          depth--;
          if (depth < 0) depth = 0;
        } else if (c == 0x5B) {
          depth++;
        } // '['
        else if (c == 0x5D) {
          depth--;
          if (depth < 0) depth = 0;
        }
      }
      return depth == 0 && !inStr;
    }

    String extractText(dynamic decoded) {
      if (decoded is Map) {
        if (decoded['generated_text'] is String) {
          return decoded['generated_text'] as String;
        }
        // Some experimental endpoints wrap output under choices
        if (decoded['choices'] is List &&
            (decoded['choices'] as List).isNotEmpty) {
          final c0 = (decoded['choices'] as List).first;
          if (c0 is Map && c0['text'] is String) return c0['text'] as String;
        }
      } else if (decoded is List && decoded.isNotEmpty) {
        final first = decoded.first;
        if (first is Map && first['generated_text'] is String) {
          return first['generated_text'] as String;
        }
        if (first is Map && first['text'] is String) {
          return first['text'] as String;
        }
      }
      return '';
    }

    Iterable<ProviderChunk> flushBuffer() sync* {
      final s = buffer.toString().trim();
      if (s.isEmpty) return;
      if (!balanced(s)) return; // wait for more
      buffer.clear();
      try {
        final decoded = jsonDecode(s);
        final text = extractText(decoded);
        if (text.isNotEmpty) {
          if (!text.startsWith(accumulated)) {
            final delta = text;
            accumulated = text;
            if (delta.isNotEmpty) {
              yield ProviderChunk(deltaText: delta, index: idx++);
            }
          } else {
            final delta = text.substring(accumulated.length);
            accumulated = text;
            if (delta.isNotEmpty) {
              yield ProviderChunk(deltaText: delta, index: idx++);
            }
          }
        }
      } catch (_) {
        if (s.isNotEmpty) {
          yield ProviderChunk(deltaText: s, index: idx++);
          accumulated += s;
        }
      }
    }

    try {
      await for (final chunk in raw) {
        for (final line in chunk.split('\n')) {
          var l = line.trim();
          if (l.isEmpty) continue;
          if (l.startsWith('data:')) {
            l = l.substring(5).trim();
            if (l == '[DONE]') {
              yield ProviderChunk(
                  deltaText: null, index: idx, finishReason: 'stop');
              return;
            }
          }
          buffer.write(l);
          // Attempt flush if balanced
          for (final c in flushBuffer()) {
            yield c;
          }
        }
      }
    } catch (_) {}
    // Final flush
    for (final c in flushBuffer()) {
      yield c;
    }
    yield ProviderChunk(deltaText: null, index: idx, finishReason: 'stop');
  }
}
