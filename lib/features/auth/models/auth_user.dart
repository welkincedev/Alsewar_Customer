class AuthUser {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? phone;
  final String firstName;
  final String lastName;
  final bool isActive;
  final String? membershipTier;
  final int? loyaltyPoints;
  final String? membershipId;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.phone,
    required this.firstName,
    required this.lastName,
    this.isActive = true,
    this.membershipTier,
    this.loyaltyPoints,
    this.membershipId,
  });

  /// Parse customer user JSON safely handling nullable or missing fields.
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    int? parsedPoints;
    if (json['loyalty_points'] != null) {
      parsedPoints = json['loyalty_points'] is int
          ? json['loyalty_points'] as int
          : int.tryParse(json['loyalty_points'].toString());
    } else if (json['points'] != null) {
      parsedPoints = json['points'] is int
          ? json['points'] as int
          : int.tryParse(json['points'].toString());
    }

    String? parsedTier;
    if (json['membership_tier'] != null) {
      parsedTier = json['membership_tier']?.toString();
    } else if (json['tier'] != null) {
      parsedTier = json['tier']?.toString();
    }

    String? parsedCardId;
    if (json['membership_id'] != null) {
      parsedCardId = json['membership_id']?.toString();
    } else if (json['card_id'] != null) {
      parsedCardId = json['card_id']?.toString();
    }

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
      membershipTier: parsedTier,
      loyaltyPoints: parsedPoints,
      membershipId: parsedCardId,
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
      if (membershipTier != null) 'membership_tier': membershipTier,
      if (loyaltyPoints != null) 'loyalty_points': loyaltyPoints,
      if (membershipId != null) 'membership_id': membershipId,
    };
  }

  AuthUser copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    String? phone,
    String? firstName,
    String? lastName,
    bool? isActive,
    String? membershipTier,
    int? loyaltyPoints,
    String? membershipId,
  }) {
    return AuthUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      membershipTier: membershipTier ?? this.membershipTier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      membershipId: membershipId ?? this.membershipId,
    );
  }

  /// Display name helper for UI greeting.
  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isNotEmpty ? full : username;
  }
}
