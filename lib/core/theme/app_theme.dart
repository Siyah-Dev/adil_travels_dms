import 'package:flutter/material.dart';

/// App theme and colors aligned with Adil Travels branding.
class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF0D944A);
  static const Color primaryDark = Color(0xFF067E3D);
  static const Color accentColor = Color(0xFFD5E88F);
  static const Color surfaceColor = Color(0xFFF7FAEC);
  static const Color onAccentColor = Color(0xFF111111);
  static const Color errorColor = Color(0xFFC62828);

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: Colors.white,
      brightness: Brightness.light,
    ).copyWith(
      onSecondary: onAccentColor,
      onPrimary: Colors.white,
      onSurface: const Color(0xFF1B1B1B),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surfaceColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD2DBBC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.4),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
    );
  }
}
