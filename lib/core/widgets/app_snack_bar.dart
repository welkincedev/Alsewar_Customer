import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

/// Al Sewar Premium Feedback SnackBar.
///
/// Designed strictly according to the Desert Luxe visual identity:
/// - Success: White surface, Deep Navy text, Champagne Gold accent border.
/// - Error: Distinguishable error tone with readable text and error icon.
/// - Info: Minimal neutral styling with Deep Navy accents.
/// - Floating behavior with configurable bottom margin to clear floating navigation.
/// - Debounces rapid calls by clearing queued SnackBars.
class AppSnackBar {
  AppSnackBar._();

  /// Show a premium Success SnackBar.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
    bool hasBottomNav = false,
  }) {
    _show(
      context,
      message: message,
      duration: duration,
      hasBottomNav: hasBottomNav,
      backgroundColor: AppColors.pureWhite,
      borderColor: AppColors.champagneGold,
      textColor: AppColors.deepNavy,
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.champagneGold,
      accentColor: AppColors.champagneGold,
    );
  }

  /// Show a premium Error SnackBar.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 3500),
    bool hasBottomNav = false,
  }) {
    // Sanitize technical prefixes
    final cleanMessage = message
        .replaceAll('Exception: ', '')
        .replaceAll('DioException: ', '')
        .trim();

    _show(
      context,
      message: cleanMessage.isNotEmpty
          ? cleanMessage
          : 'An unexpected error occurred. Please try again.',
      duration: duration,
      hasBottomNav: hasBottomNav,
      backgroundColor: const Color(0xFFFFF5F5),
      borderColor: const Color(0xFFF8B4B4),
      textColor: const Color(0xFF9B1C1C),
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFE02424),
      accentColor: const Color(0xFFE02424),
    );
  }

  /// Show a premium Information SnackBar.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2500),
    bool hasBottomNav = false,
  }) {
    _show(
      context,
      message: message,
      duration: duration,
      hasBottomNav: hasBottomNav,
      backgroundColor: AppColors.offWhite,
      borderColor: AppColors.subtleBorder,
      textColor: AppColors.deepBlack,
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.deepNavy,
      accentColor: AppColors.deepNavy,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Duration duration,
    required bool hasBottomNav,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    // Remove any currently visible SnackBar to avoid queued duplicate banners
    messenger.hideCurrentSnackBar();

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      duration: duration,
      elevation: 0,
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: hasBottomNav ? 96 : 18,
      ),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepNavy.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    messenger.showSnackBar(snackBar);
  }
}
