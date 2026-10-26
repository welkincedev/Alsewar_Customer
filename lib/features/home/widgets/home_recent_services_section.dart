import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../services/screens/services_screen.dart';
import '../../visits/models/service_visit.dart';
import '../../visits/screens/visit_detail_screen.dart';
import '../../visits/screens/visits_screen.dart';
import '../../visits/viewmodels/visit_providers.dart';

/// Al Sewar Recent Services & Live Tracker Home Section.
///
/// If an active (in-progress) visit is found, highlights a premium
/// live service tracking card with stage indicator and progress action.
/// If all visits are completed, presents the most recent service record
/// with earned loyalty points and history shortcut.
class HomeRecentServicesSection extends ConsumerWidget {
  const HomeRecentServicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(visitViewModelProvider);

    return visitsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (visits) {
        // Look for active service first
        ServiceVisit? activeVisit;
        for (final v in visits) {
          if (!v.isCompleted) {
            activeVisit = v;
            break;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Services', style: AppTextStyles.sectionHeading),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const VisitsScreen()),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: const Text(
                        'HISTORY',
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

            // ── Visit Content ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: activeVisit != null
                  ? _buildActiveServiceCard(context, activeVisit)
                  : (visits.isNotEmpty
                        ? _buildCompletedServiceCard(context, visits.first)
                        : _buildEmptyCard(context)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveServiceCard(BuildContext context, ServiceVisit visit) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VisitDetailScreen(visitId: visit.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          gradient: AppColors.charcoalGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.champagneGold.withValues(alpha: 0.35),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepCharcoal.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.goldGlow,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sync, size: 11, color: AppColors.deepCharcoal),
                      SizedBox(width: 4),
                      Text(
                        'SERVICE IN PROGRESS',
                        style: TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: AppColors.deepCharcoal,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  visit.visitNumber,
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.services.isNotEmpty
                            ? visit.services.first.name
                            : (visit.vehicleLabel.isNotEmpty
                                  ? visit.vehicleLabel
                                  : 'Auto Care Service'),
                        style: const TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Stage: ${visit.stageName} · ${visit.branchName.isNotEmpty ? visit.branchName : "Al Sewar Center"}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ShaderMask(
                      shaderCallback: (rect) =>
                          AppColors.goldGradient.createShader(rect),
                      child: const Text(
                        'Track',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.secondaryGold,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedServiceCard(BuildContext context, ServiceVisit visit) {
    final title = visit.services.isNotEmpty
        ? visit.services.first.name
        : (visit.vehicleLabel.isNotEmpty
              ? visit.vehicleLabel
              : visit.visitNumber);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VisitDetailScreen(visitId: visit.id)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sandBeige),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.deepCharcoal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AppColors.champagneGold,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AppTextStyles.headingFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepCharcoal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${visit.vehiclePlate.isNotEmpty ? "${visit.vehiclePlate} · " : ""}${visit.stageName}',
                    style: const TextStyle(
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.sandBeige.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+ Coins',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.champagneGold,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
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
              color: AppColors.sandBeige.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.history_outlined,
              color: AppColors.deepCharcoal,
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
                  'No Active Service Visits',
                  style: TextStyle(
                    fontFamily: AppTextStyles.headingFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepCharcoal,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Book your next treatment with Al Sewar',
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
              MaterialPageRoute(builder: (_) => const ServicesScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.deepCharcoal,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Book',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.pureWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
