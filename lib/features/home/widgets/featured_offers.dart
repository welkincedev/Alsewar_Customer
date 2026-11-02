import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../services/models/service_item.dart';
import '../../services/screens/service_detail_screen.dart';
import '../../services/screens/services_screen.dart';
import '../../services/viewmodels/service_providers.dart';
import '../models/featured_offer_item.dart';

/// Al Sewar Featured Offers Section.
///
/// Refined horizontal promotional carousel adhering to the Desert Luxe theme:
/// - Single horizontal scrollable row with smooth swipe navigation
/// - Compact cards in 2:3 aspect ratio (~144 px wide and 216 px tall)
/// - Clean rounded corners (16 px)
/// - Complete promotional advertising posters covering 5 categories:
///   1. Auto Service Offers
///   2. Food & Partner Offers
///   3. Referral Offers
///   4. Special Promotions
///   5. Loyalty Offers
/// - Preserves artwork aspect ratio without distortion or stretching
/// - Preserves the "Featured Offers" header and "See All" action
class FeaturedOffers extends ConsumerWidget {
  final List<FeaturedOfferItem>? offers;

  const FeaturedOffers({super.key, this.offers});

  /// Curated collection of complete promotional advertising posters covering 5 categories.
  static const List<FeaturedOfferItem> defaultOffers = [
    FeaturedOfferItem(
      id: 201,
      title: 'Premium Auto Care',
      description: 'Complete detailing and ceramic protection.',
      points: 0,
      imageAsset: 'assets/images/featured_offers/offer_auto_service.jpg',
    ),
    FeaturedOfferItem(
      id: 202,
      title: 'Partner Café Privileges',
      description: 'Complimentary gourmet lounge refreshments.',
      points: 0,
      imageAsset: 'assets/images/featured_offers/offer_partner_dining.jpg',
    ),
    FeaturedOfferItem(
      id: 203,
      title: 'Share The Privilege',
      description: 'Invite friends and earn mutual reward coins.',
      points: 0,
      imageAsset: 'assets/images/featured_offers/offer_referral_rewards.jpg',
    ),
    FeaturedOfferItem(
      id: 204,
      title: 'Seasonal Drive Care',
      description: 'All-weather road readiness and vehicle inspection.',
      points: 0,
      imageAsset: 'assets/images/featured_offers/offer_special_promo.jpg',
    ),
    FeaturedOfferItem(
      id: 205,
      title: 'VIP Loyalty Club',
      description: 'Exclusive tier privileges and reward coin multipliers.',
      points: 0,
      imageAsset: 'assets/images/featured_offers/offer_loyalty_club.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(customerServicesProvider);

    // Resolve dynamic offers or display the 5 curated promotional posters
    final List<FeaturedOfferItem> displayOffers = offers ?? defaultOffers;

    final bool isLoading =
        offers == null &&
        servicesAsync.isLoading &&
        !servicesAsync.hasValue &&
        defaultOffers.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. Section Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Featured Offers',
                  style: AppTextStyles.sectionHeading,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServicesScreen()),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.champagneGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 3),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: AppColors.champagneGold,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── 2. Horizontal Scrollable Row of Compact Offer Cards ────────
        if (isLoading)
          _buildLoadingSkeleton()
        else if (displayOffers.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 224,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: displayOffers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = displayOffers[index];
                return _buildOfferCard(context, item);
              },
            ),
          ),
        const SizedBox(key: Key('featured_offers_bottom'), height: 0),
      ],
    );
  }

  /// Builds a single compact promotional poster card in exact 2:3 aspect ratio (~144 x 216 px).
  Widget _buildOfferCard(BuildContext context, FeaturedOfferItem item) {
    return Container(
      width: 144,
      height: 216,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.subtleBorder.withValues(alpha: 0.8),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onOfferTap(context, item),
            child: SizedBox.expand(child: _buildOfferImage(item)),
          ),
        ),
      ),
    );
  }

  /// Renders the promotional image preserving aspect ratio without distortion.
  Widget _buildOfferImage(FeaturedOfferItem item) {
    final posterUrl = item.effectivePosterUrl;

    if (posterUrl != null && posterUrl.isNotEmpty) {
      return Image.network(
        posterUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          final total = loadingProgress.expectedTotalBytes;
          final loaded = loadingProgress.cumulativeBytesLoaded;
          final progress = (total != null && total > 0) ? loaded / total : null;
          return Container(
            color: AppColors.offWhite,
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.0,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.champagneGold,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          if (item.imageAsset.isNotEmpty) {
            return Image.asset(
              item.imageAsset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildImagePlaceholder(item),
            );
          }
          return _buildImagePlaceholder(item);
        },
      );
    }

    // Local asset promotional image
    return Image.asset(
      item.imageAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _buildImagePlaceholder(item),
    );
  }

  /// Elegant placeholder when artwork cannot be loaded.
  Widget _buildImagePlaceholder(FeaturedOfferItem item) {
    return Container(
      color: AppColors.offWhite,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.champagneGold.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: AppColors.champagneGold,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              item.title.isNotEmpty ? item.title : 'Featured Offer',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppTextStyles.headingFont,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Al Sewar',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Compact horizontal loading skeleton.
  Widget _buildLoadingSkeleton() {
    return SizedBox(
      height: 204,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Container(
          width: 156,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.subtleBorder),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.champagneGold),
          ),
        ),
      ),
    );
  }

  /// Empty state when no offers are available.
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.subtleBorder),
        ),
        child: Column(
          children: const [
            Icon(
              Icons.local_offer_outlined,
              color: AppColors.champagneGold,
              size: 28,
            ),
            SizedBox(height: 8),
            Text(
              'No featured offers currently available',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles offer tap navigation.
  void _onOfferTap(BuildContext context, FeaturedOfferItem item) {
    if (item.service != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: item.service!),
        ),
      );
      return;
    }

    final matched =
        AlSewarServiceCatalog.homeShortcutServices
            .where((s) => s.id == item.id || s.name == item.title)
            .firstOrNull ??
        AlSewarServiceCatalog.additionalServices
            .where((s) => s.id == item.id || s.name == item.title)
            .firstOrNull;

    if (matched != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: matched),
        ),
      );
      return;
    }

    // Default to Services catalog screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ServicesScreen()),
    );
  }
}
