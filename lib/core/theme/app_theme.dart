import 'package:flutter/material.dart';

/// Dark theme matching assignment mockup: dark blue background, yellow accents.
class AppTheme {
  static const Color _primary = Color(0xFFFFC107); // yellow accent
  static const Color _surface = Color(0xFF0D1B2A);  // dark blue
  static const Color _background = Color(0xFF0A1628);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primary,
        onPrimary: Colors.black87,
        surface: _surface,
        onSurface: Colors.white,
        background: _background,
        onBackground: Colors.white,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        hintStyle: TextStyle(color: Colors.white54),
        labelStyle: TextStyle(color: Colors.white70),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.black87,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.white54,
      ),
    );
  }
}
