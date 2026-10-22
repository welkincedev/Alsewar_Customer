class Branch {
  final int id;
  final String name;
  final String code;
  final String address;
  final String city;
  final String phone;
  final String? whatsappNumber;
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
    this.whatsappNumber,
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
      whatsappNumber: json['whatsapp_number']?.toString(),
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
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }

  Branch copyWith({
    int? id,
    String? name,
    String? code,
    String? address,
    String? city,
    String? phone,
    String? whatsappNumber,
    String? email,
    double? latitude,
    double? longitude,
    bool? isActive,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
    );
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
