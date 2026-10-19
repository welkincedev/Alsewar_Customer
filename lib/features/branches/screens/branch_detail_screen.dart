import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/business_hour.dart';
import '../viewmodels/branch_providers.dart';

class BranchDetailScreen extends ConsumerWidget {
  final int branchId;

  const BranchDetailScreen({super.key, required this.branchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchAsync = ref.watch(branchDetailProvider(branchId));
    final hoursAsync = ref.watch(branchHoursProvider(branchId));

    return Scaffold(
      appBar: AppBar(title: const Text('Branch Details')),
      body: branchAsync.when(
        data: (branch) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlack,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.storefront,
                              color: AppColors.secondaryGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name,
                                  style: AppTextStyles.heading.copyWith(
                                    color: AppColors.primaryBlack,
                                    fontSize: 20,
                                  ),
                                ),
                                if (branch.code.isNotEmpty) ...[
                                  Text(
                                    'Branch Code: ${branch.code}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryBlack.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Location & Contact Info Section
                Text(
                  'Contact & Location',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailInfoTile(
                          icon: Icons.location_city_outlined,
                          title: 'City',
                          value: branch.city,
                        ),
                        const Divider(height: 16),
                        _DetailInfoTile(
                          icon: Icons.map_outlined,
                          title: 'Address',
                          value: branch.address,
                        ),
                        if (branch.phone.isNotEmpty) ...[
                          const Divider(height: 16),
                          _DetailInfoTile(
                            icon: Icons.phone_outlined,
                            title: 'Phone',
                            value: branch.phone,
                          ),
                        ],
                        if (branch.email.isNotEmpty) ...[
                          const Divider(height: 16),
                          _DetailInfoTile(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            value: branch.email,
                          ),
                        ],
                        if (branch.latitude != null &&
                            branch.longitude != null) ...[
                          const Divider(height: 16),
                          _DetailInfoTile(
                            icon: Icons.my_location_outlined,
                            title: 'GPS Coordinates',
                            value: '${branch.latitude}, ${branch.longitude}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Operating Hours Section
                Text(
                  'Weekly Operating Hours',
                  style: AppTextStyles.title.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                hoursAsync.when(
                  data: (hours) {
                    if (hours.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No operating hours available for this branch.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      );
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: hours
                              .map((hour) => _BusinessHourRow(hour: hour))
                              .toList(),
                        ),
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.secondaryGold,
                        ),
                      ),
                    ),
                  ),
                  error: (err, stack) {
                    return Card(
                      color: AppColors.error.withValues(alpha: 0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Unable to load operating hours.',
                                style: AppTextStyles.bodySecondary.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryGold),
          ),
        ),
        error: (error, stack) {
          final cleanError = error.toString().replaceAll('Exception: ', '');
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 56,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Branch Not Found',
                    style: AppTextStyles.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cleanError,
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(branchDetailProvider(branchId));
                      ref.invalidate(branchHoursProvider(branchId));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailInfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primaryBlack, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: AppTextStyles.bodyPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BusinessHourRow extends StatelessWidget {
  final BusinessHour hour;

  const _BusinessHourRow({required this.hour});

  @override
  Widget build(BuildContext context) {
    final isClosed = hour.isClosed || hour.formattedHours == 'Closed';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              hour.dayName,
              style: AppTextStyles.bodyPrimary.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isClosed
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.secondaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hour.formattedHours,
                style: AppTextStyles.bodySecondary.copyWith(
                  color: isClosed ? AppColors.error : AppColors.primaryBlack,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
