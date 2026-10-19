import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color secondaryGold = Color(0xFFD4AF37);

  // Metallic Gold Gradient Config
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFF3E5AB), // Bright highlight gold
      Color(0xFFD4AF37), // Core brand gold
      Color(0xFFAA7C11), // Shadow gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient goldRadialGradient = RadialGradient(
    colors: [
      Color(0xFFF3E5AB), // Bright highlight gold
      Color(0xFFD4AF37), // Core brand gold
      Color(0xFFAA7C11), // Shadow gold
    ],
    center: Alignment.topLeft,
    radius: 1.5,
  );

  // Backgrounds & Surfaces
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E5E5);

  // Typography Targets
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF8C8C8C);

  // Semantic Feedback
  static const Color success = Color(0xFF198754);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF0D6EFD);
}
