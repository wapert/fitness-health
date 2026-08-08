import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF2563EB); // blue-600

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Unified gray-blue header across all pages.
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: brightness == Brightness.light
            ? Colors.blueGrey.shade200
            : Colors.blueGrey.shade800,
        foregroundColor: brightness == Brightness.light
            ? Colors.blueGrey.shade900
            : Colors.blueGrey.shade50,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);
}
