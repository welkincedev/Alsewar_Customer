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

  /// Get current customer details from /api/customer/profile/ (with fallback to /api/customer/me/)
  Future<AuthUser> getCurrentCustomer(String accessToken) async {
    try {
      Response response;
      try {
        response = await _apiClient.dio.get(
          ApiConstants.customerProfile,
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          response = await _apiClient.dio.get(
            ApiConstants.customerMe,
            options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('profile') &&
              data['profile'] is Map<String, dynamic>) {
            return AuthUser.fromJson(data['profile'] as Map<String, dynamic>);
          }
          return AuthUser.fromJson(data);
        }
        throw Exception('Invalid profile response structure.');
      } else {
        throw Exception('Unable to fetch customer profile.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update customer profile details via `PATCH /api/customer/profile/`
  /// Supports:
  /// - Text-only updates (`first_name`, `last_name`, `email`) via `application/json`
  /// - Multipart updates including `profile_picture` (file, max 2MB, JPEG/PNG/WEBP)
  /// (with fallback to `/api/customer/me/` if the host route differs)
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
    try {
      dynamic requestData;
      Options options;

      final hasImageBytes =
          profilePictureBytes != null && profilePictureBytes.isNotEmpty;
      final hasImagePath =
          profilePicturePath != null && profilePicturePath.isNotEmpty;

      if (hasImageBytes || hasImagePath) {
        final formMap = <String, dynamic>{};
        if (firstName != null && firstName.trim().isNotEmpty) {
          formMap['first_name'] = firstName.trim();
        }
        if (lastName != null && lastName.trim().isNotEmpty) {
          formMap['last_name'] = lastName.trim();
        }
        if (email != null && email.trim().isNotEmpty) {
          formMap['email'] = email.trim();
        }

        if (hasImageBytes) {
          final filename = profilePictureFilename ?? 'profile_picture.jpg';
          formMap['profile_picture'] = MultipartFile.fromBytes(
            profilePictureBytes,
            filename: filename,
          );
        } else if (hasImagePath) {
          final filename =
              profilePictureFilename ?? profilePicturePath.split('/').last;
          formMap['profile_picture'] = await MultipartFile.fromFile(
            profilePicturePath,
            filename: filename,
          );
        }

        requestData = FormData.fromMap(formMap);
        options = Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'multipart/form-data',
          },
        );
      } else {
        final payload = <String, dynamic>{};
        if (firstName != null) payload['first_name'] = firstName.trim();
        if (lastName != null) payload['last_name'] = lastName.trim();
        if (email != null) payload['email'] = email.trim();
        if (phone != null && phone.trim().isNotEmpty) {
          payload['phone'] = phone.trim();
        }

        requestData = payload;
        options = Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
      }

      Response response;
      try {
        response = await _apiClient.dio.patch(
          ApiConstants.customerProfile,
          data: requestData,
          options: options,
          onSendProgress: onSendProgress,
        );
      } on DioException catch (dioErr) {
        if (dioErr.response?.statusCode == 404) {
          response = await _apiClient.dio.patch(
            ApiConstants.customerMe,
            data: requestData,
            options: options,
            onSendProgress: onSendProgress,
          );
        } else {
          rethrow;
        }
      }

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('profile') &&
              data['profile'] is Map<String, dynamic>) {
            return AuthUser.fromJson(data['profile'] as Map<String, dynamic>);
          }
          return AuthUser.fromJson(data);
        }
        throw Exception('Invalid profile response structure.');
      } else {
        throw Exception('Failed to update customer profile.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload customer profile picture via `PATCH /api/customer/profile/`
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

  /// Remove customer profile picture via `DELETE /api/customer/profile/picture/`
  Future<void> removeProfilePicture({required String accessToken}) async {
    try {
      await _apiClient.dio.delete(
        ApiConstants.customerProfilePicture,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
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
