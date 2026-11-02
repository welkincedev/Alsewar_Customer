import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../auth/models/auth_user.dart';
import '../../profile/screens/profile_screen.dart';

/// Al Sewar Customer App — Welcome & Top Header Bar.
///
/// Features:
/// - Compact top bar with brand emblem, unread notification button, and profile avatar shortcut
/// - Warm, personalized customer greeting
/// - Strict 44x44px minimum touch targets for accessible interaction
class HomeHeader extends StatelessWidget {
  final AuthUser user;
  final VoidCallback? onNotificationTap;

  const HomeHeader({super.key, required this.user, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top Navigation Row ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              // Al Sewar Brand Emblem
              Container(
                width: 44,
                height: 44,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.subtleBorder, width: 1.0),
                  boxShadow: AppColors.softShadow,
                ),
                child: Image.asset(
                  'assets/logos/AlSewar_logoonly.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Center(
                    child: Icon(
                      Icons.local_car_wash,
                      color: AppColors.champagneGold,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Unread Notification Button (Accessible 44x44 minimum hit target)
              Semantics(
                button: true,
                label: 'Notifications',
                child: InkResponse(
                  onTap:
                      onNotificationTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'All caught up! No unread notifications.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                  radius: 24,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.subtleBorder),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: const Icon(
                          Icons.notifications_none_outlined,
                          size: 22,
                          color: AppColors.deepBlack,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.pureWhite,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Profile Avatar Shortcut (Accessible 44x44 minimum hit target)
              Semantics(
                button: true,
                label: 'My Profile',
                child: InkResponse(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: user),
                      ),
                    );
                  },
                  radius: 24,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.champagneGold,
                        width: 1.5,
                      ),
                      color: AppColors.deepBlack,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x25C6A66B),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: AppColors.champagneGold,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
