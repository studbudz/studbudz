import 'package:flutter/material.dart';

// A singleton class for managing the application's color scheme and theme mode (light/dark).
// Provides color schemes and ThemeData for both dark and light modes.
// Supports toggling between dark and light themes at runtime.
//

class CustomTheme {
  // Singleton instance
  static final CustomTheme _instance = CustomTheme._internal();

  // Private constructor for singleton pattern
  CustomTheme._internal();

  // Factory constructor returns the singleton instance
  factory CustomTheme() {
    return _instance;
  }

  bool _isDark = false; // Tracks the current theme mode

  // Returns true if the current theme is dark.
  bool get isDark => _isDark;

  // Toggles the theme mode.
  // If [isDark] is provided, sets the theme to that value.
  // Otherwise, toggles between dark and light.
  void toggleTheme([bool? isDark]) {
    if (isDark == null) {
      _isDark = !_isDark;
    } else {
      _isDark = isDark;
    }
  }

  // Color scheme definitions for dark and light themes.
  // See comments for color usage breakdown:
  // - 60% Dominant (base grays), 30% Secondary (contrast), 10% Accent (highlight)

  // Returns the current ColorScheme based on [_isDark].
  ColorScheme get colorScheme => _isDark
      ? const ColorScheme.dark(
          primary: Color(0xFF2F3640), // Button text color
          primaryContainer: Color(0xFF353B48), // Button background
          secondary: Color(0xFF00B894), // Teal accent
          tertiary: Color(0xFF00BFFF), // Sky blue accent
          error: Color(0xFFD63031), // Crimson accent
          surface: Color(0xFF121212), // General background
          onSurface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        )
      : const ColorScheme.light(
          primary: Color(0xFFD1C9BE), // Used for "forgot password"
          primaryContainer: Color(0xFFCBC5B6), // Sign in button
          secondary: Color(0xFFFF466A), // Pink accent
          tertiary: Color(0xFFFF4000), // Orange accent
          error: Color(0xFF28CECF), // Teal accent (used as error here)
          surface: Colors.white,
          onSurface: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
        );

  // Returns the current ThemeData for the application.
  // Configures button styles and color scheme according to [_isDark].
  ThemeData get theme => ThemeData(
      brightness: _isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.primaryContainer,
        ),
      ));
}
