import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../about/screens/about_us_screen.dart';
import '../../auth/models/auth_user.dart';
import '../../profile/screens/profile_screen.dart';
import '../../services/screens/services_screen.dart';

/// Local Fallback Promotional Banner Data Model.
class FallbackBannerItem {
  final String tag;
  final String title;
  final String subtitle;
  final String ctaText;
  final String imageAsset;
  final IconData visualIcon;
  final void Function(BuildContext context, AuthUser? user) onAction;

  const FallbackBannerItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.imageAsset,
    required this.visualIcon,
    required this.onAction,
  });
}

/// Al Sewar Promotional Banner Section.
///
/// Features a horizontal swipeable carousel with a 2:1 aspect ratio.
///
/// Data Logic:
/// - If backend returns active banners, display only backend banners.
/// - If backend returns no active banners, display the 3 local fallback banners:
///     1. Premium Auto Care -> ServicesScreen
///     2. Complete Auto Care -> AboutUsScreen
///     3. Loyalty Rewards -> ProfileScreen (rewards)
/// - If banners are loading, show a compact 2:1 loading skeleton.
/// - If an API error occurs, handle error separately without misleading fallback claims.
class PromotionalBanner extends StatefulWidget {
  final List<dynamic>? banners;
  final AuthUser? user;
  final bool isLoading;
  final Object? error;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const PromotionalBanner({
    super.key,
    this.banners,
    this.user,
    this.isLoading = false,
    this.error,
    this.errorMessage,
    this.onRetry,
  });

  /// The 3 official Al Sewar local fallback promotional banners.
  static final List<FallbackBannerItem> defaultFallbackBanners = [
    // 1. Premium Auto Care
    FallbackBannerItem(
      tag: 'Al Sewar Auto Center',
      title: 'Premium care for every drive',
      subtitle: 'Comprehensive exterior, interior & ceramic preservation.',
      ctaText: 'Explore our services',
      imageAsset: 'assets/images/banner_auto_care.png',
      visualIcon: Icons.auto_awesome,
      onAction: (context, _) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesScreen()),
      ),
    ),
    // 2. Complete Auto Care
    FallbackBannerItem(
      tag: 'Your Car. Our Expertise.',
      title: 'Service • Detailing • Mechanical • More',
      subtitle: 'Certified automotive craftsmanship at every Al Sewar bay.',
      ctaText: 'Discover Al Sewar',
      imageAsset: 'assets/images/banner_complete_care.png',
      visualIcon: Icons.verified_outlined,
      onAction: (context, _) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AboutUsScreen()),
      ),
    ),
    // 3. Loyalty
    FallbackBannerItem(
      tag: 'Service. Earn. Enjoy.',
      title: 'Every visit brings you closer to more rewards.',
      subtitle: 'Tiered privileges, priority bay access & exclusive benefits.',
      ctaText: 'View your rewards',
      imageAsset: 'assets/images/banner_loyalty.png',
      visualIcon: Icons.military_tech_outlined,
      onAction: (context, user) {
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen(user: user)),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutUsScreen()),
          );
        }
      },
    ),
  ];

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading State
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    // 2. Error State
    if (widget.error != null) {
      return _buildErrorState(context);
    }

    // 3. Data Logic:
    // Backend banners take priority. If empty or null, fallback to the 3 local promotional banners.
    final activeBanners = widget.banners ?? const [];
    final hasBackendBanners = activeBanners.isNotEmpty;

    final bannerCount = hasBackendBanners
        ? activeBanners.length
        : PromotionalBanner.defaultFallbackBanners.length;

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 2:1 Aspect Ratio Banner Card ────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 2.0,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: bannerCount,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      if (hasBackendBanners) {
                        return _buildBackendBannerCard(
                          context,
                          activeBanners[index],
                        );
                      } else {
                        return _buildFallbackBannerCard(
                          context,
                          PromotionalBanner.defaultFallbackBanners[index],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ),

          // ── Subtle Page Indicators (only when multiple banners exist) ─
          if (bannerCount > 1) ...[
            const SizedBox(height: 8),
            _buildPageIndicators(bannerCount),
          ],
        ],
      ),
    );
  }

  /// Compact 2:1 Loading Skeleton.
  Widget _buildLoadingState() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 2.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.deepCharcoal.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.sandBeige.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.champagneGold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Discrete Error Fallback.
  Widget _buildErrorState(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.subtleBorder, width: 1),
            boxShadow: AppColors.softShadow,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 18,
                color: AppColors.textLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.errorMessage ??
                      'Campaign offers currently unavailable.',
                  style: const TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.onRetry != null)
                TextButton(
                  onPressed: widget.onRetry,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.champagneGold,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an Al Sewar Local Fallback Promotional Card.
  Widget _buildFallbackBannerCard(
    BuildContext context,
    FallbackBannerItem item,
  ) {
    return Semantics(
      button: true,
      label: '${item.tag}: ${item.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => item.onAction(context, widget.user),
          splashColor: AppColors.champagneGold.withValues(alpha: 0.16),
          highlightColor: AppColors.champagneGold.withValues(alpha: 0.08),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Deep Black / Charcoal Surface with subtle Gold Glow
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.charcoalGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              // 2. High-resolution Local 1080x400 Asset Image
              Image.asset(
                item.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),

              // 3. Specular contrast gradient ensuring 100% typography legibility
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xF5141414),
                      Color(0xDC171717),
                      Color(0x601A1A1A),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.45, 0.72, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // 4. Subtle Champagne Gold perimeter border & soft shadow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
              ),

              // 5. Card Content Layer
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag / Header Label
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.champagneGold.withValues(
                              alpha: 0.16,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.champagneGold.withValues(
                                alpha: 0.35,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            item.tag,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.champagneGold,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Main Title
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.pureWhite,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),

                        // Subtitle
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppColors.sandBeige.withValues(alpha: 0.88),
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // CTA Link
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                item.ctaText,
                                style: const TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.champagneGold,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.champagneGold,
                            ),
                          ],
                        ),
                      ],
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

  /// Builds a Backend Banner Card.
  Widget _buildBackendBannerCard(BuildContext context, dynamic banner) {
    final title = banner is Map
        ? (banner['title'] ?? '').toString()
        : banner.toString();
    final subtitle = banner is Map
        ? (banner['subtitle'] ?? banner['description'] ?? '').toString()
        : '';
    final imageUrl = banner is Map ? banner['image_url']?.toString() : null;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: AppColors.champagneGold.withValues(alpha: 0.16),
          highlightColor: AppColors.champagneGold.withValues(alpha: 0.08),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.charcoalGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xF5141414),
                      Color(0xDC171717),
                      Color(0x601A1A1A),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.45, 0.72, 1.0],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border.all(
                    color: AppColors.champagneGold.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title.isNotEmpty)
                          Text(
                            title,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.headingFont,
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.pureWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 11,
                              color: AppColors.sandBeige.withValues(
                                alpha: 0.88,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
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

  /// Subtle Page Indicators.
  Widget _buildPageIndicators(int count) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (index) {
          final isActive = index == _currentPage;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            width: isActive ? 16 : 5,
            height: 3.5,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.champagneGold
                  : AppColors.subtleBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
