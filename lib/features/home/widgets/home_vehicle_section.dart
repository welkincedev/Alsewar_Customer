import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/screens/vehicles_screen.dart';
import '../../vehicles/viewmodels/vehicle_providers.dart';
import '../../visits/models/service_visit.dart';
import '../../visits/viewmodels/visit_providers.dart';

/// Al Sewar My Vehicles Home Section.
///
/// Displays the customer's registered vehicle(s) with ample breathing room,
/// legible typography, Saudi plate badge, and last service info.
class HomeVehicleSection extends ConsumerWidget {
  const HomeVehicleSection({super.key});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _getLastServiceDate(Vehicle vehicle, List<ServiceVisit>? visits) {
    if (visits == null || visits.isEmpty) {
      return 'No service yet';
    }

    final matching = visits.where((v) {
      if (v.vehicleId != null && v.vehicleId == vehicle.id) {
        return true;
      }
      final vPlate = v.vehiclePlate.trim().toLowerCase();
      final myPlate = vehicle.plateNumber.trim().toLowerCase();
      return vPlate.isNotEmpty && myPlate.isNotEmpty && vPlate == myPlate;
    }).toList();

    if (matching.isEmpty) {
      return 'No service yet';
    }

    matching.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final mostRecent = matching.first;
    final dt = DateTime.tryParse(mostRecent.createdAt)?.toLocal();
    if (dt == null) {
      return 'No service yet';
    }
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleViewModelProvider);
    final visitsAsync = ref.watch(visitViewModelProvider);
    final visits = visitsAsync.asData?.value;

    return vehiclesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (vehicles) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Vehicles', style: AppTextStyles.sectionHeading),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VehiclesScreen()),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: const Text(
                        'MANAGE',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.champagneGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Vehicle Content ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: vehicles.isEmpty
                  ? _buildEmptyCard(context)
                  : (vehicles.length == 1
                        ? _buildVehicleCard(
                            context,
                            vehicles.first,
                            _getLastServiceDate(vehicles.first, visits),
                          )
                        : _buildMultiVehicleCarousel(
                            context,
                            vehicles,
                            visits,
                          )),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sandBeige),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.deepCharcoal,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppColors.goldGlow,
            ),
            child: const Icon(
              Icons.directions_car_outlined,
              color: AppColors.champagneGold,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Register Your Vehicle',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track maintenance & service history',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VehiclesScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: AppColors.goldGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppColors.goldGlow,
              ),
              child: const Text(
                '+ Add',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.deepCharcoal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(
    BuildContext context,
    Vehicle vehicle,
    String lastServiceDate,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VehiclesScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sandBeige),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.deepCharcoal,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_outlined,
                    color: AppColors.champagneGold,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vehicle.displayName.isNotEmpty
                        ? vehicle.displayName
                        : 'Al Sewar Vehicle',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.textLight,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Plate Number Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sandBeige.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.sandBeige, width: 1),
                  ),
                  child: Text(
                    vehicle.plateNumber,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      color: AppColors.deepCharcoal,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Last service: $lastServiceDate',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiVehicleCarousel(
    BuildContext context,
    List<Vehicle> vehicles,
    List<ServiceVisit>? visits,
  ) {
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: vehicles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final v = vehicles[index];
          final lastService = _getLastServiceDate(v, visits);
          return SizedBox(
            width: 280,
            child: _buildVehicleCard(context, v, lastService),
          );
        },
      ),
    );
  }
}
