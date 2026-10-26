import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../app/theme/app_text_styles.dart';
import '../models/membership_card_theme.dart';
import '../models/membership_tier.dart';
import 'membership_details_bottom_sheet.dart';

/// Al Sewar Auto Center — Premium Dynamic Membership Card.
///
/// Follows the Desert Luxe aesthetic with dynamic tier theming:
/// - Silver: Brushed metallic silver surface with glossy charcoal gradient overlay, metallic silver accents, and crisp high-contrast typography
/// - Gold: Deep charcoal/black surface, champagne gold accents, white supporting text
/// - Platinum: Dark platinum/graphite surface, refined silver accents, high-contrast typography
///
/// Front of Card:
/// - Al Sewar branding
/// - Customer name (no separate greeting inside the card)
/// - Membership / Card ID (if supplied by backend)
/// - Dynamic membership tier badge
/// - Available points
/// - Refined progress indicator towards next tier (or Platinum achieved indicator)
/// - Subtle tap affordance opening the modal bottom sheet
class LoyaltyCard extends StatelessWidget {
  final CustomerMembership? membership;
  final String? memberName;
  final String? membershipCategory;
  final int? pointsBalance;
  final String pointsLabel;
  final String? membershipId;
  final String? benefitsText;
  final double? progressToNextTier;
  final String? nextTierLabel;
  final Gradient? cardGradient;
  final Color? backgroundColor;
  final bool isDevelopmentPlaceholder;
  final VoidCallback? onExploreRewards;
  final VoidCallback? onCardTap;

  const LoyaltyCard({
    super.key,
    this.membership,
    this.memberName,
    this.membershipCategory,
    this.pointsBalance,
    this.pointsLabel = 'Points',
    this.membershipId,
    this.benefitsText = 'Your loyalty, rewarded.',
    this.progressToNextTier,
    this.nextTierLabel,
    this.cardGradient,
    this.backgroundColor,
    this.isDevelopmentPlaceholder = false,
    this.onExploreRewards,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve membership domain model
    final effectiveMembership =
        membership ??
        CustomerMembership.fromUser(
          memberName: memberName ?? '',
          membershipId: membershipId,
          points: pointsBalance ?? 0,
          backendTier: membershipCategory,
        );

    final theme = MembershipCardTheme.forTier(effectiveMembership.tier);

    // Compute progress value for progress bar
    final double? effectiveProgress =
        progressToNextTier ?? effectiveMembership.progressToNextTier;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          if (onCardTap != null) {
            onCardTap!();
          } else {
            MembershipDetailsBottomSheet.show(
              context,
              membership: effectiveMembership,
              onExploreRewards: onExploreRewards,
            );
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: cardGradient ?? theme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: theme.cardBorder,
            boxShadow: theme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 1. Digital Membership Voucher Pass Background Texture
                if (theme.backgroundImageAsset != null)
                  Positioned.fill(
                    child: Image.asset(
                      theme.backgroundImageAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),

                // 2. Translucent contrast glaze ensuring 100% typography readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:
                          theme.overlayGradient ??
                          LinearGradient(
                            colors: theme.tier == MembershipTier.silver
                                ? [
                                    const Color(0xD016181C),
                                    const Color(0x781F232B),
                                    const Color(0xC8121417),
                                  ]
                                : (theme.tier == MembershipTier.gold
                                      ? [
                                          const Color(0xD8141414),
                                          const Color(0x88171717),
                                          const Color(0xCC121212),
                                        ]
                                      : [
                                          const Color(0xDE16181D),
                                          const Color(0x8C1B1E25),
                                          const Color(0xD0111317),
                                        ]),
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    ),
                  ),
                ),

                // 3. Subtle specular top-edge clear coat highlight
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white.withValues(
                            alpha: theme.tier == MembershipTier.gold
                                ? 0.35
                                : (theme.tier == MembershipTier.silver
                                      ? 0.60
                                      : 0.45),
                          ),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Header: Al Sewar Branding & Tier Badge ───────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Al Sewar Luxury Branding
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: theme.brandingColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                  'assets/logos/AlSewar_logoonly_wh.svg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                'AL SEWAR',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.headingFont,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                  color: theme.brandingColor,
                                ),
                              ),
                            ],
                          ),

                          // Tier Badge & Optional Preview Tag
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: theme.badgeGradient,
                                      borderRadius: BorderRadius.circular(20),
                                      border: theme.badgeBorder,
                                      boxShadow: theme.badgeShadow,
                                    ),
                                    child: Text(
                                      effectiveMembership.tier.displayName
                                          .toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.headingFont,
                                        color: theme.badgeTextColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isDevelopmentPlaceholder) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Preview Tier',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.bodyFont,
                                        color: Colors.white.withValues(
                                          alpha: 0.70,
                                        ),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Available Points Label ───────────────────────────────
                      Text(
                        'AVAILABLE BALANCE',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: theme.balanceLabelColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // ── Points Amount & Unit ─────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          if (theme.pointsShaderGradient != null)
                            ShaderMask(
                              shaderCallback: (rect) => theme
                                  .pointsShaderGradient!
                                  .createShader(rect),
                              child: Text(
                                CustomerMembership.formatPoints(
                                  effectiveMembership.points,
                                ),
                                style: TextStyle(
                                  fontFamily: AppTextStyles.headingFont,
                                  color: theme.pointsTextColor,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  shadows: theme.textEmbossShadow,
                                ),
                              ),
                            )
                          else
                            Text(
                              CustomerMembership.formatPoints(
                                effectiveMembership.points,
                              ),
                              style: TextStyle(
                                fontFamily: AppTextStyles.headingFont,
                                color: theme.pointsTextColor,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                shadows: theme.textEmbossShadow,
                              ),
                            ),
                          const SizedBox(width: 6),
                          Text(
                            pointsLabel,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              color: theme.pointsUnitColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Refined Progress Bar or Platinum Achieved Indicator ──
                      if (effectiveMembership.isPlatinum &&
                          nextTierLabel == null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.workspace_premium_outlined,
                              size: 14,
                              color: theme.pointsUnitColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Platinum Privileges Unlocked',
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: theme.pointsUnitColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ] else if (effectiveProgress != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: effectiveProgress.clamp(0.0, 1.0),
                            minHeight: 3.5,
                            backgroundColor: theme.progressTrackColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.progressIndicatorColor,
                            ),
                          ),
                        ),
                        if (nextTierLabel != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            nextTierLabel!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              color: theme.balanceLabelColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 14),
                      Container(height: 1, color: theme.dividerColor),
                      const SizedBox(height: 12),

                      // ── Footer: Customer Name, Card ID & Subtle Tap Affordance
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  effectiveMembership.memberName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.headingFont,
                                    color: theme.memberNameColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    shadows: theme.textEmbossShadow,
                                  ),
                                ),
                                if (effectiveMembership.membershipId !=
                                    null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'ID: ${effectiveMembership.membershipId}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.bodyFont,
                                      color: theme.cardIdColor,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Subtle Tap Affordance
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Card Details',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  color: theme.affordanceColor.withValues(
                                    alpha: 0.85,
                                  ),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: theme.affordanceColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
