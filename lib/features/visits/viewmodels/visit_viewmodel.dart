import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service_visit.dart';
import 'visit_providers.dart';

class VisitViewModel extends AsyncNotifier<List<ServiceVisit>> {
  @override
  Future<List<ServiceVisit>> build() => _fetch();

  Future<List<ServiceVisit>> _fetch() =>
      ref.read(visitApiServiceProvider).getVisits();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}
