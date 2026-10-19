import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/branch.dart';
import '../models/business_hour.dart';

class BranchService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  BranchService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  /// Retrieve authorization header options using the securely stored access token.
  Future<Options> _getAuthOptions() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token missing. Please sign in again.');
    }
    return Options(
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  /// Get list of customer branches: GET `/api/customer/branches/`
  Future<List<Branch>> getBranches() async {
    try {
      final options = await _getAuthOptions();
      final response = await _apiClient.dio.get(
        ApiConstants.customerBranches,
        options: options,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] is List
                  ? response.data['results'] as List<dynamic>
                  : []);
        return data
            .map((json) => Branch.fromJson(json as Map<String, dynamic>))
            .where((b) => b.isActive)
            .toList();
      } else {
        throw Exception('Failed to load branches.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'branches');
    } catch (e) {
      throw Exception('Unexpected error fetching branches: ${e.toString()}');
    }
  }

  /// Get branch details by ID: GET `/api/customer/branches/{id}/`
  Future<Branch> getBranchById(int id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _apiClient.dio.get(
        ApiConstants.customerBranchDetail(id),
        options: options,
      );

      if (response.statusCode == 200 && response.data != null) {
        return Branch.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load branch details.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'branch #$id');
    } catch (e) {
      throw Exception(
        'Unexpected error fetching branch details: ${e.toString()}',
      );
    }
  }

  /// Get branch weekly operating hours by ID: GET `/api/customer/branches/{id}/hours/`
  Future<List<BusinessHour>> getBranchHours(int id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _apiClient.dio.get(
        ApiConstants.customerBranchHours(id),
        options: options,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data is List
            ? response.data as List<dynamic>
            : (response.data['results'] is List
                  ? response.data['results'] as List<dynamic>
                  : []);
        final hours = data
            .map((json) => BusinessHour.fromJson(json as Map<String, dynamic>))
            .toList();
        // Sort by day of week (Monday/Sunday ordering)
        hours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
        return hours;
      } else {
        throw Exception('Failed to load branch opening hours.');
      }
    } on DioException catch (e) {
      throw _handleDioError(e, 'hours for branch #$id');
    } catch (e) {
      throw Exception(
        'Unexpected error fetching branch hours: ${e.toString()}',
      );
    }
  }

  /// Convert Dio error status codes into clear user-facing messages.
  Exception _handleDioError(DioException error, String resource) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timed out while loading $resource. Please check your network.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return Exception(
            'Session expired. Please log in again to view $resource.',
          );
        } else if (statusCode == 403) {
          return Exception('Access forbidden. Customer permissions required.');
        } else if (statusCode == 404) {
          return Exception('The requested $resource could not be found.');
        }
        return Exception(
          'Server error ($statusCode) while fetching $resource.',
        );
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      default:
        return Exception(
          'Unable to connect to branch service. Please try again.',
        );
    }
  }
}
