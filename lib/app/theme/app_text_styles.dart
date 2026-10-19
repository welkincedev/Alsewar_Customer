import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  // Headings
  static const TextStyle display = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle heading = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
  );

  static const TextStyle title = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  // Body Texts
  static const TextStyle bodyPrimary = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.5,
  );

  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.25,
  );

  // Action Elements & Captions
  static const TextStyle button = TextStyle(
    color: AppColors.backgroundLight,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.75,
  );

  static const TextStyle caption = TextStyle(
    color: AppColors.textLight,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
}
