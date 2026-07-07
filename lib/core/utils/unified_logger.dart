import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:logger/logger.dart' as rt;

import 'log_redaction.dart';
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

  @visibleForTesting
  String redactStringForTest(String input) => _redactString(input);

  @visibleForTesting
  Map<String, dynamic> redactCtxForTest(Map<String, dynamic> ctx) =>
      _redactCtx(ctx);

  String _redactString(String input) => LogRedaction.redactString(input);

  Map<String, dynamic> _redactCtx(Map<String, dynamic> ctx) =>
      LogRedaction.redactMap(ctx);

  /// Redacts an [error] object before it reaches the console printer or the
  /// JSONL file. The `logger` package's pretty printer calls `.toString()`
  /// on the raw error object internally, so passing it through unredacted
  /// would leak a token embedded in an exception message even though the
  /// log *message* string was already scrubbed. Returns `null` for a null
  /// input, otherwise a plain redacted string standing in for the error.
  Object? _redactError(Object? error) {
    if (error == null) return null;
    return _redactString(error.toString());
  }

  /// Redacts a [stack] trace's string form. Stack traces are usually just
  /// file/line data, but treat them the same as any other free-form string
  /// on the (rare) chance a token ended up embedded via string
  /// interpolation in a rethrow.
  String? _redactStack(StackTrace? stack) {
    if (stack == null) return null;
    return _redactString(stack.toString());
  }

  // Convenience severity methods -------------------------------------------------
  Future<void> d(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    final safeMessage = _redactString(message);
    final safeCtx = ctx != null ? _redactCtx(ctx) : null;
    final safeError = _redactError(error);
    final safeStack = _redactStack(stack);
    _console.d(safeMessage, error: safeError);
    await _file('debug', safeMessage,
        error: safeError, stack: safeStack, ctx: safeCtx);
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
    final safeError = _redactError(error);
    final safeStack = _redactStack(stack);
    _console.w(safeMessage, error: safeError);
    await _file('warn', safeMessage,
        error: safeError, stack: safeStack, ctx: safeCtx);
  }

  Future<void> e(String message,
      {Object? error, StackTrace? stack, Map<String, dynamic>? ctx}) async {
    final safeMessage = _redactString(message);
    final safeCtx = ctx != null ? _redactCtx(ctx) : null;
    final safeError = _redactError(error);
    final safeStack = _redactStack(stack);
    _console.e(safeMessage, error: safeError);
    await _file('error', safeMessage,
        error: safeError, stack: safeStack, ctx: safeCtx);
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

  // Internal helper to write to structured log. [error] and [stack] must
  // already be redacted strings by the time they reach here (see
  // _redactError/_redactStack) — this only assembles the JSONL payload.
  Future<void> _file(String level, String message,
      {Object? error, String? stack, Map<String, dynamic>? ctx}) {
    final payload = {
      'level': level,
      'message': message,
      if (error != null) 'error': error.toString(),
      if (stack != null) 'stack': stack,
      if (ctx != null) ...ctx,
    };
    return StructuredLogger.instance.log(
      'log',
      payload,
      category: level,
    );
  }
}
