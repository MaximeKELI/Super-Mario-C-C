import 'package:flutter/material.dart';

/// PipeLeap palette — original platformer colors.
class AppColors {
  static const red = Color(0xFFE52521);
  static const blue = Color(0xFF049CD8);
  static const yellow = Color(0xFFFBD000);
  static const green = Color(0xFF43B047);
  static const brown = Color(0xFFC84C0C);
  static const skyTop = Color(0xFF5EC8F8);
  static const skyBottom = Color(0xFFB8ECFF);
  static const brick = Color(0xFFC84C0C);
  static const pipe = Color(0xFF43B047);
  static const coin = Color(0xFFFBD000);
  static const dark = Color(0xFF1A1A2E);
  static const cream = Color(0xFFFFF8E7);
}

class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.red,
        primary: AppColors.red,
        secondary: AppColors.yellow,
        tertiary: AppColors.blue,
      ),
      fontFamily: 'Nunito',
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: AppColors.cream,
          letterSpacing: 1.2,
          shadows: [
            Shadow(color: AppColors.dark, blurRadius: 0, offset: Offset(3, 3)),
            Shadow(color: AppColors.red, blurRadius: 18, offset: Offset(0, 0)),
          ],
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.cream,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Fredoka',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.dark,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
      ),
      scaffoldBackgroundColor: AppColors.skyTop,
    );
  }
}
