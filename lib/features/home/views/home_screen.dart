import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/featured_offers.dart';
import '../widgets/floating_pill_nav_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/loyalty_card.dart';
import '../widgets/promotional_banner.dart';
import '../widgets/service_categories.dart';

/// Al Sewar Auto Center — Home Screen View.
///
/// Follows the updated client UI reference:
/// 1. App bar with notifications & profile button
/// 2. Customer greeting
/// 3. Prominent, flexible loyalty membership card
/// 4. Service / category shortcut grid
/// 5. Promotional banner carousel
/// 6. Featured offers section
class HomeScreen extends StatelessWidget {
  final AuthUser user;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const HomeScreen({
    super.key,
    required this.user,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final bottomClearance = FloatingPillNavBarUtils.calculateBottomClearance(
      context,
      clearance: 32.0,
    );

    return Scaffold(
      backgroundColor: AppColors.warmPorcelain,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation:
          floatingActionButtonLocation ??
          const FloatingAbovePillNavBarLocation(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.champagneGold,
          onRefresh: () async {
            // Let sub-widgets refresh as needed
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: bottomClearance),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. App Bar with logo, notifications & profile button + 2. Customer Greeting
                HomeHeader(
                  user: user,
                  onNotificationTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'All caught up! No unread notifications.',
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),

                // 3. Prominent Loyalty Membership Card
                LoyaltyCard(
                  memberName: user.displayName,
                  membershipCategory: 'Gold Member',
                  pointsBalance: 2450,
                  pointsLabel: 'Coins',
                  benefitsText: 'Your loyalty, rewarded.',
                  progressToNextTier: 0.70,
                  nextTierLabel: '550 points to Platinum',
                  isDevelopmentPlaceholder: true,
                  onExploreRewards: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: user),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // 4. Service / Category Shortcut Grid
                const ServiceCategories(),
                const SizedBox(height: 24),

                // 5. Promotional Banner Carousel
                const PromotionalBanner(),
                const SizedBox(height: 24),

                // 6. Featured Offers Section
                const FeaturedOffers(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
