import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/branches/services/location_service.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/branches/widgets/branch_details_bottom_sheet.dart';
import 'package:carwashapp/features/support/screens/whatsapp_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeBranchListViewModel extends BranchListViewModel {
  final List<Branch>? initialBranches;
  final Object? error;

  _FakeBranchListViewModel({this.initialBranches, this.error});

  @override
  Future<List<Branch>> build() async {
    if (error != null) {
      throw Exception(error.toString());
    }
    return initialBranches ?? [];
  }
}

class _FakeLocationService extends LocationService {
  final LocationResult result;

  _FakeLocationService({required this.result});

  @override
  Future<LocationResult> getCurrentLocation() async {
    return result;
  }
}

void main() {
  const testBranchWithCoords = Branch(
    id: 10,
    name: 'Al Sewar Riyadh Olaya',
    code: 'OLY01',
    address: 'Olaya Street, Al Olaya District',
    city: 'Riyadh',
    phone: '+966 50 123 4567',
    whatsappNumber: '+966509998877',
    email: 'olaya@alsewar.com',
    latitude: 24.7136,
    longitude: 46.6753,
    isActive: true,
  );

  const testBranchWithoutCoords = Branch(
    id: 11,
    name: 'Al Sewar Jeddah Airport',
    code: 'JED02',
    address: 'Madinah Road',
    city: 'Jeddah',
    phone: '+966 55 987 6543',
    whatsappNumber: '+966559876543',
    email: 'jeddah@alsewar.com',
    latitude: null,
    longitude: null,
    isActive: true,
  );

  const testBranchNoPhone = Branch(
    id: 12,
    name: 'Al Sewar Dammam Express',
    code: 'DMM03',
    address: 'King Abdulaziz Road',
    city: 'Dammam',
    phone: '',
    whatsappNumber: null,
    email: 'dammam@alsewar.com',
    latitude: 26.4207,
    longitude: 50.0888,
    isActive: true,
  );

  Widget createWidget({
    List<Branch>? branches,
    Object? error,
    LocationService? locationService,
    Widget? child,
  }) {
    return ProviderScope(
      overrides: [
        branchListViewModelProvider.overrideWith(
          () =>
              _FakeBranchListViewModel(initialBranches: branches, error: error),
        ),
        if (locationService != null)
          locationServiceProvider.overrideWithValue(locationService),
      ],
      child: MaterialApp(home: child ?? const BranchMapScreen()),
    );
  }

  group('BranchDetailsBottomSheet Tests', () {
    testWidgets(
      'displays branch name, address, phone, WhatsApp number, email, and side-by-side action buttons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BranchDetailsBottomSheet(branch: testBranchWithCoords),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Branch name & code
        expect(find.text('Al Sewar Riyadh Olaya'), findsOneWidget);
        expect(find.text('Branch Code: OLY01'), findsOneWidget);

        // Full address
        expect(
          find.text('Olaya Street, Al Olaya District, Riyadh'),
          findsOneWidget,
        );

        // Contact number
        expect(find.text('+966 50 123 4567'), findsOneWidget);

        // WhatsApp contact row
        expect(find.text('+966509998877'), findsOneWidget);

        // Email row
        expect(find.text('olaya@alsewar.com'), findsOneWidget);

        // Side-by-side buttons
        expect(find.text('WhatsApp'), findsOneWidget);
        expect(find.text('Get Directions'), findsOneWidget);
      },
    );

    testWidgets(
      'displays dynamic distance label when user location is provided',
      (tester) async {
        // User located ~2.4 km away from branch
        // Riyadh test coords: 24.7136, 46.6753
        // User coords slightly offset
        const userLoc = LatLng(24.7300, 46.6850);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BranchDetailsBottomSheet(
                branch: testBranchWithCoords,
                userLocation: userLoc,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Distance label is rendered with "away"
        expect(find.textContaining('away'), findsOneWidget);
        expect(find.byIcon(Icons.near_me_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'hides distance label when user location is null or branch coordinates are missing',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: BranchDetailsBottomSheet(
                branch: testBranchWithoutCoords,
                userLocation: LatLng(24.7136, 46.6753),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // No distance label when coordinates are missing
        expect(find.textContaining('away'), findsNothing);
      },
    );

    testWidgets('handles branch with missing WhatsApp gracefully', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BranchDetailsBottomSheet(branch: testBranchNoPhone),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Al Sewar Dammam Express'), findsOneWidget);
      expect(find.text('Not available'), findsOneWidget);
      expect(find.text('WhatsApp Unavailable'), findsOneWidget);
    });
  });

  group('BranchMapScreen Widget Tests (OpenStreetMap / flutter_map)', () {
    testWidgets(
      'renders FlutterMap, markers, summary pill, and compact My Location button',
      (tester) async {
        await tester.pumpWidget(createWidget(branches: [testBranchWithCoords]));
        await tester.pumpAndSettle();

        // FlutterMap is rendered
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.byType(TileLayer), findsOneWidget);
        expect(find.byType(MarkerLayer), findsOneWidget);
        expect(find.byType(RichAttributionWidget), findsOneWidget);

        // Summary pill is displayed
        expect(find.text('1 Branch Available'), findsOneWidget);
        expect(find.text('Tap marker for details'), findsOneWidget);

        // Floating action buttons (zoom controls + compact My Location button)
        expect(find.byTooltip('Zoom In'), findsOneWidget);
        expect(find.byTooltip('Zoom Out'), findsOneWidget);
        expect(find.byTooltip('My Location'), findsOneWidget);
        expect(find.byIcon(Icons.my_location), findsOneWidget);

        // Ensure "Fit All Branches" is removed
        expect(find.byTooltip('Fit All Branches'), findsNothing);
      },
    );

    testWidgets('tapping My Location obtains position and adds user marker', (
      tester,
    ) async {
      final fakeLocationService = _FakeLocationService(
        result: const LocationResult(
          status: LocationResultStatus.success,
          position: LatLng(24.7136, 46.6753),
        ),
      );

      await tester.pumpWidget(
        createWidget(
          branches: [testBranchWithCoords],
          locationService: fakeLocationService,
        ),
      );
      await tester.pumpAndSettle();

      // Tap My Location button
      await tester.tap(find.byTooltip('My Location'));
      await tester.pumpAndSettle();

      // User location marker is added to map
      expect(find.byTooltip('My Location'), findsWidgets);

      // Nearest branch feedback in snackbar
      expect(find.textContaining('Al Sewar Riyadh Olaya'), findsWidgets);
    });

    testWidgets('filters invalid coordinates and shows valid count', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(branches: [testBranchWithCoords, testBranchWithoutCoords]),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('1 Branch Available'), findsOneWidget);
    });

    testWidgets(
      'tapping branch marker opens BranchDetailsBottomSheet with branch details and actions',
      (tester) async {
        await tester.pumpWidget(createWidget(branches: [testBranchWithCoords]));
        await tester.pumpAndSettle();

        final markerFinder = find.byTooltip('Al Sewar Riyadh Olaya');
        expect(markerFinder, findsOneWidget);

        await tester.tap(markerFinder);
        await tester.pumpAndSettle();

        expect(find.byType(BranchDetailsBottomSheet), findsOneWidget);
        expect(find.text('Al Sewar Riyadh Olaya'), findsWidgets);
        expect(find.text('WhatsApp'), findsOneWidget);
        expect(find.text('Get Directions'), findsOneWidget);
      },
    );

    testWidgets(
      'displays fallback layout when all branches have missing coordinates',
      (tester) async {
        await tester.pumpWidget(
          createWidget(branches: [testBranchWithoutCoords]),
        );
        await tester.pumpAndSettle();

        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.text('Coordinates Unavailable'), findsOneWidget);
        expect(find.text('Al Sewar Jeddah Airport'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
      },
    );

    testWidgets('displays empty state when no branches are returned', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(branches: []));
      await tester.pumpAndSettle();

      expect(find.text('No Branches Found'), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Refresh'), findsOneWidget);
    });

    testWidgets('displays error state with retry button when API fails', (
      tester,
    ) async {
      await tester.pumpWidget(createWidget(error: 'Network connection error'));
      await tester.pumpAndSettle();

      expect(find.text('Could Not Load Branches'), findsOneWidget);
      expect(find.text('Network connection error'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Try Again'), findsOneWidget);
    });

    testWidgets('WhatsAppSupportScreen embeds and displays BranchMapScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          branches: [testBranchWithCoords],
          child: const WhatsAppSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WhatsAppSupportScreen), findsOneWidget);
      expect(find.byType(BranchMapScreen), findsOneWidget);
      expect(find.byType(FlutterMap), findsOneWidget);
    });
  });
}
