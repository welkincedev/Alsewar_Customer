import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/auth_user.dart';
import '../../features/auth/models/signup_request.dart';
import '../../features/auth/viewmodels/auth_state.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';
import '../../features/branches/models/branch.dart';
import '../../features/branches/viewmodels/branch_viewmodel.dart';
import '../../features/reviews/models/review.dart';
import '../../features/reviews/viewmodels/review_viewmodel.dart';
import '../../features/vehicles/models/vehicle.dart';
import '../../features/vehicles/models/vehicle_request.dart';
import '../../features/vehicles/viewmodels/vehicle_viewmodel.dart';
import '../../features/visits/models/service_visit.dart';
import '../../features/visits/viewmodels/visit_viewmodel.dart';
import 'preview_mock_data.dart';

/// Preview implementation of [AuthViewModel] that provides an instant authenticated
/// session using [PreviewMockData.sampleCustomer] without requiring the backend server.
class PreviewAuthViewModel extends AuthViewModel {
  @override
  FutureOr<AuthState> build() async {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: PreviewMockData.sampleCustomer,
    );
  }

  @override
  Future<AuthState> restoreSession() async {
    return const AuthState(
      status: AuthStatus.authenticated,
      user: PreviewMockData.sampleCustomer,
    );
  }

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.data(
      AuthState(
        status: AuthStatus.authenticated,
        user: PreviewMockData.sampleCustomer,
      ),
    );
  }

  @override
  Future<AuthUser> signup(SignupRequest request) async {
    state = const AsyncValue.data(
      AuthState(
        status: AuthStatus.authenticated,
        user: PreviewMockData.sampleCustomer,
      ),
    );
    return PreviewMockData.sampleCustomer;
  }

  @override
  Future<void> logout() async {
    state = const AsyncValue.data(
      AuthState(status: AuthStatus.unauthenticated),
    );
  }
}

/// Preview implementation of [VehicleViewModel] providing in-memory interactive CRUD
/// operations with sample vehicles.
class PreviewVehicleViewModel extends VehicleViewModel {
  late List<Vehicle> _vehicles;

  @override
  Future<List<Vehicle>> build() async {
    _vehicles = List<Vehicle>.from(PreviewMockData.sampleVehicles);
    return _vehicles;
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    _vehicles = List<Vehicle>.from(PreviewMockData.sampleVehicles);
    state = AsyncData(_vehicles);
  }

  @override
  Future<Vehicle> addVehicle(VehicleRequest request) async {
    final newVehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      plateNumber: request.plateNumber.toUpperCase(),
      make: request.make,
      model: '${request.model} [Preview]',
      year: request.year,
      color: request.color,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    _vehicles.add(newVehicle);
    state = AsyncData(List<Vehicle>.from(_vehicles));
    return newVehicle;
  }

  @override
  Future<Vehicle> updateVehicle(int id, VehicleRequest request) async {
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      final updated = Vehicle(
        id: id,
        plateNumber: request.plateNumber.toUpperCase(),
        make: request.make,
        model: '${request.model} [Preview]',
        year: request.year,
        color: request.color,
        createdAt: _vehicles[index].createdAt,
        updatedAt: DateTime.now().toIso8601String(),
      );
      _vehicles[index] = updated;
      state = AsyncData(List<Vehicle>.from(_vehicles));
      return updated;
    }
    return _vehicles.first;
  }

  @override
  Future<void> removeVehicle(int id) async {
    _vehicles.removeWhere((v) => v.id == id);
    state = AsyncData(List<Vehicle>.from(_vehicles));
  }
}

/// Preview implementation of [VisitViewModel] supplying sample service visits.
class PreviewVisitViewModel extends VisitViewModel {
  @override
  Future<List<ServiceVisit>> build() async {
    return List<ServiceVisit>.from(PreviewMockData.sampleVisits);
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(List<ServiceVisit>.from(PreviewMockData.sampleVisits));
  }
}

/// Preview implementation of [BranchListViewModel] supplying sample branches.
class PreviewBranchListViewModel extends BranchListViewModel {
  @override
  Future<List<Branch>> build() async {
    return List<Branch>.from(PreviewMockData.sampleBranches);
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(List<Branch>.from(PreviewMockData.sampleBranches));
  }
}

/// Preview implementation of [ReviewViewModel] supplying sample reviews.
class PreviewReviewViewModel extends ReviewViewModel {
  late List<CustomerReview> _reviews;

  @override
  Future<List<CustomerReview>> build() async {
    _reviews = List<CustomerReview>.from(PreviewMockData.sampleReviews);
    return _reviews;
  }

  @override
  Future<void> refresh() async {
    state = const AsyncLoading();
    _reviews = List<CustomerReview>.from(PreviewMockData.sampleReviews);
    state = AsyncData(_reviews);
  }

  @override
  Future<CustomerReview> submitReview(ReviewRequest request) async {
    final newReview = CustomerReview(
      id: DateTime.now().millisecondsSinceEpoch % 10000,
      visitId: request.visitId,
      visitDetails: {'visit_number': 'PRV-VISIT-PREVIEW'},
      branchDetails: {'name': 'Al Sewar Riyadh Olaya [Preview]'},
      rating: request.rating,
      comment: '${request.comment ?? ""} [PREVIEW REVIEW]',
      isApproved: true,
      createdAt: DateTime.now().toIso8601String(),
    );
    _reviews.insert(0, newReview);
    state = AsyncData(List<CustomerReview>.from(_reviews));
    return newReview;
  }
}
