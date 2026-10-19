class Vehicle {
  final int id;
  final String plateNumber;
  final String make;
  final String model;
  final int? year;
  final String? color;
  final String? vin;
  final int? branch;
  final String? branchName;
  final String? imageUrl;
  final String createdAt;
  final String updatedAt;

  const Vehicle({
    required this.id,
    required this.plateNumber,
    required this.make,
    required this.model,
    this.year,
    this.color,
    this.vin,
    this.branch,
    this.branchName,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Helper function to safely extract an ID if the API sends a nested map object
    int? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        return (value['id'] as num?)?.toInt();
      }
      if (value is num) {
        return value.toInt();
      }
      return int.tryParse(value.toString());
    }

    return Vehicle(
      id:
          extractId(json['id']) ??
          0, // Fallback if ID itself is nested or missing
      plateNumber: (json['plate_number'] ?? '').toString(),
      make: (json['make'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      year: extractId(json['year']),
      color: json['color']?.toString(),
      vin: json['vin']?.toString(),
      branch: extractId(json['branch']),
      // Fallback to fetch branch name from inside the object if it's nested
      branchName:
          json['branch_name']?.toString() ??
          (json['branch'] is Map ? json['branch']['name']?.toString() : null),
      imageUrl:
          json['image']?.toString() ??
          json['image_url']?.toString() ??
          json['photo']?.toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate_number': plateNumber,
      'make': make,
      'model': model,
      if (year != null) 'year': year,
      if (color != null && color!.isNotEmpty) 'color': color,
      if (vin != null && vin!.isNotEmpty) 'vin': vin,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'image': imageUrl,
    };
  }

  String get displayName {
    final parts = <String>[];
    if (year != null) parts.add(year.toString());
    if (make.isNotEmpty) parts.add(make);
    if (model.isNotEmpty) parts.add(model);
    return parts.join(' ');
  }
}
