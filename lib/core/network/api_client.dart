import 'package:dio/dio.dart';

import '../constants/api_constants.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({Dio? customDio, String? baseUrl}) {
    dio =
        customDio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
  }
}
