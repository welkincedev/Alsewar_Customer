import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/signup_request.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// Customer signup request to `/api/customer/signup/`
  Future<AuthUser> signup(SignupRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.customerSignup,
        data: request.toJson(),
      );

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null) {
        return AuthUser.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to register customer account.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception(
        'An unexpected error occurred during registration: ${e.toString()}',
      );
    }
  }

  /// Customer login request to `/api/customer/login/`
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.customerLogin,
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return LoginResponse.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to authenticate. Please check your credentials.',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  /// Refresh token request to `/api/auth/token/refresh/`
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccess = data['access']?.toString() ?? '';
        final newRefresh = data['refresh']?.toString();
        return {
          'access': newAccess,
          if (newRefresh != null && newRefresh.isNotEmpty)
            'refresh': newRefresh,
        };
      } else {
        throw Exception('Session expired. Please log in again.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get current customer details from `/api/customer/me/`
  Future<AuthUser> getCurrentCustomer(String accessToken) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.customerMe,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        return AuthUser.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Unable to fetch customer profile.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Send logout request to `/api/auth/logout/`
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.logout,
        data: {'refresh': refreshToken},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } catch (_) {
      // Ignore network failures on logout so local cleanup always proceeds.
    }
  }

  /// Convert Dio errors into user-friendly exception messages.
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timed out. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            return Exception(data['detail'].toString());
          }
          // Parse field-level DRF validation errors (e.g. {"username": ["..."], "email": ["..."]})
          final buffer = StringBuffer();
          data.forEach((key, value) {
            final fieldName = key.replaceAll('_', ' ');
            final formattedKey = fieldName.isEmpty
                ? ''
                : '${fieldName[0].toUpperCase()}${fieldName.substring(1)}';
            if (value is List) {
              final messages = value.map((e) => e.toString()).join(', ');
              buffer.write('$formattedKey: $messages ');
            } else if (value != null) {
              buffer.write('$formattedKey: ${value.toString()} ');
            }
          });
          final result = buffer.toString().trim();
          if (result.isNotEmpty) {
            return Exception(result);
          }
        }
        if (statusCode == 401 || statusCode == 400) {
          return Exception('Invalid request. Please check your input details.');
        }
        return Exception('Server error ($statusCode). Please try again later.');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception('Network error. Unable to reach backend server.');
    }
  }
}
