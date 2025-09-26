// import 'package:flutter/material.dart';
// import 'colors.dart';
//
//
// final profileTheme1 = ThemeData(
//   primaryColor: profileTheme1MainColor,
//   colorScheme: ColorScheme.light(
//     primary: profileTheme1MainColor,
//     secondary: profileTheme1SecColor,
//   ),
//
//   scaffoldBackgroundColor: profileTheme1BgColor,
//   // ... other theme properties ...
//   textTheme: TextTheme(
//     bodyMedium: TextStyle(color: Colors.black), // Full black for text// ... other text styles ...
//   ),
//   navigationBarTheme: NavigationBarThemeData(backgroundColor: profileTheme1MainColor),
// );
//
//
// final profileTheme2 = ThemeData(
//   primaryColor: profileTheme2MainColor,
//   // ... other theme properties ...
// );
//
// final profileTheme3 = ThemeData(
//   primaryColor: profileTheme3MainColor,
//   // ... other theme properties ...
// );
import 'package:flutter/material.dart';

// App palette (100% opacity)
const Color appBackgroundColor = Color(0xFFFFFAFA); // Background: #FFFAFA
const Color appBarColor =
    Color(0xFF1C1B1F); // AppBar / Continue as Guest: #1C1B1F
const Color logoutButtonColor = Color(0xFFC22527); // Logout button: #C22527
const Color deleteArchiveColor = Color(0xFFDC8A1F); // Delete/Archive: #DC8A1F
const Color primaryAppColor = Color(0xFF1976D2); // Primary: #1976D2
const Color socialButtonColor = Color(0xFF064482); // Social buttons: #064482
const Color continueAsGuestColor =
    Color(0xFF1C1B1F); // Continue as Guest: #1C1B1F
const Color userBubbleBgColor = Color(0xFFE5E5E5); // User bubble bg: #E5E5E5
const Color assistantBubbleBgColor =
    Color(0xFF717171); // Assistant bubble bg: #717171

// Light Themes
final profileTheme1Light = ThemeData(
  brightness: Brightness.light,
  primaryColor: primaryAppColor,
  colorScheme: const ColorScheme.light(
    primary: primaryAppColor,
    secondary: socialButtonColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: appBackgroundColor,
    onSurface: Colors.black,
  ),
  scaffoldBackgroundColor: appBackgroundColor,
  appBarTheme: const AppBarTheme(
      backgroundColor: appBarColor, foregroundColor: Colors.white),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.black),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: appBarColor,
  ),
  // Common actions colors available via extensions or direct usage
  // Example usage: ElevatedButton.styleFrom(backgroundColor: primaryAppColor)
);

// Dark Themes
final profileTheme1Dark = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryAppColor,
  colorScheme: const ColorScheme.dark(
    primary: primaryAppColor,
    secondary: socialButtonColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: appBarColor,
    onSurface: Colors.white,
  ).copyWith(
    surface: appBarColor,
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: appBarColor,
  appBarTheme: const AppBarTheme(
      backgroundColor: appBarColor, foregroundColor: Colors.white),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: Colors.white),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: appBarColor,
  ),
);
