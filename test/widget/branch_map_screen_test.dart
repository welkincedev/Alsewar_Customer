import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/branches/widgets/branch_details_bottom_sheet.dart';
import 'package:carwashapp/features/support/screens/whatsapp_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  const testBranchWithCoords = Branch(
    id: 10,
    name: 'Al Sewar Riyadh Olaya',
    code: 'OLY01',
    address: 'Olaya Street, Al Olaya District',
    city: 'Riyadh',
    phone: '+966 50 123 4567',
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
    email: 'dammam@alsewar.com',
    latitude: 26.4207,
    longitude: 50.0888,
    isActive: true,
  );

  Widget createWidget({List<Branch>? branches, Object? error, Widget? child}) {
    return ProviderScope(
      overrides: [
        branchListViewModelProvider.overrideWith(
          () =>
              _FakeBranchListViewModel(initialBranches: branches, error: error),
        ),
      ],
      child: MaterialApp(home: child ?? const BranchMapScreen()),
    );
  }

  group('BranchDetailsBottomSheet Tests', () {
    testWidgets(
      'displays branch name, full address, contact number, and WhatsApp button',
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

        // Active WhatsApp button
        expect(find.text('Chat on WhatsApp'), findsOneWidget);
      },
    );

    testWidgets('handles branch with empty contact phone gracefully', (
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
      'renders interactive FlutterMap, TileLayer, markers and summary pill',
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

        // Floating action buttons (zoom controls + recenter)
        expect(find.byTooltip('Zoom In'), findsOneWidget);
        expect(find.byTooltip('Zoom Out'), findsOneWidget);
        expect(find.byTooltip('Fit All Branches'), findsOneWidget);
        expect(find.byIcon(Icons.center_focus_strong), findsOneWidget);
      },
    );

    testWidgets('filters invalid coordinates and shows valid count', (
      tester,
    ) async {
      await tester.pumpWidget(
        createWidget(branches: [testBranchWithCoords, testBranchWithoutCoords]),
      );
      await tester.pumpAndSettle();

      // Only 1 branch has valid coordinates, so pill reflects 1 Branch Available
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('1 Branch Available'), findsOneWidget);
    });

    testWidgets(
      'tapping branch marker opens BranchDetailsBottomSheet with branch details',
      (tester) async {
        await tester.pumpWidget(createWidget(branches: [testBranchWithCoords]));
        await tester.pumpAndSettle();

        // Marker widget is in MarkerLayer
        final markerFinder = find.byTooltip('Al Sewar Riyadh Olaya');
        expect(markerFinder, findsOneWidget);

        // Tap the marker
        await tester.tap(markerFinder);
        await tester.pumpAndSettle();

        // Verify bottom sheet opened with branch details
        expect(find.byType(BranchDetailsBottomSheet), findsOneWidget);
        expect(find.text('Al Sewar Riyadh Olaya'), findsWidgets);
        expect(find.text('Chat on WhatsApp'), findsOneWidget);
      },
    );

    testWidgets(
      'displays fallback layout when all branches have missing coordinates',
      (tester) async {
        await tester.pumpWidget(
          createWidget(branches: [testBranchWithoutCoords]),
        );
        await tester.pumpAndSettle();

        // Base FlutterMap at default location is rendered
        expect(find.byType(FlutterMap), findsOneWidget);

        // Warning card for unavailable coordinates
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
