import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/service_item.dart';
import '../viewmodels/service_providers.dart';
import 'service_detail_screen.dart';

/// Al Sewar Available Services Screen.
///
/// A premium, image-led service catalogue displaying verified Al Sewar
/// automotive capabilities across Tyre Services, Mechanical, Body Services, and Detailing.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(customerServicesProvider);

    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.deepBlack,
                ),
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Services',
              style: TextStyle(
                fontFamily: AppTextStyles.headingFont,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlack,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Certified automotive craftsmanship across UAE bays',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              // ── Category Filter Pills ──────────────────────────────
              SizedBox(
                height: 42,
                child: ListView.separated(
                  key: const Key('category_filter_list'),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: AlSewarServiceCatalog.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = AlSewarServiceCatalog.categories[index];
                    final isSelected = cat == _selectedCategory;
                    return _buildCategoryPill(cat, isSelected);
                  },
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.subtleBorder, height: 1),
            ],
          ),
        ),
      ),
      body: servicesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.champagneGold,
            strokeWidth: 2,
          ),
        ),
        error: (err, _) => _buildErrorState(err),
        data: (backendServices) {
          // If backend returns data, merge/augment with verified company profile metadata.
          // If backend is empty, display the complete 14-service Company Profile catalogue.
          final effectiveList = backendServices.isNotEmpty
              ? backendServices
              : AlSewarServiceCatalog.allServices;

          final filteredServices = _filterServices(effectiveList);

          if (filteredServices.isEmpty) {
            return _buildEmptyCategoryState();
          }

          return ListView.separated(
            key: const Key('services_list_view'),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount: filteredServices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return _buildServiceCard(context, service);
            },
          );
        },
      ),
    );
  }

  /// Filters services based on the active category pill.
  List<ServiceItem> _filterServices(List<ServiceItem> services) {
    if (_selectedCategory == 'All') return services;

    return services.where((s) {
      if (s.category != null && s.category == _selectedCategory) {
        return true;
      }
      final inferredImage = s.effectiveImageAsset;
      if (_selectedCategory == 'Tyre Services') {
        return inferredImage.contains('tyre') ||
            s.name.toLowerCase().contains('tyre') ||
            s.name.toLowerCase().contains('wheel');
      }
      if (_selectedCategory == 'Mechanical') {
        return inferredImage.contains('mechanical') ||
            inferredImage.contains('oil') ||
            inferredImage.contains('ac') ||
            s.name.toLowerCase().contains('engine') ||
            s.name.toLowerCase().contains('mechanical') ||
            s.name.toLowerCase().contains('repair');
      }
      if (_selectedCategory == 'Body Services') {
        return inferredImage.contains('paint') ||
            s.name.toLowerCase().contains('body') ||
            s.name.toLowerCase().contains('paint') ||
            s.name.toLowerCase().contains('tint');
      }
      if (_selectedCategory == 'Detailing') {
        return inferredImage.contains('wash') ||
            inferredImage.contains('ceramic') ||
            s.name.toLowerCase().contains('wash') ||
            s.name.toLowerCase().contains('detail') ||
            s.name.toLowerCase().contains('ceramic');
      }
      return false;
    }).toList();
  }

  Widget _buildCategoryPill(String title, bool isSelected) {
    return GestureDetector(
      key: Key('category_pill_$title'),
      onTap: () => setState(() => _selectedCategory = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepBlack : AppColors.softWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.deepBlack : AppColors.subtleBorder,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.champagneGold
                  : AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  /// Visually appealing service card with automotive photography.
  Widget _buildServiceCard(BuildContext context, ServiceItem service) {
    final imageAsset = service.effectiveImageAsset;
    final category = service.category ?? _resolveCategoryFromName(service.name);

    return Semantics(
      key: Key('service_card_${service.id}'),
      button: true,
      label: '${service.name}: ${service.description}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ServiceDetailScreen(service: service),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.champagneGold.withValues(alpha: 0.12),
          highlightColor: AppColors.champagneGold.withValues(alpha: 0.06),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.subtleBorder, width: 1),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Top Automotive Photo ──────────────────────────
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 2.35,
                        child: Image.asset(
                          imageAsset,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: AppColors.softWhite,
                            child: const Center(
                              child: Icon(
                                Icons.car_repair,
                                size: 40,
                                color: AppColors.champagneGold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Specular contrast gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.5),
                              ],
                              stops: const [0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Category Tag Badge
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.deepBlack.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.champagneGold.withValues(
                                alpha: 0.4,
                              ),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            category.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.champagneGold,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 2. Card Content & Details ────────────────────────
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exact Service Title
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlack,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (service.description.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          service.description,
                          style: const TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Bottom CTA Indicator Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  service.effectiveIcon,
                                  size: 15,
                                  color: AppColors.champagneGold,
                                ),
                                const SizedBox(width: 6),
                                const Flexible(
                                  child: Text(
                                    'Certified Bay Care',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.bodyFont,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.bodyFont,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.champagneGold,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.champagneGold,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _resolveCategoryFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tyre') || lower.contains('wheel')) {
      return 'Tyre Services';
    }
    if (lower.contains('wash') ||
        lower.contains('detail') ||
        lower.contains('ceramic')) {
      return 'Detailing';
    }
    if (lower.contains('paint') ||
        lower.contains('body') ||
        lower.contains('tint')) {
      return 'Body Services';
    }
    return 'Mechanical';
  }

  Widget _buildEmptyCategoryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.miscellaneous_services_outlined,
              size: 56,
              color: AppColors.champagneGold,
            ),
            const SizedBox(height: 14),
            Text(
              'No Services in this Category',
              style: AppTextStyles.heading.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try selecting another category or view all services.',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _selectedCategory = 'All'),
              child: const Text(
                'Show All Services',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.champagneGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Could Not Load Services',
              style: AppTextStyles.heading.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString().replaceFirst('Exception: ', ''),
              style: const TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.deepBlack,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: AppColors.champagneGold,
              ),
              label: const Text(
                'Try Again',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.champagneGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => ref.invalidate(customerServicesProvider),
            ),
          ],
        ),
      ),
    );
  }
}
