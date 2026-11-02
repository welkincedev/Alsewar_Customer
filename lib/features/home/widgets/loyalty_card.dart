import 'package:flutter/material.dart';

import '../../../app/theme/app_text_styles.dart';
import '../models/membership_card_theme.dart';
import '../models/membership_tier.dart';
import 'membership_details_bottom_sheet.dart';

/// Al Sewar Auto Center — Premium Dynamic Membership Card.
///
/// Features:
/// - Compact, rounded horizontal card with consistent dimensions across all tiers
/// - Full-bleed background artwork (`BoxFit.cover`):
///     * Silver: `voucher_silver_pass.png`
///     * Gold: `voucher_gold_pass.png`
///     * Platinum: `voucher_platinum_pass.png`
/// - Subtle localized gradient overlay behind text only, preserving 100% of the artwork luster
/// - Content displays strictly:
///     1. Greeting with customer's name: "Hi, [Name]" near the top-left
///     2. Membership tier chip FIRST and coin balance SECOND in one horizontal row:
///        e.g. `[ GOLD ]  2,450 Coins`
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
    this.pointsLabel = 'Coins',
    this.membershipId,
    this.benefitsText,
    this.progressToNextTier,
    this.nextTierLabel,
    this.cardGradient,
    this.backgroundColor,
    this.isDevelopmentPlaceholder = false,
    this.onExploreRewards,
    this.onCardTap,
  });

  static String _resolveBackgroundImage(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.silver:
        return 'assets/images/slbg.png';
      case MembershipTier.gold:
        return 'assets/images/gdbg.png';
      case MembershipTier.platinum:
        return 'assets/images/plbg.png';
    }
  }

  static Color _getTierChipColor(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.silver:
        return const Color(0xFFBAC4CF); // Metallic Silver
      case MembershipTier.gold:
        return const Color(0xFFC5A059); // Champagne Gold #C5A059
      case MembershipTier.platinum:
        return const Color(0xFFCCD5E0); // Platinum / light metallic slate
    }
  }

  static Color _getTierChipBorderColor(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.silver:
        return const Color(0xFF8E9BA8);
      case MembershipTier.gold:
        return const Color(0xFFA88438);
      case MembershipTier.platinum:
        return const Color(0xFF9EABB8);
    }
  }

  static Color _getGreetingColor(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.gold:
        return Colors.white;
      case MembershipTier.silver:
      case MembershipTier.platinum:
        return const Color(0xFF171717);
    }
  }

  static Color _getCoinBalanceColor(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.gold:
        return Colors.white;
      case MembershipTier.silver:
      case MembershipTier.platinum:
        return const Color(0xFF171717);
    }
  }

  static Color _getTierChipTextColor(MembershipTier tier) {
    switch (tier) {
      case MembershipTier.gold:
        return Colors.white;
      case MembershipTier.silver:
      case MembershipTier.platinum:
        return const Color(0xFF171717);
    }
  }

  static List<Shadow>? _getTextShadows(
    MembershipTier tier, {
    bool isLarge = false,
  }) {
    switch (tier) {
      case MembershipTier.gold:
        return [
          Shadow(
            color: const Color(0x99000000),
            offset: Offset(0, isLarge ? 1.5 : 1),
            blurRadius: 3,
          ),
        ];
      case MembershipTier.silver:
      case MembershipTier.platinum:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve dynamic membership domain model from supplied arguments or user state
    final effectiveMembership =
        membership ??
        CustomerMembership.fromUser(
          memberName: memberName ?? '',
          membershipId: membershipId,
          points: pointsBalance ?? 0,
          backendTier: membershipCategory,
        );

    final theme = MembershipCardTheme.forTier(effectiveMembership.tier);

    final rawName = memberName ?? effectiveMembership.memberName;
    final greetingName = rawName.trim().isNotEmpty
        ? rawName.trim()
        : 'Customer';
    final tierDisplayName = effectiveMembership.tier.tierName.toUpperCase();
    final coinsFormatted = CustomerMembership.formatPoints(
      effectiveMembership.points,
    );
    final coinsUnit = pointsLabel.isNotEmpty && pointsLabel != 'Points'
        ? pointsLabel
        : 'Coins';

    final backgroundAsset = _resolveBackgroundImage(effectiveMembership.tier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Semantics(
        button: true,
        label:
            'Membership Card: $tierDisplayName tier, $coinsFormatted $coinsUnit for $greetingName',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
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
            height: 120,
            decoration: BoxDecoration(
              color: backgroundColor,
              gradient: cardGradient ?? theme.cardGradient,
              borderRadius: BorderRadius.circular(30),
              border: theme.cardBorder,
              //boxShadow: theme.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Full-Card Background Artwork (voucher pass with BoxFit.cover)
                  Image.asset(
                    backgroundAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),

                  // // 2. Subtle Localized Gradient Overlay behind text only for Gold tier
                  // if (effectiveMembership.tier == MembershipTier.gold)
                  //   Positioned(
                  //     left: 0,
                  //     top: 0,
                  //     bottom: 0,
                  //     width: 220,
                  //     child: IgnorePointer(
                  //       child: Container(
                  //         decoration: BoxDecoration(
                  //           gradient: LinearGradient(
                  //             colors: _getVignetteColors(
                  //               effectiveMembership.tier,
                  //             ),
                  //             stops: const [0.0, 1.0],
                  //             begin: Alignment.centerLeft,
                  //             end: Alignment.centerRight,
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ),

                  // // 3. Subtle Specular Top-Edge Clear Coat Highlight
                  // Positioned(
                  //   top: 0,
                  //   left: 0,
                  //   right: 0,
                  //   height: 1.0,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       gradient: LinearGradient(
                  //         colors: [
                  //           Colors.white.withValues(alpha: 0.0),
                  //           Colors.white.withValues(alpha: 0.30),
                  //           Colors.white.withValues(alpha: 0.0),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // 4. Foreground Content: Greeting near top-left, Tier Chip + Coins in one row below
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 22,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top-left: Greeting with customer's name
                        Text(
                          'Hi, $greetingName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _getGreetingColor(effectiveMembership.tier),
                            letterSpacing: -0.2,
                            shadows: _getTextShadows(effectiveMembership.tier),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Membership tier FIRST and coin balance SECOND in one horizontal row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Compact rounded chip for tier
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTierChipColor(
                                  effectiveMembership.tier,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTierChipBorderColor(
                                    effectiveMembership.tier,
                                  ),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        effectiveMembership.tier ==
                                            MembershipTier.gold
                                        ? const Color(0x40000000)
                                        : const Color(0x18000000),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                tierDisplayName,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.headingFont,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: _getTierChipTextColor(
                                    effectiveMembership.tier,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Loyalty coin balance
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '$coinsFormatted $coinsUnit',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.headingFont,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: _getCoinBalanceColor(
                                      effectiveMembership.tier,
                                    ),
                                    letterSpacing: -0.3,
                                    shadows: _getTextShadows(
                                      effectiveMembership.tier,
                                      isLarge: true,
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
