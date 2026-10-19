import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/review.dart';

class ReviewService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  ReviewService({ApiClient? apiClient, TokenStorage? tokenStorage})
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

  /// GET /api/customer/reviews/
  Future<List<CustomerReview>> getReviews() async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.get(
        ApiConstants.customerReviews,
        options: opts,
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data is List
            ? res.data as List<dynamic>
            : (res.data['results'] as List<dynamic>? ?? []);
        return list
            .map((j) => CustomerReview.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load reviews.');
    } on DioException catch (e) {
      throw _handleError(e, 'reviews');
    }
  }

  /// POST /api/customer/reviews/
  Future<CustomerReview> submitReview(ReviewRequest request) async {
    try {
      final opts = await _authOptions();
      final res = await _apiClient.dio.post(
        ApiConstants.customerReviews,
        data: request.toJson(),
        options: opts,
      );
      if ((res.statusCode == 201 || res.statusCode == 200) &&
          res.data != null) {
        return CustomerReview.fromJson(res.data as Map<String, dynamic>);
      }
      throw Exception('Failed to submit review.');
    } on DioException catch (e) {
      throw _handleError(e, 'review');
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
