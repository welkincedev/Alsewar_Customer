import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/vehicle.dart';
import '../models/vehicle_request.dart';

class VehicleService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  VehicleService({ApiClient? apiClient, TokenStorage? tokenStorage})
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

  /// GET /api/customer/vehicles/
  Future<List<Vehicle>> getVehicles() async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.get(
        ApiConstants.customerVehicles,
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data is List
            ? res.data as List<dynamic>
            : (res.data['results'] as List<dynamic>? ?? []);
        return list
            .map((j) => Vehicle.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load vehicles.');
    } on DioException catch (e) {
      throw _handleError(e, 'vehicles');
    }
  }

  /// POST /api/customer/vehicles/
  Future<Vehicle> createVehicle(VehicleRequest request) async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.post(
        ApiConstants.customerVehicles,
        data: request.toJson(),
        options: opts,
      );
      if ((res.statusCode == 201 || res.statusCode == 200) &&
          res.data != null) {
        return Vehicle.fromJson(res.data as Map<String, dynamic>);
      }
      throw Exception('Failed to register vehicle.');
    } on DioException catch (e) {
      throw _handleError(e, 'vehicle');
    }
  }

  /// PATCH /api/customer/vehicles/{id}/
  Future<Vehicle> updateVehicle(int id, Map<String, dynamic> fields) async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.patch(
        ApiConstants.customerVehicleDetail(id),
        data: fields,
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        return Vehicle.fromJson(res.data as Map<String, dynamic>);
      }
      throw Exception('Failed to update vehicle.');
    } on DioException catch (e) {
      throw _handleError(e, 'vehicle #$id');
    }
  }

  /// DELETE /api/customer/vehicles/{id}/
  Future<void> deleteVehicle(int id) async {
    try {
      final opts = await _authOptions();
      await _apiClient.dio.delete(
        ApiConstants.customerVehicleDetail(id),
        options: opts,
      );
    } on DioException catch (e) {
      throw _handleError(e, 'vehicle #$id');
    }
  }

  Exception _handleError(DioException e, String resource) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Connection timed out loading $resource. Check your network.',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          if (data.containsKey('detail')) {
            return Exception(data['detail'].toString());
          }
          final buf = StringBuffer();
          data.forEach((k, v) {
            final key =
                '${k[0].toUpperCase()}${k.substring(1).replaceAll('_', ' ')}';
            if (v is List) {
              buf.write('$key: ${v.join(', ')} ');
            } else {
              buf.write('$key: $v ');
            }
          });
          final msg = buf.toString().trim();
          if (msg.isNotEmpty) return Exception(msg);
        }
        if (code == 401) {
          return Exception('Session expired. Please log in again.');
        } else if (code == 403) {
          return Exception('Access forbidden. Customer permissions required.');
        } else if (code == 404) {
          return Exception('The requested $resource could not be found.');
        }
        return Exception('Server error ($code) while saving $resource.');
      default:
        return Exception(
          'Unable to connect. Please check your internet connection.',
        );
    }
  }
}
