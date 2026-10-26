import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../branches/models/branch.dart';
import '../../branches/screens/branch_detail_screen.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../../branches/screens/branch_map_screen.dart';
import '../../branches/viewmodels/branch_viewmodel.dart';
import '../../home/widgets/floating_pill_nav_bar.dart';
import '../../services/screens/services_screen.dart';
import '../models/about_us_content.dart';
import '../providers/about_us_providers.dart';

/// Al Sewar Auto Center — Premium About Us Screen.
///
/// Designed with the Desert Luxe design system and aligned with the Home Screen:
/// - Pure White canvas with crisp Deep Black and Champagne Gold accents
/// - 7 high-value modular sections powered by [aboutUsContentProvider]
/// - Live branch network integration via [branchListViewModelProvider]
/// - Verified support channels with interactive url launchers
/// - Bottom clearance accommodating the floating pill navigation bar
/// - Fully responsive across 320px–480px viewports
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
    return _ProviderScopeDetector(
      child: _AboutUsScaffold(
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

/// Fallback wrapper that injects a local [ProviderScope] only if none exists in ancestors.
class _ProviderScopeDetector extends StatelessWidget {
  final Widget child;

  const _ProviderScopeDetector({required this.child});

  @override
  Widget build(BuildContext context) {
    bool hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    if (hasScope) {
      return child;
    }
    return ProviderScope(child: child);
  }
}

class _AboutUsScaffold extends ConsumerWidget {
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const _AboutUsScaffold({
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(aboutUsContentProvider);
    final bottomClearance = FloatingPillNavBarUtils.calculateBottomClearance(
      context,
      clearance: 20.0,
    );

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation:
          floatingActionButtonLocation ??
          const FloatingAbovePillNavBarLocation(),
      appBar: AppBar(
        title: const Text('About Al Sewar'),
        backgroundColor: AppColors.deepBlack,
        foregroundColor: AppColors.champagneGold,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: bottomClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Brand Hero Section ──────────────────────────────
              _buildHeroSection(context, content.hero),
              const SizedBox(height: 20),

              // ── 2. Company Overview & Core Pillars ──────────────────
              _buildOverviewSection(context, content.overview),
              const SizedBox(height: 24),

              // ── 3. Company at a Glance (Key Metrics) ───────────────
              _buildMetricsSection(context, content.stats),
              const SizedBox(height: 24),

              // ── 4. Mission & Vision Statements ─────────────────────
              _buildMissionVisionSection(context, content.missionVision),
              const SizedBox(height: 24),

              // ── 5. Core Services Showcase ──────────────────────────
              _buildServicesSection(context, content.services),
              const SizedBox(height: 24),

              // ── 6. Branch Network Access ───────────────────────────
              _buildBranchAccessSection(context, ref),
              const SizedBox(height: 24),

              // ── 7. Verified Concierge & Support ────────────────────
              _buildContactSection(context, content.contact),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. BRAND HERO SECTION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context, CompanyHeroContent hero) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.deepBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.champagneGold.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Hero Imagery with Gradient Tint
          Positioned.fill(
            child: Image.asset(
              hero.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          // Deep Charcoal / Obsidian Vignette Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepBlack.withValues(alpha: 0.88),
                    AppColors.deepBlack.withValues(alpha: 0.94),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Content Overlay
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Al Sewar Brand Emblem Frame
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.champagneGold,
                          width: 1.2,
                        ),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Image.asset(
                        hero.logoAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.local_car_wash,
                          color: AppColors.champagneGold,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hero.title,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.headingFont,
                              color: AppColors.champagneGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hero.subtitle,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.headingFont,
                              color: AppColors.pureWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Established Tag Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(
                            alpha: 0.45,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        hero.tag,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.champagneGold,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.pureWhite.withValues(alpha: 0.08),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppColors.champagneGold,
                        size: 16,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The pinnacle benchmark of luxury automotive care and detailing in the Gulf.',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: AppColors.pureWhite,
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. COMPANY OVERVIEW & CORE PILLARS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildOverviewSection(
    BuildContext context,
    CompanyOverviewContent overview,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.champagneGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              overview.badge,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                color: AppColors.champagneGold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            overview.headline,
            style: const TextStyle(
              fontFamily: AppTextStyles.headingFont,
              color: AppColors.deepBlack,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            overview.description,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.subtleBorder),
          const SizedBox(height: 14),
          // Core Pillars
          ...overview.pillars.map((pillar) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.softWhite,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: AppColors.subtleBorder),
                    ),
                    child: Icon(
                      pillar.icon,
                      color: AppColors.champagneGold,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pillar.title,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.deepBlack,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pillar.description,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: AppColors.textSecondary,
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
          }),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. COMPANY AT A GLANCE (KEY METRICS)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMetricsSection(BuildContext context, List<CompanyStat> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('At a Glance', style: AppTextStyles.sectionHeading),
        const SizedBox(height: 12),
        // 2x2 Grid of Key Statistics
        Row(
          children: [
            Expanded(child: _buildStatCard(stats[0])),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard(stats[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatCard(stats[2])),
            const SizedBox(width: 10),
            Expanded(child: _buildStatCard(stats[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(CompanyStat stat) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  stat.icon,
                  color: AppColors.champagneGold,
                  size: 16,
                ),
              ),
              if (stat.subLabel != null)
                Flexible(
                  child: Text(
                    stat.subLabel!,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.textLight,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: const TextStyle(
              fontFamily: AppTextStyles.headingFont,
              color: AppColors.deepBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.label,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. MISSION & VISION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMissionVisionSection(
    BuildContext context,
    MissionVisionContent mv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Purpose & Outlook', style: AppTextStyles.sectionHeading),
        const SizedBox(height: 12),
        _buildPhilosophyCard(
          icon: mv.missionIcon,
          title: mv.missionTitle,
          body: mv.missionBody,
        ),
        const SizedBox(height: 12),
        _buildPhilosophyCard(
          icon: mv.visionIcon,
          title: mv.visionTitle,
          body: mv.visionBody,
        ),
      ],
    );
  }

  Widget _buildPhilosophyCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.deepBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.champagneGold, size: 22),
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
                    color: AppColors.deepBlack,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. OUR SERVICES
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildServicesSection(
    BuildContext context,
    List<ServiceDivision> services,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('Core Services', style: AppTextStyles.sectionHeading),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicesScreen()),
              ),
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.champagneGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...services.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.subtleBorder),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      color: AppColors.champagneGold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.headingFont,
                                  color: AppColors.deepBlack,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (item.tag != null) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.softWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.subtleBorder,
                                  ),
                                ),
                                child: Text(
                                  item.tag!,
                                  style: const TextStyle(
                                    fontFamily: AppTextStyles.bodyFont,
                                    color: AppColors.textLight,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.description,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. BRANCH NETWORK ACCESS
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBranchAccessSection(BuildContext context, WidgetRef ref) {
    final branchAsync = ref.watch(branchListViewModelProvider);
    final countText = branchAsync.when(
      data: (branches) => '${branches.length} Locations Active',
      loading: () => 'Locating Network...',
      error: (_, _) => 'Gulf Network',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.deepBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: AppColors.champagneGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Al Sewar Branch Network',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        color: AppColors.deepBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      countText,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFont,
                        color: AppColors.champagneGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Locate nearby Al Sewar centers, check real-time business hours, or contact branch managers directly.',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Live branch preview snippet if data is available
          branchAsync.when(
            data: (branches) {
              if (branches.isEmpty) return const SizedBox.shrink();
              final previewBranches = branches.take(2).toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: previewBranches.map((branch) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _buildBranchMiniCard(context, branch),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          LayoutBuilder(
            builder: (context, constraints) {
              final exploreButton = FilledButton.icon(
                icon: const Icon(Icons.map_outlined, size: 16),
                label: const Text(
                  'Explore on Map',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.deepBlack,
                  foregroundColor: AppColors.champagneGold,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BranchMapScreen()),
                ),
              );

              final listButton = OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepBlack,
                  side: const BorderSide(color: AppColors.subtleBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BranchListScreen()),
                ),
                child: const Text(
                  'View All Service Centers',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );

              if (constraints.maxWidth < 270) {
                return Column(
                  children: [
                    SizedBox(width: double.infinity, child: exploreButton),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: listButton),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: exploreButton),
                  const SizedBox(width: 10),
                  Expanded(child: listButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBranchMiniCard(BuildContext context, Branch branch) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BranchDetailScreen(branchId: branch.id),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 16,
              color: AppColors.champagneGold,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                branch.name,
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepBlack,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              branch.city,
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 11,
                color: AppColors.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 14,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 7. VERIFIED CONCIERGE & SUPPORT
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildContactSection(
    BuildContext context,
    ContactSupportContent contact,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.subtleBorder),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.champagneGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.headset_mic_outlined,
                  color: AppColors.champagneGold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.sectionTitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        color: AppColors.deepBlack,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      contact.sectionSubtitle,
                      style: const TextStyle(
                        fontFamily: AppTextStyles.bodyFont,
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildContactRow(
            icon: Icons.phone_outlined,
            title: contact.phoneTitle,
            value: contact.phoneNumber,
            onTap: () async {
              final uri = Uri.parse(
                'tel:${contact.phoneNumber.replaceAll(' ', '')}',
              );
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          const Divider(height: 18, color: AppColors.subtleBorder),
          _buildContactRow(
            icon: Icons.email_outlined,
            title: contact.emailTitle,
            value: contact.emailAddress,
            onTap: () async {
              final uri = Uri.parse('mailto:${contact.emailAddress}');
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
          ),
          const Divider(height: 18, color: AppColors.subtleBorder),
          _buildContactRow(
            icon: Icons.chat_bubble_outline,
            title: contact.whatsappTitle,
            value: contact.whatsappSubtitle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BranchMapScreen()),
              );
            },
          ),
          const Divider(height: 18, color: AppColors.subtleBorder),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_outlined,
                  size: 18,
                  color: AppColors.champagneGold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.operatingHoursTitle,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          fontSize: 11,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        contact.operatingHours,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          fontSize: 12.5,
                          color: AppColors.deepBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.champagneGold),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 11,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 13,
                      color: AppColors.deepBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}
