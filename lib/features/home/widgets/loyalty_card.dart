import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

/// Highly configurable, reusable loyalty membership card.
///
/// Supports:
/// - Configurable member name
/// - Configurable membership category / tier
/// - Configurable points balance & currency label
/// - Optional progress bar and label for next tier upgrade
/// - Configurable background color or gradient
/// - Transparent development placeholder indicator
class LoyaltyCard extends StatelessWidget {
  final String memberName;
  final String membershipCategory;
  final int pointsBalance;
  final String pointsLabel;
  final String? benefitsText;
  final double? progressToNextTier; // Range 0.0 to 1.0
  final String? nextTierLabel;
  final Gradient? cardGradient;
  final Color? backgroundColor;
  final bool isDevelopmentPlaceholder;
  final VoidCallback? onExploreRewards;
  final VoidCallback? onCardTap;

  const LoyaltyCard({
    super.key,
    required this.memberName,
    this.membershipCategory = 'GOLD MEMBER',
    this.pointsBalance = 2450,
    this.pointsLabel = 'Coins',
    this.benefitsText = 'Your loyalty, rewarded.',
    this.progressToNextTier = 0.70,
    this.nextTierLabel = '550 points to next tier',
    this.cardGradient,
    this.backgroundColor,
    this.isDevelopmentPlaceholder = true,
    this.onExploreRewards,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onCardTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient:
                cardGradient ??
                const LinearGradient(
                  colors: [Color(0xFF1E1E1E), Color(0xFF0D0D0D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Tier Badge & Placeholder Tag ───────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        membershipCategory.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  if (isDevelopmentPlaceholder) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Preview Tier',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // ── Available Balance Label ────────────────────────────
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 4),

              // ── Points Amount & Currency ───────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ShaderMask(
                    shaderCallback: (rect) =>
                        AppColors.goldGradient.createShader(rect),
                    child: Text(
                      _formattedPoints(pointsBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      pointsLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Customer Name
                  if (memberName.isNotEmpty)
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            memberName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                ],
              ),

              // ── Optional Next Tier Progress Bar ────────────────────
              if (progressToNextTier != null) ...[
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressToNextTier!.clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.secondaryGold,
                    ),
                  ),
                ),
                if (nextTierLabel != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    nextTierLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],

              const SizedBox(height: 18),
              Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
              const SizedBox(height: 14),

              // ── Footer: Benefit Text & Rewards Link ────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      benefitsText ?? 'Your loyalty, rewarded.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onExploreRewards,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) =>
                              AppColors.goldGradient.createShader(rect),
                          child: const Text(
                            'Explore rewards',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: AppColors.secondaryGold,
                          size: 13,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formattedPoints(int points) {
    if (points >= 1000) {
      final str = points.toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        buffer.write(str[i]);
        count++;
        if (count % 3 == 0 && i != 0) {
          buffer.write(',');
        }
      }
      return buffer.toString().split('').reversed.join('');
    }
    return points.toString();
  }
}
