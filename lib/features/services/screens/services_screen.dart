import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../viewmodels/service_providers.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(customerServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Services'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
      ),
      backgroundColor: AppColors.backgroundLight,
      body: servicesAsync.when(
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
                Text('Could Not Load Services', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
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
                  onPressed: () => ref.invalidate(customerServicesProvider),
                ),
              ],
            ),
          ),
        ),
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.miscellaneous_services_outlined,
                      size: 64,
                      color: AppColors.secondaryGold,
                    ),
                    const SizedBox(height: 16),
                    Text('No Services Available', style: AppTextStyles.heading),
                    const SizedBox(height: 8),
                    Text(
                      'Check back soon.',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final svc = services[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.miscellaneous_services,
                      color: AppColors.secondaryGold,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    svc.name,
                    style: AppTextStyles.title.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: svc.description.isNotEmpty
                      ? Text(
                          svc.description,
                          style: AppTextStyles.bodySecondary,
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
