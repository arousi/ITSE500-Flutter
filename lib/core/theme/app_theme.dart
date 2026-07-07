import 'package:flutter/material.dart';

class AppPalette extends ThemeExtension<AppPalette> {
  final Color primary; // buttons default, toggles
  final Color appBar;
  final Color logoutButton; // destructive primary
  final Color logoutBg; // background behind logout section
  final Color assistantBubble;
  final Color userBubble;
  final Color deleteArchive;
  final Color inputFill;

  const AppPalette({
    required this.primary,
    required this.appBar,
    required this.logoutButton,
    required this.logoutBg,
    required this.assistantBubble,
    required this.userBubble,
    required this.deleteArchive,
    required this.inputFill,
  });

  @override
  AppPalette copyWith({
    Color? primary,
    Color? appBar,
    Color? logoutButton,
    Color? logoutBg,
    Color? assistantBubble,
    Color? userBubble,
    Color? deleteArchive,
    Color? inputFill,
  }) =>
      AppPalette(
        primary: primary ?? this.primary,
        appBar: appBar ?? this.appBar,
        logoutButton: logoutButton ?? this.logoutButton,
        logoutBg: logoutBg ?? this.logoutBg,
        assistantBubble: assistantBubble ?? this.assistantBubble,
        userBubble: userBubble ?? this.userBubble,
        deleteArchive: deleteArchive ?? this.deleteArchive,
        inputFill: inputFill ?? this.inputFill,
      );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppPalette(
      primary: l(primary, other.primary),
      appBar: l(appBar, other.appBar),
      logoutButton: l(logoutButton, other.logoutButton),
      logoutBg: l(logoutBg, other.logoutBg),
      assistantBubble: l(assistantBubble, other.assistantBubble),
      userBubble: l(userBubble, other.userBubble),
      deleteArchive: l(deleteArchive, other.deleteArchive),
      inputFill: l(inputFill, other.inputFill),
    );
  }
}

// Hex helpers
const _kPrimary = Color(0xFF1976D2); // buttons & toggles
const _kAppBar = Color(0xFF393939);
const _kLogoutBtn = Color(0xFFC22527);
const _kLogoutBg = Color(0xFF1C1B1F);
const _kAssistantBubble = Color(0xFF717171);
const _kUserBubble = Color(0xFFE5E5E5);
const _kDeleteArchive = Color(0xFFDC8A1F);

ThemeData _buildTheme({required bool dark}) {
  final palette = AppPalette(
    primary: _kPrimary,
    appBar: _kAppBar,
    logoutButton: _kLogoutBtn,
    logoutBg: _kLogoutBg,
    assistantBubble: _kAssistantBubble,
    userBubble: _kUserBubble,
    deleteArchive: _kDeleteArchive,
    inputFill: dark ? const Color(0xFF2B2B2B) : const Color(0xFFF5F5F5),
  );

  final base = dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  final cs = ColorScheme.fromSeed(
    seedColor: _kPrimary,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: _kPrimary,
  );
  return base.copyWith(
    colorScheme: cs,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.appBar,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected) ? _kPrimary : null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? _kPrimary.withOpacity(0.5)
            : null;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _kPrimary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _kPrimary, width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.black87),
    ),
    extensions: [palette],
  );
}

final ThemeData customLightTheme = _buildTheme(dark: false);
final ThemeData customDarkTheme = _buildTheme(dark: true);
