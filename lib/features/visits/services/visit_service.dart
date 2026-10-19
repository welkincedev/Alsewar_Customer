import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/service_visit.dart';

class VisitApiService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  VisitApiService({ApiClient? apiClient, TokenStorage? tokenStorage})
    : _apiClient = apiClient ?? ApiClient(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  Future<Options> _authOptions() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token missing. Please sign in again.');
    }
    return Options(
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  /// GET /api/customer/visits/
  Future<List<ServiceVisit>> getVisits() async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.get(
        ApiConstants.customerVisits,
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data is List
            ? res.data as List<dynamic>
            : (res.data['results'] as List<dynamic>? ?? []);
        return list
            .map((j) => ServiceVisit.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load service visits.');
    } on DioException catch (e) {
      throw _handleError(e, 'service visits');
    }
  }

  /// GET /api/customer/visits/{id}/
  Future<ServiceVisit> getVisitById(int id) async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.get(
        ApiConstants.customerVisitDetail(id),
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        return ServiceVisit.fromJson(res.data as Map<String, dynamic>);
      }
      throw Exception('Failed to load visit details.');
    } on DioException catch (e) {
      throw _handleError(e, 'visit #$id');
    }
  }

  Exception _handleError(DioException e, String resource) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out loading $resource.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          return Exception(data['detail'].toString());
        }
        if (code == 401) {
          return Exception('Session expired. Please log in again.');
        }
        if (code == 404) {
          return Exception(
            'Visit not found or does not belong to your account.',
          );
        }
        return Exception('Server error ($code).');
      default:
        return Exception('Unable to connect. Please check your internet.');
    }
  }
}
