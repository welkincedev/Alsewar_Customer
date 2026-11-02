import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../branches/screens/branch_detail_screen.dart';
import '../../branches/screens/branch_list_screen.dart';
import '../../branches/screens/branch_map_screen.dart';
import '../../branches/viewmodels/branch_viewmodel.dart';
import '../../home/widgets/floating_pill_nav_bar.dart';
import '../../services/screens/services_screen.dart';
import '../models/about_us_content.dart';
import '../providers/about_us_providers.dart';

const Color _mutedTextColor = Color(0xFF536471);

/// Al Sewar Auto Center — Premium, Image-Led About Us Screen.
///
/// Features a distinctive, high-end automotive brand presentation:
/// - Editorial hero composition blending authentic Al Sewar logo branding and luxury automotive photography
/// - Typographic heritage statement with expandable story and high-impact metric counters
/// - Split-tone Mission & Vision showcase balancing Deep Navy and Soft White surfaces
/// - Image-led horizontal visual gallery of core service divisions with real automotive imagery
/// - Live branch network presence with direct Map and Service Center directory access
/// - Verified website portal (www.alsewarauto.com) and direct helpline support
/// - Zero LayoutBuilder assertions; built entirely with responsive, crash-free flex layouts
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

class _AboutUsScaffold extends ConsumerStatefulWidget {
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const _AboutUsScaffold({
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  ConsumerState<_AboutUsScaffold> createState() => _AboutUsScaffoldState();
}

class _AboutUsScaffoldState extends ConsumerState<_AboutUsScaffold> {
  bool _isStoryExpanded = false;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(aboutUsContentProvider);
    final bottomClearance = FloatingPillNavBarUtils.calculateBottomClearance(
      context,
      clearance: 28.0,
    );

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation:
          widget.floatingActionButtonLocation ??
          const FloatingAbovePillNavBarLocation(),
      appBar: AppBar(
        title: const Text(
          'About Al Sewar',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            color: AppColors.deepNavy,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.deepNavy,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.subtleBorder, height: 1),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottomClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Premium Brand Hero Section ─────────────────────────────
              _buildHeroSection(context, content.hero),
              const SizedBox(height: 24),

              // ── 2. About Al Sewar (Editorial Heritage & Metric Matrix) ─────
              _buildWhoWeAreSection(context, content.whoWeAre),
              const SizedBox(height: 24),

              // ── 3. Mission & Vision (Split-Tone Luxury Duo) ────────────────
              _buildMissionVisionSection(context, content.missionVision),
              const SizedBox(height: 24),

              // ── 4. Our Services (Image-Led Horizontal Visual Reel) ─────────
              _buildServicesSection(context, content.services),
              const SizedBox(height: 24),

              // ── 5. Our Presence (Network Coverage & Map Navigation) ────────
              _buildBranchPresenceSection(context, ref),
              const SizedBox(height: 24),

              // ── 6. Official Verified Website ───────────────────────────────
              _buildWebsiteSection(context, content.contact.websiteUrl),
              const SizedBox(height: 20),

              // ── 7. Verified Contact & Support ──────────────────────────────
              _buildContactSection(context, content.contact),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. PREMIUM BRAND HERO SECTION
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildHeroSection(BuildContext context, CompanyHeroContent hero) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Automotive Photography
          Positioned.fill(
            child: Image.asset(
              hero.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

          // Deep Navy Luxury Gradient Overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.deepNavy.withValues(alpha: 0.76),
                    AppColors.deepNavy.withValues(alpha: 0.94),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Subtle Gold Rim Illumination at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 1.5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.champagneGold.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Hero Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Brand Anchor: Logo Badge + Experience Pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Official Al Sewar Logo Pod
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(alpha: 0.5),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.14),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/logos/AlSewarlogo-nobg.png',
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Image.asset(
                          hero.logoAsset,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.directions_car,
                            color: AppColors.champagneGold,
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Years Experience Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.champagneGold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(alpha: 0.7),
                          width: 1.0,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppColors.champagneGold,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '11+ YRS',
                            style: TextStyle(
                              fontFamily: AppTextStyles.headingFont,
                              color: AppColors.champagneGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Category Eyebrow
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    hero.tag,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      color: AppColors.champagneGold,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Prominent Headline
                Text(
                  hero.title,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: AppColors.pureWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  hero.subtitle,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.champagneGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                // Supporting Sentence
                Text(
                  hero.description,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: AppColors.pureWhite.withValues(alpha: 0.88),
                    fontSize: 12.5,
                    height: 1.45,
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
  // 2. ABOUT AL SEWAR (Editorial Heritage & Metric Matrix)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWhoWeAreSection(BuildContext context, WhoWeAreContent whoWeAre) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Who We Are', badge: 'HERITAGE'),
        const SizedBox(height: 12),

        // Editorial Headline & Lead Paragraph
        Text(
          whoWeAre.headline,
          style: const TextStyle(
            fontFamily: AppTextStyles.headingFont,
            color: AppColors.deepNavy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),

        // Concise 2-3 Line Summary
        Text(
          whoWeAre.shortSummary,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            color: _mutedTextColor,
            fontSize: 13,
            height: 1.55,
          ),
        ),

        // Expandable Story
        if (_isStoryExpanded) ...[
          const SizedBox(height: 10),
          Text(
            whoWeAre.extendedStory,
            style: const TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: _mutedTextColor,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
        const SizedBox(height: 6),

        // Read More / Read Less Toggle
        InkWell(
          onTap: () {
            setState(() {
              _isStoryExpanded = !_isStoryExpanded;
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isStoryExpanded ? 'Read less' : 'Read more',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: AppColors.champagneGold,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isStoryExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.champagneGold,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // High-Impact Metric Strip (Key Milestones)
        _buildKeyFacts(whoWeAre.keyFacts),
      ],
    );
  }

  /// Clean 2x2 metric matrix with gold typography and subtle borders.
  Widget _buildKeyFacts(List<CompanyFact> facts) {
    if (facts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.subtleBorder),
      ),
      child: Column(
        children: [
          if (facts.length >= 2)
            Row(
              children: [
                Expanded(child: _buildMetricTile(facts[0])),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.subtleBorder,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                Expanded(child: _buildMetricTile(facts[1])),
              ],
            ),
          if (facts.length >= 4) ...[
            const Divider(height: 16, color: AppColors.subtleBorder),
            Row(
              children: [
                Expanded(child: _buildMetricTile(facts[2])),
                Container(
                  width: 1,
                  height: 48,
                  color: AppColors.subtleBorder,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                ),
                Expanded(child: _buildMetricTile(facts[3])),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(CompanyFact fact) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.champagneGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(fact.icon, size: 17, color: AppColors.champagneGold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fact.value,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: AppColors.deepNavy,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  fact.label,
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    color: _mutedTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. MISSION & VISION (Split-Tone Duo)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildMissionVisionSection(
    BuildContext context,
    MissionVisionContent mv,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Mission & Vision'),
        const SizedBox(height: 12),

        // Split-Tone Duo: Mission (Navy) & Vision (Off-White)
        Column(
          children: [
            // 1. Our Mission (Deep Navy Anchor)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.champagneGold.withValues(alpha: 0.6),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      mv.missionIcon,
                      size: 18,
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mv.missionTitle,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.pureWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mv.missionMotto,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.champagneGold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mv.missionBody,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: AppColors.pureWhite.withValues(alpha: 0.84),
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. Our Vision (Refined Soft White Surface)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.subtleBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.champagneGold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.champagneGold.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Icon(
                      mv.visionIcon,
                      size: 18,
                      color: AppColors.champagneGold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mv.visionTitle,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.deepNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mv.visionMotto,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.champagneGold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          mv.visionBody,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: _mutedTextColor,
                            fontSize: 12,
                            height: 1.45,
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
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. OUR SERVICES (Image-Led Horizontal Visual Reel)
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
            Expanded(child: _buildSectionHeader('Our Services')),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicesScreen()),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      color: AppColors.champagneGold,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: AppColors.champagneGold,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Horizontal Image-Led Visual Service Cards
        SizedBox(
          height: 172,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildImageServiceCard(context, service, index);
            },
          ),
        ),
      ],
    );
  }

  /// Maps core service divisions to verified automotive photo assets.
  String _getServiceImageAsset(String title, int index) {
    final lower = title.toLowerCase();
    if (lower.contains('tyre') || lower.contains('tire')) {
      return 'assets/images/service_tyre.jpg';
    } else if (lower.contains('mech') ||
        lower.contains('engine') ||
        lower.contains('repair')) {
      return 'assets/images/service_mechanical.jpg';
    } else if (lower.contains('body') || lower.contains('paint')) {
      return 'assets/images/service_painting.jpg';
    } else if (lower.contains('detail') ||
        lower.contains('ceramic') ||
        lower.contains('wash')) {
      return 'assets/images/service_ceramic.jpg';
    }
    // Fallback to services directory assets
    const fallbacks = [
      'assets/images/service_tyre.jpg',
      'assets/images/service_mechanical.jpg',
      'assets/images/service_painting.jpg',
      'assets/images/service_ceramic.jpg',
    ];
    return fallbacks[index % fallbacks.length];
  }

  Widget _buildImageServiceCard(
    BuildContext context,
    ServiceDivision service,
    int index,
  ) {
    final imageAsset = _getServiceImageAsset(service.title, index);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesScreen()),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 148,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.subtleBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Real Automotive Background Photography
            Positioned.fill(
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.deepNavy,
                  child: Center(
                    child: Icon(
                      service.icon,
                      color: AppColors.champagneGold,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

            // Top-to-Bottom Gradient Overlay for legibility
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.35),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Tag Pill (01, 02, etc.)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  service.tag ?? '0${index + 1}',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: AppColors.champagneGold,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            // Bottom Service Name & Subtitle
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      color: AppColors.pureWhite,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.subtitle,
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.pureWhite.withValues(alpha: 0.75),
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. OUR PRESENCE (Network Coverage & Map Navigation)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildBranchPresenceSection(BuildContext context, WidgetRef ref) {
    final branchAsync = ref.watch(branchListViewModelProvider);
    final countLabel = branchAsync.when(
      data: (branches) => '${branches.length} Locations Across UAE',
      loading: () => '10 Locations Across UAE',
      error: (_, _) => '10 Locations Across UAE',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildSectionHeader('Our Presence')),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.champagneGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.champagneGold.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              child: Text(
                countLabel,
                style: const TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  color: AppColors.champagneGold,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Serving Kalba HQ, Sharjah, Fujairah, Ras Al Khaimah, Dibba, Dubai and Ajman with complete automotive facilities.',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: _mutedTextColor,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),

              // Live branch preview cards or default HQ card
              branchAsync.when(
                data: (branches) {
                  final displayBranches = branches.isNotEmpty
                      ? branches.take(2).toList()
                      : const [];

                  if (displayBranches.isEmpty) {
                    return _buildDefaultHqCard(context);
                  }

                  return Column(
                    children: displayBranches.map((branch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BranchDetailScreen(branchId: branch.id),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.subtleBorder),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.champagneGold.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_outlined,
                                    size: 15,
                                    color: AppColors.champagneGold,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        branch.name,
                                        style: const TextStyle(
                                          fontFamily: AppTextStyles.headingFont,
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.deepNavy,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        branch.city,
                                        style: const TextStyle(
                                          fontFamily: AppTextStyles.bodyFont,
                                          fontSize: 11,
                                          color: _mutedTextColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 11,
                                  color: _mutedTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => _buildDefaultHqCard(context),
                error: (_, _) => _buildDefaultHqCard(context),
              ),
              const SizedBox(height: 6),

              // Action Buttons: Explore on Map & View All Service Centers
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.map_outlined, size: 16),
                      label: const Text(
                        'Explore on Map',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.deepNavy,
                        foregroundColor: AppColors.champagneGold,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BranchMapScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.deepNavy,
                        side: const BorderSide(color: AppColors.subtleBorder),
                        backgroundColor: AppColors.pureWhite,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BranchListScreen(),
                        ),
                      ),
                      child: const Text(
                        'View All Service Centers',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultHqCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const BranchDetailScreen(branchId: 1),
          ),
        ),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                size: 16,
                color: AppColors.champagneGold,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Al Sewar Kalba HQ',
                      style: TextStyle(
                        fontFamily: AppTextStyles.headingFont,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    Text(
                      'Industrial Area, Kalba, Sharjah',
                      style: TextStyle(
                        fontFamily: AppTextStyles.bodyFont,
                        fontSize: 11,
                        color: _mutedTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 11, color: _mutedTextColor),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 6. OFFICIAL WEBSITE LINK (Verified from Company Profile)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildWebsiteSection(BuildContext context, String? websiteUrl) {
    if (websiteUrl == null || websiteUrl.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () async {
        final uri = Uri.parse(websiteUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language_outlined,
                size: 18,
                color: AppColors.champagneGold,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit Our Website',
                    style: TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      color: AppColors.deepNavy,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'www.alsewarauto.com',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.champagneGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.champagneGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.open_in_new,
                size: 14,
                color: AppColors.champagneGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 7. VERIFIED CONTACT & SUPPORT (Working Call, Email, and Operating Hours)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildContactSection(
    BuildContext context,
    CompanyContactContent contact,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Contact & Support'),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtleBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildContactRow(
                icon: Icons.phone_outlined,
                label: 'Main Office (Kalba)',
                value: contact.primaryPhone,
                onTap: () async {
                  final uri = Uri.parse(
                    'tel:${contact.primaryPhone.replaceAll(' ', '')}',
                  );
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              const Divider(height: 18, color: AppColors.subtleBorder),
              _buildContactRow(
                icon: Icons.phone_android_outlined,
                label: 'Customer Support',
                value: contact.secondaryPhone,
                onTap: () async {
                  final uri = Uri.parse(
                    'tel:${contact.secondaryPhone.replaceAll(' ', '')}',
                  );
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              const Divider(height: 18, color: AppColors.subtleBorder),
              _buildContactRow(
                icon: Icons.email_outlined,
                label: 'Email Inquiry',
                value: contact.email,
                onTap: () async {
                  final uri = Uri.parse('mailto:${contact.email}');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              const Divider(height: 18, color: AppColors.subtleBorder),
              _buildContactRow(
                icon: Icons.access_time_outlined,
                label: contact.operatingHoursTitle,
                value: contact.operatingHours,
              ),
              const Divider(height: 18, color: AppColors.subtleBorder),
              _buildContactRow(
                icon: Icons.business_outlined,
                label: 'Headquarters',
                value: contact.headquarters,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final content = Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.champagneGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.champagneGold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: _mutedTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  color: onTap != null
                      ? AppColors.champagneGold
                      : AppColors.deepNavy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          const Icon(
            Icons.arrow_forward_ios,
            size: 11,
            color: AppColors.champagneGold,
          ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? badge}) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 15,
          decoration: BoxDecoration(
            color: AppColors.champagneGold,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: AppTextStyles.headingFont,
            color: AppColors.deepNavy,
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.champagneGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontFamily: AppTextStyles.headingFont,
                color: AppColors.champagneGold,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
