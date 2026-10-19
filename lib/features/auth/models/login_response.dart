import 'auth_user.dart';

class LoginResponse {
  final String access;
  final String refresh;
  final AuthUser user;

  const LoginResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access']?.toString() ?? '',
      refresh: json['refresh']?.toString() ?? '',
      user: json['user'] != null
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : const AuthUser(
              id: 0,
              username: '',
              email: '',
              role: '',
              phone: '',
              firstName: '',
              lastName: '',
            ),
    );
  }
}
