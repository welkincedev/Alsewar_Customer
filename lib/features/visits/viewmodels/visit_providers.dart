import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/viewmodels/auth_providers.dart';
import '../models/service_visit.dart';
import '../services/visit_service.dart';
import 'visit_viewmodel.dart';

final visitApiClientProvider = Provider<ApiClient>(
  (ref) => ref.watch(apiClientProvider),
);

final visitStorageProvider = Provider<TokenStorage>(
  (ref) => ref.watch(tokenStorageProvider),
);

final visitApiServiceProvider = Provider<VisitApiService>((ref) {
  return VisitApiService(
    apiClient: ref.watch(visitApiClientProvider),
    tokenStorage: ref.watch(visitStorageProvider),
  );
});

final visitViewModelProvider =
    AsyncNotifierProvider<VisitViewModel, List<ServiceVisit>>(
      VisitViewModel.new,
    );

final visitDetailProvider = FutureProvider.family<ServiceVisit, int>((ref, id) {
  return ref.read(visitApiServiceProvider).getVisitById(id);
});
