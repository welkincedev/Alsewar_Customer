import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../services/screens/services_screen.dart';

/// Featured offers section displaying curated deals and package promotions.
class FeaturedOffers extends StatelessWidget {
  const FeaturedOffers({super.key});

  final List<_OfferDetail> _offers = const [
    _OfferDetail(
      title: 'Full Exterior & Polish',
      description:
          'Triple-foam hand wash, wheel de-ironing, and paint gloss sealant.',
      tag: 'POPULAR',
      savingText: 'Save 20%',
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
              Text(
                'Featured Offers',
                style: AppTextStyles.title.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                ),
                child: const Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppColors.secondaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── Horizontal Cards List ───────────────────────────────────
        SizedBox(
          height: 154,
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
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                  color: AppColors.primaryBlack,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(
                    color: AppColors.secondaryGold,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.savingText,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: AppTextStyles.bodyPrimary.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                item.description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                  fontSize: 11,
                  height: 1.3,
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
              children: const [
                Text(
                  'Explore package',
                  style: TextStyle(
                    color: AppColors.secondaryGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 12,
                  color: AppColors.secondaryGold,
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
