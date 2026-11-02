import 'package:flutter/material.dart';

/// Al Sewar Service Item model.
///
/// Encapsulates service catalogue items with full support for:
/// - Backend API payloads (`id`, `name`, `description`)
/// - Company Profile verified metadata (`category`, `shortName`, `tagline`, `imageAsset`, `icon`, `highlights`)
class ServiceItem {
  final int id;
  final String name;
  final String description;
  final String? shortName;
  final String? category;
  final String? tagline;
  final String? imageAsset;
  final IconData? icon;
  final String? iconAsset;
  final List<String>? highlights;

  const ServiceItem({
    required this.id,
    required this.name,
    required this.description,
    this.shortName,
    this.category,
    this.tagline,
    this.imageAsset,
    this.icon,
    this.iconAsset,
    this.highlights,
  });

  /// Resolves the display label for compact shortcut buttons.
  String get displayShortName => shortName ?? name;

  /// Resolves a reliable automotive photo asset for any service item.
  String get effectiveImageAsset {
    if (imageAsset != null && imageAsset!.isNotEmpty) {
      return imageAsset!;
    }
    return resolveImageByName(name, category);
  }

  /// Resolves a consistent, recognizable outline icon for any service item.
  IconData get effectiveIcon {
    if (icon != null) {
      return icon!;
    }
    return resolveIconByName(name);
  }

  /// Resolves the local asset illustration path for service shortcuts.
  String get effectiveIconAsset {
    if (iconAsset != null && iconAsset!.isNotEmpty) {
      return iconAsset!;
    }
    return resolveIconAssetByName(name, category);
  }

  /// Automatically matches appropriate local icon asset for dynamic/backend services.
  static String resolveIconAssetByName(String name, [String? category]) {
    final lower = '${name.toLowerCase()} ${category?.toLowerCase() ?? ''}';
    if (lower.contains('tyre') ||
        lower.contains('tire') ||
        lower.contains('wheel')) {
      return 'assets/images/service_icons/tire.png';
    }
    if (lower.contains('oil') ||
        lower.contains('battery') ||
        lower.contains('fluid')) {
      return 'assets/images/service_icons/battery.png';
    }
    if (lower.contains('wash') || lower.contains('hydro')) {
      return 'assets/images/service_icons/wash.png';
    }
    if (lower.contains('ceramic') ||
        lower.contains('detail') ||
        lower.contains('polish') ||
        lower.contains('ppf')) {
      return 'assets/images/service_icons/detailing.png';
    }
    if (lower.contains('ac') ||
        lower.contains('cooling') ||
        lower.contains('air')) {
      return 'assets/images/service_icons/ac.png';
    }
    if (lower.contains('paint') ||
        lower.contains('color') ||
        lower.contains('body') ||
        lower.contains('accident') ||
        lower.contains('bumper')) {
      return 'assets/images/service_icons/painting.png';
    }
    return 'assets/images/service_icons/repair.png';
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? '').toString();
    final category = json['category']?.toString();
    return ServiceItem(
      id: (json['id'] as num? ?? json['service_id'] as num? ?? 0).toInt(),
      name: name,
      description: (json['description'] ?? '').toString(),
      shortName: json['short_name']?.toString(),
      category: category,
      tagline: json['tagline']?.toString(),
      imageAsset: json['image_asset']?.toString() ?? json['image']?.toString(),
      iconAsset: json['icon_asset']?.toString(),
      highlights: (json['highlights'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (shortName != null) 'short_name': shortName,
      if (category != null) 'category': category,
      if (tagline != null) 'tagline': tagline,
      if (imageAsset != null) 'image_asset': imageAsset,
      if (iconAsset != null) 'icon_asset': iconAsset,
      if (highlights != null) 'highlights': highlights,
    };
  }

  /// Automatically matches appropriate photography for dynamic/backend services.
  static String resolveImageByName(String name, [String? category]) {
    final lower = '${name.toLowerCase()} ${category?.toLowerCase() ?? ''}';
    if (lower.contains('tyre') ||
        lower.contains('tire') ||
        lower.contains('wheel')) {
      return 'assets/images/service_tyre.jpg';
    }
    if (lower.contains('oil') ||
        lower.contains('battery') ||
        lower.contains('fluid')) {
      return 'assets/images/service_oil_battery.jpg';
    }
    if (lower.contains('wash') || lower.contains('hydro')) {
      return 'assets/images/service_wash.jpg';
    }
    if (lower.contains('ceramic') ||
        lower.contains('detail') ||
        lower.contains('polish') ||
        lower.contains('ppf')) {
      return 'assets/images/service_ceramic.jpg';
    }
    if (lower.contains('ac') ||
        lower.contains('cooling') ||
        lower.contains('air')) {
      return 'assets/images/service_ac_repair.jpg';
    }
    if (lower.contains('paint') ||
        lower.contains('body') ||
        lower.contains('accident') ||
        lower.contains('bumper')) {
      return 'assets/images/service_painting.jpg';
    }
    if (lower.contains('inspect') ||
        lower.contains('underbody') ||
        lower.contains('tint')) {
      return 'assets/images/service_inspection.jpg';
    }
    return 'assets/images/service_mechanical.jpg';
  }

  /// Resolves an outline icon matching the service title.
  static IconData resolveIconByName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tyre') ||
        lower.contains('tire') ||
        lower.contains('wheel')) {
      return Icons.tire_repair_outlined;
    }
    if (lower.contains('oil') || lower.contains('battery')) {
      return Icons.oil_barrel_outlined;
    }
    if (lower.contains('wash') || lower.contains('hydro')) {
      return Icons.local_car_wash_outlined;
    }
    if (lower.contains('ceramic') ||
        lower.contains('polish') ||
        lower.contains('detail')) {
      return Icons.auto_awesome_outlined;
    }
    if (lower.contains('ac') ||
        lower.contains('air') ||
        lower.contains('cool')) {
      return Icons.ac_unit_outlined;
    }
    if (lower.contains('paint') || lower.contains('color')) {
      return Icons.format_paint_outlined;
    }
    if (lower.contains('inspect') || lower.contains('diagnostic')) {
      return Icons.fact_check_outlined;
    }
    if (lower.contains('body') ||
        lower.contains('accident') ||
        lower.contains('bumper')) {
      return Icons.car_crash_outlined;
    }
    return Icons.handyman_outlined;
  }
}

/// Official Al Sewar Service Catalogue extracted directly from Al Sewar Company Profile.pdf.
class AlSewarServiceCatalog {
  // ── Seven Main Services for Home Shortcuts ────────────────────────────────
  static const List<ServiceItem> homeShortcutServices = [
    // 1. Tyre Services (Division 01)
    ServiceItem(
      id: 101,
      name: 'Tyre Services',
      shortName: 'Tyre Services',
      category: 'Tyre Services',
      tagline: 'Safety, performance and peace of mind on every journey.',
      description: 'Fast and safe tyre fitting, 3D laser wheel alignment, dynamic balancing, nitrogen filling, puncture repairs and TPMS sensor calibration.',
      imageAsset: 'assets/images/service_tyre.jpg',
      icon: Icons.tire_repair_outlined,
      iconAsset: 'assets/images/service_icons/tire.png',
      highlights: [
        'Tyre Changing & Safe Rim Fitting',
        '3D Wheel Alignment & Dynamic Balancing',
        'Puncture Repair & Pressure Inspection',
        'Nitrogen Filling for Temperature Stability',
        'TPMS Sensor Diagnostics & Maintenance',
        'Tyre Rims & Premium Wheel Care',
      ],
    ),

    // 2. Auto Repair & Maintenance (Division 02)
    ServiceItem(
      id: 102,
      name: 'Auto Repair & Maintenance',
      shortName: 'Auto Repair',
      category: 'Mechanical',
      tagline: 'Precision care for every part that powers your drive.',
      description: 'Complete care and maintenance for your vehicle. Modern diagnostic equipment and genuine quality parts for reliable engine, brake and mechanical repairs.',
      imageAsset: 'assets/images/service_mechanical.jpg',
      icon: Icons.handyman_outlined,
      iconAsset: 'assets/images/service_icons/repair.png',
      highlights: [
        'Complete Mechanical Care & Servicing',
        'Computerized Engine Diagnostics',
        'Brake System Overhaul & Disc Resurfacing',
        'Transmission & Drivetrain Servicing',
        'Suspension, Steering & Bushing Repairs',
        'Preventative Periodic Maintenance',
      ],
    ),

    // 3. Oil Change & Battery (Division 02)
    ServiceItem(
      id: 103,
      name: 'Oil Change & Battery',
      shortName: 'Oil & Battery',
      category: 'Mechanical',
      tagline: 'Better engine performance and dependable starts, every time.',
      description: 'High-grade synthetic lubricant replacement, OEM filter installation, electronic battery health testing, terminal cleaning and essential fluid top-ups.',
      imageAsset: 'assets/images/service_oil_battery.jpg',
      icon: Icons.oil_barrel_outlined,
      iconAsset: 'assets/images/service_icons/battery.png',
      highlights: [
        'Premium Synthetic & Mineral Oil Replacement',
        'OEM Engine Oil Filter Exchange',
        'Digital Battery Health & Alternator Test',
        'Battery Terminal Cleaning & Anti-Corrosion Treatment',
        'Coolant, Brake & Steering Fluid Top-Ups',
        'Complimentary Multi-Point Visual Inspection',
      ],
    ),

    // 4. Car Wash (Division 04)
    ServiceItem(
      id: 104,
      name: 'Car Wash',
      shortName: 'Car Wash',
      category: 'Detailing',
      tagline: 'Thorough cleaning for a spotless and refreshed finish.',
      description: 'Multi-stage pH-balanced foam bath, high-pressure undercarriage wash, microfibre hand wash, wheel de-ironing, glass buffing and interior vacuuming.',
      imageAsset: 'assets/images/service_wash.jpg',
      icon: Icons.local_car_wash_outlined,
      iconAsset: 'assets/images/service_icons/wash.png',
      highlights: [
        'Touchless High-Pressure Pre-Rinse',
        'pH-Neutral Snow Foam Bath',
        'Wheel Rim De-Ironing & Tyre Dressing',
        'Pure Demineralized Water Spotless Rinse',
        'Interior Cabin Vacuum & Mat Cleaning',
        'Streak-Free Glass Polish Inside & Out',
      ],
    ),

    // 5. Car Ceramic Coating (Division 04)
    ServiceItem(
      id: 105,
      name: 'Car Ceramic Coating',
      shortName: 'Ceramic Coating',
      category: 'Detailing',
      tagline:
          'Long-lasting protection with a deep gloss and hydrophobic finish.',
      description: 'Multi-stage machine paint correction followed by 9H nano-ceramic surface application for extreme mirror gloss, hydrophobic water beading and UV defense.',
      imageAsset: 'assets/images/service_ceramic.jpg',
      icon: Icons.auto_awesome_outlined,
      iconAsset: 'assets/images/service_icons/detailing.png',
      highlights: [
        'Multi-Stage Paint Correction & Swirl Removal',
        '9H Hardness Ultra-Durable Ceramic Layer',
        'Super-Hydrophobic Self-Cleaning Effect',
        'Intense Mirror Reflection & Paint Depth',
        'UV Ray, Bird Dropping & Oxidation Shield',
        'Certified Multi-Year Protection Warranty',
      ],
    ),

    // 6. AC Repair & Servicing (Division 02)
    ServiceItem(
      id: 106,
      name: 'AC Repair & Servicing',
      shortName: 'AC Servicing',
      category: 'Mechanical',
      tagline: 'Better cooling performance and refreshing cabin air.',
      description: 'Digital AC system diagnostics, electronic refrigerant leak testing, precision gas recovery & recharge, compressor servicing and cabin anti-bacterial ozone sanitization.',
      imageAsset: 'assets/images/service_ac_repair.jpg',
      icon: Icons.ac_unit_outlined,
      iconAsset: 'assets/images/service_icons/ac.png',
      highlights: [
        'AC Gas Recovery, Vacuum & Precision Recharge',
        'Electronic Leak Detection & Pressure Testing',
        'Compressor, Condenser & Expansion Valve Diagnostics',
        'Cabin Pollen Filter Replacement',
        'Evaporator Anti-Bacterial Deodorization',
        'Vent Temperature & Airflow Optimization',
      ],
    ),

    // 7. Car Painting (Division 03)
    ServiceItem(
      id: 107,
      name: 'Car Painting',
      shortName: 'Car Painting',
      category: 'Body Services',
      tagline: 'High-quality paint finishes for a flawless and lasting look.',
      description: 'Computerized spectrophotometer paint matching, heated downdraft spray booth application, panel blending, scratch rectification and premium clear-coat baking.',
      imageAsset: 'assets/images/service_painting.jpg',
      icon: Icons.format_paint_outlined,
      iconAsset: 'assets/images/service_icons/painting.png',
      highlights: [
        'Computerized Spectrophotometer Color Formulation',
        'Dust-Free Heated Downdraft Spray Booth',
        'Full Body Resprays & Spot Panel Touch-Ups',
        'Scratch, Stone-Chip & Scuff Rectification',
        'High-Solid UV Resistant Clear Coat',
        'Showroom Mirror Finish Buff & Polish',
      ],
    ),
  ];

  // ── Additional Services from Company Profile ──────────────────────────────
  static const List<ServiceItem> additionalServices = [
    // 8. Wheel Alignment & Balancing (Division 01)
    ServiceItem(
      id: 108,
      name: 'Wheel Alignment & Balancing',
      shortName: 'Wheel Alignment',
      category: 'Tyre Services',
      tagline: 'Ensures even wear and a smooth, safe drive.',
      description: 'Precision 3D computerized laser alignment to factory camber, caster and toe angles, coupled with dynamic road-force balancing for smooth high-speed highway cruising.',
      imageAsset: 'assets/images/service_tyre.jpg',
      icon: Icons.speed_outlined,
      highlights: [
        'Computerized 3D 4-Wheel Laser Alignment',
        'Dynamic Road-Force Wheel Balancing',
        'Steering Angle Calibration & Zeroing',
        'Suspension Geometry Inspection',
      ],
    ),

    // 9. Engine Diagnostics & Repair (Division 02)
    ServiceItem(
      id: 109,
      name: 'Engine Diagnostics & Repair',
      shortName: 'Diagnostics',
      category: 'Mechanical',
      tagline: 'Accurate diagnostics to find and fix issues the right way.',
      description: 'Advanced OBD-II computerized scanning, live telemetry sensor monitoring, ignition and fuel injection troubleshooting and complete powertrain repairs.',
      imageAsset: 'assets/images/service_mechanical.jpg',
      icon: Icons.troubleshoot_outlined,
      highlights: [
        'Dealer-Level Computerized Scanning',
        'Check Engine Light Diagnostics & Reset',
        'Fuel Injection & Ignition Troubleshooting',
        'Engine Timing, Gasket & Seal Replacements',
      ],
    ),

    // 10. Accident & Body Repair (Division 03)
    ServiceItem(
      id: 110,
      name: 'Accident & Body Repair',
      shortName: 'Body Repair',
      category: 'Body Services',
      tagline: 'Restoring your vehicle to pre-accident condition.',
      description: 'Chassis frame laser alignment, collision reconstruction, hydraulic dent pulling, fender repair and seamless structural panel replacement to OEM specifications.',
      imageAsset: 'assets/images/service_painting.jpg',
      icon: Icons.car_crash_outlined,
      highlights: [
        'Collision Frame Straightening & Alignment',
        'Structural Steel & Aluminum Repair',
        'Bumper, Fender & Hood Panel Replacement',
        'Insurance Claim Assessment & Repairs',
      ],
    ),

    // 11. Interior & Exterior Detailing (Division 04)
    ServiceItem(
      id: 111,
      name: 'Interior & Exterior Detailing',
      shortName: 'Full Detailing',
      category: 'Detailing',
      tagline: 'Complete cleaning and conditioning for a fresh, like-new experience.',
      description: 'Exhaustive deep restoration including leather conditioning, carpet steam extraction, plastic UV protection, 2-stage exterior machine compounding and engine bay detail.',
      imageAsset: 'assets/images/service_ceramic.jpg',
      icon: Icons.clean_hands_outlined,
      highlights: [
        'Deep Steam Carpet & Headliner Extraction',
        'Fine Leather Cleaning & Conditioning Balm',
        'Ozone Air Purification & Allergen Removal',
        'Multi-Stage Rotary Machine Compounding',
      ],
    ),

    // 12. Window Film / Tinting (Division 03)
    ServiceItem(
      id: 112,
      name: 'Window Film / Tinting',
      shortName: 'Window Tinting',
      category: 'Body Services',
      tagline: 'Enhances privacy, reduces heat and blocks UV rays.',
      description: 'Premium nano-ceramic automotive window films rejecting up to 99% UV rays and 80% infrared solar heat, improving cabin thermal comfort and protecting interior upholstery.',
      imageAsset: 'assets/images/service_inspection.jpg',
      icon: Icons.branding_watermark_outlined,
      highlights: [
        'Up to 99% Harmful UV Ray Rejection',
        'High Infrared Solar Heat Reflection',
        'Crystal-Clear Optical Clarity Day & Night',
        'Zero Signal Interference with GPS & Mobile',
      ],
    ),

    // 13. Vehicle Inspection (Division 02)
    ServiceItem(
      id: 113,
      name: 'Vehicle Inspection',
      shortName: 'Inspection',
      category: 'Mechanical',
      tagline: 'Thorough inspections for your safety and peace of mind.',
      description: 'Comprehensive multi-point digital vehicle health inspection covering brakes, suspension, powertrain, electrical system, fluid condition, chassis and tyres.',
      imageAsset: 'assets/images/service_inspection.jpg',
      icon: Icons.fact_check_outlined,
      highlights: [
        'Multi-Point Comprehensive Safety Audit',
        'Brake Pad Thickness & Rotor Inspection',
        'Suspension, Steering & Tie-Rod Check',
        'Digital Report with Transparent Guidance',
      ],
    ),

    // 14. Paint Protection Film (PPF) (Division 04)
    ServiceItem(
      id: 114,
      name: 'Paint Protection Film (PPF)',
      shortName: 'PPF Protection',
      category: 'Detailing',
      tagline: 'Invisible shield against scratches, chips and road debris.',
      description: 'Optically clear, self-healing polyurethane film wrapped over vulnerable body panels to shield against highway stone chips, harsh sandstorms and road tar.',
      imageAsset: 'assets/images/service_ceramic.jpg',
      icon: Icons.shield_outlined,
      highlights: [
        'Self-Healing Top Coat with Heat Activation',
        'Deflects High-Speed Stone Chips & Gravel',
        'Stain & Road Tar Chemical Resistance',
        'Seamless Invisible Edge-Wrapped Finish',
      ],
    ),
  ];

  /// The complete combined catalogue of all verified Al Sewar services.
  static List<ServiceItem> get allServices => [
    ...homeShortcutServices,
    ...additionalServices,
  ];

  /// All unique service divisions/categories.
  static const List<String> categories = [
    'All',
    'Tyre Services',
    'Mechanical',
    'Body Services',
    'Detailing',
  ];
}
