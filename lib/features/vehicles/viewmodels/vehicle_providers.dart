import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/viewmodels/auth_providers.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import 'vehicle_viewmodel.dart';

final vehicleApiClientProvider = Provider<ApiClient>(
  (ref) => ref.watch(apiClientProvider),
);

final vehicleStorageProvider = Provider<TokenStorage>(
  (ref) => ref.watch(tokenStorageProvider),
);

final vehicleServiceProvider = Provider<VehicleService>((ref) {
  return VehicleService(
    apiClient: ref.watch(vehicleApiClientProvider),
    tokenStorage: ref.watch(vehicleStorageProvider),
  );
});

final vehicleViewModelProvider =
    AsyncNotifierProvider<VehicleViewModel, List<Vehicle>>(
      VehicleViewModel.new,
    );
