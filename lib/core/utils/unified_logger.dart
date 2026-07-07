import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logger/logger.dart' as rt;

import 'structured_logger.dart';

/// Unified logger that mirrors logs to runtime console and structured JSONL files.
/// Use this everywhere instead of creating ad-hoc Logger() or manual file writes.
class UnifiedLogger {
  UnifiedLogger._internal()
      : _console = rt.Logger(
          printer: rt.PrettyPrinter(
            methodCount: 0,
            errorMethodCount: 8,
            lineLength: 100,
            colors: true,
            printEmojis: true,
            dateTimeFormat: rt.DateTimeFormat.dateAndTime,
          ),
        );

  static final UnifiedLogger instance = UnifiedLogger._internal();

  final rt.Logger _console;

  static const _sensitiveKeys = {
    'authorization',
    'api_key',
    'api-key',
    'x-api-key',
    'x-goog-api-key',
    'openai-api-key',
    'openrouter-api-key',
    'access_token',
    'refresh_token',
  };

  // Matches "Bearer <token>" (case-insensitive) and common raw provider API
  // key prefixes (OpenAI/OpenRouter "sk-...", Google "AIza...") so secrets
  // interpolated directly into a log message string are still scrubbed
  // before hitting the console, not just structured map payloads.
  static final RegExp _bearerPattern =
      RegExp(r'Bearer\s+\S+', caseSensitive: false);
  static final RegExp _rawKeyPattern =
      RegExp(r'\b(sk-[A-Za-z0-9_-]{6,}|AIza[A-Za-z0-9_-]{10,})\b');

  @visibleForTesting
  String redactStringForTest(String input) => _redactString(input);

  @visibleForTesting
  Map<String, dynamic> redactCtxForTest(Map<String, dynamic> ctx) =>
      _redactCtx(ctx);

  String _redactString(String input) {
    return input
        .replaceAll(_bearerPattern, 'Bearer ***')
        .replaceAll(_rawKeyPattern, '***');
  }

  Map<String, dynamic> _redactCtx(Map<String, dynamic> ctx) {
    final out = <String, dynamic>{};
    ctx.forEach((k, v) {
      if (_sensitiveKeys.contains(k.toLowerCase())) {
        out[k] = '***';
      } else if (v is Map<String, dynamic>) {
        out[k] = _redactCtx(v);
      } else if (v is String) {
        out[k] = _redactString(v);
      } else {
        out[k] = v;
      }
    });
    return out;
  }

  // Convenience severity methods -------------------------------------------------
  Future<void> d(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    final safeMessage = _redactString(message);
    final safeCtx = ctx != null ? _redactCtx(ctx) : null;
    _console.d(safeMessage, error: error, stackTrace: stack);
    await _file('debug', safeMessage, error: error, stack: stack, ctx: safeCtx);
  }

  Future<void> i(String message, {Map<String, dynamic>? ctx}) async {
    final safeMessage = _redactString(message);
    final safeCtx = ctx != null ? _redactCtx(ctx) : null;
    _console.i(safeMessage);
    await _file('info', safeMessage, ctx: safeCtx);
  }

  Future<void> w(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    final safeMessage = _redactString(message);
    final safeCtx = ctx != null ? _redactCtx(ctx) : null;
    _console.w(safeMessage, error: error, stackTrace: stack);
    await _file('warn', safeMessage, error: error, stack: stack, ctx: safeCtx);
  }

  Future<void> e(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    final safeMessage = _redactString(message);
    final safeCtx = ctx != null ? _redactCtx(ctx) : null;
    _console.e(safeMessage, error: error, stackTrace: stack);
    await _file('error', safeMessage, error: error, stack: stack, ctx: safeCtx);
  }

  /// Structured event logging. Appears in both console and JSONL with metadata.
  Future<void> event(
    String event, {
    Map<String, dynamic> payload = const {},
    String? category,
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
    // Delegate pretty console + JSONL to StructuredLogger to avoid duplicates
    await StructuredLogger.instance.log(
      event,
      payload,
      category: category,
      className: className,
      methodName: methodName,
      conversationId: conversationId,
      messageId: messageId,
      requestId: requestId,
      responseId: responseId,
      outputId: outputId,
      providerId: providerId,
      model: model,
      phase: phase,
      status: status,
      httpStatus: httpStatus,
      durationMs: durationMs,
      url: url,
    );
  }

  Future<int> cleanOldLogs({int retainDays = 7}) {
    return StructuredLogger.instance.cleanOldLogs(retainDays: retainDays);
  }

  // Internal helper to write to structured log
  Future<void> _file(String level, String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) {
    final payload = {
      'level': level,
      'message': message,
      if (error != null) 'error': error.toString(),
      if (stack != null) 'stack': stack.toString(),
      if (ctx != null) ...ctx,
    };
    return StructuredLogger.instance.log(
      'log',
      payload,
      category: level,
    );
  }
}
