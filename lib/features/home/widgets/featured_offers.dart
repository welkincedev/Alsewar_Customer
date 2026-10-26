import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../services/screens/services_screen.dart';

/// Curated Featured Offers & Campaign Packages Section.
///
/// Refined according to Desert Luxe guidelines:
/// - Light, crisp Pure White surfaces that complement rather than compete with the dark hero LoyaltyCard
/// - Gold tag & savings badges
/// - Manrope headings and DM Sans body text
/// - Smooth horizontal browsing of packages
class FeaturedOffers extends StatelessWidget {
  const FeaturedOffers({super.key});

  static const List<_OfferDetail> _offers = [
    _OfferDetail(
      title: 'Full Exterior & Polish',
      description:
          'Triple-foam hand wash, wheel de-ironing, and paint gloss sealant.',
      tag: 'POPULAR',
      savingText: 'Save 20%',
    ),
    _OfferDetail(
      title: 'Ceramic Shield Package',
      description: 'Complimentary interior sanitization with every full body ceramic polish.',
      tag: 'EXCLUSIVE',
      savingText: 'Special Value',
    ),
    _OfferDetail(
      title: 'Executive Interior Deep Clean',
      description:
          'Leather conditioning, carpet extraction, and AC ozone purification.',
      tag: 'BEST VALUE',
      savingText: 'Complimentary Wax',
    ),
    _OfferDetail(
      title: 'Maintenance Engine Bay Care',
      description:
          'Precision degreasing and protective dressing for electrical safety.',
      tag: 'SPECIAL',
      savingText: 'Quick Turnaround',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured Offers', style: AppTextStyles.sectionHeading),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.champagneGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Horizontal Package Cards List ───────────────────────────
        SizedBox(
          height: 142,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: _offers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = _offers[index];
              return _buildOfferCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard(BuildContext context, _OfferDetail item) {
    return Container(
      width: 276,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.deepBlack,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: AppColors.champagneGold,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.champagneGold.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: AppColors.champagneGold.withValues(alpha: 0.28),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    item.savingText,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.richMetallicGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.cardTitle.copyWith(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlack,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                item.description,
                style: AppTextStyles.supporting.copyWith(
                  fontFamily: AppTextStyles.bodyFont,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServicesScreen()),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Explore package',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.richMetallicGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: AppColors.richMetallicGold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferDetail {
  final String title;
  final String description;
  final String tag;
  final String savingText;

  const _OfferDetail({
    required this.title,
    required this.description,
    required this.tag,
    required this.savingText,
  });
}
