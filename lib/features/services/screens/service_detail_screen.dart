import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../branches/screens/branch_map_screen.dart';
import '../models/service_item.dart';

/// Al Sewar Service Detail Screen.
///
/// Provides a dedicated, full-page view for any Al Sewar automotive service.
/// Displays verified company-profile descriptions, key highlights, automotive imagery,
/// and immediate branch routing.
class ServiceDetailScreen extends StatelessWidget {
  final ServiceItem service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final imageAsset = service.effectiveImageAsset;
    final category = service.category ?? 'Al Sewar Automotive Care';
    final highlights =
        service.highlights ??
        const [
          'Certified Al Sewar Automotive Craftsmanship',
          'Modern Computerized Diagnostic Equipment',
          'Genuine OEM & High-Grade Replacement Parts',
          'Transparent Quotation & Upfront Pricing',
        ];

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: CustomScrollView(
        slivers: [
          // ── 1. Automotive Hero Header with Back Button ────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.pureWhite,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.pureWhite.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.deepBlack,
                  ),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Back',
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: AppColors.softWhite,
                      child: const Center(
                        child: Icon(
                          Icons.car_repair,
                          size: 64,
                          color: AppColors.champagneGold,
                        ),
                      ),
                    ),
                  ),
                  // Dark specular gradient overlay for contrast and luxury finish
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                  // Bottom category pill badge
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.champagneGold,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepBlack,
                              letterSpacing: 0.6,
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

          // ── 2. Service Information Body ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlack,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (service.tagline != null &&
                      service.tagline!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      service.tagline!,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFont,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.champagneGold,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.subtleBorder, height: 1),
                  const SizedBox(height: 16),

                  // Service Overview Section
                  const Text(
                    'Service Overview',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description.isNotEmpty ? service.description : 'Certified automotive care carried out by experienced technicians using modern diagnostic tools at all Al Sewar branches.',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Key Capabilities & Highlights
                  const Text(
                    'What We Deliver',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.subtleBorder,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (int i = 0; i < highlights.length; i++) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.18,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.champagneGold,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  highlights[i],
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.bodyFont,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.deepBlack,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (i != highlights.length - 1)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                color: AppColors.subtleBorder,
                                height: 1,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // The Al Sewar Guarantee
                  const Text(
                    'The Al Sewar Standard',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlack,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildGuaranteeBadge(
                        icon: Icons.workspace_premium_outlined,
                        title: '11+ Years',
                        subtitle: 'UAE Trust',
                      ),
                      const SizedBox(width: 10),
                      _buildGuaranteeBadge(
                        icon: Icons.speed_outlined,
                        title: '20+ Years',
                        subtitle: 'Expertise',
                      ),
                      const SizedBox(width: 10),
                      _buildGuaranteeBadge(
                        icon: Icons.pin_drop_outlined,
                        title: '10 Locations',
                        subtitle: 'Northern Emirates',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── 3. Sticky Bottom Action Bar ──────────────────────────────
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          border: const Border(
            top: BorderSide(color: AppColors.subtleBorder, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BranchMapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.champagneGold,
                  ),
                  label: const Text(
                    'Find Nearest Branch',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepBlack,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuaranteeBadge({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.subtleBorder, width: 0.8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.champagneGold),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppTextStyles.headingFont,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 10.5,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
