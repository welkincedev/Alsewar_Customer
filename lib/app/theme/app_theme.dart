import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppTextStyles.bodyFont,
      primaryColor: AppColors.deepCharcoal,
      scaffoldBackgroundColor: AppColors.warmPorcelain,

      // Global Component Token Mapping
      colorScheme: const ColorScheme.light(
        primary: AppColors.deepCharcoal,
        secondary: AppColors.champagneGold,
        surface: AppColors.warmPorcelain,
        error: AppColors.error,
        onPrimary: AppColors.pureWhite,
        onSecondary: AppColors.deepCharcoal,
        onSurface: AppColors.deepCharcoal,
        onError: AppColors.pureWhite,
      ),

      // Framework Typography Bridge
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display,
        headlineMedium: AppTextStyles.heading,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.cardTitle,
        bodyLarge: AppTextStyles.bodyPrimary,
        bodyMedium: AppTextStyles.bodySecondary,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
      ),

      // Top Header Bars Styling
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepCharcoal,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.champagneGold),
        titleTextStyle: TextStyle(
          fontFamily: AppTextStyles.headingFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.pureWhite,
        ),
      ),

      // Input Field Form Decorations
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.pureWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          color: AppColors.textLight,
          fontSize: 13,
        ),
        labelStyle: const TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          color: AppColors.textSecondary,
          fontSize: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sandBeige),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.sandBeige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.champagneGold,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),

      // Primary Button Layout Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepCharcoal,
          foregroundColor: AppColors.pureWhite,
          textStyle: AppTextStyles.button,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // Structural Card Frameworks
      cardTheme: CardThemeData(
        color: AppColors.pureWhite,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.sandBeige, width: 1),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: AppTextStyles.bodyFont,
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.sandBeige,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
