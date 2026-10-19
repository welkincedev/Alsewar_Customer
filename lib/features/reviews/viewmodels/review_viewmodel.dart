import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/review.dart';
import 'review_providers.dart';

class ReviewViewModel extends AsyncNotifier<List<CustomerReview>> {
  @override
  Future<List<CustomerReview>> build() => _fetch();

  Future<List<CustomerReview>> _fetch() =>
      ref.read(reviewServiceProvider).getReviews();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  /// Returns the submitted review, or throws.
  Future<CustomerReview> submitReview(ReviewRequest request) async {
    final review = await ref.read(reviewServiceProvider).submitReview(request);
    await refresh();
    return review;
  }
}
