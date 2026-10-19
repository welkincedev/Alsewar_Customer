import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/viewmodels/auth_providers.dart';
import '../models/review.dart';
import '../services/review_service.dart';
import 'review_viewmodel.dart';

final reviewApiClientProvider = Provider<ApiClient>(
  (ref) => ref.watch(apiClientProvider),
);

final reviewStorageProvider = Provider<TokenStorage>(
  (ref) => ref.watch(tokenStorageProvider),
);

final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService(
    apiClient: ref.watch(reviewApiClientProvider),
    tokenStorage: ref.watch(reviewStorageProvider),
  );
});

final reviewViewModelProvider =
    AsyncNotifierProvider<ReviewViewModel, List<CustomerReview>>(
      ReviewViewModel.new,
    );
