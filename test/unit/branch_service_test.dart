import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/core/network/api_client.dart';
import 'package:carwashapp/core/storage/token_storage.dart';
import 'package:carwashapp/features/branches/services/branch_service.dart';

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

class FakeTokenStorage implements TokenStorage {
  String? token = 'valid_token_123';

  @override
  Future<String?> getAccessToken() async => token;

  @override
  Future<String?> getRefreshToken() async => 'refresh_123';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<void> updateAccessToken({
    required String accessToken,
    String? newRefreshToken,
  }) async {}

  @override
  Future<void> clearTokens() async {
    token = null;
  }

  @override
  Future<bool> hasAccessToken() async => token != null;
}

void main() {
  late Dio dio;
  late MockAdapter mockAdapter;
  late FakeTokenStorage fakeTokenStorage;
  late BranchService branchService;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8001'));
    mockAdapter = MockAdapter();
    dio.httpClientAdapter = mockAdapter;
    fakeTokenStorage = FakeTokenStorage();
    branchService = BranchService(
      apiClient: ApiClient(customDio: dio),
      tokenStorage: fakeTokenStorage,
    );
  });

  group('BranchService Tests', () {
    test('getBranches returns active branches with Bearer header', () async {
      mockAdapter.fetchHandler = (options) {
        expect(options.path, '/api/customer/branches/');
        expect(options.headers['Authorization'], 'Bearer valid_token_123');

        return ResponseBody.fromString(
          jsonEncode([
            {
              'id': 1,
              'name': 'Dubai Main Branch',
              'code': 'DB01',
              'address': 'Sheikh Zayed Rd',
              'city': 'Dubai',
              'phone': '+971400000',
              'email': 'dubai@alsewar.com',
              'latitude': 25.20,
              'longitude': 55.27,
              'is_active': true,
            },
            {
              'id': 2,
              'name': 'Inactive Branch',
              'code': 'DB02',
              'address': 'Closed St',
              'city': 'Dubai',
              'phone': '',
              'email': '',
              'is_active': false,
            },
          ]),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final branches = await branchService.getBranches();

      expect(branches.length, 1);
      expect(branches.first.name, 'Dubai Main Branch');
      expect(branches.first.isActive, true);
    });

    test('getBranchById handles 404 Not Found error cleanly', () async {
      mockAdapter.fetchHandler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Not found.'}),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => branchService.getBranchById(999),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains(
                  'The requested branch #999 could not be found.',
                ),
          ),
        ),
      );
    });

    test('getBranchHours handles 401 Unauthorized error', () async {
      mockAdapter.fetchHandler = (options) {
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Given token not valid for any token type'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => branchService.getBranchHours(1),
        throwsA(
          predicate(
            (e) =>
                e is Exception &&
                e.toString().contains('Session expired. Please log in again'),
          ),
        ),
      );
    });
  });
}
