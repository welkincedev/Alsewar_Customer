import 'package:carwashapp/features/vehicles/models/vehicle.dart';
import 'package:carwashapp/features/vehicles/models/vehicle_request.dart';
import 'package:carwashapp/features/vehicles/screens/vehicles_screen.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_providers.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_viewmodel.dart';
import 'package:carwashapp/features/visits/models/service_visit.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_providers.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeVehicleViewModel extends VehicleViewModel {
  final List<Vehicle> initialVehicles;
  VehicleRequest? lastAddedRequest;
  VehicleRequest? lastUpdatedRequest;
  int? lastUpdatedId;

  _FakeVehicleViewModel({this.initialVehicles = const []});

  @override
  Future<List<Vehicle>> build() async => initialVehicles;

  @override
  Future<Vehicle> addVehicle(VehicleRequest request) async {
    lastAddedRequest = request;
    final newVehicle = Vehicle(
      id: 999,
      plateNumber: request.plateNumber,
      make: request.make,
      model: request.model,
      year: request.year,
      color: request.color,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
    state = AsyncData([...state.asData?.value ?? [], newVehicle]);
    return newVehicle;
  }

  @override
  Future<Vehicle> updateVehicle(int id, VehicleRequest request) async {
    lastUpdatedId = id;
    lastUpdatedRequest = request;
    final updated = Vehicle(
      id: id,
      plateNumber: request.plateNumber,
      make: request.make,
      model: request.model,
      year: request.year,
      color: request.color,
      createdAt: '2026-01-01T00:00:00Z',
      updatedAt: DateTime.now().toIso8601String(),
    );
    state = AsyncData(
      (state.asData?.value ?? []).map((v) => v.id == id ? updated : v).toList(),
    );
    return updated;
  }
}

class _FakeVisitViewModel extends VisitViewModel {
  final List<ServiceVisit> initialVisits;
  _FakeVisitViewModel({this.initialVisits = const []});

  @override
  Future<List<ServiceVisit>> build() async => initialVisits;
}

void main() {
  const testVehicle1 = Vehicle(
    id: 101,
    plateNumber: 'DXB-9876',
    make: 'Lexus',
    model: 'LX600',
    year: 2024,
    color: 'Sonic Titanium',
    createdAt: '2026-01-10T08:00:00Z',
    updatedAt: '2026-01-10T08:00:00Z',
  );

  const testVehicle2 = Vehicle(
    id: 102,
    plateNumber: 'KSA-1234',
    make: 'Porsche',
    model: 'Cayenne GTS',
    year: 2023,
    color: 'Crayon Grey',
    createdAt: '2026-02-15T10:00:00Z',
    updatedAt: '2026-02-15T10:00:00Z',
  );

  const olderVisit = ServiceVisit(
    id: 1,
    visitNumber: 'VIS-001',
    vehicleDetails: {
      'id': 101,
      'plate_number': 'DXB-9876',
      'make': 'Lexus',
      'model': 'LX600',
    },
    services: [],
    statusHistory: [],
    createdAt: '2026-01-15T10:00:00Z',
    updatedAt: '2026-01-15T11:00:00Z',
  );

  const newerVisit = ServiceVisit(
    id: 2,
    visitNumber: 'VIS-002',
    vehicleDetails: {
      'id': 101,
      'plate_number': 'DXB-9876',
      'make': 'Lexus',
      'model': 'LX600',
    },
    services: [],
    statusHistory: [],
    createdAt: '2026-03-22T14:30:00Z',
    updatedAt: '2026-03-22T15:00:00Z',
  );

  Widget createWidget({
    required List<Vehicle> vehicles,
    required List<ServiceVisit> visits,
    _FakeVehicleViewModel? fakeVehicleVm,
  }) {
    return ProviderScope(
      overrides: [
        vehicleViewModelProvider.overrideWith(
          () =>
              fakeVehicleVm ?? _FakeVehicleViewModel(initialVehicles: vehicles),
        ),
        visitViewModelProvider.overrideWith(
          () => _FakeVisitViewModel(initialVisits: visits),
        ),
      ],
      child: const MaterialApp(home: VehiclesScreen()),
    );
  }

  group('VehiclesScreen Redesign Tests', () {
    testWidgets(
      'Vehicle card renders image fallback, name, model, plate, and last service date',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            vehicles: [testVehicle1],
            visits: [newerVisit, olderVisit],
          ),
        );
        await tester.pumpAndSettle();

        // Vehicle Name & Model
        expect(find.text('Lexus'), findsOneWidget);
        expect(find.text('LX600 (2024)'), findsOneWidget);

        // Plate number
        expect(find.text('DXB-9876'), findsOneWidget);

        // Color badge
        expect(find.text('Sonic Titanium'), findsOneWidget);

        // Image placeholder icon
        expect(
          find.byIcon(Icons.directions_car_filled_outlined),
          findsOneWidget,
        );

        // Last Service Date displays most recent formatted date (22 Mar 2026)
        expect(find.text('Last Service: '), findsOneWidget);
        expect(find.text('22 Mar 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'Last service date selects the most recent visit when multiple visits exist',
      (tester) async {
        // Provide visits in out-of-order sequence
        await tester.pumpWidget(
          createWidget(
            vehicles: [testVehicle1],
            visits: [olderVisit, newerVisit],
          ),
        );
        await tester.pumpAndSettle();

        // Most recent visit is newerVisit (22 Mar 2026), not olderVisit (15 Jan 2026)
        expect(find.text('22 Mar 2026'), findsOneWidget);
        expect(find.text('15 Jan 2026'), findsNothing);
      },
    );

    testWidgets(
      'Displays "No service yet" when no service history exists for vehicle',
      (tester) async {
        // testVehicle2 has NO visits
        await tester.pumpWidget(
          createWidget(
            vehicles: [testVehicle2],
            visits: [newerVisit, olderVisit], // visits belong to testVehicle1
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Porsche'), findsOneWidget);
        expect(find.text('Cayenne GTS (2023)'), findsOneWidget);
        expect(find.text('KSA-1234'), findsOneWidget);
        expect(find.text('No service yet'), findsOneWidget);
      },
    );

    testWidgets(
      'Delete button is completely absent from customer vehicle cards',
      (tester) async {
        await tester.pumpWidget(
          createWidget(
            vehicles: [testVehicle1, testVehicle2],
            visits: [newerVisit],
          ),
        );
        await tester.pumpAndSettle();

        // Neither delete icon nor delete text should be present anywhere
        expect(find.byIcon(Icons.delete_outline), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        expect(find.text('Remove'), findsNothing);
        expect(find.text('Delete'), findsNothing);
      },
    );

    testWidgets(
      'Edit button is present on vehicle cards and opens prefilled sheet',
      (tester) async {
        final fakeVm = _FakeVehicleViewModel(initialVehicles: [testVehicle1]);
        await tester.pumpWidget(
          createWidget(
            vehicles: [testVehicle1],
            visits: [newerVisit],
            fakeVehicleVm: fakeVm,
          ),
        );
        await tester.pumpAndSettle();

        // Edit icon button exists
        final editButton = find.byIcon(Icons.edit_outlined);
        expect(editButton, findsOneWidget);

        // Tap Edit button
        await tester.tap(editButton);
        await tester.pumpAndSettle();

        // Modal bottom sheet appears
        expect(find.text('Edit Vehicle'), findsOneWidget);
        expect(find.text('Update Vehicle'), findsOneWidget);

        // Verify fields are prefilled with testVehicle1 values in form
        expect(find.widgetWithText(TextFormField, 'DXB-9876'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Lexus'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'LX600'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, '2024'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'Sonic Titanium'),
          findsOneWidget,
        );

        // Submit update
        await tester.tap(find.text('Update Vehicle'));
        await tester.pumpAndSettle();

        expect(fakeVm.lastUpdatedId, equals(101));
        expect(fakeVm.lastUpdatedRequest?.plateNumber, equals('DXB-9876'));
        expect(fakeVm.lastUpdatedRequest?.make, equals('Lexus'));
        expect(fakeVm.lastUpdatedRequest?.model, equals('LX600'));
      },
    );

    testWidgets(
      'Add Vehicle FloatingActionButton opens empty form and calls addVehicle',
      (tester) async {
        final fakeVm = _FakeVehicleViewModel(initialVehicles: [testVehicle1]);
        await tester.pumpWidget(
          createWidget(
            vehicles: [testVehicle1],
            visits: [],
            fakeVehicleVm: fakeVm,
          ),
        );
        await tester.pumpAndSettle();

        // Tap Add Vehicle FAB
        await tester.tap(find.text('Add Vehicle'));
        await tester.pumpAndSettle();

        expect(find.text('Add Vehicle'), findsWidgets);
        expect(find.text('Save Vehicle'), findsOneWidget);

        // Fill in new vehicle fields
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Plate Number *'),
          'UAE-5555',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Make *'),
          'BMW',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Model *'),
          'M5',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Year'),
          '2025',
        );

        await tester.tap(find.text('Save Vehicle'));
        await tester.pumpAndSettle();

        expect(fakeVm.lastAddedRequest?.plateNumber, equals('UAE-5555'));
        expect(fakeVm.lastAddedRequest?.make, equals('BMW'));
        expect(fakeVm.lastAddedRequest?.model, equals('M5'));
        expect(fakeVm.lastAddedRequest?.year, equals(2025));
      },
    );

    testWidgets('Empty state renders when customer has no vehicles', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(vehicles: [], visits: []));
      await tester.pumpAndSettle();

      expect(find.text('No Vehicles Yet'), findsOneWidget);
      expect(
        find.text('Add your vehicle to track services and history.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });
  });
}
