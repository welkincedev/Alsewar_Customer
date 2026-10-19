import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/vehicle.dart';
import '../models/vehicle_request.dart';
import 'vehicle_providers.dart';

class VehicleViewModel extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() => _fetchVehicles();

  Future<List<Vehicle>> _fetchVehicles() {
    return ref.read(vehicleServiceProvider).getVehicles();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchVehicles);
  }

  Future<Vehicle> addVehicle(VehicleRequest request) async {
    final vehicle = await ref
        .read(vehicleServiceProvider)
        .createVehicle(request);
    state.whenData((list) {
      state = AsyncData([...list, vehicle]);
    });
    return vehicle;
  }

  Future<Vehicle> updateVehicle(int id, VehicleRequest request) async {
    final vehicle = await ref
        .read(vehicleServiceProvider)
        .updateVehicle(id, request.toJson());
    state.whenData((list) {
      state = AsyncData(list.map((v) => v.id == id ? vehicle : v).toList());
    });
    return vehicle;
  }

  Future<void> removeVehicle(int id) async {
    await ref.read(vehicleServiceProvider).deleteVehicle(id);
    state.whenData(
      (list) => state = AsyncData(list.where((v) => v.id != id).toList()),
    );
  }
}
