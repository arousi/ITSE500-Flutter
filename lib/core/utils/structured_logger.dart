import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:logger/logger.dart' as rt;

import 'log_redaction.dart';

/// Minimal structured JSONL logger with daily JSONL files and redaction.
class StructuredLogger {
  StructuredLogger._();
  static final StructuredLogger instance = StructuredLogger._();
  final rt.Logger _console = rt.Logger(
    printer: rt.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: rt.DateTimeFormat.dateAndTime,
    ),
  );

  static const _filePrefix = 'app-telemetry';
  // One file per day, regardless of size — ensures a day's logs are in one file.
  Future<File> _resolveFile() async {
    final dir = await path_provider.getApplicationDocumentsDirectory();
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final base = File('${dir.path}/$_filePrefix-$y-$m-$d.jsonl');
    if (!await base.exists()) return base.create(recursive: true);
    return base;
  }

  Map<String, dynamic> _redact(Map<String, dynamic> m) =>
      LogRedaction.redactMap(m);

  /// Redacts a free-form string value (e.g. the `url` field, which is
  /// passed as a separate named parameter rather than through [_redact]'s
  /// map, and can carry a secret in its query string — e.g. Gemini's
  /// `...?key=<apiKey>`).
  String? _redactUrl(String? url) =>
      url == null ? null : LogRedaction.redactString(url);

  Future<void> log(
    String event,
    Map<String, dynamic> payload, {
    String? category,
    // correlation and context fields
    String? className,
    String? methodName,
    String? conversationId,
    String? messageId,
    String? requestId,
    String? responseId,
    String? outputId,
    String? providerId,
    String? model,
    String? phase,
    String? status,
    int? httpStatus,
    int? durationMs,
    String? url,
  }) async {
    try {
      final file = await _resolveFile();
      final redPayload = _redact(payload);
      final safeUrl = _redactUrl(url);
      final record = {
        'ts': DateTime.now().toIso8601String(),
        'event': event,
        if (category != null) 'category': category,
        'payload': redPayload,
        'platform': defaultTargetPlatform.toString(),
        if (className != null) 'class': className,
        if (methodName != null) 'method': methodName,
        if (conversationId != null) 'conversationId': conversationId,
        if (messageId != null) 'messageId': messageId,
        if (requestId != null) 'requestId': requestId,
        if (responseId != null) 'responseId': responseId,
        if (outputId != null) 'outputId': outputId,
        if (providerId != null) 'providerId': providerId,
        if (model != null) 'model': model,
        if (phase != null) 'phase': phase,
        if (status != null) 'status': status,
        if (httpStatus != null) 'httpStatus': httpStatus,
        if (durationMs != null) 'durationMs': durationMs,
        if (safeUrl != null) 'url': safeUrl,
      };
      // Pretty-print a concise line to runtime logs (suppress mirror 'log' noise)
      final isMirrorLog =
          event == 'log' && (category == 'info' || category == 'debug');
      if (!isMirrorLog) {
        final tagParts = <String?>[category, event, phase, status];
        final tag =
            tagParts.whereType<String>().where((s) => s.isNotEmpty).join(' | ');
        final dims = <String, dynamic>{
          if (httpStatus != null) 'http': httpStatus,
          if (durationMs != null) 'ms': durationMs,
          if (safeUrl != null) 'url': safeUrl,
        };
        final isError = (httpStatus != null && httpStatus >= 400) ||
            status == 'error' ||
            (category == 'error');

        // Header line
        if (isError) {
          _console.e(tag.isEmpty ? 'error' : tag);
        } else {
          _console.i(tag.isEmpty ? 'event' : tag);
        }

        // Dimensions line
        if (dims.isNotEmpty) {
          if (isError) {
            _console.w(dims);
          } else {
            _console.d(dims);
          }
        }

        // Extra details for errors: surface provider/model and a short error message snippet
        if (isError) {
          final details = <String, dynamic>{
            if (providerId != null) 'provider': providerId,
            if (model != null) 'model': model,
          };
          // Try to extract useful message from payload
          dynamic errObj;
          if (redPayload.containsKey('error')) {
            errObj = redPayload['error'];
          } else if (redPayload.containsKey('message')) {
            errObj = redPayload['message'];
          } else if (redPayload.containsKey('body')) {
            errObj = redPayload['body'];
          }
          String? snippet;
          if (errObj is String) {
            snippet = errObj;
          } else if (errObj is Map) {
            snippet = (errObj['message'] ?? errObj['error'] ?? '').toString();
          }
          if (snippet != null && snippet.isNotEmpty) {
            // clamp snippet length
            const maxLen = 400;
            if (snippet.length > maxLen) {
              snippet = '${snippet.substring(0, maxLen)}...';
            }
            details['detail'] = snippet;
          }
          if (details.isNotEmpty) {
            _console.w(details);
          }

          // Lightweight, provider-aware tip for common OpenAI 401/403/429 cases
          if ((url?.contains('api.openai.com') ?? false) &&
              httpStatus != null) {
            String? tip;
            if (httpStatus == 401) {
              tip = 'OpenAI 401 unauthorized — check API key and org header.';
            } else if (httpStatus == 403) {
              tip =
                  'OpenAI 403 forbidden — model access or policy restriction.';
            } else if (httpStatus == 429) {
              tip =
                  'OpenAI 429 rate/quota — top up billing or choose a lower-cost model (e.g., gpt-4o-mini).';
            }
            if (tip != null) {
              _console.w({'tip': tip});
            }
          }
        }
      }
      await file.writeAsString('${jsonEncode(record)}\n',
          mode: FileMode.append, flush: true);
    } catch (_) {
      // swallow logging errors
    }
  }

  /// Deletes telemetry files older than [retainDays].
  Future<int> cleanOldLogs({int retainDays = 7}) async {
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      final now = DateTime.now();
      final files = Directory(dir.path).listSync().whereType<File>();
      int deleted = 0;
      for (final f in files) {
        final name = f.uri.pathSegments.isNotEmpty
            ? f.uri.pathSegments.last
            : f.path.split(Platform.pathSeparator).last;
        final m = RegExp(
                '^${RegExp.escape(_filePrefix)}-(\\d{4})-(\\d{2})-(\\d{2})\\.jsonl')
            .firstMatch(name);
        if (m != null) {
          final y = int.tryParse(m.group(1)!);
          final mo = int.tryParse(m.group(2)!);
          final d = int.tryParse(m.group(3)!);
          if (y != null && mo != null && d != null) {
            final fileDate = DateTime(y, mo, d);
            if (now.difference(fileDate).inDays > retainDays) {
              try {
                await f.delete();
                deleted++;
              } catch (_) {}
            }
          }
        }
      }
      return deleted;
    } catch (_) {
      return 0;
    }
  }
}
