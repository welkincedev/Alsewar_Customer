import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../about/screens/about_us_screen.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../../branches/screens/branch_map_screen.dart';
import '../../home/models/membership_tier.dart';
import '../../home/widgets/membership_details_bottom_sheet.dart';
import '../../reviews/screens/reviews_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../visits/screens/visits_screen.dart';
import 'edit_profile_screen.dart';

/// Al Sewar Customer App — My Account & Profile Screen.

/// Refined according to the Desert Luxe design system:
/// - Compact header with back navigation, My Account title, Help and Sign Out actions
/// - Customer profile summary card with avatar, member tier badge, and quick edit
/// - Clean grouped cards for Personal Information, Activities, and Support & Settings
/// - Full-screen Edit Profile navigation for editing customer information
/// - Interactive dialogs for Notifications, Security, Terms, and App Rating
/// - Social links, version info, and prominent Sign Out action
class ProfileScreen extends ConsumerWidget {
  final AuthUser? user;
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider).value;
    final currentUser = authState?.user ?? user;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.pureWhite,
        appBar: AppBar(
          title: const Text('My Account'),
          backgroundColor: AppColors.pureWhite,
          foregroundColor: AppColors.deepBlack,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'No active session found.',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }

    final membership = CustomerMembership.fromUser(
      memberName: currentUser.displayName,
      membershipId: currentUser.membershipId,
      points: currentUser.loyaltyPoints ?? 0,
      backendTier: currentUser.membershipTier,
    );

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text(
          'My Account',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlack,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.deepBlack,
            size: 18,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppColors.deepNavy,
              size: 21,
            ),
            tooltip: 'Customer Support',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutUsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.champagneGold,
          backgroundColor: AppColors.deepNavy,
          onRefresh: () async {
            try {
              await ref.read(authViewModelProvider.notifier).refreshProfile();
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Customer Profile Summary Card ────────────────────
                _buildSummaryCard(context, currentUser, membership),
                const SizedBox(height: 22),

                // ── 3. MY ACTIVITIES ─────────────────────────────────────
                _buildSectionHeader('MY ACTIVITIES'),
                const SizedBox(height: 10),
                _buildGroupedCard([
                  _actionTile(
                    icon: Icons.directions_car_outlined,
                    title: 'My Vehicles',
                    subtitle: 'Manage registered cars & license plates',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.history_outlined,
                    title: 'Service History',
                    subtitle: 'Past visits, status tracking & stages',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VisitsScreen()),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.miscellaneous_services_outlined,
                    title: 'My Services',
                    subtitle:
                        'Browse carwash, detailing & maintenance packages',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServicesScreen()),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.star_outline,
                    title: 'My Reviews',
                    subtitle: 'Ratings & feedback submitted for visits',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewsScreen()),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.workspace_premium_outlined,
                    title: 'Loyalty Points & Rewards',
                    subtitle:
                        '${membership.tier.displayName} · ${membership.points} Points',
                    trailingBadge: '${membership.points}',
                    onTap: () => MembershipDetailsBottomSheet.show(
                      context,
                      membership: membership,
                    ),
                  ),
                ]),
                const SizedBox(height: 22),

                // ── 4. SUPPORT & SETTINGS ────────────────────────────────
                _buildSectionHeader('SUPPORT & SETTINGS'),
                const SizedBox(height: 10),
                _buildGroupedCard([
                  _actionTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Push notifications & visit stage updates',
                    onTap: () => _showNotificationsDialog(context),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.security_outlined,
                    title: 'Security',
                    subtitle: 'Account protection & login session',
                    onTap: () => _showSecurityDialog(context, currentUser),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Customer Support',
                    subtitle:
                        'About Al Sewar, mission, core services & contact',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.chat_outlined,
                    title: 'WhatsApp Support',
                    subtitle:
                        'Select a branch for direct verified WhatsApp chat',
                    trailingWidget: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Branches',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: Color(0xFF1E7E34),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BranchMapScreen(),
                      ),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.storefront_outlined,
                    title: 'Service Centers',
                    subtitle: 'Find Al Sewar branches & operating hours',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BranchListScreen(),
                      ),
                    ),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.policy_outlined,
                    title: 'Terms & Policies',
                    subtitle: 'Privacy commitment & terms of service',
                    onTap: () => _showTermsDialog(context),
                  ),
                  _divider(),
                  _actionTile(
                    icon: Icons.thumb_up_alt_outlined,
                    title: 'Rate the App',
                    subtitle: 'Share your feedback on the App Store',
                    onTap: () => _showRateDialog(context),
                  ),
                ]),
                const SizedBox(height: 28),

                // ── 5. Social Links & Brand Footer ──────────────────────
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialIconButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            tooltip: 'WhatsApp',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BranchMapScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          _socialIconButton(
                            icon: Icons.language_rounded,
                            tooltip: 'Official Website',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutUsScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          _socialIconButton(
                            icon: Icons.phone_in_talk_outlined,
                            tooltip: 'Call Support',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AboutUsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Al Sewar Auto Center • Version 1.2.0',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Desert Luxe Automotive Care',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.textLight,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── 6. Prominent Sign Out / Logout Action ───────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 19,
                    ),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFF8B4B4),
                        width: 1.2,
                      ),
                      backgroundColor: const Color(0xFFFDF2F2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _confirmSignOut(context, ref),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper Widgets ──────────────────────────────────────────────────

  Widget _buildSummaryCard(
    BuildContext context,
    AuthUser user,
    CustomerMembership membership,
  ) {
    final initials = user.displayName.isNotEmpty
        ? user.displayName[0].toUpperCase()
        : 'C';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtleBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with Champagne Gold Border
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.champagneGold, width: 2),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.deepNavy,
              backgroundImage:
                  (user.profilePicture != null &&
                      user.profilePicture!.isNotEmpty)
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child:
                  (user.profilePicture == null || user.profilePicture!.isEmpty)
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        color: AppColors.champagneGold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // User details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: AppColors.deepBlack,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.email.isNotEmpty ? user.email : user.username,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 7),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${membership.tier.displayName.toUpperCase()} MEMBER',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: AppColors.champagneGold,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      '${membership.points} pts',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        color: AppColors.richMetallicGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Edit button
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.deepNavy,
            ),
            tooltip: 'Edit Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTextStyles.headingFont,
          color: AppColors.deepNavy,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: AppColors.subtleBorder);
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailingBadge,
    Widget? trailingWidget,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 19, color: AppColors.deepNavy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.deepBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFont,
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.deepNavy,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trailingBadge,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      color: AppColors.champagneGold,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (trailingWidget != null) ...[
                trailingWidget,
                const SizedBox(width: 8),
              ],
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.subtleBorder, width: 1.0),
        ),
        child: Icon(icon, size: 18, color: AppColors.deepNavy),
      ),
    );
  }

  // ── Dialogs & Interactions ──────────────────────────────────────────

  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Your notifications are active. You will receive live alerts for:',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '• Vehicle wash and service stage updates',
              style: TextStyle(fontSize: 12.5),
            ),
            SizedBox(height: 6),
            Text(
              '• Exclusive loyalty coin rewards and tier upgrades',
              style: TextStyle(fontSize: 12.5),
            ),
            SizedBox(height: 6),
            Text(
              '• Al Sewar seasonal campaigns and offers',
              style: TextStyle(fontSize: 12.5),
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.deepNavy),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showSecurityDialog(BuildContext context, AuthUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Account Security',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Al Sewar account is protected with secure JWT authentication.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: const [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF1E7E34),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Active verified customer session',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.champagneGold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Account ID: #${user.id}',
                  style: const TextStyle(fontSize: 12.5),
                ),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.deepNavy),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Terms & Policies',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Al Sewar Auto Center is committed to transparency, service quality, and data security.\n\n'
            '• Service Warranty: All mechanical repairs and ceramic coating applications are protected under official Al Sewar craftsmanship standards.\n'
            '• Privacy Commitment: Customer vehicle details, contact information, and service history are securely stored and never shared with unauthorized third parties.\n'
            '• Loyalty Program: Reward coins are credited automatically upon service completion and can be redeemed at all participating service centers.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.deepNavy),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Enjoying Al Sewar?',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your ratings help us maintain premium automotive service quality across all our branches.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.star,
                    color: AppColors.champagneGold,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Maybe Later'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.deepNavy),
            onPressed: () {
              Navigator.pop(ctx);
              AppSnackBar.showSuccess(
                context,
                'Thank you for rating Al Sewar Auto Center!',
              );
            },
            child: const Text('Submit Rating'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of your Al Sewar account?',
          style: AppTextStyles.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authViewModelProvider.notifier).logout();

      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }
}
