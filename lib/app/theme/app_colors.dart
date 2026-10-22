import 'package:flutter/material.dart';

abstract class AppColors {
  // Canonical Desert Luxe Palette
  static const Color warmPorcelain = Color(0xFFF6F2EA); // Main app background
  static const Color deepCharcoal = Color(
    0xFF1C1C1B,
  ); // Primary text, buttons, dark surfaces
  static const Color champagneGold = Color(
    0xFFC6A66B,
  ); // Premium accents, rewards, highlights
  static const Color sandBeige = Color(
    0xFFE9E0D2,
  ); // Secondary surfaces, subtle borders
  static const Color pureWhite = Color(
    0xFFFFFFFF,
  ); // Cards, inputs, clean surfaces

  // Aliases for Backwards-Compatibility
  static const Color primaryBlack = deepCharcoal;
  static const Color secondaryGold = champagneGold;
  static const Color backgroundLight = warmPorcelain;
  static const Color surfaceLight = sandBeige;
  static const Color cardLight = pureWhite;
  static const Color borderLight = sandBeige;

  // Typography Targets
  static const Color textPrimary = deepCharcoal;
  static const Color textSecondary = Color(0xFF636058);
  static const Color textLight = Color(0xFF969083);

  // Metallic Champagne Gold Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFDEC595), // Bright highlight champagne gold
      Color(0xFFC6A66B), // Core brand champagne gold
      Color(0xFFA88849), // Deep rich champagne gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient goldRadialGradient = RadialGradient(
    colors: [Color(0xFFDEC595), Color(0xFFC6A66B), Color(0xFFA88849)],
    center: Alignment.topLeft,
    radius: 1.5,
  );

  // Deep Charcoal Gradient for luxury surfaces (e.g. Loyalty Card)
  static const LinearGradient charcoalGradient = LinearGradient(
    colors: [Color(0xFF2C2C29), Color(0xFF1C1C1B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Semantic Feedback
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF1976D2);

  // Soft Luxury Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(color: Color(0x0A1C1C1B), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x101C1C1B), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(color: Color(0x28C6A66B), blurRadius: 12, offset: Offset(0, 4)),
  ];
}
