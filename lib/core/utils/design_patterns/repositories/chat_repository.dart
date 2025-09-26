import 'package:flutter_app_itse500/core/utils/design_patterns/repositories/data_repository.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/adapters/provider_adapter.dart';
import 'package:flutter_app_itse500/core/utils/design_patterns/factories/provider_adapter_factory.dart';
import 'package:flutter_app_itse500/core/utils/structured_logger.dart';

class ChatRepository {
  final DataRepository _data;
  final ProviderAdapterFactory _factory;

  ChatRepository(
      {DataRepository? dataRepository, ProviderAdapterFactory? factory})
      : _data = dataRepository ?? DataRepository(),
        _factory = factory ?? ProviderAdapterFactory();

  Future<ProviderParsed> sendOnce({
    required ProviderId providerId,
    required GenerationContext ctx,
    bool stream = false,
  }) async {
    final adapter = _factory.forProvider(providerId);
    final req = adapter.buildRequest(ctx: ctx, stream: stream);
    try {
      final t0 = DateTime.now();
      await StructuredLogger.instance.log(
        'llm.request',
        {
          'headers': req.headers,
          'body': req.body,
        },
        category: 'llm',
        className: 'ChatRepository',
        methodName: 'sendOnce',
        providerId: providerId.toString(),
        model: ctx.model,
        requestId: ctx.requestId,
        conversationId: ctx.conversationId,
        phase: 'send',
        url: req.url,
      );
      final resp = await _data.sendLlmRequest(
          url: req.url, headers: req.headers, body: req.body);
      final data = (resp['data'] as Map<String, dynamic>);
      final dt = DateTime.now().difference(t0).inMilliseconds;
      await StructuredLogger.instance.log(
        'llm.response',
        {
          'sample_keys': data.keys.take(5).toList(),
        },
        category: 'llm',
        className: 'ChatRepository',
        methodName: 'sendOnce',
        providerId: providerId.toString(),
        model: ctx.model,
        requestId: ctx.requestId,
        conversationId: ctx.conversationId,
        phase: 'parse',
        status: 'ok',
        durationMs: dt,
        url: req.url,
      );
      return adapter.parseResponse(data, ctx);
    } catch (e) {
      await StructuredLogger.instance.log(
        'llm.error',
        {
          'error': e.toString(),
        },
        category: 'llm',
        className: 'ChatRepository',
        methodName: 'sendOnce',
        providerId: providerId.toString(),
        model: ctx.model,
        requestId: ctx.requestId,
        conversationId: ctx.conversationId,
        phase: 'error',
        status: 'error',
        url: req.url,
      );
      await _data.logError('ChatRepository.sendOnce error: $e');
      rethrow;
    }
  }

  /// Streaming API: builds a streaming request and returns provider-parsed chunks
  Stream<ProviderChunk> sendStream({
    required ProviderId providerId,
    required GenerationContext ctx,
  }) async* {
    final adapter = _factory.forProvider(providerId);
    final req = adapter.buildRequest(ctx: ctx, stream: true);
    try {
      await StructuredLogger.instance.log(
        'llm.stream.start',
        {
          'headers': req.headers,
          'body': req.body,
        },
        category: 'llm',
        className: 'ChatRepository',
        methodName: 'sendStream',
        providerId: providerId.toString(),
        model: ctx.model,
        requestId: ctx.requestId,
        conversationId: ctx.conversationId,
        phase: 'send',
        url: req.url,
      );
      final raw = _data.sendLlmRequestStream(
          url: req.url, headers: req.headers, body: req.body);
      yield* adapter.streamParser(raw, ctx);
      await StructuredLogger.instance.log(
        'llm.stream.end',
        {},
        category: 'llm',
        className: 'ChatRepository',
        methodName: 'sendStream',
        providerId: providerId.toString(),
        model: ctx.model,
        requestId: ctx.requestId,
        conversationId: ctx.conversationId,
        phase: 'end',
        status: 'ok',
        url: req.url,
      );
    } catch (e) {
      await StructuredLogger.instance.log(
        'llm.stream.error',
        {
          'error': e.toString(),
        },
        category: 'llm',
        className: 'ChatRepository',
        methodName: 'sendStream',
        providerId: providerId.toString(),
        model: ctx.model,
        requestId: ctx.requestId,
        conversationId: ctx.conversationId,
        phase: 'error',
        status: 'error',
        url: req.url,
      );
      await _data.logError('ChatRepository.sendStream error: $e');
      rethrow;
    }
  }
}
