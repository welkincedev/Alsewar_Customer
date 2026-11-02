import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/signup_request.dart';
import '../services/auth_service.dart';
import 'auth_providers.dart';
import 'auth_state.dart';

class AuthViewModel extends AsyncNotifier<AuthState> {
  late final AuthService _authService;
  late final TokenStorage _tokenStorage;
  bool _isLoggingOut = false;

  @override
  FutureOr<AuthState> build() async {
    _authService = ref.watch(authServiceProvider);
    _tokenStorage = ref.watch(tokenStorageProvider);
    return restoreSession();
  }

  /// Restore customer session from stored tokens during splash screen check
  Future<AuthState> restoreSession() async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (accessToken == null || accessToken.isEmpty) {
        return const AuthState(status: AuthStatus.unauthenticated);
      }

      try {
        final user = await _authService.getCurrentCustomer(accessToken);

        // Verify account is active
        if (!user.isActive) {
          await _tokenStorage.clearTokens();
          return const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Account is inactive. Please contact support.',
          );
        }

        // Verify role is strictly CUSTOMER
        if (user.role.toUpperCase() == 'CUSTOMER') {
          return AuthState(status: AuthStatus.authenticated, user: user);
        } else {
          await _tokenStorage.clearTokens();
          return const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage:
                'Access denied. Only customer accounts are permitted.',
          );
        }
      } catch (e) {
        // Access token might be expired, attempt token refresh if refresh token is available
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            final refreshedTokens = await _authService.refreshToken(
              refreshToken,
            );
            final newAccess = refreshedTokens['access']!;
            final newRefresh = refreshedTokens['refresh'];

            await _tokenStorage.updateAccessToken(
              accessToken: newAccess,
              newRefreshToken: newRefresh,
            );

            final user = await _authService.getCurrentCustomer(newAccess);

            if (!user.isActive) {
              await _tokenStorage.clearTokens();
              return const AuthState(
                status: AuthStatus.unauthenticated,
                errorMessage: 'Account is inactive. Please contact support.',
              );
            }

            if (user.role.toUpperCase() == 'CUSTOMER') {
              return AuthState(status: AuthStatus.authenticated, user: user);
            }
          } catch (_) {
            // Token refresh failed as well
          }
        }

        // If token validation or refresh fails, clear invalid session
        await _tokenStorage.clearTokens();
        return const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (_) {
      await _tokenStorage.clearTokens();
      return const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Customer login execution
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.login(
        LoginRequest(username: username.trim(), password: password),
      );

      // Confirm that user account is active
      if (!response.user.isActive) {
        state = AsyncValue.data(
          const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Account is inactive. Please contact support.',
          ),
        );
        return;
      }

      // Confirm that returned role is strictly CUSTOMER
      if (response.user.role.toUpperCase() != 'CUSTOMER') {
        state = AsyncValue.data(
          const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Access restricted to customer accounts only.',
          ),
        );
        return;
      }

      // Store tokens securely (including rotated refresh token if provided)
      await _tokenStorage.saveTokens(
        accessToken: response.access,
        refreshToken: response.refresh,
      );

      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: response.user),
      );
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      state = AsyncValue.data(
        AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: cleanMessage,
        ),
      );
    }
  }

  /// Customer signup execution
  Future<AuthUser> signup(SignupRequest request) async {
    try {
      final user = await _authService.signup(request);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  /// Update customer profile execution
  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    List<int>? profilePictureBytes,
    String? profilePictureFilename,
    String? profilePicturePath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final currentUser = state.value?.user;
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      final updatedUser = await _authService.updateProfile(
        accessToken: accessToken,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        profilePictureBytes: profilePictureBytes,
        profilePictureFilename: profilePictureFilename,
        profilePicturePath: profilePicturePath,
        onSendProgress: onSendProgress,
      );

      // Merge updated profile data while preserving non-profile fields
      final mergedUser = updatedUser.copyWith(
        loyaltyPoints: updatedUser.loyaltyPoints ?? currentUser?.loyaltyPoints,
        membershipTier:
            updatedUser.membershipTier ?? currentUser?.membershipTier,
        membershipId: updatedUser.membershipId ?? currentUser?.membershipId,
        phone: updatedUser.phone ?? phone ?? currentUser?.phone,
        profilePicture:
            updatedUser.profilePicture ?? currentUser?.profilePicture,
      );

      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: mergedUser),
      );
      return mergedUser;
    } else if (currentUser != null) {
      // Offline/Preview mode fallback when no backend session exists
      final localUpdated = currentUser.copyWith(
        firstName: firstName ?? currentUser.firstName,
        lastName: lastName ?? currentUser.lastName,
        phone: phone ?? currentUser.phone,
        email: email ?? currentUser.email,
        profilePicture:
            (profilePicturePath != null && profilePicturePath.isNotEmpty)
            ? profilePicturePath
            : currentUser.profilePicture,
      );
      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: localUpdated),
      );
      return localUpdated;
    }

    throw Exception('Authentication required. Please log in.');
  }

  /// Fetch the latest customer profile from backend using profile/me API and update auth state
  Future<AuthUser> refreshProfile() async {
    final currentUser = state.value?.user;
    final accessToken = await _tokenStorage.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      final fetchedUser = await _authService.getCurrentCustomer(accessToken);

      // Merge and preserve non-profile fields (loyalty points, tier, membership ID, phone, etc.)
      final mergedUser = fetchedUser.copyWith(
        loyaltyPoints: fetchedUser.loyaltyPoints ?? currentUser?.loyaltyPoints,
        membershipTier:
            fetchedUser.membershipTier ?? currentUser?.membershipTier,
        membershipId: fetchedUser.membershipId ?? currentUser?.membershipId,
        phone:
            (fetchedUser.phone != null && fetchedUser.phone!.trim().isNotEmpty)
            ? fetchedUser.phone
            : currentUser?.phone,
        profilePicture:
            (fetchedUser.profilePicture != null &&
                fetchedUser.profilePicture!.trim().isNotEmpty)
            ? fetchedUser.profilePicture
            : currentUser?.profilePicture,
      );

      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: mergedUser),
      );
      return mergedUser;
    } else if (currentUser != null) {
      return currentUser;
    }

    throw Exception('Authentication required. Please log in.');
  }

  /// Customer logout execution
  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    try {
      try {
        final accessToken = await _tokenStorage.getAccessToken();
        final refreshToken = await _tokenStorage.getRefreshToken();

        if (accessToken != null &&
            accessToken.isNotEmpty &&
            refreshToken != null &&
            refreshToken.isNotEmpty) {
          await _authService.logout(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
        }
      } catch (_) {
        // Backend logout failure or network error is ignored so local session cleanup always proceeds.
      }

      // Always clear local access and refresh tokens, even if backend request fails
      try {
        await _tokenStorage.clearTokens();
      } catch (_) {
        // Handle unexpected storage errors safely
      }

      // Always update authentication state to unauthenticated
      state = const AsyncValue.data(
        AuthState(status: AuthStatus.unauthenticated),
      );
    } finally {
      _isLoggingOut = false;
    }
  }
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);
