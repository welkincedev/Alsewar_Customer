import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../viewmodels/visit_providers.dart';

class VisitDetailScreen extends ConsumerWidget {
  final int visitId;
  const VisitDetailScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitAsync = ref.watch(visitDetailProvider(visitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Details'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: visitAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondaryGold),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('Could Not Load Visit', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (visit) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlack, Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.secondaryGold,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            visit.visitNumber,
                            style: AppTextStyles.heading.copyWith(
                              color: AppColors.secondaryGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: visit.isCompleted
                            ? AppColors.success.withValues(alpha: 0.2)
                            : AppColors.secondaryGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: visit.isCompleted
                              ? AppColors.success
                              : AppColors.secondaryGold,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        visit.stageName,
                        style: AppTextStyles.bodyPrimary.copyWith(
                          color: visit.isCompleted
                              ? AppColors.success
                              : AppColors.secondaryGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vehicle & Branch Information
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle & Location',
                        style: AppTextStyles.title.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 16),
                      _infoRow(
                        Icons.directions_car_outlined,
                        'Vehicle',
                        '${visit.vehiclePlate} – ${visit.vehicleLabel}',
                      ),
                      const SizedBox(height: 8),
                      _infoRow(
                        Icons.storefront_outlined,
                        'Branch',
                        visit.branchName,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Services List
              if (visit.services.isNotEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Services Included',
                          style: AppTextStyles.title.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 16),
                        ...visit.services.map(
                          (s) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                  color: AppColors.secondaryGold,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: AppTextStyles.bodyPrimary
                                            .copyWith(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Status History Timeline
              if (visit.statusHistory.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Timeline & Milestones',
                          style: AppTextStyles.title.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 16),
                        ...visit.statusHistory.map(
                          (h) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: AppColors.secondaryGold,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (visit.statusHistory.last != h)
                                      Container(
                                        width: 2,
                                        height: 36,
                                        color: AppColors.borderLight,
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        h.stageName,
                                        style: AppTextStyles.bodyPrimary
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (h.notes != null &&
                                          h.notes!.isNotEmpty)
                                        Text(
                                          h.notes!,
                                          style: AppTextStyles.bodySecondary,
                                        ),
                                      Text(
                                        _formatDate(h.createdAt),
                                        style: AppTextStyles.caption,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryGold),
        const SizedBox(width: 8),
        Text('$label: ', style: AppTextStyles.bodySecondary),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyPrimary.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final min = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day}/${dt.month}/${dt.year} $hour:$min $ampm';
    } catch (_) {
      return iso;
    }
  }
}
