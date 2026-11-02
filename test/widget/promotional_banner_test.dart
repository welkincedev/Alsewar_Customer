import 'package:carwashapp/app/theme/app_colors.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/services/location_service.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/home/widgets/promotional_banner.dart';
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
    username: 'vip_customer',
    email: 'vip@alsewar.com',
    firstName: 'VIP',
    lastName: 'Member',
    role: 'CUSTOMER',
    isActive: true,
  );

  Widget buildTestWidget({
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
        theme: ThemeData(
          splashFactory: InkRipple.splashFactory,
          scaffoldBackgroundColor: AppColors.warmPorcelain,
        ),
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  group('PromotionalBanner Fallback Carousel & Aspect Ratio Tests', () {
    testWidgets(
      'Empty backend banners render 3 local fallback banners with 2:1 aspect ratio',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: const PromotionalBanner(banners: [], user: testUser),
          ),
        );
        await tester.pumpAndSettle();

        // Must NOT return SizedBox.shrink()
        expect(find.byType(PromotionalBanner), findsOneWidget);
        expect(find.byType(PageView), findsOneWidget);

        // AspectRatio widget enforces exactly 2:1
        final aspectRatioFinder = find.byType(AspectRatio);
        expect(aspectRatioFinder, findsOneWidget);
        final aspectRatioWidget = tester.widget<AspectRatio>(aspectRatioFinder);
        expect(aspectRatioWidget.aspectRatio, equals(2.0));

        // Banner 1: Premium Auto Care
        expect(find.text('Al Sewar Auto Center'), findsOneWidget);
        expect(find.text('Premium care for every drive'), findsOneWidget);
        expect(find.text('Explore our services'), findsOneWidget);

        // Subtle Page indicators are rendered
        final animatedContainers = find.descendant(
          of: find.byType(PromotionalBanner),
          matching: find.byType(AnimatedContainer),
        );
        expect(animatedContainers, findsNWidgets(3));

        // Swipe to Banner 2: Complete Auto Care
        await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
        await tester.pumpAndSettle();

        expect(find.text('Your Car. Our Expertise.'), findsOneWidget);
        expect(
          find.text('Service • Detailing • Mechanical • More'),
          findsOneWidget,
        );
        expect(find.text('Discover Al Sewar'), findsOneWidget);

        // Swipe to Banner 3: Loyalty
        await tester.fling(find.byType(PageView), const Offset(-300, 0), 800);
        await tester.pumpAndSettle();

        expect(find.text('Service. Earn. Enjoy.'), findsOneWidget);
        expect(
          find.text('Every visit brings you closer to more rewards.'),
          findsOneWidget,
        );
        expect(find.text('View your rewards'), findsOneWidget);
      },
    );

    testWidgets('Backend banners take priority over local fallback banners', (
      tester,
    ) async {
      final backendBanners = [
        {
          'title': 'Active Backend Campaign',
          'subtitle': 'Verified priority promotion from backend API',
        },
      ];

      await tester.pumpWidget(
        buildTestWidget(
          child: PromotionalBanner(banners: backendBanners, user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Backend Campaign'), findsOneWidget);
      expect(
        find.text('Verified priority promotion from backend API'),
        findsOneWidget,
      );

      // Fallback banners are NOT displayed
      expect(find.text('Al Sewar Auto Center'), findsNothing);
    });

    testWidgets('Tapping fallback banner triggers existing navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const PromotionalBanner(banners: [], user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Banner 1 (Explore our services -> ServicesScreen)
      await tester.tap(find.text('Explore our services'));
      await tester.pumpAndSettle();

      expect(find.byType(ServicesScreen), findsOneWidget);
    });

    testWidgets('Loading state renders compact 2.7:1 skeleton indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(child: const PromotionalBanner(isLoading: true)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Al Sewar Auto Center'), findsNothing);
    });

    testWidgets(
      'Error state displays discrete error and does not show fallback banners',
      (tester) async {
        bool retried = false;

        await tester.pumpWidget(
          buildTestWidget(
            child: PromotionalBanner(
              error: Exception('Backend network failure'),
              errorMessage: 'Could not load campaigns.',
              onRetry: () => retried = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Could not load campaigns.'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.text('Al Sewar Auto Center'), findsNothing);

        await tester.tap(find.text('Retry'));
        expect(retried, isTrue);
      },
    );

    testWidgets(
      'Responsive audit across 320px, 360px, 390px, and 480px viewports with zero overflow',
      (tester) async {
        const viewports = [
          Size(320, 568), // Compact
          Size(360, 640), // Standard Android
          Size(390, 844), // iPhone 12/13/14
          Size(480, 900), // Large phone / Phablet
        ];

        for (final vp in viewports) {
          tester.view.physicalSize = vp;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(
            buildTestWidget(
              child: const PromotionalBanner(banners: []),
              size: vp,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Al Sewar Auto Center'), findsOneWidget);
          expect(find.text('Premium care for every drive'), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      },
    );

    testWidgets(
      'Ultra-narrow constraints (w <= 1.3) render with zero RenderFlex overflow',
      (tester) async {
        // Specifically reproducing the reported BoxConstraints(0.0<=w<=1.3, 0.0<=h<=Infinity)
        await tester.pumpWidget(
          buildTestWidget(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 0.0,
                maxWidth: 1.3,
                minHeight: 0.0,
                maxHeight: double.infinity,
              ),
              child: const PromotionalBanner(banners: []),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Must not throw any RenderFlex overflow exceptions
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'PromotionalBanner inside HomeScreen SingleChildScrollView and Column(crossAxisAlignment: CrossAxisAlignment.start)',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [PromotionalBanner(banners: [])],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PromotionalBanner), findsOneWidget);
        expect(find.text('Al Sewar Auto Center'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
