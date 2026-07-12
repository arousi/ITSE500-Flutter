import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Shared helper for computing the default primary API base URL.
///
/// On web, this app is served same-origin with its Django backend (e.g.
/// `https://itse500.swe.com.ly/app/` serving the SPA and
/// `https://itse500.swe.com.ly/api/v1/` serving the API), so the safest
/// default is same-origin `/api/v1/`. This avoids hardcoding any specific
/// domain and keeps staging/local-dev deployments working without a rebuild.
///
/// On non-web platforms (desktop/mobile), fall back to the configured
/// `PRIMARY_API_BASE` from `.env`, or the production domain as a last resort.
String defaultPrimaryApiBase() {
  if (kIsWeb) {
    try {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty) return '$origin/api/v1/';
    } catch (_) {
      // Fall through to the non-web default below.
    }
  }
  try {
    final envBase = dotenv.env['PRIMARY_API_BASE'];
    if (envBase != null && envBase.isNotEmpty) return envBase;
  } catch (_) {
    // dotenv not initialized (e.g. unit tests); fall through.
  }
  return 'https://itse500.swe.com.ly/api/v1/';
}
