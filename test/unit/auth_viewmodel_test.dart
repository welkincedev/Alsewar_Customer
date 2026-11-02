import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carwashapp/core/storage/token_storage.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/auth/models/login_request.dart';
import 'package:carwashapp/features/auth/models/login_response.dart';
import 'package:carwashapp/features/auth/models/signup_request.dart';
import 'package:carwashapp/features/auth/services/auth_service.dart';
import 'package:carwashapp/features/auth/viewmodels/auth_providers.dart';
import 'package:carwashapp/features/auth/viewmodels/auth_state.dart';
import 'package:carwashapp/features/auth/viewmodels/auth_viewmodel.dart';

const testCustomer = AuthUser(
  id: 1,
  username: 'customer1',
  email: 'cust1@test.com',
  role: 'CUSTOMER',
  phone: '12345678',
  firstName: 'Cust',
  lastName: 'One',
  isActive: true,
  loyaltyPoints: 5000,
  membershipTier: 'Gold',
);

class FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;

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
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      refreshToken = newRefreshToken;
    }
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

class FakeAuthService implements AuthService {
  AuthUser? mockUser;
  LoginResponse? mockLoginResponse;
  Map<String, String>? mockRefreshedTokens;
  bool shouldFailLogin = false;
  bool shouldFailSignup = false;

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    if (shouldFailLogin) {
      throw Exception('Invalid username or password.');
    }
    return mockLoginResponse!;
  }

  @override
  Future<AuthUser> signup(SignupRequest request) async {
    if (shouldFailSignup) {
      throw Exception('Username: A user with that username already exists.');
    }
    return mockUser!;
  }

  bool shouldFailGetCurrentCustomer = false;
  int getCurrentCustomerCallCount = 0;

  @override
  Future<AuthUser> getCurrentCustomer(String accessToken) async {
    getCurrentCustomerCallCount++;
    if (shouldFailGetCurrentCustomer) {
      throw Exception('Server unreachable: 500');
    }
    return mockUser!;
  }

  bool shouldFailUpdateProfile = false;
  String? lastPassedAccessToken;
  Map<String, String?> lastUpdatePayload = {};

  @override
  Future<AuthUser> updateProfile({
    required String accessToken,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    List<int>? profilePictureBytes,
    String? profilePictureFilename,
    String? profilePicturePath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    lastPassedAccessToken = accessToken;
    lastUpdatePayload = {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
    };
    if (shouldFailUpdateProfile) {
      throw Exception('Email: A user with this email already exists.');
    }
    return (mockUser ?? testCustomer).copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      profilePicture: profilePictureFilename != null
          ? 'http://10.0.2.2:8001/media/$profilePictureFilename'
          : null,
    );
  }

  @override
  Future<AuthUser> uploadProfilePicture({
    required String accessToken,
    required List<int> imageBytes,
    required String filename,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    return updateProfile(
      accessToken: accessToken,
      profilePictureBytes: imageBytes,
      profilePictureFilename: filename,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<void> removeProfilePicture({required String accessToken}) async {}

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    return mockRefreshedTokens!;
  }

  bool throwOnLogout = false;
  int logoutCallCount = 0;

  @override
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    logoutCallCount++;
    if (throwOnLogout) {
      throw Exception('Backend logout failed');
    }
  }
}

void main() {
  late FakeTokenStorage fakeTokenStorage;
  late FakeAuthService fakeAuthService;
  late ProviderContainer container;

  setUp(() {
    fakeTokenStorage = FakeTokenStorage();
    fakeAuthService = FakeAuthService();

    container = ProviderContainer(
      overrides: [
        tokenStorageProvider.overrideWithValue(fakeTokenStorage),
        authServiceProvider.overrideWithValue(fakeAuthService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthViewModel Logic Tests', () {
    test('login with valid CUSTOMER user succeeds and saves tokens', () async {
      fakeAuthService.mockLoginResponse = const LoginResponse(
        access: 'access_123',
        refresh: 'refresh_123',
        user: AuthUser(
          id: 1,
          username: 'customer1',
          email: 'cust1@test.com',
          role: 'CUSTOMER',
          phone: '123456',
          firstName: 'Cust',
          lastName: 'One',
          isActive: true,
        ),
      );

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(username: 'customer1', password: 'Password123');

      final state = container.read(authViewModelProvider).value!;
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.username, 'customer1');
      expect(await fakeTokenStorage.getAccessToken(), 'access_123');
      expect(await fakeTokenStorage.getRefreshToken(), 'refresh_123');
    });

    test(
      'login with inactive account is rejected with inactive message',
      () async {
        fakeAuthService.mockLoginResponse = const LoginResponse(
          access: 'access_123',
          refresh: 'refresh_123',
          user: AuthUser(
            id: 2,
            username: 'inactive_cust',
            email: 'inactive@test.com',
            role: 'CUSTOMER',
            phone: '',
            firstName: '',
            lastName: '',
            isActive: false,
          ),
        );

        final viewModel = container.read(authViewModelProvider.notifier);
        await viewModel.login(
          username: 'inactive_cust',
          password: 'Password123',
        );

        final state = container.read(authViewModelProvider).value!;
        expect(state.status, AuthStatus.unauthenticated);
        expect(
          state.errorMessage,
          'Account is inactive. Please contact support.',
        );
      },
    );

    test('login with MANAGER role is rejected', () async {
      fakeAuthService.mockLoginResponse = const LoginResponse(
        access: 'access_123',
        refresh: 'refresh_123',
        user: AuthUser(
          id: 3,
          username: 'manager_user',
          email: 'mgr@test.com',
          role: 'MANAGER',
          phone: '',
          firstName: '',
          lastName: '',
          isActive: true,
        ),
      );

      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(username: 'manager_user', password: 'Password123');

      final state = container.read(authViewModelProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(
        state.errorMessage,
        'Access restricted to customer accounts only.',
      );
    });

    test('logout clears tokens and sets unauthenticated state', () async {
      await fakeTokenStorage.saveTokens(
        accessToken: 'acc',
        refreshToken: 'ref',
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.logout();

      final state = container.read(authViewModelProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(await fakeTokenStorage.getAccessToken(), isNull);
      expect(await fakeTokenStorage.getRefreshToken(), isNull);
    });

    test('logout always clears local tokens and sets unauthenticated state even when backend fails', () async {
      fakeAuthService.throwOnLogout = true;
      await fakeTokenStorage.saveTokens(
        accessToken: 'acc_fail',
        refreshToken: 'ref_fail',
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.logout();

      final state = container.read(authViewModelProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(await fakeTokenStorage.getAccessToken(), isNull);
      expect(await fakeTokenStorage.getRefreshToken(), isNull);
      expect(fakeAuthService.logoutCallCount, 1);
    });

    test('logout prevents multiple simultaneous operations', () async {
      await fakeTokenStorage.saveTokens(
        accessToken: 'acc_sim',
        refreshToken: 'ref_sim',
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      // Trigger simultaneous logout calls
      await Future.wait([viewModel.logout(), viewModel.logout()]);

      expect(fakeAuthService.logoutCallCount, 1);
      final state = container.read(authViewModelProvider).value!;
      expect(state.status, AuthStatus.unauthenticated);
      expect(await fakeTokenStorage.getAccessToken(), isNull);
    });

    test('updateProfile updates state, sends bearer token and preserves loyalty points', () async {
      await fakeTokenStorage.saveTokens(
        accessToken: 'valid_bearer_token',
        refreshToken: 'valid_refresh_token',
      );
      fakeAuthService.mockUser = testCustomer;
      final viewModel = container.read(authViewModelProvider.notifier);

      // Initialize state with test customer
      await container.read(authViewModelProvider.future);

      final updatedUser = await viewModel.updateProfile(
        firstName: 'Tariq',
        lastName: 'Al-Said',
        email: 'tariq@alsewar.com',
      );

      expect(updatedUser.firstName, 'Tariq');
      expect(updatedUser.lastName, 'Al-Said');
      expect(updatedUser.email, 'tariq@alsewar.com');
      // Preserved fields
      expect(updatedUser.loyaltyPoints, testCustomer.loyaltyPoints);
      expect(updatedUser.membershipTier, testCustomer.membershipTier);
      expect(fakeAuthService.lastPassedAccessToken, 'valid_bearer_token');

      // State is updated
      final state = container.read(authViewModelProvider).value!;
      expect(state.user?.firstName, 'Tariq');
      expect(state.user?.lastName, 'Al-Said');
      // Tokens remain intact
      expect(await fakeTokenStorage.getAccessToken(), 'valid_bearer_token');
    });

    test('updateProfile updates profile picture and preserves existing user fields', () async {
      await fakeTokenStorage.saveTokens(
        accessToken: 'valid_bearer_token',
        refreshToken: 'valid_refresh_token',
      );
      fakeAuthService.mockUser = testCustomer;
      final viewModel = container.read(authViewModelProvider.notifier);
      await container.read(authViewModelProvider.future);

      final updatedUser = await viewModel.updateProfile(
        firstName: 'Tariq',
        lastName: 'Al-Said',
        email: 'tariq@alsewar.com',
        profilePictureBytes: [1, 2, 3],
        profilePictureFilename: 'tariq_avatar.jpg',
      );

      expect(updatedUser.profilePicture, contains('tariq_avatar.jpg'));
      expect(updatedUser.loyaltyPoints, testCustomer.loyaltyPoints);
      expect(updatedUser.membershipTier, testCustomer.membershipTier);

      final state = container.read(authViewModelProvider).value!;
      expect(state.user?.profilePicture, contains('tariq_avatar.jpg'));
    });

    test(
      'updateProfile propagates backend API validation errors without masking',
      () async {
        await fakeTokenStorage.saveTokens(
          accessToken: 'valid_bearer_token',
          refreshToken: 'valid_refresh_token',
        );
        fakeAuthService.mockUser = testCustomer;
        fakeAuthService.shouldFailUpdateProfile = true;
        final viewModel = container.read(authViewModelProvider.notifier);
        await container.read(authViewModelProvider.future);

        expect(
          () => viewModel.updateProfile(email: 'duplicate@example.com'),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains(
                'Email: A user with this email already exists.',
              ),
            ),
          ),
        );

        // User session and tokens remain intact after API error
        final state = container.read(authViewModelProvider).value!;
        expect(state.isAuthenticated, isTrue);
        expect(await fakeTokenStorage.getAccessToken(), 'valid_bearer_token');
      },
    );

    test('updateProfile in preview/mock mode updates local state when no token exists', () async {
      fakeAuthService.mockLoginResponse = const LoginResponse(
        access: 'temp_token',
        refresh: 'temp_refresh',
        user: testCustomer,
      );
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(username: 'customer1', password: 'Password123');

      // Clear tokens to simulate preview/offline session where user is loaded in state
      await fakeTokenStorage.clearTokens();

      final updatedUser = await viewModel.updateProfile(
        firstName: 'Guest',
        lastName: 'Previewer',
      );

      expect(updatedUser.firstName, 'Guest');
      expect(updatedUser.lastName, 'Previewer');
      final state = container.read(authViewModelProvider).value!;
      expect(state.user?.firstName, 'Guest');
    });

    test('refreshProfile fetches latest customer data from backend and preserves loyalty points and tokens', () async {
      await fakeTokenStorage.saveTokens(
        accessToken: 'valid_bearer_token',
        refreshToken: 'valid_refresh_token',
      );
      fakeAuthService.mockUser = testCustomer;
      final viewModel = container.read(authViewModelProvider.notifier);
      await container.read(authViewModelProvider.future);

      // Backend now returns updated customer details
      fakeAuthService.mockUser = testCustomer.copyWith(
        firstName: 'Fahad',
        lastName: 'Al-Busaidi',
        email: 'fahad@alsewar.com',
        profilePicture: 'http://10.0.2.2:8001/media/fahad.jpg',
      );

      final refreshed = await viewModel.refreshProfile();

      expect(refreshed.firstName, 'Fahad');
      expect(refreshed.lastName, 'Al-Busaidi');
      expect(refreshed.email, 'fahad@alsewar.com');
      expect(refreshed.profilePicture, contains('fahad.jpg'));
      // Loyalty points and membership tier are preserved
      expect(refreshed.loyaltyPoints, testCustomer.loyaltyPoints);
      expect(refreshed.membershipTier, testCustomer.membershipTier);

      // State is updated
      final state = container.read(authViewModelProvider).value!;
      expect(state.user?.firstName, 'Fahad');
      expect(await fakeTokenStorage.getAccessToken(), 'valid_bearer_token');
      expect(
        fakeAuthService.getCurrentCustomerCallCount,
        2,
      ); // Initial build + refresh
    });

    test('refreshProfile throws and preserves existing state when backend fetch fails', () async {
      await fakeTokenStorage.saveTokens(
        accessToken: 'valid_bearer_token',
        refreshToken: 'valid_refresh_token',
      );
      fakeAuthService.mockUser = testCustomer;
      final viewModel = container.read(authViewModelProvider.notifier);
      await container.read(authViewModelProvider.future);

      fakeAuthService.shouldFailGetCurrentCustomer = true;

      expect(() => viewModel.refreshProfile(), throwsA(isA<Exception>()));

      final state = container.read(authViewModelProvider).value!;
      expect(state.user?.firstName, testCustomer.firstName);
      expect(await fakeTokenStorage.getAccessToken(), 'valid_bearer_token');
    });
  });
}
