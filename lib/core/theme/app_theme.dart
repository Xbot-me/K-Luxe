import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
          color: AppColors.onSurface,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: AppColors.primary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
          letterSpacing: 2.0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
    );
  }
}
