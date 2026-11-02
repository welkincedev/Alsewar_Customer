import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import 'membership_tier.dart';

/// Styling tokens and visual assets for dynamic membership cards.
///
/// Follows the Desert Luxe aesthetic with tailored palettes for each tier:
/// - Silver: Brushed metallic silver surface with glossy charcoal gradient overlay, metallic silver accents, and crisp high-contrast typography
/// - Gold: Deep charcoal/black surface, champagne gold accents, white supporting text
/// - Platinum: Dark platinum/graphite surface, refined silver accents, high-contrast typography
class MembershipCardTheme {
  final MembershipTier tier;
  final Gradient cardGradient;
  final Border cardBorder;
  final List<BoxShadow> cardShadow;
  final Color brandingColor;
  final Color memberNameColor;
  final Color cardIdColor;
  final Color balanceLabelColor;
  final Color pointsTextColor;
  final Gradient? pointsShaderGradient;
  final Color pointsUnitColor;
  final Gradient badgeGradient;
  final Color badgeTextColor;
  final Border? badgeBorder;
  final List<BoxShadow>? badgeShadow;
  final Color progressTrackColor;
  final Color progressIndicatorColor;
  final Color affordanceColor;
  final Color dividerColor;
  final String? backgroundImageAsset;
  final String passLabel;
  final List<Shadow>? textEmbossShadow;
  final Gradient? overlayGradient;

  const MembershipCardTheme({
    required this.tier,
    required this.cardGradient,
    required this.cardBorder,
    required this.cardShadow,
    required this.brandingColor,
    required this.memberNameColor,
    required this.cardIdColor,
    required this.balanceLabelColor,
    required this.pointsTextColor,
    this.pointsShaderGradient,
    required this.pointsUnitColor,
    required this.badgeGradient,
    required this.badgeTextColor,
    this.badgeBorder,
    this.badgeShadow,
    required this.progressTrackColor,
    required this.progressIndicatorColor,
    required this.affordanceColor,
    required this.dividerColor,
    this.backgroundImageAsset,
    this.passLabel = 'VIP PASS',
    this.textEmbossShadow,
    this.overlayGradient,
  });

  /// Factory creating the official theme matching the customer's membership tier
  factory MembershipCardTheme.forTier(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.silver:
        return MembershipCardTheme(
          tier: MembershipTier.silver,
          cardGradient: AppColors.silverSurfaceGradient,
          cardBorder: Border.all(
            color: const Color(0xFFBAC4CF).withValues(alpha: 0.85),
            width: 1.2,
          ),
          cardShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x208A9BA8),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
          brandingColor: const Color(0xFFF0F3F7),
          memberNameColor: Colors.white,
          cardIdColor: const Color(0xFFBAC4CF),
          balanceLabelColor: const Color(0xFF9EABB9),
          pointsTextColor: Colors.white,
          pointsShaderGradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFD6DEE7), Color(0xFFB0BAC7)],
            stops: [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          pointsUnitColor: const Color(0xFFB8C2CC),
          badgeGradient: AppColors.silverBadgeGradient,
          badgeTextColor: AppColors.deepCharcoal,
          badgeBorder: Border.all(color: const Color(0xFFA8B2BC), width: 0.8),
          badgeShadow: const [
            BoxShadow(
              color: Color(0x35BAC4CF),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          progressTrackColor: Colors.white.withValues(alpha: 0.12),
          progressIndicatorColor: const Color(0xFFBAC4CF),
          affordanceColor: const Color(0xFFBAC4CF),
          dividerColor: Colors.white.withValues(alpha: 0.10),
          backgroundImageAsset: 'assets/images/slbg.png',
          passLabel: 'SILVER VIP PASS',
          textEmbossShadow: const [
            Shadow(
              color: Color(0x99000000),
              offset: Offset(0, 1.5),
              blurRadius: 2.5,
            ),
          ],
          overlayGradient: AppColors.silverOverlayGradient,
        );

      case MembershipTier.gold:
        return MembershipCardTheme(
          tier: MembershipTier.gold,
          cardGradient: AppColors.charcoalGradient,
          cardBorder: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.42),
            width: 1.2,
          ),
          cardShadow: [
            BoxShadow(
              color: AppColors.deepBlack.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.champagneGold.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
          brandingColor: AppColors.champagneGold,
          memberNameColor: Colors.white,
          cardIdColor: Colors.white.withValues(alpha: 0.60),
          balanceLabelColor: Colors.white.withValues(alpha: 0.55),
          pointsTextColor: Colors.white,
          pointsShaderGradient: AppColors.goldGradient,
          pointsUnitColor: Colors.white.withValues(alpha: 0.80),
          badgeGradient: AppColors.goldGradient,
          badgeTextColor: AppColors.deepCharcoal,
          badgeBorder: null,
          badgeShadow: AppColors.goldGlow,
          progressTrackColor: Colors.white.withValues(alpha: 0.14),
          progressIndicatorColor: AppColors.champagneGold,
          affordanceColor: AppColors.champagneGold,
          dividerColor: Colors.white.withValues(alpha: 0.10),
          backgroundImageAsset: 'assets/images/gdbg.png',
          passLabel: 'GOLD VIP PASS',
          textEmbossShadow: const [
            Shadow(
              color: Color(0xA0000000),
              offset: Offset(0, 1.5),
              blurRadius: 3,
            ),
          ],
          overlayGradient: const LinearGradient(
            colors: [Color(0xD8141414), Color(0x88171717), Color(0xCC121212)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );

      case MembershipTier.platinum:
        return MembershipCardTheme(
          tier: MembershipTier.platinum,
          cardGradient: AppColors.platinumSurfaceGradient,
          cardBorder: Border.all(
            color: const Color(0xFFD8DEE7).withValues(alpha: 0.45),
            width: 1.2,
          ),
          cardShadow: const [
            BoxShadow(
              color: Color(0x45000000),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Color(0x25BAC4D2),
              blurRadius: 14,
              offset: Offset(0, 2),
            ),
          ],
          brandingColor: const Color.fromARGB(255, 255, 255, 255),
          memberNameColor: Colors.white,
          cardIdColor: AppColors.platinumSecondaryText,
          balanceLabelColor: const Color.fromARGB(255, 245, 246, 248),
          pointsTextColor: AppColors.platinumSilverText,
          pointsShaderGradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFD6DBE4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          pointsUnitColor: const Color(0xFFB4BAC6),
          badgeGradient: AppColors.platinumBadgeGradient,
          badgeTextColor: const Color(0xFF101216),
          badgeBorder: Border.all(color: const Color(0xFFE2E7EE), width: 0.8),
          badgeShadow: const [
            BoxShadow(
              color: Color(0x30CCD5E0),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
          progressTrackColor: Colors.white.withValues(alpha: 0.12),
          progressIndicatorColor: const Color(0xFFE2E7EE),
          affordanceColor: const Color(0xFFD0D6E0),
          dividerColor: Colors.white.withValues(alpha: 0.12),
          backgroundImageAsset: 'assets/images/plbg.png',
          passLabel: 'PLATINUM VIP PASS',
          textEmbossShadow: const [
            Shadow(
              color: Color(0xA0000000),
              offset: Offset(0, 1.5),
              blurRadius: 3,
            ),
          ],
          overlayGradient: const LinearGradient(
            colors: [Color(0xDE16181D), Color(0x8C1B1E25), Color(0xD0111317)],
            stops: [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );
    }
  }
}
