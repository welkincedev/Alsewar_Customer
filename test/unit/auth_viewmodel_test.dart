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

  @override
  Future<AuthUser> getCurrentCustomer(String accessToken) async {
    return mockUser!;
  }

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
  });
}
