import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/membership_tier.dart';

/// Polished modal bottom sheet displaying customer membership details,
/// tier progression, earning rules, and rewards action.
class MembershipDetailsBottomSheet extends StatelessWidget {
  final CustomerMembership membership;
  final VoidCallback? onExploreRewards;

  const MembershipDetailsBottomSheet({
    super.key,
    required this.membership,
    this.onExploreRewards,
  });

  /// Static helper to display the sheet from anywhere
  static Future<void> show(
    BuildContext context, {
    required CustomerMembership membership,
    VoidCallback? onExploreRewards,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MembershipDetailsBottomSheet(
        membership: membership,
        onExploreRewards: onExploreRewards,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.warmPorcelain,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        bottom: bottomInset + bottomPadding + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag Handle ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.sandBeige,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Top Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Membership Details',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepCharcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.deepCharcoal,
                    ),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── 1. Hero Points & Tier Summary Card ───────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildHeroCard(),
            ),
            const SizedBox(height: 16),

            // ── 2. Tier Progression Card (or Platinum Achieved) ──────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: membership.isPlatinum
                  ? _buildPlatinumAchievedCard()
                  : _buildProgressionCard(),
            ),
            const SizedBox(height: 16),

            // ── 3. Earning Rule & Tier Brackets Card ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildEarningRuleCard(),
            ),
            const SizedBox(height: 24),

            // ── 4. View Rewards CTA Button ───────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepCharcoal,
                    foregroundColor: AppColors.champagneGold,
                    splashFactory: InkRipple.splashFactory,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    onExploreRewards?.call();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.card_giftcard_outlined,
                        color: AppColors.champagneGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'View Rewards',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.champagneGold,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Points Card ───────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.charcoalGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x181C1C1B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AVAILABLE POINTS',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              _buildTierBadge(),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                CustomerMembership.formatPoints(membership.points),
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  color: AppColors.champagneGold,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Points',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  membership.memberName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (membership.membershipId != null) ...[
                const SizedBox(width: 8),
                Text(
                  'ID: ${membership.membershipId}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge() {
    final isSilver = membership.tier == MembershipTier.silver;
    final isPlat = membership.tier == MembershipTier.platinum;

    Gradient badgeGrad;
    Color textColor;
    if (isSilver) {
      badgeGrad = AppColors.silverBadgeGradient;
      textColor = AppColors.deepCharcoal;
    } else if (isPlat) {
      badgeGrad = AppColors.platinumBadgeGradient;
      textColor = const Color(0xFF101216);
    } else {
      badgeGrad = AppColors.goldGradient;
      textColor = AppColors.deepCharcoal;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: badgeGrad,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSilver ? null : AppColors.goldGlow,
      ),
      child: Text(
        membership.tier.displayName.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTextStyles.headingFont,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: textColor,
        ),
      ),
    );
  }

  // ── Progression Card (Silver & Gold) ───────────────────────────────────
  Widget _buildProgressionCard() {
    final nextTierName = membership.nextTierName ?? '';
    final requiredPoints = membership.nextTierRequiredPoints ?? 0;
    final remainingPoints = membership.pointsRemainingToNextTier ?? 0;
    final progressFraction = membership.progressToNextTier ?? 0.0;
    final percent = (progressFraction * 100).toInt();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sandBeige, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next Tier: $nextTierName',
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.champagneGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: AppColors.sandBeige.withValues(alpha: 0.6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.champagneGold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Required Points',
                  value: CustomerMembership.formatPoints(requiredPoints),
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.sandBeige),
              Expanded(
                child: _buildMetricTile(
                  label: 'Points Remaining',
                  value: CustomerMembership.formatPoints(remainingPoints),
                  highlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Earn ${CustomerMembership.formatPoints(remainingPoints)} more points to unlock $nextTierName membership benefits.',
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 11,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.champagneGold : AppColors.deepCharcoal,
          ),
        ),
      ],
    );
  }

  // ── Platinum Achieved Card ─────────────────────────────────────────────
  Widget _buildPlatinumAchievedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.goldGlow,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.deepCharcoal,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Platinum Membership Achieved',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepCharcoal,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'You have achieved the highest membership tier at Al Sewar Auto Center. Enjoy maximum privileges, priority vehicle bay access, and premier concierge care.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Earning Rule Card ──────────────────────────────────────────────────
  Widget _buildEarningRuleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sandBeige, width: 1),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: AppColors.champagneGold,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Earning Rule',
                style: TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepCharcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Every AED 100 spent earns 1 point across all Al Sewar service centers.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 13,
              color: AppColors.deepCharcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: AppColors.sandBeige),
          const SizedBox(height: 12),
          const Text(
            'Membership Tiers',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          _buildTierRow(
            'Silver',
            '0 – 25,000 points',
            isCurrent: membership.tier == MembershipTier.silver,
          ),
          const SizedBox(height: 4),
          _buildTierRow(
            'Gold',
            '25,001 – 50,000 points',
            isCurrent: membership.tier == MembershipTier.gold,
          ),
          const SizedBox(height: 4),
          _buildTierRow(
            'Platinum',
            '50,001+ points',
            isCurrent: membership.tier == MembershipTier.platinum,
          ),
        ],
      ),
    );
  }

  Widget _buildTierRow(
    String tierName,
    String range, {
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.champagneGold.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (isCurrent) ...[
                const Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: AppColors.champagneGold,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                tierName,
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  fontSize: 13,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  color: isCurrent
                      ? AppColors.deepCharcoal
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            range,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppColors.champagneGold : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
