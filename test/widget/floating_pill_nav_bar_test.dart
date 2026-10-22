import 'package:carwashapp/app/theme/app_colors.dart';
import 'package:carwashapp/features/about/screens/about_us_screen.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:carwashapp/features/home/views/home_screen.dart';
import 'package:carwashapp/features/home/widgets/floating_pill_nav_bar.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBranchListViewModel extends BranchListViewModel {
  final List<Branch>? initialBranches;

  _FakeBranchListViewModel({this.initialBranches});

  @override
  Future<List<Branch>> build() async {
    return initialBranches ?? [];
  }

  @override
  Future<void> refresh() async {
    state = AsyncValue.data(initialBranches ?? []);
  }
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

  const threeItems = [
    PillNavItem(
      icon: Icons.info_outline,
      activeIcon: Icons.info,
      label: 'About Us',
    ),
    PillNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    PillNavItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'WhatsApp',
    ),
  ];

  const fiveItems = [
    PillNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
    ),
    PillNavItem(
      icon: Icons.local_car_wash_outlined,
      activeIcon: Icons.local_car_wash,
      label: 'Services',
    ),
    PillNavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month,
      label: 'Bookings',
    ),
    PillNavItem(
      icon: Icons.stars_outlined,
      activeIcon: Icons.stars,
      label: 'Rewards',
    ),
    PillNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  Widget buildTestWidget({
    required int currentIndex,
    required ValueChanged<int> onTap,
    required List<PillNavItem> items,
    double screenWidth = 390.0,
    double screenHeight = 844.0,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(screenWidth, screenHeight),
          padding: const EdgeInsets.only(bottom: 24.0),
        ),
        child: SizedBox(
          width: screenWidth,
          height: screenHeight,
          child: Scaffold(
            backgroundColor: AppColors.warmPorcelain,
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.only(bottom: 12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FloatingPillNavBar(
                  currentIndex: currentIndex,
                  onTap: onTap,
                  items: items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  group('FloatingPillNavBar Widget Tests', () {
    testWidgets('renders 3 items correctly with active indicator and styling', (
      tester,
    ) async {
      int selectedTab = 1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return buildTestWidget(
              currentIndex: selectedTab,
              onTap: (index) => setState(() => selectedTab = index),
              items: threeItems,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 3 item labels exist
      expect(find.text('About Us'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);

      // Verify FloatingPillNavBar widget exists
      expect(find.byType(FloatingPillNavBar), findsOneWidget);

      // Verify active item icon (Icons.home) and inactive icon (Icons.info_outline)
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);

      // Tap About Us tab (index 0)
      await tester.tap(find.text('About Us'));
      await tester.pumpAndSettle();

      expect(selectedTab, equals(0));
      expect(find.byIcon(Icons.info), findsOneWidget);

      // Tap WhatsApp tab (index 2)
      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();

      expect(selectedTab, equals(2));
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    });

    testWidgets(
      'renders all five navigation destinations and handles tab changes smoothly',
      (tester) async {
        int selectedTab = 0;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return buildTestWidget(
                currentIndex: selectedTab,
                onTap: (index) => setState(() => selectedTab = index),
                items: fiveItems,
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        // Verify all 5 destination labels are present
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Services'), findsOneWidget);
        expect(find.text('Bookings'), findsOneWidget);
        expect(find.text('Rewards'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);

        // Tap each of the remaining 4 tabs and assert state updates
        for (int i = 1; i < fiveItems.length; i++) {
          await tester.tap(find.text(fiveItems[i].label));
          await tester.pumpAndSettle();
          expect(selectedTab, equals(i));
        }
      },
    );

    testWidgets('active tab has NO Champagne Gold dot or circular badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(currentIndex: 1, onTap: (_) {}, items: threeItems),
      );
      await tester.pumpAndSettle();

      // Find any Container or AnimatedContainer with circle shape and champagneGold
      final goldCircleFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          return box.shape == BoxShape.circle &&
              box.color == AppColors.champagneGold;
        }
        if (widget is AnimatedContainer && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          return box.shape == BoxShape.circle &&
              box.color == AppColors.champagneGold;
        }
        return false;
      });

      expect(goldCircleFinder, findsNothing);
    });

    testWidgets(
      'responsive layout on small screen width (320px) without overflow',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            currentIndex: 1,
            onTap: (_) {},
            items: threeItems,
            screenWidth: 320,
            screenHeight: 568,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.byType(FloatingPillNavBar), findsOneWidget);
        expect(find.text('About Us'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
      },
    );

    testWidgets(
      'responsive layout on 5 items across 320px, 390px, and 480px widths',
      (tester) async {
        final screenWidths = [320.0, 390.0, 480.0];

        for (final width in screenWidths) {
          await tester.pumpWidget(
            buildTestWidget(
              currentIndex: 2,
              onTap: (_) {},
              items: fiveItems,
              screenWidth: width,
              screenHeight: 800,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Services'), findsOneWidget);
          expect(find.text('Bookings'), findsOneWidget);
          expect(find.text('Rewards'), findsOneWidget);
          expect(find.text('Profile'), findsOneWidget);
        }
      },
    );

    testWidgets('respects Desert Luxe styling attributes', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(currentIndex: 0, onTap: (_) {}, items: threeItems),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<FloatingPillNavBar>(
        find.byType(FloatingPillNavBar),
      );
      expect(navBar.backgroundColor, equals(AppColors.deepCharcoal));
      expect(navBar.activeIndicatorColor, equals(AppColors.pureWhite));
      expect(navBar.inactiveColor, equals(AppColors.sandBeige));
      expect(navBar.accentColor, equals(AppColors.champagneGold));
    });

    testWidgets('provides correct semantics and accessible labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(currentIndex: 0, onTap: (_) {}, items: threeItems),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'About Us',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Home',
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'WhatsApp',
        ),
        findsOneWidget,
      );

      // Verify Tooltips are provided for each item
      expect(find.byTooltip('About Us'), findsOneWidget);
      expect(find.byTooltip('Home'), findsOneWidget);
      expect(find.byTooltip('WhatsApp'), findsOneWidget);
    });
  });

  group('Screen Rendering Above Floating Navigation Tests', () {
    testWidgets(
      'CustomerMainShell renders screen content with extendBody: true and transparent navigation wrapper',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              customerServicesProvider.overrideWith((ref) => const []),
            ],
            child: const MaterialApp(home: CustomerMainShell(user: testUser)),
          ),
        );
        await tester.pump();

        // Scaffold has extendBody enabled so screen content renders behind transparent margins
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        expect(scaffold.extendBody, isTrue);

        // Screen content is visible and takes full body height
        final homeScreenFinder = find.byType(HomeScreen);
        expect(homeScreenFinder, findsOneWidget);

        final homeSize = tester.getSize(homeScreenFinder);
        expect(
          homeSize.height,
          greaterThan(500.0),
          reason: 'HomeScreen must extend with full body height',
        );

        // Floating pill bar is positioned at the bottom and retains Deep Charcoal
        final navBarFinder = find.byType(FloatingPillNavBar);
        expect(navBarFinder, findsOneWidget);

        final navBar = tester.widget<FloatingPillNavBar>(navBarFinder);
        expect(navBar.backgroundColor, equals(AppColors.deepCharcoal));
        expect(tester.getTopLeft(navBarFinder).dy, greaterThan(400.0));
      },
    );

    testWidgets(
      'All five tabs display their respective screens and update content on switch',
      (tester) async {
        final fiveScreens = [
          Container(
            key: const ValueKey('screen_home'),
            color: Colors.white,
            child: const Center(child: Text('Screen Content: Home')),
          ),
          Container(
            key: const ValueKey('screen_services'),
            color: Colors.white,
            child: const Center(child: Text('Screen Content: Services')),
          ),
          Container(
            key: const ValueKey('screen_bookings'),
            color: Colors.white,
            child: const Center(child: Text('Screen Content: Bookings')),
          ),
          Container(
            key: const ValueKey('screen_rewards'),
            color: Colors.white,
            child: const Center(child: Text('Screen Content: Rewards')),
          ),
          Container(
            key: const ValueKey('screen_profile'),
            color: Colors.white,
            child: const Center(child: Text('Screen Content: Profile')),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: CustomerMainShell(
              user: testUser,
              initialIndex: 0,
              pages: fiveScreens,
              navItems: fiveItems,
            ),
          ),
        );
        await tester.pump();

        // 1. Initial tab (Home) is visible
        expect(find.text('Screen Content: Home'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('screen_home'))).height,
          greaterThan(400.0),
        );

        // 2. Switch to Services tab
        await tester.tap(find.text('Services'));
        await tester.pumpAndSettle();
        expect(find.text('Screen Content: Services'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('screen_services'))).height,
          greaterThan(400.0),
        );

        // 3. Switch to Bookings tab
        await tester.tap(find.text('Bookings'));
        await tester.pumpAndSettle();
        expect(find.text('Screen Content: Bookings'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('screen_bookings'))).height,
          greaterThan(400.0),
        );

        // 4. Switch to Rewards tab
        await tester.tap(find.text('Rewards'));
        await tester.pumpAndSettle();
        expect(find.text('Screen Content: Rewards'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('screen_rewards'))).height,
          greaterThan(400.0),
        );

        // 5. Switch to Profile tab
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.text('Screen Content: Profile'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('screen_profile'))).height,
          greaterThan(400.0),
        );
      },
    );
  });

  group('FloatingAbovePillNavBarLocation Location & Geometry Tests', () {
    testWidgets('calculates correct Offset in LTR text direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButtonLocation: const FloatingAbovePillNavBarLocation(
              bottomOffset: 86.0,
              endOffset: 16.0,
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            body: const Center(child: Text('Body')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      expect(fabFinder, findsOneWidget);
      final fabRect = tester.getRect(fabFinder);

      // On standard 800x600 test screen:
      // Width = 800. FAB width = 56. endOffset = 16.
      // fabX = 800 - 56 - 16 = 728.
      expect(fabRect.left, equals(800.0 - 56.0 - 16.0));
      // fabY = 600 - 56 - 86 = 458.
      expect(fabRect.top, equals(600.0 - 56.0 - 86.0));
    });

    testWidgets('calculates correct Offset in RTL text direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              floatingActionButtonLocation:
                  const FloatingAbovePillNavBarLocation(
                    bottomOffset: 86.0,
                    endOffset: 16.0,
                  ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      final fabRect = tester.getRect(fabFinder);
      // In RTL, fabX = endOffset = 16.0
      expect(fabRect.left, closeTo(16.0, 0.01));
    });

    testWidgets('accounts for safe area bottom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              padding: EdgeInsets.only(bottom: 34.0),
              viewPadding: EdgeInsets.only(bottom: 34.0),
            ),
            child: Scaffold(
              floatingActionButtonLocation:
                  const FloatingAbovePillNavBarLocation(
                    bottomOffset: 86.0,
                    endOffset: 16.0,
                  ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fabFinder = find.byType(FloatingActionButton);
      final fabRect = tester.getRect(fabFinder);
      // On standard 800x600 test surface: fabY = 600 - 56 - (86 + 34) = 424.0
      expect(fabRect.top, equals(600.0 - 56.0 - (86.0 + 34.0)));
    });
  });

  group('FAB Layering, Visibility & Interactivity Tests', () {
    testWidgets(
      'CustomerMainShell renders FAB above pill bar and handles clicks without interception',
      (tester) async {
        bool fabClicked = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              customerServicesProvider.overrideWith((ref) => const []),
            ],
            child: MaterialApp(
              home: CustomerMainShell(
                user: testUser,
                floatingActionButton: FloatingActionButton(
                  key: const ValueKey('shell_fab'),
                  onPressed: () => fabClicked = true,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // FAB is visible
        final fabFinder = find.byKey(const ValueKey('shell_fab'));
        expect(fabFinder, findsOneWidget);

        final navBarFinder = find.byType(FloatingPillNavBar);
        expect(navBarFinder, findsOneWidget);

        // FAB is positioned vertically above the floating pill nav bar
        final fabRect = tester.getRect(fabFinder);
        final navBarRect = tester.getRect(navBarFinder);
        expect(fabRect.bottom, lessThanOrEqualTo(navBarRect.top + 6.0));

        // FAB click works
        await tester.tap(fabFinder);
        await tester.pump();
        expect(fabClicked, isTrue);

        // Bottom nav bar tabs are interactive
        await tester.tap(find.text('About Us'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byType(AboutUsScreen), findsOneWidget);
      },
    );

    testWidgets(
      'HomeScreen renders FAB cleanly and supports scrolling with bottom clearance',
      (tester) async {
        bool fabClicked = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              customerServicesProvider.overrideWith((ref) => const []),
            ],
            child: MaterialApp(
              home: HomeScreen(
                user: testUser,
                floatingActionButton: FloatingActionButton(
                  key: const ValueKey('home_fab'),
                  onPressed: () => fabClicked = true,
                  child: const Icon(Icons.build),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final fabFinder = find.byKey(const ValueKey('home_fab'));
        expect(fabFinder, findsOneWidget);

        // Click works
        await tester.tap(fabFinder);
        expect(fabClicked, isTrue);

        // Screen scrolling functions without issue
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
        );
        await tester.pump();
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'AboutUsScreen renders FAB cleanly and supports scrolling with bottom clearance',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AboutUsScreen(
              floatingActionButton: FloatingActionButton(
                key: ValueKey('about_fab'),
                onPressed: null,
                child: Icon(Icons.share),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final fabFinder = find.byKey(const ValueKey('about_fab'));
        expect(fabFinder, findsOneWidget);

        // Scroll works
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();
        expect(find.text('View All Service Centers'), findsOneWidget);
      },
    );

    testWidgets(
      'BranchMapScreen FABs remain visible and clickable inside CustomerMainShell',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              branchListViewModelProvider.overrideWith(
                () => _FakeBranchListViewModel(
                  initialBranches: [
                    const Branch(
                      id: 1,
                      name: 'Al Sewar Main',
                      code: 'MAIN01',
                      address: 'King Fahd Road',
                      city: 'Riyadh',
                      phone: '+966501234567',
                      email: 'main@alsewar.com',
                      latitude: 24.7136,
                      longitude: 46.6753,
                      isActive: true,
                    ),
                  ],
                ),
              ),
            ],
            child: const MaterialApp(
              home: CustomerMainShell(user: testUser, initialIndex: 2),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Zoom and recenter buttons are present and interactive
        expect(find.byTooltip('Zoom In'), findsOneWidget);
        expect(find.byTooltip('Zoom Out'), findsOneWidget);
        expect(find.byTooltip('My Location'), findsOneWidget);

        await tester.tap(find.byTooltip('Zoom In'));
        await tester.pump();
        expect(tester.takeException(), isNull);

        // Bottom nav bar remains interactive
        await tester.tap(find.text('Home'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Branch Locations'), findsNothing);
      },
    );
  });

  group('Responsive Phone Size Tests (Compact, Standard, Large)', () {
    final testSizes = [
      const Size(320, 568), // Compact (iPhone SE)
      const Size(390, 844), // Standard (iPhone 12/13/14)
      const Size(480, 900), // Large phone
    ];

    for (final size in testSizes) {
      testWidgets(
        'CustomerMainShell with FAB on size ${size.width}x${size.height} has 0 overflow',
        (tester) async {
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                customerServicesProvider.overrideWith((ref) => const []),
              ],
              child: MaterialApp(
                home: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    padding: const EdgeInsets.only(bottom: 24.0),
                  ),
                  child: SizedBox(
                    width: size.width,
                    height: size.height,
                    child: CustomerMainShell(
                      user: testUser,
                      floatingActionButton: FloatingActionButton(
                        onPressed: () {},
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          expect(tester.takeException(), isNull);
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.byType(FloatingPillNavBar), findsOneWidget);
        },
      );
    }
  });
}
