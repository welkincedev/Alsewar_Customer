import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/api_constants.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../../home/widgets/floating_pill_nav_bar.dart';

/// Development-stage About Us Screen highlighting company background,
/// core automotive care services, and operational standards.
class AboutUsScreen extends StatelessWidget {
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AboutUsScreen({
    super.key,
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
      appBar: AppBar(
        title: const Text('About Al Sewar'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: bottomClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondaryGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logos/AlSewarlogo-removebg.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.local_car_wash,
                    color: AppColors.secondaryGold,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Al Sewar Auto Center',
                style: AppTextStyles.heading.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                'Excellence in Vehicle Care & Detailing',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.secondaryGold,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Mission Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.charcoalGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.workspace_premium,
                          color: AppColors.secondaryGold,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Our Commitment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Al Sewar Auto Center delivers unmatched automotive wash, premium detailing, and routine care services. Utilizing state-of-the-art water filtration, pH-balanced formulas, and meticulous hand-craftsmanship, we preserve your vehicle’s showroom shine and longevity.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Key Highlights
              _buildFeatureTile(
                icon: Icons.auto_awesome,
                title: 'Precision Detailing',
                description: 'Multi-stage clay bar decontamination, ceramic sealant, and interior steam rejuvenation.',
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.eco_outlined,
                title: 'Eco-Conscious Washing',
                description: 'Optimized water-recycling and biodegradable cleansers gentle on paint and the environment.',
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                icon: Icons.verified_user_outlined,
                title: 'Certified Technicians',
                description: 'Trained vehicle specialists ensuring high inspection standards from intake to delivery.',
              ),
              const SizedBox(height: 24),

              // Contact & Branch Quick Nav
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONNECT WITH US',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _contactRow(
                      Icons.phone_outlined,
                      ApiConstants.supportPhone,
                    ),
                    const SizedBox(height: 8),
                    _contactRow(
                      Icons.email_outlined,
                      ApiConstants.supportEmail,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlack,
                          foregroundColor: AppColors.secondaryGold,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.storefront, size: 18),
                        label: const Text('View All Service Centers'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BranchListScreen(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.secondaryGold, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyPrimary.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySecondary.copyWith(
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
