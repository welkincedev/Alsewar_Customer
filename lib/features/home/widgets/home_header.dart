import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../auth/models/auth_user.dart';
import '../../profile/screens/profile_screen.dart';

/// Top header for Home Screen including:
/// - App bar with logo, notification icon with badge, and profile avatar button
/// - Warm customer greeting with customer display name
class HomeHeader extends StatelessWidget {
  final AuthUser user;
  final VoidCallback? onNotificationTap;

  const HomeHeader({super.key, required this.user, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── App Bar Row ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              // Al Sewar Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/logos/AlSewar_logoonly.png',
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_car_wash,
                      color: AppColors.secondaryGold,
                      size: 26,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Notification Icon with Unread Badge
              Stack(
                children: [
                  _circleIconButton(
                    icon: Icons.notifications_outlined,
                    onTap:
                        onNotificationTap ??
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No new notifications.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Profile Avatar Button (Navigates to ProfileScreen)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(user: user),
                    ),
                  );
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondaryGold,
                      width: 1.5,
                    ),
                    color: AppColors.primaryBlack,
                  ),
                  child: Center(
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(
                        color: AppColors.secondaryGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Customer Greeting ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Day,',
                style: AppTextStyles.bodySecondary.copyWith(
                  fontFamily: AppTextStyles.bodyFont,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.displayName.isNotEmpty
                    ? user.displayName
                    : 'Valued Customer',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading.copyWith(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: AppColors.deepCharcoal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.sandBeige),
          boxShadow: AppColors.softShadow,
        ),
        child: Icon(icon, size: 21, color: AppColors.deepCharcoal),
      ),
    );
  }
}
