import 'package:flutter/material.dart';

class AppTheme {
  // Premium Tablet-First Color Palette
  static const Color background = Color(0xFF121212); // Soft Dark (Matte Black)
  static const Color surface = Color(0xFF1E1E1E); // Card Surface
  static const Color primary = Color(0xFFFFB74D); // Warm Beige Orange (Accent)
  static const Color secondary = Color(0xFFE0E0E0); // Soft White (Text)
  static const Color textSecondary = Color(0xFF9E9E9E); // Muted Text
  static const Color success = Color(0xFF81C784); // Soft Green
  static const Color error = Color(0xFFE57373); // Soft Red

  static ThemeData get luxuryDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(primary: primary, secondary: primary, surface: surface, background: background, error: error),

      // Typography - Gilroy
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Gilroy', fontSize: 32, fontWeight: FontWeight.w700, color: secondary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontFamily: 'Gilroy', fontSize: 28, fontWeight: FontWeight.w600, color: secondary, letterSpacing: -0.5),
        headlineLarge: TextStyle(fontFamily: 'Gilroy', fontSize: 24, fontWeight: FontWeight.w600, color: secondary),
        headlineMedium: TextStyle(fontFamily: 'Gilroy', fontSize: 20, fontWeight: FontWeight.w500, color: secondary),
        titleLarge: TextStyle(fontFamily: 'Gilroy', fontSize: 18, fontWeight: FontWeight.w600, color: secondary),
        titleMedium: TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w500, color: secondary),
        bodyLarge: TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w400, color: secondary),
        bodyMedium: TextStyle(fontFamily: 'Gilroy', fontSize: 14, fontWeight: FontWeight.w400, color: textSecondary),
        bodySmall: TextStyle(fontFamily: 'Gilroy', fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: TextStyle(fontFamily: 'Gilroy', fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: Colors.black),
        labelSmall: TextStyle(fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w500, color: secondary),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: secondary, size: 24),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: secondary),
        titleTextStyle: TextStyle(fontFamily: 'Gilroy', fontSize: 20, fontWeight: FontWeight.w600, color: secondary, letterSpacing: 0.5),
      ),

      // Card Theme
      cardTheme: CardThemeData(color: surface, elevation: 4, shadowColor: Colors.black.withOpacity(0.3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black, // Text color on primary button
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary, width: 1.5)),
        hintStyle: const TextStyle(fontFamily: 'Gilroy', color: textSecondary),
        labelStyle: const TextStyle(fontFamily: 'Gilroy', color: secondary),
      ),
    );
  }
}
