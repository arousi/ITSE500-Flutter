/// Shared secret-redaction utility used by [UnifiedLogger] and
/// [StructuredLogger] so the sensitive-key set and value-pattern scrubbing
/// live in exactly one place instead of being duplicated (and drifting)
/// across both loggers.
class LogRedaction {
  LogRedaction._();

  /// Payload/context keys whose value is always fully redacted, regardless
  /// of what it looks like.
  static const sensitiveKeys = {
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

  // Matches "Bearer <token>" (case-insensitive) so secrets interpolated
  // directly into a log message/URL string are scrubbed too, not just
  // structured map payloads keyed by a sensitive key name.
  static final RegExp _bearerPattern =
      RegExp(r'Bearer\s+\S+', caseSensitive: false);

  // Common raw provider API key prefixes: OpenAI/OpenRouter ("sk-..."),
  // Google ("AIza..."), Hugging Face ("hf_...").
  static final RegExp _rawKeyPattern = RegExp(
      r'\b(sk-[A-Za-z0-9_-]{6,}|AIza[A-Za-z0-9_-]{10,}|hf_[A-Za-z0-9]{6,})\b');

  // Matches a "key=" (or "api_key=", "apikey=", "token=", "access_token=")
  // query-string parameter value, e.g. the Gemini
  // "...models/gemini-pro:generateContent?key=AIza..." pattern, so a raw
  // secret embedded in a URL's query string is scrubbed even when it
  // doesn't match one of the known provider key-prefix shapes above.
  static final RegExp _queryKeyPattern = RegExp(
      r'([?&](?:key|api_key|apikey|token|access_token)=)[^&\s]+',
      caseSensitive: false);

  /// Redacts secrets found *inside* a free-form string (log message, error
  /// text, stack trace, or URL) — as opposed to [redactMap], which redacts
  /// by key name.
  static String redactString(String input) {
    return input
        .replaceAll(_bearerPattern, 'Bearer ***')
        .replaceAllMapped(_queryKeyPattern, (m) => '${m.group(1)}***')
        .replaceAll(_rawKeyPattern, '***');
  }

  /// Recursively redacts a context/payload map: fully redacts values whose
  /// key is in [sensitiveKeys] (case-insensitive), and runs [redactString]
  /// over every other string value (including a top-level `url` value) so
  /// secrets embedded in non-key-named fields are still caught.
  static Map<String, dynamic> redactMap(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((k, v) {
      if (sensitiveKeys.contains(k.toString().toLowerCase())) {
        out[k] = '***';
      } else if (v is Map<String, dynamic>) {
        out[k] = redactMap(v);
      } else if (v is List) {
        out[k] = v
            .map((e) => e is Map<String, dynamic>
                ? redactMap(e)
                : (e is String ? redactString(e) : e))
            .toList();
      } else if (v is String) {
        out[k] = redactString(v);
      } else {
        out[k] = v;
      }
    });
    return out;
  }
}
