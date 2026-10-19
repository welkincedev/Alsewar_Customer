class ServiceItem {
  final int id;
  final String name;
  final String description;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.description,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: (json['id'] as num? ?? json['service_id'] as num? ?? 0).toInt(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}
