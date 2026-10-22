import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  // Font Families
  static const String headingFont = 'Manrope';
  static const String bodyFont = 'DMSans';

  // Headings (Manrope)
  static const TextStyle display = TextStyle(
    fontFamily: headingFont,
    color: AppColors.textPrimary,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: headingFont,
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
  );

  static const TextStyle sectionHeading = TextStyle(
    fontFamily: headingFont,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );

  static const TextStyle title = TextStyle(
    fontFamily: headingFont,
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle cardTitle = TextStyle(
    fontFamily: headingFont,
    color: AppColors.textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle loyaltyPoints = TextStyle(
    fontFamily: headingFont,
    color: AppColors.champagneGold,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  // Body Texts (DM Sans)
  static const TextStyle bodyPrimary = TextStyle(
    fontFamily: bodyFont,
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: bodyFont,
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );

  static const TextStyle supporting = TextStyle(
    fontFamily: bodyFont,
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );

  // Action Elements & Captions (DM Sans)
  static const TextStyle button = TextStyle(
    fontFamily: bodyFont,
    color: AppColors.pureWhite,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFont,
    color: AppColors.textLight,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.2,
  );

  // Occasional Emphasis
  static const TextStyle emphasis = TextStyle(
    fontFamily: bodyFont,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
    fontSize: 13,
  );
}
