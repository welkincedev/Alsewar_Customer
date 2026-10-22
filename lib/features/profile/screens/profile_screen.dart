import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../../reviews/screens/reviews_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../visits/screens/visits_screen.dart';

/// Dedicated Profile Screen for the customer.
///
/// Organized into:
/// - Header with user avatar and membership status
/// - MY PROFILE (Customer & Personal info)
/// - MY ACTIVITIES (Vehicles, Service History, Services, Reviews, Loyalty Points)
/// - SUPPORT & SETTINGS (Customer Support, WhatsApp Support, Branches, Logout)
class ProfileScreen extends ConsumerWidget {
  final AuthUser? user;
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider).value;
    final currentUser = user ?? authState?.user;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: AppColors.secondaryGold,
        ),
        body: const Center(
          child: Text(
            'No active session found.',
            style: AppTextStyles.bodySecondary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.warmPorcelain,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Header Profile Card ───────────────────────────
              _buildHeaderCard(context, currentUser),
              const SizedBox(height: 24),

              // ── MY PROFILE SECTION ─────────────────────────────────
              _buildSectionHeader('MY PROFILE'),
              const SizedBox(height: 10),
              _buildProfileCard([
                _infoTile(
                  icon: Icons.person_outline,
                  label: 'Full Name',
                  value: currentUser.displayName,
                ),
                _divider(),
                _infoTile(
                  icon: Icons.badge_outlined,
                  label: 'Username',
                  value: currentUser.username,
                ),
                _divider(),
                _infoTile(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value:
                      (currentUser.phone != null &&
                          currentUser.phone!.isNotEmpty)
                      ? currentUser.phone!
                      : 'Not provided',
                ),
                _divider(),
                _infoTile(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  value: currentUser.email.isNotEmpty
                      ? currentUser.email
                      : 'Not provided',
                ),
              ]),
              const SizedBox(height: 24),

              // ── MY ACTIVITIES SECTION ──────────────────────────────
              _buildSectionHeader('MY ACTIVITIES'),
              const SizedBox(height: 10),
              _buildProfileCard([
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
                  subtitle: 'Browse carwash, detailing & maintenance packages',
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
                  subtitle: 'Gold Member · 2,450 Coins (Development Tier)',
                  trailingBadge: '2,450',
                  onTap: () => _showLoyaltyInfo(context),
                ),
              ]),
              const SizedBox(height: 24),

              // ── SUPPORT & SETTINGS SECTION ─────────────────────────
              _buildSectionHeader('SUPPORT & SETTINGS'),
              const SizedBox(height: 10),
              _buildProfileCard([
                _actionTile(
                  icon: Icons.storefront_outlined,
                  title: 'Service Centers',
                  subtitle: 'Find Al Sewar branches & business hours',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BranchListScreen()),
                  ),
                ),
                _divider(),
                _actionTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Customer Support',
                  subtitle: 'Assistance, operating hours & helpline',
                  onTap: () => _showCustomerSupportDialog(context),
                ),
                _divider(),
                _actionTile(
                  icon: Icons.chat_outlined,
                  title: 'WhatsApp Support',
                  subtitle: 'Direct help via official WhatsApp channel',
                  trailingWidget: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Direct',
                      style: TextStyle(
                        color: Color(0xFF1E7E34),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => _openWhatsAppSupport(context),
                ),
                _divider(),
              ]),
              const SizedBox(height: 24),

              // ── Sign Out Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _confirmSignOut(context, ref),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets ────────────────────────────────────────────────────────

  Widget _buildHeaderCard(BuildContext context, AuthUser user) {
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
        boxShadow: [
          BoxShadow(
            color: AppColors.deepCharcoal.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with gold border
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryGold, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.secondaryGold,
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : 'C',
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  color: AppColors.primaryBlack,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email.isNotEmpty
                      ? user.email
                      : (user.phone ?? user.username),
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'GOLD MEMBER',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: AppColors.deepCharcoal,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Customer Account',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: AppTextStyles.headingFont,
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return const Divider(height: 1, color: AppColors.borderLight);
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryBlack),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyPrimary.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: AppColors.primaryBlack),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyPrimary.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textLight,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingBadge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    trailingBadge,
                    style: const TextStyle(
                      color: AppColors.secondaryGold,
                      fontSize: 11,
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
                Icons.arrow_forward_ios,
                size: 13,
                color: AppColors.textLight,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Actions & Dialogs ──────────────────────────────────────────────

  void _showLoyaltyInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      color: AppColors.secondaryGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Loyalty Program',
                      style: AppTextStyles.heading,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Preview Stage',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Your current membership tier is Gold Member with 2,450 points. As per backend API specification, real-time loyalty point earning and redemption endpoints are scheduled for upcoming backend phases.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    foregroundColor: AppColors.secondaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomerSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.headset_mic, color: AppColors.secondaryGold),
            SizedBox(width: 10),
            Expanded(
              child: Text('Customer Support', overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Al Sewar Customer Assistance is available Saturday to Thursday, 8:00 AM - 10:00 PM.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: 14),
            _dialogInfoRow(Icons.phone, 'Helpline', ApiConstants.supportPhone),
            const SizedBox(height: 8),
            _dialogInfoRow(Icons.email, 'Email', ApiConstants.supportEmail),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openWhatsAppSupport(BuildContext context) {
    final number = ApiConstants.whatsappSupportNumber;
    if (number.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.chat, color: Color(0xFF25D366)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'WhatsApp Support',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: const Text(
            'The official Al Sewar WhatsApp support number is currently being configured by administration. Please reach our helpline directly via Customer Support.',
            style: AppTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Contact via WhatsApp'),
          content: Text(
            'Official WhatsApp Support: $number\n\nYou can chat with an Al Sewar representative directly for bookings and queries.',
            style: AppTextStyles.bodySecondary,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: number));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('WhatsApp number copied to clipboard.'),
                    backgroundColor: AppColors.primaryBlack,
                  ),
                );
              },
              child: const Text('Copy Number'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  Widget _dialogInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryGold),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value, style: AppTextStyles.bodySecondary)),
      ],
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
