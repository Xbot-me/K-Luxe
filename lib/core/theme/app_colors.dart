import 'package:flutter/material.dart';

class AppColors {
  AppColors._();


  // Brand Colors
  

  // --- Primary ---
  static const Color primary = Color(0xFFD7BAFF);
  static const Color onPrimary = Color(0xFF41117C);
  static const Color secondary = Color(0xFFFFB1C7);
  static const Color onSecondary = Color(0xFF650031);
  static const Color primaryLight = Color(0xFFE6F1FB);
  static const Color primaryDark = Color(0xFF0C447C);

  // --- Neutrals ---
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF131313);
  static const Color border = Color(0xFFD3D1C7);
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFCCC3D3);

  // --- Text ---
  static const Color textPrimary = Color(0xFF2C2C2A);
  static const Color textSecondary = Color(0xFF888780);
  static const Color textHint = Color(0xFFB4B2A9);

  // --- Semantic ---
  static const Color success = Color(0xFF1D9E75);
  static const Color successLight = Color(0xFFEAF3DE);
  static const Color error = Color(0xFFD85A30);
  static const Color errorLight = Color(0xFFFAECE7);
  static const Color warning = Color(0xFFBA7517);
  static const Color warningLight = Color(0xFFFAEEDA);


    // Custom Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );



}
