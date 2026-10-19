import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// Save access and refresh tokens securely after successful authentication.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Retrieve stored access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Retrieve stored refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Update the access token (and optionally refresh token if provided).
  Future<void> updateAccessToken({
    required String accessToken,
    String? newRefreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: newRefreshToken);
    }
  }

  /// Clear stored access and refresh tokens during logout or invalid session.
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Check if an access token exists locally.
  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
