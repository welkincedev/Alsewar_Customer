import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/branches/viewmodels/branch_providers.dart';
import '../../features/branches/viewmodels/branch_viewmodel.dart';
import '../../features/reviews/viewmodels/review_providers.dart';
import '../../features/services/viewmodels/service_providers.dart';
import '../../features/vehicles/viewmodels/vehicle_providers.dart';
import '../../features/visits/viewmodels/visit_providers.dart';
import 'preview_mock_data.dart';
import 'preview_viewmodels.dart';

/// Centralized Riverpod overrides for UI preview mode.
///
/// Injected into [ProviderScope] in `main.dart` only when
/// `PreviewConfig.isPreviewEnabled` is true.
final previewOverrides = [
  // 1. Customer Authentication Session
  authViewModelProvider.overrideWith(PreviewAuthViewModel.new),

  // 2. Customer Vehicles
  vehicleViewModelProvider.overrideWith(PreviewVehicleViewModel.new),

  // 3. Service Catalogue
  customerServicesProvider.overrideWith(
    (ref) => Future.value(PreviewMockData.sampleServices),
  ),
  branchServicesProvider.overrideWith(
    (ref, branchId) => Future.value(PreviewMockData.sampleServices),
  ),

  // 4. Service Visits (History & Detail)
  visitViewModelProvider.overrideWith(PreviewVisitViewModel.new),
  visitDetailProvider.overrideWith(
    (ref, id) => Future.value(PreviewMockData.getVisitById(id)),
  ),

  // 5. Branches & Operating Hours
  branchListViewModelProvider.overrideWith(PreviewBranchListViewModel.new),
  branchDetailProvider.overrideWith(
    (ref, id) => Future.value(PreviewMockData.getBranchById(id)),
  ),
  branchHoursProvider.overrideWith(
    (ref, id) => Future.value(PreviewMockData.sampleBusinessHours),
  ),

  // 6. Customer Reviews
  reviewViewModelProvider.overrideWith(PreviewReviewViewModel.new),
];
