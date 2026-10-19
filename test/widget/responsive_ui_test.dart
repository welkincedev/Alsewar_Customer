import 'package:carwashapp/app/screens/splashscreen.dart';
import 'package:carwashapp/core/storage/token_storage.dart';
import 'package:carwashapp/features/about/screens/about_us_screen.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/auth/models/login_request.dart';
import 'package:carwashapp/features/auth/models/login_response.dart';
import 'package:carwashapp/features/auth/models/signup_request.dart';
import 'package:carwashapp/features/auth/screens/customer_login_screen.dart';
import 'package:carwashapp/features/auth/screens/customer_signup_screen.dart';
import 'package:carwashapp/features/auth/services/auth_service.dart';
import 'package:carwashapp/features/auth/viewmodels/auth_providers.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/screens/branch_list_screen.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/home/screens/customer_home_screen.dart';
import 'package:carwashapp/features/home/widgets/loyalty_card.dart';
import 'package:carwashapp/features/home/widgets/service_categories.dart';
import 'package:carwashapp/features/profile/screens/profile_screen.dart';
import 'package:carwashapp/features/reviews/models/review.dart';
import 'package:carwashapp/features/reviews/screens/reviews_screen.dart';
import 'package:carwashapp/features/reviews/viewmodels/review_providers.dart';
import 'package:carwashapp/features/reviews/viewmodels/review_viewmodel.dart';
import 'package:carwashapp/features/services/models/service_item.dart';
import 'package:carwashapp/features/services/screens/services_screen.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:carwashapp/features/support/screens/whatsapp_support_screen.dart';
import 'package:carwashapp/features/vehicles/models/vehicle.dart';
import 'package:carwashapp/features/vehicles/screens/vehicles_screen.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_providers.dart';
import 'package:carwashapp/features/vehicles/viewmodels/vehicle_viewmodel.dart';
import 'package:carwashapp/features/visits/models/service_visit.dart';
import 'package:carwashapp/features/visits/screens/visits_screen.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_providers.dart';
import 'package:carwashapp/features/visits/viewmodels/visit_viewmodel.dart';
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

const screenSizes = {
  'Small (320x568)': Size(320, 568),
  'Medium (390x844)': Size(390, 844),
  'Large (480x900)': Size(480, 900),
};

class FakeBranchListViewModel extends BranchListViewModel {
  final List<Branch> initialBranches;
  FakeBranchListViewModel({this.initialBranches = const []});
  @override
  Future<List<Branch>> build() async => initialBranches;
}

class FakeVehicleViewModel extends VehicleViewModel {
  final List<Vehicle> initialVehicles;
  FakeVehicleViewModel({this.initialVehicles = const []});
  @override
  Future<List<Vehicle>> build() async => initialVehicles;
}

class FakeVisitViewModel extends VisitViewModel {
  final List<ServiceVisit> initialVisits;
  FakeVisitViewModel({this.initialVisits = const []});
  @override
  Future<List<ServiceVisit>> build() async => initialVisits;
}

class FakeReviewViewModel extends ReviewViewModel {
  final List<CustomerReview> initialReviews;
  FakeReviewViewModel({this.initialReviews = const []});
  @override
  Future<List<CustomerReview>> build() async => initialReviews;
}

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

  const mockBranch = Branch(
    id: 1,
    name: 'Central Branch',
    code: 'CB01',
    city: 'Riyadh',
    address: 'King Fahd Road',
    phone: '+966112345678',
    email: 'central@alsewar.com',
  );

  const mockVehicle = Vehicle(
    id: 1,
    plateNumber: 'ABC 1234',
    make: 'Toyota',
    model: 'Land Cruiser',
    year: 2023,
    color: 'White',
    createdAt: '2026-03-01T10:00:00Z',
    updatedAt: '2026-03-01T10:00:00Z',
  );

  const mockVisit = ServiceVisit(
    id: 1,
    visitNumber: 'VIS-00101',
    vehicleDetails: {
      'plate_number': 'ABC 1234',
      'make': 'Toyota',
      'model': 'Land Cruiser',
    },
    branchDetails: {'name': 'Central Branch'},
    services: [
      VisitServiceEntry(
        id: 1,
        name: 'Premium Exterior Wash',
        description: 'Exterior wash',
      ),
    ],
    statusHistory: [],
    createdAt: '2026-03-01T10:00:00Z',
    updatedAt: '2026-03-01T10:00:00Z',
  );

  const mockReview = CustomerReview(
    id: 1,
    visitId: 1,
    visitDetails: {'visit_number': 'VIS-00101'},
    branchDetails: {'name': 'Central Branch'},
    rating: 5,
    comment: 'Excellent service and attention to detail!',
    isApproved: true,
    createdAt: '2026-03-01T10:00:00Z',
  );

  final overrides = [
    customerServicesProvider.overrideWith((ref) => mockServices),
    branchListViewModelProvider.overrideWith(
      () => FakeBranchListViewModel(initialBranches: const [mockBranch]),
    ),
    vehicleViewModelProvider.overrideWith(
      () => FakeVehicleViewModel(initialVehicles: const [mockVehicle]),
    ),
    visitViewModelProvider.overrideWith(
      () => FakeVisitViewModel(initialVisits: const [mockVisit]),
    ),
    reviewViewModelProvider.overrideWith(
      () => FakeReviewViewModel(initialReviews: const [mockReview]),
    ),
    tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
    authServiceProvider.overrideWithValue(_FakeAuthService()),
  ];

  Widget buildTestableWidget(Widget child, Size size) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
  }

  for (final entry in screenSizes.entries) {
    final label = entry.key;
    final size = entry.value;

    group('Responsive Audit - $label', () {
      testWidgets('SplashScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const SplashScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('CustomerLoginScreen renders without overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestableWidget(const CustomerLoginScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('CustomerSignupScreen renders without overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestableWidget(const CustomerSignupScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('CustomerMainShell & HomeScreen render without overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestableWidget(const CustomerMainShell(user: testUser), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'LoyaltyCard renders without overflow with long member names',
        (tester) async {
          await tester.pumpWidget(
            buildTestableWidget(
              const Scaffold(
                body: SingleChildScrollView(
                  child: LoyaltyCard(
                    memberName: 'Very Long Customer Name For Member Test',
                    membershipCategory: 'VIP PLATINUM PLUS MEMBER',
                    pointsBalance: 999999,
                    benefitsText: 'Full comprehensive vehicle privileges',
                  ),
                ),
              ),
              size,
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets('ServiceCategories renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(
            const Scaffold(
              body: SingleChildScrollView(child: ServiceCategories()),
            ),
            size,
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('AboutUsScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const AboutUsScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('WhatsAppSupportScreen renders without overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          buildTestableWidget(const WhatsAppSupportScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('ProfileScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const ProfileScreen(user: testUser), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('BranchListScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const BranchListScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('VehiclesScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const VehiclesScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('ServicesScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const ServicesScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('VisitsScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const VisitsScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });

      testWidgets('ReviewsScreen renders without overflow', (tester) async {
        await tester.pumpWidget(
          buildTestableWidget(const ReviewsScreen(), size),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    });
  }
}

class _FakeTokenStorage implements TokenStorage {
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

class _FakeAuthService implements AuthService {
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
