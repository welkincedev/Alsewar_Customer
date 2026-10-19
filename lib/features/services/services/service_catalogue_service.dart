import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/service_item.dart';

class ServiceCatalogueService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ServiceCatalogueService({ApiClient? apiClient, TokenStorage? tokenStorage})
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

  /// GET /api/customer/services/
  Future<List<ServiceItem>> getServices({String? search}) async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.get(
        ApiConstants.customerServices,
        queryParameters: search != null && search.isNotEmpty
            ? {'search': search}
            : null,
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data is List
            ? res.data as List<dynamic>
            : (res.data['results'] as List<dynamic>? ?? []);
        return list
            .map((j) => ServiceItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load services.');
    } on DioException catch (e) {
      throw _handleError(e, 'services');
    }
  }

  /// GET /api/customer/branches/{branchId}/services/
  Future<List<ServiceItem>> getServicesByBranch(int branchId) async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.get(
        ApiConstants.customerBranchServices(branchId),
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data is List
            ? res.data as List<dynamic>
            : (res.data['results'] as List<dynamic>? ?? []);
        return list
            .map((j) => ServiceItem.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load branch services.');
    } on DioException catch (e) {
      throw _handleError(e, 'services at branch #$branchId');
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
          return Exception('The requested $resource could not be found.');
        }
        return Exception('Server error ($code).');
      default:
        return Exception('Unable to connect. Please check your internet.');
    }
  }
}
