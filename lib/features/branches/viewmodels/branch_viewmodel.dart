import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/branch.dart';
import '../services/branch_service.dart';
import 'branch_providers.dart';

class BranchListViewModel extends AsyncNotifier<List<Branch>> {
  late final BranchService _branchService;

  @override
  FutureOr<List<Branch>> build() async {
    _branchService = ref.watch(branchServiceProvider);
    return _fetchBranches();
  }

  /// Fetch active branches
  Future<List<Branch>> _fetchBranches() async {
    return await _branchService.getBranches();
  }

  /// Refresh branch list explicitly
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchBranches());
  }
}

final branchListViewModelProvider =
    AsyncNotifierProvider<BranchListViewModel, List<Branch>>(
      BranchListViewModel.new,
    );
