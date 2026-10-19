class AuthUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? phone;
  final String firstName;
  final String lastName;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.isActive = true,
  });

  /// Parse customer user JSON safely handling nullable or missing fields.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString(),
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] == null ||
                json['is_active'].toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'phone': phone,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
    };
  }

  /// Display name helper for UI greeting.
  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }
}
