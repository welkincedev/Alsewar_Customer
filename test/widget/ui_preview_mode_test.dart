import 'package:carwashapp/app/app.dart';
import 'package:carwashapp/dev/preview/preview_config.dart';
import 'package:carwashapp/dev/preview/preview_mock_data.dart';
import 'package:carwashapp/dev/preview/preview_providers.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:carwashapp/features/home/views/home_screen.dart';
import 'package:carwashapp/features/home/widgets/loyalty_card.dart';
import 'package:carwashapp/features/home/widgets/membership_details_bottom_sheet.dart';
import 'package:carwashapp/features/profile/screens/profile_screen.dart';
import 'package:carwashapp/features/services/screens/services_screen.dart';
import 'package:carwashapp/features/vehicles/models/vehicle_request.dart';
import 'package:carwashapp/features/vehicles/screens/vehicles_screen.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_providers.dart';
import 'package:carwashapp/features/visits/screens/visit_detail_screen.dart';
import 'package:carwashapp/features/visits/screens/visits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    // Reset preview mode to default
    PreviewConfig.enable();
  });

  group('PreviewConfig Unit Tests', () {
    test('enables and disables preview mode toggles correctly', () {
      PreviewConfig.enable();
      expect(PreviewConfig.isPreviewEnabled, isTrue);

      PreviewConfig.disable();
      expect(PreviewConfig.isPreviewEnabled, isFalse);

      PreviewConfig.enable();
      expect(PreviewConfig.isPreviewEnabled, isTrue);
    });
  });

  group('PreviewMockData Integrity & Clearly Identified Mock Values', () {
    test('sample customer profile has valid customer role, Gold tier and preview indicator', () {
      final customer = PreviewMockData.sampleCustomer;
      expect(customer.id, equals(999));
      expect(customer.role, equals('CUSTOMER'));
      expect(customer.isActive, isTrue);
      expect(customer.lastName, contains('#'));
      expect(customer.email, contains('.dev'));
      expect(customer.displayName, contains('Ahmed'));
      expect(customer.loyaltyPoints, equals(30000));
      expect(customer.membershipTier, equals('GOLD'));
      expect(customer.membershipId, equals('AS-88301'));
    });

    test('sample vehicles have preview markers and correct attributes', () {
      final vehicles = PreviewMockData.sampleVehicles;
      expect(vehicles.length, equals(3));

      // Each vehicle is clearly marked with #
      for (final v in vehicles) {
        expect(v.model, contains('#'));
        expect(v.plateNumber, startsWith('PRV '));
      }

      expect(vehicles[0].make, equals('Mercedes-Benz'));
      expect(vehicles[1].make, equals('Porsche'));
      expect(vehicles[2].make, equals('Lexus'));
    });

    test(
      'sample visits map to vehicles and branches with preview indicators',
      () {
        final visits = PreviewMockData.sampleVisits;
        expect(visits.length, equals(3));

        // Visit 1 is for vehicle 101 and completed
        expect(visits[0].vehicleId, equals(101));
        expect(visits[0].isCompleted, isTrue);
        expect(visits[0].createdAt, equals('2026-10-14T09:00:00Z'));
        expect(visits[0].visitNumber, startsWith('PRV-VISIT-'));

        // Visit 2 is for vehicle 102 and completed
        expect(visits[1].vehicleId, equals(102));
        expect(visits[1].isCompleted, isTrue);
        expect(visits[1].createdAt, equals('2026-09-28T13:00:00Z'));

        // Visit 3 is for vehicle 101 and in progress
        expect(visits[2].vehicleId, equals(101));
        expect(visits[2].isCompleted, isFalse);
        expect(visits[2].stageName, equals('In Progress'));
      },
    );

    test('sample services catalogue contains luxury detailing entries', () {
      final services = PreviewMockData.sampleServices;
      expect(services.length, greaterThanOrEqualTo(4));
      for (final s in services) {
        expect(s.name, contains('#'));
        expect(s.description.isNotEmpty, isTrue);
      }
    });

    test('sample branches have valid coordinates and contact details', () {
      final branches = PreviewMockData.sampleBranches;
      expect(branches.length, equals(3));
      for (final b in branches) {
        expect(b.name, contains('#'));
        expect(b.latitude, isNotNull);
        expect(b.longitude, isNotNull);
        expect(b.phone, isNotEmpty);
      }
    });
  });

  group('UI Preview Mode Widget & Screen Previews', () {
    testWidgets(
      'CarWashApp boots directly into CustomerMainShell with PREVIEW banner in preview mode',
      (tester) async {
        PreviewConfig.enable();

        await tester.pumpWidget(
          ProviderScope(overrides: previewOverrides, child: const CarWashApp()),
        );
        await tester.pumpAndSettle();

        // 1. App loads CustomerMainShell directly without waiting for live backend
        expect(find.byType(CustomerMainShell), findsOneWidget);
        expect(find.byType(HomeScreen), findsOneWidget);

        // 2. Corner PREVIEW badge is displayed
        final bannerFinder = find.byType(Banner);
        expect(bannerFinder, findsOneWidget);
        expect(tester.widget<Banner>(bannerFinder).message, 'PREVIEW');

        // 3. Customer greeting displays preview member
        expect(find.textContaining('Ahmed'), findsWidgets);

        // 4. Loyalty Card displays preview Gold member info
        expect(find.byType(LoyaltyCard), findsOneWidget);
        expect(find.textContaining('Ahmed Al-Mansoor #'), findsNWidgets(2));
        expect(find.text('30,000'), findsOneWidget);
        expect(find.text('GOLD MEMBER'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Gold LoyaltyCard in preview mode opens MembershipDetailsBottomSheet with 30,000 pts and Platinum target',
      (tester) async {
        PreviewConfig.enable();

        await tester.pumpWidget(
          ProviderScope(overrides: previewOverrides, child: const CarWashApp()),
        );
        await tester.pumpAndSettle();

        // 1. Verify Gold member hero card is visible
        expect(find.byType(LoyaltyCard), findsOneWidget);
        expect(find.text('30,000'), findsOneWidget);
        expect(find.text('GOLD MEMBER'), findsOneWidget);

        // 2. Tap LoyaltyCard to open details bottom sheet
        await tester.tap(find.byType(LoyaltyCard));
        await tester.pumpAndSettle();

        // 3. Verify Membership Details sheet contents
        expect(find.byType(MembershipDetailsBottomSheet), findsOneWidget);
        expect(find.text('Membership Details'), findsOneWidget);
        expect(find.text('Next Tier: Platinum'), findsOneWidget);
        expect(
          find.text('50,001'),
          findsOneWidget,
        ); // Required points for Platinum
        expect(find.text('20,001'), findsOneWidget); // Points remaining
        expect(
          find.textContaining('20,001 more points to unlock Platinum'),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(MembershipDetailsBottomSheet),
            matching: find.text('ID: AS-88301'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'VehiclesScreen renders preview vehicle cards with computed last service dates and "No service yet"',
      (tester) async {
        PreviewConfig.enable();

        await tester.pumpWidget(
          ProviderScope(
            overrides: previewOverrides,
            child: const MaterialApp(home: VehiclesScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // 1. All 3 sample vehicles are displayed
        expect(find.text('PRV 101'), findsOneWidget);
        expect(find.text('PRV 202'), findsOneWidget);
        expect(find.text('PRV 303'), findsOneWidget);

        // 2. Models with # tags are rendered
        expect(find.textContaining('S 500 #'), findsOneWidget);
        expect(find.textContaining('Cayenne GTS #'), findsOneWidget);
        expect(find.textContaining('LX 600 #'), findsOneWidget);

        // 3. Vehicle 101 shows recent service date from Visit 3 (Oct 20, 2026)
        expect(find.textContaining('20 Oct 2026'), findsOneWidget);

        // 4. Vehicle 102 shows service date from Visit 2
        expect(find.textContaining('28 Sep 2026'), findsOneWidget);

        // 5. Vehicle 103 (no visits) displays "No service yet"
        expect(find.text('No service yet'), findsOneWidget);

        // 6. Delete button is absent
        expect(find.byIcon(Icons.delete), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
      },
    );

    testWidgets('Interactive addVehicle updates in-memory preview state', (
      tester,
    ) async {
      PreviewConfig.enable();

      final container = ProviderContainer(overrides: previewOverrides);
      addTearDown(container.dispose);

      // Initial count
      final initialVehicles = await container.read(
        vehicleViewModelProvider.future,
      );
      expect(initialVehicles.length, equals(3));

      // Add a 4th preview vehicle
      await container
          .read(vehicleViewModelProvider.notifier)
          .addVehicle(
            const VehicleRequest(
              plateNumber: 'PRV 404',
              make: 'Audi',
              model: 'RS e-tron GT',
              year: 2025,
              color: 'Tactical Green',
            ),
          );

      final updatedVehicles = await container.read(
        vehicleViewModelProvider.future,
      );
      expect(updatedVehicles.length, equals(4));
      expect(updatedVehicles.last.plateNumber, equals('PRV 404'));
      expect(updatedVehicles.last.model, contains('RS e-tron GT #'));
    });

    testWidgets('ServicesScreen renders catalogue in preview mode', (
      tester,
    ) async {
      PreviewConfig.enable();

      await tester.pumpWidget(
        ProviderScope(
          overrides: previewOverrides,
          child: const MaterialApp(home: ServicesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Executive Hydro-Wash #'), findsOneWidget);
      expect(find.text('Ceramic Shield Detailing #'), findsOneWidget);
      expect(find.text('Interior Ozone Sanitization #'), findsOneWidget);
    });

    testWidgets('VisitsScreen renders service history in preview mode', (
      tester,
    ) async {
      PreviewConfig.enable();

      await tester.pumpWidget(
        ProviderScope(
          overrides: previewOverrides,
          child: const MaterialApp(home: VisitsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PRV-VISIT-2026-001'), findsOneWidget);
      expect(find.text('PRV-VISIT-2026-002'), findsOneWidget);
      expect(find.text('PRV-VISIT-2026-003'), findsOneWidget);
      expect(find.text('Completed'), findsWidgets);
      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets(
      'VisitDetailScreen renders visit details and timeline in preview mode',
      (tester) async {
        PreviewConfig.enable();

        await tester.pumpWidget(
          ProviderScope(
            overrides: previewOverrides,
            child: const MaterialApp(home: VisitDetailScreen(visitId: 201)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('PRV-VISIT-2026-001'), findsOneWidget);
        expect(find.text('Executive Hydro-Wash #'), findsOneWidget);
        expect(find.text('Ceramic Shield Detailing #'), findsOneWidget);
        expect(find.text('Checked In'), findsOneWidget);
      },
    );

    testWidgets(
      'ProfileScreen renders preview customer data and logout works',
      (tester) async {
        PreviewConfig.enable();

        await tester.pumpWidget(
          ProviderScope(
            overrides: previewOverrides,
            child: const MaterialApp(
              home: ProfileScreen(user: PreviewMockData.sampleCustomer),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Ahmed Al-Mansoor #'), findsNWidgets(2));
        expect(
          find.textContaining('preview.customer@alsewar.dev'),
          findsNWidgets(2),
        );
        expect(find.text('+966 50 123 4567'), findsOneWidget);
      },
    );

    testWidgets('BranchMapScreen renders preview branches on OpenStreetMap', (
      tester,
    ) async {
      PreviewConfig.enable();

      await tester.pumpWidget(
        ProviderScope(
          overrides: previewOverrides,
          child: const MaterialApp(home: BranchMapScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 3 preview branches available
      expect(find.text('3 Branches Available'), findsOneWidget);
      expect(find.byTooltip('Zoom In'), findsOneWidget);
      expect(find.byTooltip('Zoom Out'), findsOneWidget);
    });

    testWidgets(
      'When preview mode is disabled, CarWashApp does not show PREVIEW banner',
      (tester) async {
        PreviewConfig.disable();

        await tester.pumpWidget(
          const ProviderScope(overrides: [], child: CarWashApp()),
        );
        await tester.pump();

        // Banner with 'PREVIEW' message is NOT displayed
        expect(find.byType(Banner), findsNothing);
      },
    );
  });
}
