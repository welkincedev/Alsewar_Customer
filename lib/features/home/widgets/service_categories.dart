import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../services/screens/services_screen.dart';
import '../../services/viewmodels/service_providers.dart';

/// Service shortcut grid on the Home screen.
///
/// Features clean, responsive category cards for quick access to automotive services.
class ServiceCategories extends ConsumerWidget {
  const ServiceCategories({super.key});

  static const _categoryIconMap = <String, IconData>{
    'wash': Icons.local_car_wash,
    'detail': Icons.auto_awesome,
    'maintenance': Icons.build_outlined,
    'clean': Icons.cleaning_services,
    'polish': Icons.shutter_speed,
    'wax': Icons.star_border,
    'oil': Icons.oil_barrel_outlined,
    'brake': Icons.speed,
  };

  IconData _resolveIcon(String name) {
    final lower = name.toLowerCase();
    for (final entry in _categoryIconMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.miscellaneous_services;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(customerServicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Our Services', style: AppTextStyles.sectionHeading),
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
        ),
        const SizedBox(height: 14),

        // ── Categories Row ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: servicesAsync.when(
            loading: () => const SizedBox(
              height: 80,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondaryGold,
                  strokeWidth: 2,
                ),
              ),
            ),
            error: (_, _) => _buildFallbackGrid(context),
            data: (services) {
              if (services.isEmpty) {
                return _buildFallbackGrid(context);
              }
              // Take up to 3 services plus "More"
              final display = services.take(3).toList();
              return Row(
                children: [
                  ...display.map(
                    (s) => Expanded(
                      child: _CategoryItem(
                        icon: _resolveIcon(s.name),
                        label: s.name,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServicesScreen(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _CategoryItem(
                      icon: Icons.grid_view_rounded,
                      label: 'More',
                      isAccent: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServicesScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackGrid(BuildContext context) {
    final fallbackItems = [
      {'name': 'Car Wash', 'icon': Icons.local_car_wash},
      {'name': 'Detailing', 'icon': Icons.auto_awesome},
      {'name': 'Maintenance', 'icon': Icons.build_outlined},
      {'name': 'More', 'icon': Icons.grid_view_rounded},
    ];

    return Row(
      children: fallbackItems.map((item) {
        final isMore = item['name'] == 'More';
        return Expanded(
          child: _CategoryItem(
            icon: item['icon'] as IconData,
            label: item['name'] as String,
            isAccent: isMore,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServicesScreen()),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isAccent;

  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: isAccent ? AppColors.deepCharcoal : AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAccent ? AppColors.champagneGold : AppColors.sandBeige,
                width: isAccent ? 1.5 : 1,
              ),
              boxShadow: isAccent ? AppColors.goldGlow : AppColors.softShadow,
            ),
            child: Icon(
              icon,
              color: isAccent
                  ? AppColors.champagneGold
                  : AppColors.deepCharcoal,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontFamily: AppTextStyles.bodyFont,
                color: AppColors.deepCharcoal,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
