class VehicleRequest {
  final String plateNumber;
  final String make;
  final String model;
  final int? year;
  final String? color;
  final String? vin;

  const VehicleRequest({
    required this.plateNumber,
    required this.make,
    required this.model,
    this.year,
    this.color,
    this.vin,
  });

  Map<String, dynamic> toJson() {
    return {
      'plate_number': plateNumber.trim().toUpperCase(),
      'make': make.trim(),
      'model': model.trim(),
      if (year != null) 'year': year,
      if (color != null && color!.trim().isNotEmpty) 'color': color!.trim(),
      if (vin != null && vin!.trim().isNotEmpty) 'vin': vin!.trim(),
    };
  }
}
