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

    test(
      'updateProfile sends PATCH to /api/customer/profile/ with bearer token',
      () async {
        mockAdapter.fetchHandler = (options) {
          expect(options.method, 'PATCH');
          expect(options.path, '/api/customer/profile/');
          expect(options.headers['Authorization'], 'Bearer valid_jwt_token');
          final data = options.data as Map<String, dynamic>;
          expect(data['first_name'], 'Salman');
          expect(data['last_name'], 'Al Balushi');
          expect(data['email'], 'salman.albalushi@example.com');

          return ResponseBody.fromString(
            jsonEncode({
              'id': 15,
              'username': 'salman_k',
              'first_name': 'Salman',
              'last_name': 'Al Balushi',
              'email': 'salman.albalushi@example.com',
              'phone': '+96891234567',
              'role': 'CUSTOMER',
              'profile_picture': 'http://10.0.2.2:8001/media/profile_pictures/customer_15/avatar.jpg',
              'is_active': true,
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final updatedUser = await authService.updateProfile(
          accessToken: 'valid_jwt_token',
          firstName: 'Salman',
          lastName: 'Al Balushi',
          email: 'salman.albalushi@example.com',
        );

        expect(updatedUser.id, 15);
        expect(updatedUser.firstName, 'Salman');
        expect(updatedUser.lastName, 'Al Balushi');
        expect(updatedUser.email, 'salman.albalushi@example.com');
        expect(updatedUser.profilePicture, contains('avatar.jpg'));
      },
    );

    test('updateProfile sends multipart/form-data when profilePictureBytes is provided', () async {
      mockAdapter.fetchHandler = (options) {
        expect(options.path, '/api/customer/profile/');
        expect(options.headers['Authorization'], 'Bearer valid_jwt_token');
        expect(
          options.headers['Content-Type'],
          contains('multipart/form-data'),
        );
        expect(options.data, isA<FormData>());
        final formData = options.data as FormData;
        expect(
          formData.fields.any(
            (f) => f.key == 'first_name' && f.value == 'Salman',
          ),
          isTrue,
        );
        expect(formData.files.any((f) => f.key == 'profile_picture'), isTrue);

        return ResponseBody.fromString(
          jsonEncode({
            'id': 15,
            'username': 'salman_k',
            'first_name': 'Salman',
            'last_name': 'Al Balushi',
            'email': 'salman.albalushi@example.com',
            'role': 'CUSTOMER',
            'profile_picture': 'http://10.0.2.2:8001/media/profile_pictures/customer_15/new_pic.jpg',
            'is_active': true,
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final updatedUser = await authService.updateProfile(
        accessToken: 'valid_jwt_token',
        firstName: 'Salman',
        lastName: 'Al Balushi',
        email: 'salman.albalushi@example.com',
        profilePictureBytes: [0xFF, 0xD8, 0xFF, 0xE0],
        profilePictureFilename: 'new_pic.jpg',
      );

      expect(updatedUser.id, 15);
      expect(updatedUser.profilePicture, contains('new_pic.jpg'));
    });

    test('updateProfile falls back to /api/customer/me/ on 404', () async {
      int callCount = 0;
      mockAdapter.fetchHandler = (options) {
        callCount++;
        if (callCount == 1) {
          expect(options.path, '/api/customer/profile/');
          return ResponseBody.fromString(
            jsonEncode({'detail': 'Not found.'}),
            404,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else {
          expect(options.path, '/api/customer/me/');
          return ResponseBody.fromString(
            jsonEncode({
              'id': 15,
              'username': 'salman_k',
              'first_name': 'Salman',
              'last_name': 'Al Balushi',
              'email': 'salman@example.com',
              'role': 'CUSTOMER',
              'is_active': true,
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
      };

      final updatedUser = await authService.updateProfile(
        accessToken: 'valid_jwt_token',
        firstName: 'Salman',
        lastName: 'Al Balushi',
      );

      expect(callCount, 2);
      expect(updatedUser.firstName, 'Salman');
    });

    test(
      'updateProfile surfaces DRF validation errors with clean message',
      () async {
        mockAdapter.fetchHandler = (options) {
          return ResponseBody.fromString(
            jsonEncode({
              'email': ['A user with this email already exists.'],
            }),
            400,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        expect(
          () => authService.updateProfile(
            accessToken: 'valid_jwt_token',
            email: 'duplicate@example.com',
          ),
          throwsA(
            predicate<Exception>(
              (e) => e.toString().contains(
                'Email: A user with this email already exists.',
              ),
            ),
          ),
        );
      },
    );
  });
}
