/// Result of validating a provider API key / endpoint.
///
/// Distinguishes an actually-invalid credential from a transient failure
/// (network error, CORS failure, timeout, rate limit, upstream 5xx) so the
/// UI can show "Invalid key" vs. "Unreachable — retry" instead of a single
/// generic red "Disconnected" for both cases.
enum ProviderCheckStatus {
  /// Credential validated successfully (HTTP 200 + expected payload shape).
  valid,

  /// The provider rejected the credential itself (HTTP 401/403).
  invalidKey,

  /// The check could not be completed for a reason unrelated to the
  /// credential's validity — network error, CORS failure, timeout, 429
  /// rate limit, or a 5xx from the provider. Safe to retry.
  unreachable,
}
