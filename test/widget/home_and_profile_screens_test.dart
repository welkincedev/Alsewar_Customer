import 'package:carwashapp/core/storage/token_storage.dart';
import 'package:carwashapp/features/about/screens/about_us_screen.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/auth/models/login_request.dart';
import 'package:carwashapp/features/auth/models/login_response.dart';
import 'package:carwashapp/features/auth/models/signup_request.dart';
import 'package:carwashapp/features/auth/services/auth_service.dart';
import 'package:carwashapp/features/auth/viewmodels/auth_providers.dart';
import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:carwashapp/features/home/views/home_screen.dart';
import 'package:carwashapp/features/home/widgets/featured_offers.dart';
import 'package:carwashapp/features/home/widgets/loyalty_card.dart';
import 'package:carwashapp/features/home/widgets/promotional_banner.dart';
import 'package:carwashapp/features/home/widgets/service_categories.dart';
import 'package:carwashapp/features/profile/screens/profile_screen.dart';
import 'package:carwashapp/features/services/models/service_item.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:carwashapp/features/support/screens/whatsapp_support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

void main() {
  const mockServices = [
    ServiceItem(
      id: 1,
      name: 'Car Wash',
      description: 'Exterior high-pressure wash',
    ),
    ServiceItem(
      id: 2,
      name: 'Detailing',
      description: 'Complete interior detail',
    ),
  ];

  final fakeTokenStorage = _FakeWidgetTokenStorage();
  final fakeAuthService = _FakeWidgetAuthService();

  group('Home & Shell Widget Tests', () {
    testWidgets(
      'CustomerMainShell displays 3 bottom navigation items (About Us, Home, WhatsApp)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              customerServicesProvider.overrideWith((ref) => mockServices),
            ],
            child: const MaterialApp(home: CustomerMainShell(user: testUser)),
          ),
        );

        await tester.pump();

        // Verify bottom navigation items exist
        expect(find.byType(BottomNavigationBar), findsOneWidget);
        expect(find.text('About Us'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);

        // Initially active on Home tab
        expect(find.byType(HomeScreen), findsOneWidget);

        // Tap About Us tab
        await tester.tap(find.text('About Us'));
        await tester.pump();
        expect(find.byType(AboutUsScreen), findsOneWidget);

        // Tap WhatsApp tab
        await tester.tap(find.text('WhatsApp'));
        await tester.pump();
        expect(find.byType(WhatsAppSupportScreen), findsOneWidget);
      },
    );

    testWidgets('HomeScreen renders all 6 required sections properly', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customerServicesProvider.overrideWith((ref) => mockServices),
          ],
          child: const MaterialApp(home: HomeScreen(user: testUser)),
        ),
      );

      await tester.pump();

      // Greeting with user name
      expect(find.text('Good Day,'), findsOneWidget);
      expect(find.text('Ahmed Al-Mansoor'), findsWidgets);

      // Loyalty Card
      expect(find.byType(LoyaltyCard), findsOneWidget);
      expect(find.text('GOLD MEMBER'), findsOneWidget);
      expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
      expect(find.text('2,450'), findsOneWidget);

      // Service Categories
      expect(find.byType(ServiceCategories), findsOneWidget);
      expect(find.text('Our Services'), findsOneWidget);

      // Promotional Banner
      expect(find.byType(PromotionalBanner), findsOneWidget);

      // Featured Offers
      expect(find.byType(FeaturedOffers), findsOneWidget);
      expect(find.text('Featured Offers'), findsOneWidget);
    });

    testWidgets('LoyaltyCard displays configurable points, tier and progress', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoyaltyCard(
              memberName: 'Sultan Al-Otaibi',
              membershipCategory: 'Platinum Member',
              pointsBalance: 5800,
              pointsLabel: 'Pts',
              progressToNextTier: 0.85,
              nextTierLabel: '200 pts to Diamond',
              isDevelopmentPlaceholder: true,
            ),
          ),
        ),
      );

      expect(find.text('PLATINUM MEMBER'), findsOneWidget);
      expect(find.text('5,800'), findsOneWidget);
      expect(find.text('Pts'), findsOneWidget);
      expect(find.text('Sultan Al-Otaibi'), findsOneWidget);
      expect(find.text('200 pts to Diamond'), findsOneWidget);
      expect(find.text('Preview Tier'), findsOneWidget);
    });

    testWidgets(
      'ProfileScreen renders MY PROFILE, MY ACTIVITIES and SUPPORT & SETTINGS',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: ProfileScreen(user: testUser)),
          ),
        );

        await tester.pump();

        // Header info
        expect(find.text('Ahmed Al-Mansoor'), findsWidgets);
        expect(find.text('customer@alsewar.com'), findsWidgets);

        // Section titles
        expect(find.text('MY PROFILE'), findsOneWidget);
        expect(find.text('MY ACTIVITIES'), findsOneWidget);
        expect(find.text('SUPPORT & SETTINGS'), findsOneWidget);

        // Activity tiles
        expect(find.text('My Vehicles'), findsOneWidget);
        expect(find.text('Service History'), findsOneWidget);
        expect(find.text('My Services'), findsOneWidget);
        expect(find.text('My Reviews'), findsOneWidget);
        expect(find.text('Loyalty Points & Rewards'), findsOneWidget);

        // Support tiles
        expect(find.text('Customer Support'), findsOneWidget);
        expect(find.text('WhatsApp Support'), findsOneWidget);
        expect(find.text('Sign Out'), findsWidgets);
      },
    );

    testWidgets(
      'ProfileScreen Sign Out opens dialog, confirms, and pops back to root',
      (tester) async {
        fakeTokenStorage.accessToken = 'test_token';
        fakeTokenStorage.refreshToken = 'test_refresh';

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeTokenStorage),
              authServiceProvider.overrideWithValue(fakeAuthService),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(user: testUser),
                          ),
                        );
                      },
                      child: const Text('Open Profile'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open profile screen
        await tester.tap(find.text('Open Profile'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfileScreen), findsOneWidget);

        // Tap Sign Out icon button in AppBar
        await tester.tap(find.byTooltip('Sign Out'));
        await tester.pumpAndSettle();

        // Verify confirmation dialog appears
        expect(
          find.text(
            'Are you sure you want to sign out of your Al Sewar account?',
          ),
          findsOneWidget,
        );
        expect(find.widgetWithText(FilledButton, 'Sign Out'), findsOneWidget);

        // Confirm sign out
        await tester.tap(find.widgetWithText(FilledButton, 'Sign Out'));
        await tester.pumpAndSettle();

        // Verify local tokens were cleared
        expect(fakeTokenStorage.accessToken, isNull);
        expect(fakeTokenStorage.refreshToken, isNull);

        // ProfileScreen is popped, returning to root
        expect(find.byType(ProfileScreen), findsNothing);
        expect(find.text('Open Profile'), findsOneWidget);
      },
    );
  });
}

class _FakeWidgetTokenStorage implements TokenStorage {
  String? accessToken = 'valid_token';
  String? refreshToken = 'valid_refresh';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> updateAccessToken({
    required String accessToken,
    String? newRefreshToken,
  }) async {
    this.accessToken = accessToken;
    if (newRefreshToken != null) refreshToken = newRefreshToken;
  }

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }

  @override
  Future<bool> hasAccessToken() async =>
      accessToken != null && accessToken!.isNotEmpty;
}

class _FakeWidgetAuthService implements AuthService {
  @override
  Future<AuthUser> getCurrentCustomer(String accessToken) async => testUser;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<AuthUser> signup(SignupRequest request) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async => {
    'access': 'new_access',
    'refresh': 'new_refresh',
  };

  @override
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {}
}
