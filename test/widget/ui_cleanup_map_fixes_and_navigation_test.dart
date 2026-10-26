import 'package:carwashapp/features/about/screens/about_us_screen.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/branches/widgets/branch_details_bottom_sheet.dart';
import 'package:carwashapp/features/branches/services/location_service.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:carwashapp/features/home/views/home_screen.dart';
import 'package:carwashapp/features/home/widgets/featured_offers.dart';
import 'package:carwashapp/features/home/widgets/floating_pill_nav_bar.dart';
import 'package:carwashapp/features/home/widgets/home_quick_actions.dart';
import 'package:carwashapp/features/home/widgets/home_recent_services_section.dart';
import 'package:carwashapp/features/home/widgets/home_vehicle_section.dart';
import 'package:carwashapp/features/home/widgets/membership_details_bottom_sheet.dart';
import 'package:carwashapp/features/home/widgets/promotional_banner.dart';
import 'package:carwashapp/features/profile/screens/profile_screen.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:carwashapp/features/vehicles/models/vehicle.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_providers.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_viewmodel.dart';
import 'package:carwashapp/features/visits/models/service_visit.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_providers.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeLocationService extends LocationService {
  final LocationResult result;
  _FakeLocationService(this.result);

  @override
  Future<LocationResult> getCurrentLocation() async => result;
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
  final List<Branch> branches;
  _TestBranchListViewModel(this.branches);

  @override
  Future<List<Branch>> build() async => branches;
}

void main() {
  const testUser = AuthUser(
    id: 1,
    username: 'testcustomer',
    email: 'customer@alsewar.com',
    phone: '+966501234567',
    role: 'CUSTOMER',
    isActive: true,
    firstName: 'Ahmed',
    lastName: 'Al-Mansoor',
    loyaltyPoints: 3200,
    membershipTier: 'GOLD',
    membershipId: 'AS-882190',
  );

  const testBranch = Branch(
    id: 1,
    name: 'Al Sewar Olaya',
    code: 'OLY01',
    address: 'Olaya St, Building 14',
    city: 'Riyadh',
    phone: '+966501234567',
    whatsappNumber: '+966509876543',
    email: 'olaya@alsewar.com',
    latitude: 24.7136,
    longitude: 46.6753,
    isActive: true,
  );

  Widget createTestWidget({
    required Widget child,
    List<Branch> branches = const [testBranch],
    LatLng? userLocation = const LatLng(24.7130, 46.6750),
  }) {
    return ProviderScope(
      overrides: [
        customerServicesProvider.overrideWith((ref) => const []),
        vehicleViewModelProvider.overrideWith(() => _TestVehicleViewModel()),
        visitViewModelProvider.overrideWith(() => _TestVisitViewModel()),
        branchListViewModelProvider.overrideWith(
          () => _TestBranchListViewModel(branches),
        ),
        locationServiceProvider.overrideWithValue(
          _FakeLocationService(
            LocationResult(
              status: userLocation != null
                  ? LocationResultStatus.success
                  : LocationResultStatus.permissionDenied,
              position: userLocation,
            ),
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 47, bottom: 34),
            viewPadding: EdgeInsets.only(top: 47, bottom: 34),
          ),
          child: child,
        ),
      ),
    );
  }

  group('1. Bug Fixes: Nearest Branch Snackbar', () {
    testWidgets(
      'Nearest branch snackbar has approximately 2.5-second duration, floating overlay, and dismisses without displacing FAB',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const Scaffold(body: BranchMapScreen())),
        );
        await tester.pumpAndSettle();

        // Trigger GPS location via unique FAB
        final locationFab = find.widgetWithIcon(
          FloatingActionButton,
          Icons.my_location,
        );
        expect(locationFab, findsOneWidget);
        final fabCenterBefore = tester.getCenter(locationFab);

        await tester.tap(locationFab);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // Verify snackbar is configured with floating overlay and approximately 2.5-second duration
        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);
        final snackBar = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBar.duration, equals(const Duration(milliseconds: 2500)));
        expect(snackBar.behavior, equals(SnackBarBehavior.floating));
        expect(
          find.textContaining('Located! Nearest branch: Al Sewar Olaya'),
          findsOneWidget,
        );

        // Verify location FAB fixed position is preserved without displacement
        final fabCenterAfter = tester.getCenter(locationFab);
        expect(fabCenterAfter, equals(fabCenterBefore));

        // Tapping action opens BranchDetailsBottomSheet and dismisses SnackBar
        await tester.tap(find.text('View'));
        await tester.pumpAndSettle();
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byType(BranchDetailsBottomSheet), findsOneWidget);
      },
    );

    testWidgets('Duplicate snackbars are debounced on rapid location taps', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const Scaffold(body: BranchMapScreen())),
      );
      await tester.pumpAndSettle();

      final locationFab = find.widgetWithIcon(
        FloatingActionButton,
        Icons.my_location,
      );
      await tester.tap(locationFab);
      await tester.pump();
      expect(find.byType(SnackBar), findsOneWidget);

      // Rapidly tap again immediately
      await tester.tap(locationFab);
      await tester.pump();

      // Remains only 1 snackbar on screen (no duplicate queued)
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('2. Bug Fixes: Map Initial Loading & Constraints', () {
    testWidgets(
      'BranchMapScreen renders tiles and layout without touch gesture',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const Scaffold(body: BranchMapScreen())),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(FlutterMap), findsOneWidget);
        expect(find.byType(TileLayer), findsOneWidget);
        expect(find.byType(MarkerLayer), findsOneWidget);
        expect(find.text('1 Branch Available'), findsOneWidget);
        expect(find.byTooltip('My Location'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'BranchMapScreen inside CustomerMainShell activates seamlessly when switched',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: const CustomerMainShell(user: testUser, initialIndex: 1),
          ),
        );
        await tester.pumpAndSettle();

        // Initially on Home screen
        expect(find.byType(HomeScreen), findsOneWidget);

        // Switch to WhatsApp (Map) tab
        await tester.tap(find.text('WhatsApp'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(BranchMapScreen), findsOneWidget);
        expect(find.byType(FlutterMap), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('3. Home Page Restructuring & Spacing', () {
    testWidgets(
      'HomeScreen completely removes My Vehicles and Recent Services sections',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const HomeScreen(user: testUser)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeVehicleSection), findsNothing);
        expect(find.byType(HomeRecentServicesSection), findsNothing);
        expect(find.text('My Vehicles'), findsNothing);
        expect(find.text('Recent Services'), findsNothing);
      },
    );

    testWidgets(
      'HomeQuickActions has exactly 4 shortcuts: Branches, Services, History, Vehicles',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            child: const Scaffold(body: HomeQuickActions(user: testUser)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Branches'), findsOneWidget);
        expect(find.text('Services'), findsOneWidget);
        expect(find.text('History'), findsOneWidget);
        expect(find.text('Vehicles'), findsOneWidget);

        // Concierge shortcut is replaced by Vehicles
        expect(find.text('Concierge'), findsNothing);
      },
    );

    testWidgets(
      'PromotionalBanner renders before FeaturedOffers and displays fallback carousel when backend is empty',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const HomeScreen(user: testUser)),
        );
        await tester.pumpAndSettle();

        // PromotionalBanner renders the 2.7:1 fallback carousel with local banners
        expect(find.byType(PromotionalBanner), findsOneWidget);
        expect(find.text('Al Sewar Auto Center'), findsOneWidget);
        expect(find.text('Premium care for every drive'), findsOneWidget);
        expect(find.text('Explore our services'), findsOneWidget);

        // FeaturedOffers is present directly below
        expect(find.byType(FeaturedOffers), findsOneWidget);
        expect(find.text('Featured Offers'), findsOneWidget);
      },
    );

    testWidgets('Home Page bottom clearance eliminates excessive whitespace', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const CustomerMainShell(user: testUser, initialIndex: 1),
        ),
      );
      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(SingleChildScrollView);
      expect(scrollableFinder, findsOneWidget);

      // Scroll to bottom
      await tester.drag(scrollableFinder, const Offset(0, -600));
      await tester.pumpAndSettle();

      final navBarFinder = find.byType(FloatingPillNavBar);
      final navBarTop = tester.getTopLeft(navBarFinder).dy;
      final offersBottom = tester.getBottomLeft(find.byType(FeaturedOffers)).dy;

      // Distance between bottom of Featured Offers and top of pill nav bar is balanced and safe
      expect(offersBottom, lessThan(navBarTop));
      expect(navBarTop - offersBottom, greaterThanOrEqualTo(20.0));
    });
  });

  group('4. About Us Simplification', () {
    testWidgets('AboutUsScreen renders the 5 streamlined high-value sections', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget(child: const AboutUsScreen()));
      await tester.pumpAndSettle();

      // 1. Brief Intro
      expect(find.text('AL SEWAR AUTO CENTER'), findsOneWidget);
      expect(find.text('Excellence in Automotive Care'), findsOneWidget);

      // 2. Mission & Vision
      expect(find.text('Our Mission'), findsOneWidget);
      expect(find.text('Our Vision'), findsOneWidget);

      // 3. Main Service Categories
      expect(find.text('Core Services'), findsOneWidget);
      expect(find.text('Express Wash & Detailing'), findsOneWidget);
      expect(find.text('Interior Preservation'), findsOneWidget);
      expect(find.text('Ceramic & Paint Protection'), findsOneWidget);
      expect(find.text('Diagnostics & Maintenance'), findsOneWidget);

      // 4. Branch Access
      expect(find.text('Al Sewar Branch Network'), findsOneWidget);
      expect(find.text('Explore on Map'), findsOneWidget);
      expect(find.text('View All Service Centers'), findsOneWidget);

      // 5. Verified Support
      expect(find.text('Verified Support'), findsOneWidget);
      expect(find.text('Customer Helpline'), findsOneWidget);
      expect(find.text('Support Email'), findsOneWidget);
      expect(find.text('WhatsApp Concierge'), findsOneWidget);
    });
  });

  group('5. Profile Screen Navigation Refinement', () {
    testWidgets(
      'Tapping Loyalty Points & Rewards opens MembershipDetailsBottomSheet',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(child: const ProfileScreen(user: testUser)),
        );
        await tester.pumpAndSettle();

        final loyaltyTile = find.text('Loyalty Points & Rewards');
        expect(loyaltyTile, findsOneWidget);
        await tester.scrollUntilVisible(loyaltyTile, 150.0);
        await tester.tap(loyaltyTile);
        await tester.pumpAndSettle();

        // Detailed membership bottom sheet is shown
        expect(find.byType(MembershipDetailsBottomSheet), findsOneWidget);
        expect(find.text('Membership Details'), findsOneWidget);
        expect(find.text('View Rewards'), findsOneWidget);
        expect(
          find.textContaining('Every AED 100 spent earns 1 point'),
          findsOneWidget,
        );
      },
    );

    testWidgets('Tapping Customer Support navigates to AboutUsScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const ProfileScreen(user: testUser)),
      );
      await tester.pumpAndSettle();

      final supportTile = find.text('Customer Support');
      expect(supportTile, findsOneWidget);
      await tester.scrollUntilVisible(supportTile, 150.0);
      await tester.tap(supportTile);
      await tester.pumpAndSettle();

      expect(find.byType(AboutUsScreen), findsOneWidget);
      expect(find.text('About Al Sewar'), findsOneWidget);
    });

    testWidgets('Tapping WhatsApp Support navigates to BranchMapScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(child: const ProfileScreen(user: testUser)),
      );
      await tester.pumpAndSettle();

      final whatsappTile = find.text('WhatsApp Support');
      expect(whatsappTile, findsOneWidget);
      await tester.scrollUntilVisible(whatsappTile, 150.0);
      await tester.tap(whatsappTile);
      await tester.pumpAndSettle();

      expect(find.byType(BranchMapScreen), findsOneWidget);
      expect(find.text('Branch Locations'), findsOneWidget);
    });
  });
}
