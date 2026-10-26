import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/branches/services/location_service.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/services/models/service_item.dart';
import 'package:carwashapp/features/services/screens/service_detail_screen.dart';
import 'package:carwashapp/features/services/screens/services_screen.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    return const LocationResult(status: LocationResultStatus.permissionDenied);
  }
}

class _TestBranchListViewModel extends BranchListViewModel {
  @override
  Future<List<Branch>> build() async => const [];
}

void main() {
  Widget createTestWidget({
    required Widget child,
    List<ServiceItem>? services,
    Object? error,
    Size size = const Size(390, 844),
  }) {
    return ProviderScope(
      overrides: [
        customerServicesProvider.overrideWith((ref) async {
          if (error != null) throw error;
          return services ?? const [];
        }),
        branchListViewModelProvider.overrideWith(
          () => _TestBranchListViewModel(),
        ),
        locationServiceProvider.overrideWithValue(_FakeLocationService()),
      ],
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  group('Available Services Screen Redesign Tests', () {
    testWidgets(
      'Renders compact header with title, subtitle, and category filter pills',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const ServicesScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.text('Available Services'), findsOneWidget);
        expect(
          find.text('Certified automotive craftsmanship across UAE bays'),
          findsOneWidget,
        );

        // Verify category pills
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Tyre Services'), findsWidgets);
        expect(find.text('Mechanical'), findsWidgets);
        expect(find.text('Body Services'), findsWidgets);
        expect(find.text('Detailing'), findsWidgets);
      },
    );

    testWidgets(
      'Renders verified Company Profile services when backend is empty',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const ServicesScreen(), services: const []),
        );
        await tester.pumpAndSettle();

        // First service card is in viewport
        expect(find.byKey(const Key('service_card_101')), findsOneWidget);

        // Drag down vertical list to reveal subsequent verified services
        await tester.drag(
          find.byKey(const Key('services_list_view')),
          const Offset(0, -350),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('service_card_102')), findsOneWidget);

        await tester.drag(
          find.byKey(const Key('services_list_view')),
          const Offset(0, -350),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('service_card_103')), findsOneWidget);
      },
    );

    testWidgets('Category filter pills dynamically filter displayed services', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const ServicesScreen()));
      await tester.pumpAndSettle();

      // Tap "Tyre Services" filter pill
      await tester.tap(find.byKey(const Key('category_pill_Tyre Services')));
      await tester.pumpAndSettle();

      // Tyre Services card should be visible in the vertical list
      expect(find.byKey(const Key('service_card_101')), findsOneWidget);

      // Drag to reveal the second tyre division service
      await tester.drag(
        find.byKey(const Key('services_list_view')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('service_card_108')), findsOneWidget);

      // Should NOT display Mechanical or Detailing services in Tyre Services tab
      expect(find.byKey(const Key('service_card_102')), findsNothing);
      expect(find.byKey(const Key('service_card_103')), findsNothing);
      expect(find.byKey(const Key('service_card_105')), findsNothing);
    });

    testWidgets(
      'Tapping a service card navigates to dedicated ServiceDetailScreen',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const ServicesScreen()),
        );
        await tester.pumpAndSettle();

        // Tap the first service card ("Tyre Services")
        await tester.tap(find.byKey(const Key('service_card_101')));
        await tester.pumpAndSettle();

        // Verify ServiceDetailScreen is opened
        expect(find.byType(ServiceDetailScreen), findsOneWidget);
        expect(find.text('Service Overview'), findsOneWidget);
        expect(find.text('What We Deliver'), findsOneWidget);
        expect(find.text('The Al Sewar Standard'), findsOneWidget);
        expect(find.text('Find Nearest Branch'), findsOneWidget);

        // Verify verified sub-services / highlights
        expect(
          find.textContaining('3D Wheel Alignment & Dynamic Balancing'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ServiceDetailScreen Find Nearest Branch navigates to BranchMapScreen',
      (tester) async {
        const testService = ServiceItem(
          id: 101,
          name: 'Tyre Services',
          category: 'Tyre Services',
          description:
              'Fast and safe tyre fitting and computerized wheel balancing.',
        );

        await tester.pumpWidget(
          createTestWidget(
            child: const ServiceDetailScreen(service: testService),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Find Nearest Branch
        await tester.tap(find.text('Find Nearest Branch'));
        await tester.pumpAndSettle();

        expect(find.byType(BranchMapScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Responsive audit of ServicesScreen across 320px, 360px, 390px, and 480px viewports',
      (tester) async {
        const viewports = [
          Size(320, 568),
          Size(360, 640),
          Size(390, 844),
          Size(480, 900),
        ];

        for (final vp in viewports) {
          tester.view.physicalSize = vp;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createTestWidget(child: const ServicesScreen(), size: vp),
          );
          await tester.pumpAndSettle();

          expect(find.text('Available Services'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('Error state displays retry button and recovers cleanly', (
      tester,
    ) async {
      bool fail = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerServicesProvider.overrideWith((ref) async {
              if (fail) throw Exception('API Connection timeout');
              return const [
                ServiceItem(
                  id: 1,
                  name: 'Service Restored',
                  description: 'Restored service',
                ),
              ];
            }),
          ],
          child: const MaterialApp(home: ServicesScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could Not Load Services'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      fail = false;
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(find.text('Service Restored'), findsOneWidget);
    });
  });
}
