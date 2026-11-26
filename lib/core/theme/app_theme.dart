import 'package:flutter/material.dart';

/// Palet warna prototipe SkinSense: Navy gelap, biru es lembut, coral/rose CTA, permukaan bersih.
class AppTheme {
  AppTheme._();

  static const navy = Color(0xFF0E2954);
  static const navyDark = Color(0xFF091B3A);
  static const navyMid = Color(0xFF1A3A6E);
  static const ink = Color(0xFF0E2954);
  static const teal = Color(0xFF0E2954);
  static const slate = Color(0xFF5A6B87);
  static const mist = Color(0xFFEAF1FB);
  static const ice = Color(0xFFF4F8FE);
  static const pearl = Color(0xFFF6F9FC);
  static const coral = Color(0xFFF66B85);
  static const coralSoft = Color(0xFFFFEEF1);
  static const border = Color(0xFFE1E9F4);
  static const gold = Color(0xFFE5A024);
  static const emerald = Color(0xFF1F9D74);
  static const periwinkle = Color(0xFF5B6FD1);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: navy,
      secondary: coral,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: pearl,
      appBarTheme: const AppBarTheme(
        backgroundColor: pearl,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: navy,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: navy,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          side: const BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ice,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: navy, width: 1.4),
        ),
      ),
    );
  }
}
