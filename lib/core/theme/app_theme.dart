import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../tenant/tenant_model.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Resolves the primary typography font family dynamically
  static TextStyle Function({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) _getFontBuilder(String family) {
    switch (family.toLowerCase().replaceAll(' ', '')) {
      case 'cinzel':
        return GoogleFonts.cinzel;
      case 'playfairdisplay':
      case 'playfair':
        return GoogleFonts.playfairDisplay;
      case 'montserrat':
        return GoogleFonts.montserrat;
      case 'spacegrotesk':
        return GoogleFonts.spaceGrotesk;
      case 'inter':
      default:
        return GoogleFonts.inter;
    }
  }

  /// Builds a dynamic ThemeData instance parameterized by the active tenant config
  static ThemeData buildDynamicTheme(TenantConfig config) {
    final branding = config.branding;
    final primary = branding.primaryColor;
    final secondary = branding.secondaryColor;
    final background = branding.backgroundColor;
    final surface = branding.surfaceColor;
    final text = branding.textColor;

    final isDark = background.computeLuminance() < 0.5;
    final onPrimary = primary.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final onSecondary = secondary.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    final fontBuilder = _getFontBuilder(branding.fontFamily);
    final radius = BorderRadius.circular(branding.borderRadius);

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            onPrimary: onPrimary,
            secondary: secondary,
            onSecondary: onSecondary,
            surface: surface,
            onSurface: text,
            onSurfaceVariant: text.withValues(alpha: 0.7),
            error: AppColors.error,
          )
        : ColorScheme.light(
            primary: primary,
            onPrimary: onPrimary,
            secondary: secondary,
            onSecondary: onSecondary,
            surface: surface,
            onSurface: text,
            onSurfaceVariant: text.withValues(alpha: 0.7),
            error: AppColors.error,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: fontBuilder(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.0,
          color: text,
        ),
        displayMedium: fontBuilder(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: text,
        ),
        titleLarge: fontBuilder(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: text,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: text,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: text.withValues(alpha: 0.7),
        ),
        labelLarge: fontBuilder(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: primary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: fontBuilder(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: text,
          letterSpacing: 2.0,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          textStyle: fontBuilder(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: radius,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        ),
      ),
    );
  }

  /// Default static dark theme
  static ThemeData get darkTheme => buildDynamicTheme(TenantConfig.defaultTenant);
}
