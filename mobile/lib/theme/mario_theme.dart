import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classic Mario palette with premium motion-friendly surfaces.
class MarioColors {
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

class MarioTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MarioColors.red,
        primary: MarioColors.red,
        secondary: MarioColors.yellow,
        tertiary: MarioColors.blue,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: MarioColors.cream,
          letterSpacing: 1.2,
          shadows: const [
            Shadow(color: MarioColors.dark, blurRadius: 0, offset: Offset(3, 3)),
            Shadow(color: MarioColors.red, blurRadius: 18, offset: Offset(0, 0)),
          ],
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: MarioColors.cream,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: MarioColors.dark,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: MarioColors.dark,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: MarioColors.dark,
        ),
      ),
      scaffoldBackgroundColor: MarioColors.skyTop,
    );
  }
}
