import 'package:carwashapp/app/theme/app_colors.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/services/location_service.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/home/widgets/home_quick_actions.dart';
import 'package:carwashapp/features/services/screens/service_detail_screen.dart';
import 'package:carwashapp/features/services/screens/services_screen.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:carwashapp/features/vehicles/models/vehicle.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_providers.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_viewmodel.dart';
import 'package:carwashapp/features/visits/models/service_visit.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_providers.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<LocationResult> getCurrentLocation() async {
    return const LocationResult(status: LocationResultStatus.permissionDenied);
  }
}

class _TestVehicleViewModel extends VehicleViewModel {
  @override
  Future<List<Vehicle>> build() async => const [];
}

class _TestVisitViewModel extends VisitViewModel {
  @override
  Future<List<ServiceVisit>> build() async => const [];
}

class _TestBranchListViewModel extends BranchListViewModel {
  @override
  Future<List<Branch>> build() async => const [];
}

void main() {
  const testUser = AuthUser(
    id: 1,
    username: 'vip_member',
    email: 'member@alsewar.com',
    firstName: 'VIP',
    lastName: 'Member',
    role: 'CUSTOMER',
    isActive: true,
  );

  Widget createTestWidget({
    required Widget child,
    Size size = const Size(390, 844),
  }) {
    return ProviderScope(
      overrides: [
        customerServicesProvider.overrideWith((ref) => const []),
        vehicleViewModelProvider.overrideWith(() => _TestVehicleViewModel()),
        visitViewModelProvider.overrideWith(() => _TestVisitViewModel()),
        branchListViewModelProvider.overrideWith(
          () => _TestBranchListViewModel(),
        ),
        locationServiceProvider.overrideWithValue(_FakeLocationService()),
      ],
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );
  }

  group('HomeQuickActions – Service Shortcuts Grid Tests', () {
    testWidgets(
      'Renders section header with Our Services and VIEW ALL action',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const HomeQuickActions(user: testUser)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeQuickActions), findsOneWidget);
        expect(find.text('Our Services'), findsOneWidget);
        expect(find.text('VIEW ALL'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders seven verified services from Company Profile + More shortcut (8 total)',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const HomeQuickActions(user: testUser)),
        );
        await tester.pumpAndSettle();

        // 7 services + 1 More
        expect(find.text('Tyre Services'), findsOneWidget);
        expect(find.text('Auto Repair'), findsOneWidget);
        expect(find.text('Oil & Battery'), findsOneWidget);
        expect(find.text('Car Wash'), findsOneWidget);
        expect(find.text('Ceramic Coating'), findsOneWidget);
        expect(find.text('AC Servicing'), findsOneWidget);
        expect(find.text('Car Painting'), findsOneWidget);
        expect(find.text('More'), findsOneWidget);

        // Verify total 8 shortcut buttons
        final semanticsFinders = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.button == true,
        );
        expect(semanticsFinders, findsNWidgets(8));
      },
    );

    testWidgets(
      'Cards feature Pure White surface, subtle border, subtle shadow, and Image illustration with BoxFit.contain',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const HomeQuickActions(user: testUser)),
        );
        await tester.pumpAndSettle();

        final semanticsFinders = find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.button == true,
        );
        expect(semanticsFinders, findsNWidgets(8));

        for (final cardFinder in semanticsFinders.evaluate()) {
          final semantics = cardFinder.widget as Semantics;
          final animatedContainerFinder = find.descendant(
            of: find.byWidget(semantics),
            matching: find.byType(AnimatedContainer),
          );
          final animatedContainer = tester.widget<AnimatedContainer>(
            animatedContainerFinder.first,
          );
          final decoration = animatedContainer.decoration as BoxDecoration;

          // 16px corner radius
          expect(decoration.borderRadius, equals(BorderRadius.circular(16)));

          // Pure white surface
          expect(decoration.color, equals(AppColors.pureWhite));

          // Thin subtle border
          expect(decoration.border, isNotNull);
          expect(decoration.border!.top.color, equals(AppColors.subtleBorder));
          expect(decoration.border!.top.width, equals(1.0));

          // Subtle shadow present
          expect(decoration.boxShadow, isNotNull);

          // Image illustration with BoxFit.contain
          final imageFinder = find.descendant(
            of: find.byWidget(semantics),
            matching: find.byType(Image),
          );
          final image = tester.widget<Image>(imageFinder);
          expect(image.fit, equals(BoxFit.contain));

          // Navy label text
          final textFinder = find.descendant(
            of: find.byWidget(semantics),
            matching: find.byType(Text),
          );
          final textWidget = tester.widget<Text>(textFinder);
          expect(textWidget.style?.color, equals(AppColors.deepNavy));

          // AnimatedScale widget present for press animation
          final scaleFinder = find.descendant(
            of: find.byWidget(semantics),
            matching: find.byType(AnimatedScale),
          );
          expect(scaleFinder, findsOneWidget);
        }
      },
    );

    testWidgets('Cards have equal widths in each row and consistent heights', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const HomeQuickActions(user: testUser),
          size: const Size(390, 844),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinders = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.button == true,
      );

      final sizes = <Size>[];
      for (final element in semanticsFinders.evaluate()) {
        sizes.add(tester.getSize(find.byWidget(element.widget)));
      }

      expect(sizes.length, equals(8));

      // All 8 cards have equal height of 82px
      for (final s in sizes) {
        expect(s.height, equals(82.0));
      }

      // Row 1 tiles have equal width
      final r1Width = sizes[0].width;
      expect(sizes[1].width, equals(r1Width));
      expect(sizes[2].width, equals(r1Width));
      expect(sizes[3].width, equals(r1Width));

      // Row 2 tiles have equal width
      final r2Width = sizes[4].width;
      expect(sizes[5].width, equals(r2Width));
      expect(sizes[6].width, equals(r2Width));
      expect(sizes[7].width, equals(r2Width));
    });

    testWidgets(
      'Responsive audit across 320px, 360px, 390px, and 480px viewports with zero overflow',
      (tester) async {
        const viewports = [
          Size(320, 568), // Compact
          Size(360, 640), // Standard Android
          Size(390, 844), // iPhone
          Size(480, 900), // Large phone
        ];

        for (final vp in viewports) {
          tester.view.physicalSize = vp;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            createTestWidget(
              child: const HomeQuickActions(user: testUser),
              size: vp,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Our Services'), findsOneWidget);
          expect(find.text('Tyre Services'), findsOneWidget);
          expect(find.text('Auto Repair'), findsOneWidget);
          expect(find.text('Oil & Battery'), findsOneWidget);
          expect(find.text('Car Wash'), findsOneWidget);
          expect(find.text('Ceramic Coating'), findsOneWidget);
          expect(find.text('AC Servicing'), findsOneWidget);
          expect(find.text('Car Painting'), findsOneWidget);
          expect(find.text('More'), findsOneWidget);

          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets('Tapping service shortcut opens ServiceDetailScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const HomeQuickActions(user: testUser)),
      );
      await tester.pumpAndSettle();

      // Tap Tyre Services
      await tester.tap(find.text('Tyre Services'));
      await tester.pumpAndSettle();

      expect(find.byType(ServiceDetailScreen), findsOneWidget);
      expect(find.text('What We Deliver'), findsOneWidget);
      expect(find.text('Find Nearest Branch'), findsOneWidget);
    });

    testWidgets('Tapping More shortcut opens Available Services catalogue', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const HomeQuickActions(user: testUser)),
      );
      await tester.pumpAndSettle();

      // Tap More
      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.byType(ServicesScreen), findsOneWidget);
      expect(find.text('Available Services'), findsOneWidget);
    });

    testWidgets('Tapping VIEW ALL opens Available Services catalogue', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const HomeQuickActions(user: testUser)),
      );
      await tester.pumpAndSettle();

      // Tap VIEW ALL
      await tester.tap(find.text('VIEW ALL'));
      await tester.pumpAndSettle();

      expect(find.byType(ServicesScreen), findsOneWidget);
      expect(find.text('Available Services'), findsOneWidget);
    });
  });
}
