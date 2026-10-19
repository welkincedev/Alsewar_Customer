import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/core/network/api_client.dart';
import 'package:carwashapp/features/auth/models/login_request.dart';
import 'package:carwashapp/features/auth/models/signup_request.dart';
import 'package:carwashapp/features/auth/services/auth_service.dart';

class MockAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions options) fetchHandler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return fetchHandler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late Dio dio;
  late MockAdapter mockAdapter;
  late AuthService authService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8001'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    authService = AuthService(apiClient: ApiClient(customDio: dio));
  });

  group('AuthService Tests', () {
    test('signup success returns created AuthUser', () async {
      mockAdapter.fetchHandler = (options) {
        expect(options.path, '/api/customer/signup/');
        return ResponseBody.fromString(
          jsonEncode({
            'id': 10,
            'username': 'john_doe',
            'email': 'john@example.com',
            'role': 'CUSTOMER',
            'phone': '9876543210',
            'first_name': 'John',
            'last_name': 'Doe',
            'is_active': true,
          }),
          201,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = SignupRequest(
        username: 'john_doe',
        email: 'john@example.com',
        password: 'SecretPassword123!',
      );

      final user = await authService.signup(request);
      expect(user.id, 10);
      expect(user.username, 'john_doe');
      expect(user.role, 'CUSTOMER');
    });

    test('signup duplicate username throws formatted error', () async {
      mockAdapter.fetchHandler = (options) {
        return ResponseBody.fromString(
          jsonEncode({
            'username': ['A user with that username already exists.'],
          }),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = SignupRequest(
        username: 'existing_user',
        email: 'test@example.com',
        password: 'SecretPassword123!',
      );

      expect(
        () => authService.signup(request),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'Username: A user with that username already exists.',
                ),
          ),
        ),
      );
    });

    test('login success returns tokens and user', () async {
      mockAdapter.fetchHandler = (options) {
        expect(options.path, '/api/customer/login/');
        return ResponseBody.fromString(
          jsonEncode({
            'access': 'access_token_123',
            'refresh': 'refresh_token_123',
            'user': {
              'id': 3,
              'username': 'testcustomer',
              'email': 'cust@example.com',
              'role': 'CUSTOMER',
              'phone': '+971500000002',
              'first_name': '',
              'last_name': '',
              'is_active': true,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      const request = LoginRequest(
        username: 'testcustomer',
        password: 'Password123',
      );
      final response = await authService.login(request);

      expect(response.access, 'access_token_123');
      expect(response.refresh, 'refresh_token_123');
      expect(response.user.username, 'testcustomer');
    });

    test('refreshToken supports rotated refresh token', () async {
      mockAdapter.fetchHandler = (options) {
        expect(options.path, '/api/auth/token/refresh/');
        return ResponseBody.fromString(
          jsonEncode({
            'access': 'new_access_token',
            'refresh': 'rotated_refresh_token',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await authService.refreshToken('old_refresh_token');
      expect(result['access'], 'new_access_token');
      expect(result['refresh'], 'rotated_refresh_token');
    });
  });
}
