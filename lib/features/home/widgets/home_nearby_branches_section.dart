import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../branches/models/branch.dart';
import '../../branches/screens/branch_detail_screen.dart';
import '../../branches/screens/branch_map_screen.dart';
import '../../branches/viewmodels/branch_viewmodel.dart';

/// Al Sewar Nearby / Recommended Branches Home Section.
///
/// Features compact horizontal cards showing active service centers,
/// their addresses, operating status, and quick map navigation.
class HomeNearbyBranchesSection extends ConsumerWidget {
  const HomeNearbyBranchesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchListViewModelProvider);

    return branchesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (branches) {
        if (branches.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Centers',
                      style: AppTextStyles.sectionHeading,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BranchMapScreen(),
                        ),
                      ),
                      child: const Text(
                        'MAP VIEW',
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
              const SizedBox(height: 8),

              // ── Horizontal Branch Cards ───────────────────────────
              SizedBox(
                height: 72,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: branches.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    return _buildBranchCard(context, branch);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchCard(BuildContext context, Branch branch) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BranchDetailScreen(branchId: branch.id),
        ),
      ),
      child: Container(
        width: 230,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sandBeige),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.deepCharcoal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_outlined,
                    color: AppColors.champagneGold,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    branch.name,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 10,
                  color: AppColors.textLight,
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: AppColors.champagneGold,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${branch.address}${branch.city.isNotEmpty ? ", ${branch.city}" : ""}',
                    style: const TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontSize: 11,
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
}
