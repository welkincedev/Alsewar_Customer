import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../services/screens/services_screen.dart';

/// Promotional banner carousel for campaigns, seasonal discounts, and brand offers.
class PromotionalBanner extends StatefulWidget {
  const PromotionalBanner({super.key});

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  final List<_PromoItem> _promos = const [
    _PromoItem(
      badge: 'EXCLUSIVE',
      title: 'Ceramic Shield Package',
      subtitle: 'Complimentary interior sanitization with every full body ceramic polish.',
      accentColor: AppColors.secondaryGold,
    ),
    _PromoItem(
      badge: 'SEASONAL',
      title: 'Hydro-Wash & Wax',
      subtitle: 'Experience 4-stage pH balanced pressure wash with paint seal protection.',
      accentColor: Color(0xFFE5C158),
    ),
    _PromoItem(
      badge: 'MEMBER REWARD',
      title: 'Double Coins Days',
      subtitle: 'Earn 2x loyalty points on all maintenance services this week.',
      accentColor: AppColors.secondaryGold,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 166,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _promos.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final promo = _promos[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildBannerCard(context, promo),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // ── Dot Indicators ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _promos.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 18 : 6,
              height: 5,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.secondaryGold
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCard(BuildContext context, _PromoItem promo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF262626), Color(0xFF141414)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative watermark icon
          Positioned(
            right: -10,
            bottom: -15,
            child: Icon(
              Icons.auto_awesome,
              size: 110,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Badge + Preview Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      promo.badge,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  Text(
                    'PROMO',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              // Title and Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promo.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              // Action Link
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                ),
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: promo.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: promo.accentColor,
                      size: 13,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PromoItem {
  final String badge;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _PromoItem({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
