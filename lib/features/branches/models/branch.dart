class Branch {
  final int id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String phone;
  final String email;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  const Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.city,
    required this.phone,
    required this.email,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  /// Safely parse Branch JSON handling optional and nullable fields.
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] == null ||
                json['is_active'].toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'city': city,
      'phone': phone,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }

  /// Full formatted address string for UI display.
  String get fullAddress {
    if (city.isNotEmpty &&
        !address.toLowerCase().contains(city.toLowerCase())) {
      return '$address, $city';
    }
    return address;
  }
}
