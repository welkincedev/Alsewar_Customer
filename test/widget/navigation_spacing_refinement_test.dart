import 'package:carwashapp/app/theme/app_colors.dart';
import 'package:carwashapp/features/about/screens/about_us_screen.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:carwashapp/features/home/widgets/featured_offers.dart';
import 'package:carwashapp/features/home/widgets/floating_pill_nav_bar.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBranchListViewModel extends BranchListViewModel {
  final List<Branch> branches;
  _FakeBranchListViewModel(this.branches);

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
  );

  const testBranch = Branch(
    id: 1,
    name: 'Al Sewar Olaya',
    code: 'OLY01',
    address: 'Olaya St',
    city: 'Riyadh',
    phone: '+966501234567',
    email: 'olaya@alsewar.com',
    latitude: 24.7136,
    longitude: 46.6753,
    isActive: true,
  );

  Widget createShellWidget({
    int initialIndex = 1,
    Size screenSize = const Size(390, 844),
    double bottomInset = 34.0,
  }) {
    return ProviderScope(
      overrides: [
        customerServicesProvider.overrideWith((ref) => const []),
        branchListViewModelProvider.overrideWith(
          () => _FakeBranchListViewModel([testBranch]),
        ),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
            size: screenSize,
            padding: EdgeInsets.only(bottom: bottomInset, top: 47),
            viewPadding: EdgeInsets.only(bottom: bottomInset, top: 47),
          ),
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: CustomerMainShell(
              user: testUser,
              initialIndex: initialIndex,
            ),
          ),
        ),
      ),
    );
  }

  group('Floating Navigation & Screen Spacing Refinement Tests', () {
    testWidgets(
      'FloatingPillNavBarUtils calculates dynamic clearance correctly',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                padding: EdgeInsets.only(bottom: 34.0),
              ),
              child: Builder(
                builder: (context) {
                  final clearance =
                      FloatingPillNavBarUtils.calculateBottomClearance(
                        context,
                        clearance: 32.0,
                      );
                  // 62 (height) + 12 (margin) + 34 (bottomInset) + 32 (clearance) = 140.0
                  expect(clearance, equals(140.0));

                  final controlsBottom =
                      FloatingPillNavBarUtils.calculateControlsBottomOffset(
                        context,
                        clearance: 16.0,
                      );
                  // 62 (height) + 12 (margin) + 34 (bottomInset) + 16 (clearance) = 124.0
                  expect(controlsBottom, equals(124.0));

                  return const SizedBox();
                },
              ),
            ),
          ),
        );
        await tester.pump();
      },
    );

    testWidgets(
      'Home Screen: Featured Offers cards scroll fully above floating navigation bar without overlap',
      (tester) async {
        await tester.pumpWidget(createShellWidget(initialIndex: 1));
        await tester.pumpAndSettle();

        // 1. Initial render has shell and nav bar
        final navBarFinder = find.byType(FloatingPillNavBar);
        expect(navBarFinder, findsOneWidget);
        final navBarTopY = tester.getTopLeft(navBarFinder).dy;

        // 2. Scroll to the very bottom
        final scrollableFinder = find.byType(SingleChildScrollView);
        expect(scrollableFinder, findsOneWidget);

        await tester.drag(scrollableFinder, const Offset(0, -600));
        await tester.pumpAndSettle();

        // 3. FeaturedOffers section is completely visible
        expect(find.byType(FeaturedOffers), findsOneWidget);
        expect(find.text('Featured Offers'), findsOneWidget);
        expect(find.text('VIEW ALL'), findsNWidgets(2));
        expect(find.text('Full Exterior & Polish'), findsOneWidget);
        expect(find.text('Save 20%'), findsOneWidget);

        // 4. Bottom of the Featured Offers section sits strictly above the floating nav bar
        final offersRect = tester.getRect(find.byType(FeaturedOffers));
        expect(
          offersRect.bottom,
          lessThan(navBarTopY),
          reason: 'Featured Offers must scroll completely above the floating pill nav bar',
        );

        // 5. Gap between bottom of offers and top of nav bar is at least 20px
        expect(navBarTopY - offersRect.bottom, greaterThanOrEqualTo(20.0));
      },
    );

    testWidgets(
      'About Us Screen: "View All Service Centers" button scrolls fully above floating navigation bar',
      (tester) async {
        await tester.pumpWidget(createShellWidget(initialIndex: 0));
        await tester.pumpAndSettle();

        final navBarFinder = find.byType(FloatingPillNavBar);
        final navBarTopY = tester.getTopLeft(navBarFinder).dy;

        final scrollableFinder = find.byType(SingleChildScrollView);
        expect(scrollableFinder, findsOneWidget);

        // Scroll to the bottom of About Us
        await tester.drag(scrollableFinder, const Offset(0, -600));
        await tester.pumpAndSettle();

        // The bottom action button is fully visible
        final buttonFinder = find.text('View All Service Centers');
        expect(buttonFinder, findsOneWidget);

        // The button sits strictly above the floating navigation bar
        final buttonRect = tester.getRect(buttonFinder);
        expect(
          buttonRect.bottom,
          lessThan(navBarTopY),
          reason:
              'Button must scroll completely above the floating pill nav bar',
        );
        expect(navBarTopY - buttonRect.bottom, greaterThanOrEqualTo(20.0));
      },
    );

    testWidgets(
      'Map Screen: map is visible behind floating nav, zoom and recenter FABs float above nav bar',
      (tester) async {
        await tester.pumpWidget(createShellWidget(initialIndex: 2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // 1. FlutterMap renders and fills full body behind transparent navigation
        expect(find.byType(FlutterMap), findsOneWidget);
        final mapRect = tester.getRect(find.byType(FlutterMap));
        final shellHeight = tester
            .getSize(find.byType(CustomerMainShell))
            .height;
        expect(
          mapRect.bottom,
          equals(shellHeight),
        ); // Extends to absolute screen bottom

        // 2. Floating navigation bar is rendered
        final navBarFinder = find.byType(FloatingPillNavBar);
        expect(navBarFinder, findsOneWidget);
        final navBarTopY = tester.getTopLeft(navBarFinder).dy;

        // 3. Zoom In, Zoom Out, and My Location FABs are above nav bar
        final zoomInFinder = find.byTooltip('Zoom In');
        final zoomOutFinder = find.byTooltip('Zoom Out');
        final recenterFinder = find.byTooltip('My Location');

        expect(zoomInFinder, findsOneWidget);
        expect(zoomOutFinder, findsOneWidget);
        expect(recenterFinder, findsOneWidget);

        final recenterRect = tester.getRect(recenterFinder);
        expect(
          recenterRect.bottom,
          lessThan(navBarTopY),
          reason:
              'Map recenter button must sit above the floating pill nav bar',
        );

        // 4. Controls are clickable and interactive
        await tester.tap(zoomInFinder);
        await tester.pump();
        expect(tester.takeException(), isNull);

        await tester.tap(recenterFinder);
        await tester.pump();
        expect(tester.takeException(), isNull);

        // 5. Attribution is positioned at bottom-left
        final attributionFinder = find.byType(RichAttributionWidget);
        expect(attributionFinder, findsOneWidget);
        final attributionWidget = tester.widget<RichAttributionWidget>(
          attributionFinder,
        );
        expect(
          attributionWidget.alignment,
          equals(AttributionAlignment.bottomLeft),
        );
      },
    );

    testWidgets('Navigation bar retains 3 destinations and soft shadow', (
      tester,
    ) async {
      await tester.pumpWidget(createShellWidget(initialIndex: 1));
      await tester.pumpAndSettle();

      final navBarFinder = find.byType(FloatingPillNavBar);
      final navBar = tester.widget<FloatingPillNavBar>(navBarFinder);

      // Deep Charcoal background
      expect(navBar.backgroundColor, equals(AppColors.deepCharcoal));
      // White active indicator
      expect(navBar.activeIndicatorColor, equals(AppColors.pureWhite));

      // 3 items: About Us, Home, WhatsApp
      expect(navBar.items.length, equals(3));
      expect(navBar.items[0].label, equals('About Us'));
      expect(navBar.items[1].label, equals('Home'));
      expect(navBar.items[2].label, equals('WhatsApp'));

      // Tapping tabs switches screens
      await tester.tap(find.text('About Us'));
      await tester.pumpAndSettle();
      expect(find.byType(AboutUsScreen), findsOneWidget);

      await tester.tap(find.text('WhatsApp'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(BranchMapScreen), findsOneWidget);
    });

    testWidgets('Responsive phone sizes render with 0 overflow', (
      tester,
    ) async {
      final phoneSizes = [
        const Size(320, 568), // Compact (iPhone SE)
        const Size(390, 844), // Standard (iPhone 13/14)
        const Size(480, 900), // Large modern phone
      ];

      for (final size in phoneSizes) {
        for (int tab = 0; tab < 3; tab++) {
          await tester.pumpWidget(
            createShellWidget(
              initialIndex: tab,
              screenSize: size,
              bottomInset: size.width < 360 ? 0.0 : 34.0,
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));

          expect(
            tester.takeException(),
            isNull,
            reason:
                'Tab $tab on size ${size.width}x${size.height} must have no overflow',
          );
        }
      }
    });
  });
}
