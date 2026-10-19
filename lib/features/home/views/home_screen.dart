import 'package:flutter/material.dart';

import '../../auth/models/auth_user.dart';
import '../../profile/screens/profile_screen.dart';
import '../widgets/featured_offers.dart';
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

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFD4AF37),
          onRefresh: () async {
            // Let sub-widgets refresh as needed
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
