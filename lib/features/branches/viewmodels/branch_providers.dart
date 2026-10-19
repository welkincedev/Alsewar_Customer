import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/viewmodels/auth_providers.dart';
import '../models/branch.dart';
import '../models/business_hour.dart';
import '../services/branch_service.dart';

/// Provider for BranchApiClient sharing the centralized ApiClient
final branchApiClientProvider = Provider<ApiClient>((ref) {
  return ref.watch(apiClientProvider);
});

/// Provider for BranchService
final branchServiceProvider = Provider<BranchService>((ref) {
  final apiClient = ref.watch(branchApiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return BranchService(apiClient: apiClient, tokenStorage: tokenStorage);
});

/// Family provider for fetching single branch details
final branchDetailProvider = FutureProvider.family<Branch, int>((
  ref,
  branchId,
) async {
  final branchService = ref.watch(branchServiceProvider);
  return await branchService.getBranchById(branchId);
});

/// Family provider for fetching branch weekly operating hours
final branchHoursProvider = FutureProvider.family<List<BusinessHour>, int>((
  ref,
  branchId,
) async {
  final branchService = ref.watch(branchServiceProvider);
  return await branchService.getBranchHours(branchId);
});
