import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/viewmodels/auth_providers.dart';
import '../models/service_item.dart';
import '../services/service_catalogue_service.dart';

final serviceApiClientProvider = Provider<ApiClient>(
  (ref) => ref.watch(apiClientProvider),
);

final serviceStorageProvider = Provider<TokenStorage>(
  (ref) => ref.watch(tokenStorageProvider),
);

final serviceCatalogueServiceProvider = Provider<ServiceCatalogueService>(
  (ref) => ServiceCatalogueService(
    apiClient: ref.watch(serviceApiClientProvider),
    tokenStorage: ref.watch(serviceStorageProvider),
  ),
);

/// All catalogue services
final customerServicesProvider = FutureProvider<List<ServiceItem>>((ref) {
  return ref.read(serviceCatalogueServiceProvider).getServices();
});

/// Services for a specific branch
final branchServicesProvider = FutureProvider.family<List<ServiceItem>, int>((
  ref,
  branchId,
) {
  return ref
      .read(serviceCatalogueServiceProvider)
      .getServicesByBranch(branchId);
});
