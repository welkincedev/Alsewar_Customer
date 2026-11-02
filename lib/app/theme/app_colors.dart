import 'package:flutter/material.dart';

/// Al Sewar Auto Center — Premium White, Black & Gold Design System Colors.
///
/// Palette specifications:
/// - Pure White: #FFFFFF (Scaffold background, card surfaces, clean canvas)
/// - Deep Black: #171717 (Headings, primary buttons, high-contrast dark surfaces, line icons)
/// - Champagne Gold: #C6A66B (Brand signature accent, loyalty highlights, badges, active states)
/// - Soft Neutral: #F5F5F5 (Subtle secondary surfaces, inner fills)
/// - Subtle Border: #E8E8E8 (Crisp, refined card and input borders)
abstract class AppColors {
  // ─── Primary Brand Colors ──────────────────────────────────────────
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FB);
  static const Color deepBlack = Color(0xFF171717);
  static const Color charcoal = Color(0xFF171717);
  static const Color deepNavy = Color(0xFF021C4B);
  static const Color navy = deepNavy;

  static const Color signatureGold = Color(0xFFD9B152);
  static const Color champagneGold = Color(0xFFC5A059);
  static const Color richMetallicGold = Color(0xFFB38B45);

  static const Color softWhite = Color(0xFFF8F8F8);
  static const Color subtleBorder = Color(0xFFE6E6E6);

  // ─── Semantic Aliases & Compatibility Tokens ───────────────────────
  static const Color primaryBlack = deepBlack;
  static const Color deepCharcoal = deepBlack;
  static const Color warmPorcelain = pureWhite;
  static const Color backgroundLight = pureWhite;
  static const Color surfaceLight = softWhite;
  static const Color cardLight = pureWhite;
  static const Color sandBeige = subtleBorder;
  static const Color borderLight = subtleBorder;
  static const Color secondaryGold = champagneGold;

  // ─── Typography ────────────────────────────────────────────────────
  static const Color textPrimary = deepBlack;
  static const Color textSecondary = Color(0xFF555555);
  static const Color textLight = Color(0xFF8A8A8A);

  // ─── Metallic Champagne Gold Gradients ────────────────────────────
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFDEC595), // Bright highlight champagne gold
      Color(0xFFC6A66B), // Core brand champagne gold
      Color(0xFFB38B45), // Deep rich metallic gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Solid metallic surface gradient for Champagne Gold shortcut cards
  static const LinearGradient goldCardGradient = LinearGradient(
    colors: [
      Color(0xFFDEC595), // Specular light champagne highlight
      Color(0xFFC6A66B), // Signature champagne gold
      Color(0xFFB38B45), // Rich metallic gold base
    ],
    stops: [0.0, 0.45, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient goldRadialGradient = RadialGradient(
    colors: [Color(0xFFDEC595), Color(0xFFC6A66B), Color(0xFFA88849)],
    center: Alignment.topLeft,
    radius: 1.5,
  );

  // ─── Deep Black Glossy Gradient ───────────────────────────────────
  static const LinearGradient charcoalGradient = LinearGradient(
    colors: [Color(0xFF282828), Color(0xFF1C1C1B), Color(0xFF141414)],
    stops: [0.0, 0.45, 1.0],
    begin: Alignment(-0.6, -1.0),
    end: Alignment(0.8, 1.0),
  );

  // ─── Silver Membership Tier Palette ───────────────────────────────
  static const LinearGradient silverSurfaceGradient = LinearGradient(
    colors: [
      Color(0xFFF9FAFC), // Specular light highlight
      Color(0xFFE5E9EE), // Core metallic silver body
      Color(0xFFD3D8E2), // Directional metallic shade
      Color(0xFFECF0F5), // Secondary luster highlight
    ],
    stops: [0.0, 0.32, 0.68, 1.0],
    begin: Alignment(-0.8, -1.0),
    end: Alignment(0.8, 1.0),
  );

  static const LinearGradient silverBadgeGradient = LinearGradient(
    colors: [Color(0xFFF0F3F7), Color(0xFFC0CAD5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color silverBorder = Color(0xFFB0BAC6);
  static const Color silverDarkText = Color(0xFF171717);
  static const Color silverSecondaryText = Color(0xFF505864);

  static const LinearGradient silverOverlayGradient = LinearGradient(
    colors: [
      Color(0xD016181C), // Deep charcoal/obsidian top-left
      Color(
        0x781F232B,
      ), // Smoked luminous mid-tone allowing metallic silver base to gleam
      Color(0xC8121417), // Deep charcoal floor bottom-right
    ],
    stops: [0.0, 0.48, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Platinum Membership Tier Palette ─────────────────────────────
  static const LinearGradient platinumSurfaceGradient = LinearGradient(
    colors: [
      Color(0xFF2E323A), // Metallic graphite highlight
      Color(0xFF1B1D22), // Deep obsidian platinum
      Color(0xFF0F1114), // Deep floor
    ],
    stops: [0.0, 0.40, 1.0],
    begin: Alignment(-0.8, -1.0),
    end: Alignment(0.8, 1.0),
  );

  static const LinearGradient platinumBadgeGradient = LinearGradient(
    colors: [Color(0xFFE8ECF2), Color(0xFFB0B7C2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color platinumBorder = Color(0xFFCFD5DF);
  static const Color platinumSilverText = Color(0xFFF0F3F7);
  static const Color platinumSecondaryText = Color(0xFF9CA4B1);

  static const List<BoxShadow> platinumGlow = [
    BoxShadow(color: Color(0x28CCD5DF), blurRadius: 12, offset: Offset(0, 4)),
  ];

  // ─── Semantic Feedback ────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF1976D2);

  // ─── Soft Refined Shadows ─────────────────────────────────────────
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x08000000), // Clean neutral soft shadow
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0C000000), // Clean depth shadow for white cards
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(color: Color(0x28C6A66B), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Premium depth shadow for solid metallic Champagne Gold shortcut cards
  static const List<BoxShadow> goldCardShadow = [
    BoxShadow(color: Color(0x2EB38B45), blurRadius: 10, offset: Offset(0, 3)),
    BoxShadow(color: Color(0x10171717), blurRadius: 4, offset: Offset(0, 1)),
  ];
}
