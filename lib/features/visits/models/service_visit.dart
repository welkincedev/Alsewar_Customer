class VisitStage {
  final String name;
  final String? description;
  final bool isTerminal;

  const VisitStage({
    required this.name,
    this.description,
    required this.isTerminal,
  });

  factory VisitStage.fromJson(Map<String, dynamic> json) {
    return VisitStage(
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      isTerminal: (json['is_terminal'] as bool?) ?? false,
    );
  }
}

class VisitStatusHistory {
  final int id;
  final String stageName;
  final String? stageDescription;
  final String? notes;
  final String createdAt;

  const VisitStatusHistory({
    required this.id,
    required this.stageName,
    this.stageDescription,
    this.notes,
    required this.createdAt,
  });

  factory VisitStatusHistory.fromJson(Map<String, dynamic> json) {
    return VisitStatusHistory(
      id: (json['id'] as num).toInt(),
      stageName: (json['stage_name'] ?? '').toString(),
      stageDescription: json['stage_description']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

class VisitServiceEntry {
  final int id;
  final String name;
  final String description;

  const VisitServiceEntry({
    required this.id,
    required this.name,
    required this.description,
  });

  factory VisitServiceEntry.fromJson(Map<String, dynamic> json) {
    // handles both list-level {id, name, description} and
    // the nested {id, service, service_name} format
    if (json.containsKey('service_name')) {
      return VisitServiceEntry(
        id: (json['id'] as num).toInt(),
        name: (json['service_name'] ?? '').toString(),
        description: (json['service_description'] ?? '').toString(),
      );
    }
    return VisitServiceEntry(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
    );
  }
}

class ServiceVisit {
  final int id;
  final String visitNumber;
  final Map<String, dynamic>? vehicleDetails;
  final Map<String, dynamic>? branchDetails;
  final VisitStage? currentStage;
  final List<VisitServiceEntry> services;
  final List<VisitStatusHistory> statusHistory;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  const ServiceVisit({
    required this.id,
    required this.visitNumber,
    this.vehicleDetails,
    this.branchDetails,
    this.currentStage,
    required this.services,
    required this.statusHistory,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ServiceVisit.fromJson(Map<String, dynamic> json) {
    VisitStage? stage;
    final stageRaw = json['current_stage'];
    if (stageRaw is Map<String, dynamic>) {
      stage = VisitStage.fromJson(stageRaw);
    }

    final servicesList = (json['services'] as List<dynamic>? ?? [])
        .map((s) => VisitServiceEntry.fromJson(s as Map<String, dynamic>))
        .toList();

    final historyList = (json['status_history'] as List<dynamic>? ?? [])
        .map((h) => VisitStatusHistory.fromJson(h as Map<String, dynamic>))
        .toList();

    return ServiceVisit(
      id: (json['id'] as num).toInt(),
      visitNumber: (json['visit_number'] ?? '').toString(),
      vehicleDetails: json['vehicle_details'] as Map<String, dynamic>?,
      branchDetails: json['branch_details'] as Map<String, dynamic>?,
      currentStage: stage,
      services: servicesList,
      statusHistory: historyList,
      notes: json['notes']?.toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      updatedAt: (json['updated_at'] ?? '').toString(),
    );
  }

  int? get vehicleId {
    if (vehicleDetails != null) {
      final idVal = vehicleDetails!['id'] ?? vehicleDetails!['vehicle_id'];
      if (idVal is num) return idVal.toInt();
      if (idVal != null) return int.tryParse(idVal.toString());
    }
    return null;
  }

  String get vehiclePlate => (vehicleDetails?['plate_number'] ?? '').toString();
  String get vehicleMake => (vehicleDetails?['make'] ?? '').toString();
  String get vehicleModel => (vehicleDetails?['model'] ?? '').toString();
  String get vehicleLabel => '$vehicleMake $vehicleModel'.trim();
  String get branchName => (branchDetails?['name'] ?? '').toString();
  String get branchCity => (branchDetails?['city'] ?? '').toString();
  String get stageName => currentStage?.name ?? 'Unknown';
  bool get isCompleted => currentStage?.isTerminal ?? false;
}
