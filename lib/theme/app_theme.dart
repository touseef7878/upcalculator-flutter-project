import 'package:flutter/material.dart';

class AppTheme {
  // ─── Color Palette ────────────────────────────────────────────────────────
  static const Color background   = Color(0xFF0D0D0D);
  static const Color surface      = Color(0xFF1A1A1A);
  static const Color surfaceHigh  = Color(0xFF242424);
  static const Color accent       = Color(0xFF00D4FF);
  static const Color accentAlt    = Color(0xFF7B61FF);
  static const Color danger       = Color(0xFFFF4D6D);
  static const Color success      = Color(0xFF00E5A0);
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecondary= Color(0xFF9E9E9E);
  static const Color divider      = Color(0xFF2A2A2A);

  // Button colors
  static const Color btnNumber    = Color(0xFF1E1E1E);
  static const Color btnOperator  = Color(0xFF1A2A3A);
  static const Color btnFunction  = Color(0xFF1A1A2E);
  static const Color btnEquals    = Color(0xFF00D4FF);
  static const Color btnClear     = Color(0xFF2A1A1A);
  static const Color btnSpecial   = Color(0xFF1A2A1A);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentAlt,
        surface: surface,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textSecondary),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 48, fontWeight: FontWeight.w300),
        displayMedium: TextStyle(color: textPrimary, fontSize: 36, fontWeight: FontWeight.w300),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        labelLarge: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      dividerColor: divider,
      cardColor: surface,
    );
  }
}
