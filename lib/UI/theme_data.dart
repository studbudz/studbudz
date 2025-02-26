import 'package:flutter/material.dart';

class CustomTheme {
  static final CustomTheme _instance = CustomTheme._internal();

  CustomTheme._internal();

  factory CustomTheme() {
    return _instance;
  }

  bool _isDark = true;

  bool get isDark => _isDark;

  void toggleTheme([bool? isDark]) {
    if (isDark == null) {
      _isDark = !_isDark;
    } else {
      _isDark = isDark;
    }
  }

  // Dark theme
  // 60% (Dominant - Deep, Neutral Base) → Dark Grays (#2F3640, #353B48)
  // 30% (Secondary - Supporting Contrast) → Teal (#00B894) & Sky Blue (#00BFFF)
  // 10% (Accent - Bold Highlights) → Crimson (#D63031)

  // Light theme
  // 60% (Dominant - Deep, Neutral Base) → Light Grays (#d1c9be, #cbc5b6)
  // 30% (Secondary - Supporting Contrast) → Pink (#ff466a) & Orange (#fe4000)
  // 10% (Accent - Bold Highlights) → Teal (#28cecf)
  ColorScheme get colorScheme => _isDark
      ? const ColorScheme.dark(
          primary: Color(0xFF2F3640),
          primaryContainer: Color(0xFF353B48),
          secondary: Color(0xFF00B894),
          tertiary: Color(0xFF00BFFF),
          error: Color(0xFFD63031),
          surface: Color(0xFF121212),
          onSurface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
        )
      : const ColorScheme.light(
          primary: Color(0xFFD1C9BE),
          primaryContainer: Color(0xFFCBC5B6),
          secondary: Color(0xFFFF466A),
          tertiary: Color(0xFFFF4000),
          error: Color(0xFF28CECF),
          surface: Colors.white,
          onSurface: Colors.black,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
        );

  ThemeData get theme => ThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        colorScheme: colorScheme,
      );
}
