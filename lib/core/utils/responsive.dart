import 'package:flutter/material.dart';

/// Canonical responsive breakpoints shared with the web app.
class Breakpoints {
  Breakpoints._();
  static const double sm480 = 480;
  static const double md768 = 768;
  static const double lg1024 = 1024;
  static const double xl1280 = 1280;
}

/// Convenience responsive helpers on [BuildContext].
extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;

  /// Small phones (< 480 logical px).
  bool get isSmallMobile => _width < Breakpoints.sm480;

  /// Below the tablet/desktop breakpoint (< 768 logical px).
  bool get isMobile => _width < Breakpoints.md768;

  /// Tablet range: [768, 1024).
  bool get isTablet =>
      _width >= Breakpoints.md768 && _width < Breakpoints.lg1024;

  /// Desktop range: >= 1024 logical px.
  bool get isDesktop => _width >= Breakpoints.lg1024;

  /// Wide desktop range: >= 1280 logical px.
  bool get isWideDesktop => _width >= Breakpoints.xl1280;

  /// A sensible max content width for centered forms/content on larger
  /// viewports, so content doesn't stretch edge-to-edge on desktop.
  double get maxContentWidth {
    if (isDesktop) return Breakpoints.xl1280;
    if (isTablet) return Breakpoints.lg1024;
    return _width;
  }
}
