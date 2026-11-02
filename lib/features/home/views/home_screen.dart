import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../branches/viewmodels/branch_viewmodel.dart';
import '../../profile/screens/profile_screen.dart';
import '../../services/viewmodels/service_providers.dart';
import '../../vehicles/viewmodels/vehicle_providers.dart';
import '../../visits/viewmodels/visit_providers.dart';
import '../models/membership_tier.dart';
import '../widgets/featured_offers.dart';
import '../widgets/floating_pill_nav_bar.dart';
import '../widgets/home_header.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/loyalty_card.dart';
import '../widgets/promotional_banner.dart';

/// Al Sewar Auto Center — Premium Home Page View.
///
/// Built according to Desert Luxe guidelines and the streamlined hierarchy:
/// - 1. Welcome / Hero: Compact header, branded emblem, customer greeting, notification & profile
/// - 2. Rewards Wallet: Prominent loyalty card (the single dark luxury hero anchor)
/// - 3. Quick Actions: 4 evenly spaced shortcuts (Branches, Services, History, Vehicles)
/// - 4. Promotional Banner: Backend campaign banners (hidden when empty)
/// - 5. Featured Offers: Curated promotional package showcase positioned directly below banners
class HomeScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider).value;
    final currentUser = authState?.user ?? user;

    final bottomClearance = FloatingPillNavBarUtils.calculateBottomClearance(
      context,
      clearance: 20.0,
    );

    // Dynamic customer membership resolved directly from actual backend user data
    final membership = CustomerMembership.fromUser(
      memberName: currentUser.displayName,
      membershipId: currentUser.membershipId,
      points: currentUser.loyaltyPoints ?? 0,
      backendTier: currentUser.membershipTier,
    );

    return Theme(
      data: Theme.of(context).copyWith(splashFactory: InkRipple.splashFactory),
      child: Scaffold(
        backgroundColor: AppColors.pureWhite,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation:
            floatingActionButtonLocation ??
            const FloatingAbovePillNavBarLocation(),
        body: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: AppColors.champagneGold,
            onRefresh: () async {
              try {
                await Future.wait([
                  ref.read(vehicleViewModelProvider.notifier).refresh(),
                  ref.read(visitViewModelProvider.notifier).refresh(),
                  ref.read(branchListViewModelProvider.notifier).refresh(),
                  ref.refresh(customerServicesProvider.future),
                ]);
              } catch (_) {
                // Gracefully handle refresh in offline/test mode
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottomClearance),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Welcome / Hero (Emblem, Greeting, Notifications & Profile Shortcut)
                  HomeHeader(
                    user: currentUser,
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
                  const SizedBox(height: 16),

                  // 2. Rewards Wallet (Dynamic Premium Membership Card)
                  LoyaltyCard(
                    membership: membership,
                    memberName: currentUser.displayName,
                    membershipCategory: membership.tier.displayName,
                    pointsBalance: membership.points,
                    pointsLabel: 'Points',
                    membershipId: currentUser.membershipId,
                    progressToNextTier: membership.progressToNextTier,
                    onExploreRewards: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: currentUser),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. Quick Actions (Branches, Services, History, Vehicles)
                  HomeQuickActions(user: currentUser),
                  const SizedBox(height: 20),

                  // 4. Promotional Banner (Shows backend banners or 3 local fallback banners)
                  PromotionalBanner(user: currentUser),
                  const SizedBox(height: 18),

                  // 5. Featured Offers (Directly below banner section)
                  const FeaturedOffers(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
