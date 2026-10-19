import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../models/service_visit.dart';
import '../viewmodels/visit_providers.dart';
import 'visit_detail_screen.dart';

class VisitsScreen extends ConsumerWidget {
  const VisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: visitsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondaryGold),
        ),
        error: (err, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('Could Not Load Visits', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                  ),
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.secondaryGold,
                  ),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(color: AppColors.secondaryGold),
                  ),
                  onPressed: () =>
                      ref.read(visitViewModelProvider.notifier).refresh(),
                ),
              ],
            ),
          ),
        ),
        data: (visits) {
          if (visits.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.history_outlined,
                      size: 72,
                      color: AppColors.secondaryGold,
                    ),
                    const SizedBox(height: 20),
                    Text('No Service History', style: AppTextStyles.heading),
                    const SizedBox(height: 8),
                    Text(
                      'Your visits will appear here.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.secondaryGold,
            onRefresh: () =>
                ref.read(visitViewModelProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: visits.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final visit = visits[i];
                return _VisitCard(visit: visit);
              },
            ),
          );
        },
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  final ServiceVisit visit;
  const _VisitCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final isCompleted = visit.isCompleted;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VisitDetailScreen(visitId: visit.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_outline
                          : Icons.directions_car_filled_outlined,
                      color: AppColors.secondaryGold,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          visit.visitNumber,
                          style: AppTextStyles.title.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          visit.vehiclePlate,
                          style: AppTextStyles.bodySecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.secondaryGold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        visit.stageName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.secondaryGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      visit.branchName,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.directions_car_outlined,
                    size: 14,
                    color: AppColors.textLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      visit.vehicleLabel,
                      style: AppTextStyles.caption,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (visit.services.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: visit.services
                      .map(
                        (s) => Chip(
                          label: Text(s.name, style: AppTextStyles.caption),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: AppColors.surfaceLight,
                          side: const BorderSide(color: AppColors.borderLight),
                          padding: EdgeInsets.zero,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
