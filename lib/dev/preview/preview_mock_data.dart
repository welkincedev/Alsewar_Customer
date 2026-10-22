import '../../features/auth/models/auth_user.dart';
import '../../features/branches/models/branch.dart';
import '../../features/branches/models/business_hour.dart';
import '../../features/reviews/models/review.dart';
import '../../features/services/models/service_item.dart';
import '../../features/vehicles/models/vehicle.dart';
import '../../features/visits/models/service_visit.dart';

/// Centralized sample mock data for UI previews during offline development.
///
/// All mock data items are clearly tagged with `[Preview]` so they cannot be
/// mistaken for real customer information.
class PreviewMockData {
  // ─── 1. Sample Customer Profile ──────────────────────────────────────────
  static const AuthUser sampleCustomer = AuthUser(
    id: 999,
    username: 'preview_user',
    email: 'preview.customer@alsewar.dev',
    role: 'CUSTOMER',
    phone: '+966 50 123 4567',
    firstName: 'Ahmed',
    lastName: 'Al-Mansoor [Preview]',
    isActive: true,
  );

  // ─── 2. Sample Vehicles ──────────────────────────────────────────────────
  static final List<Vehicle> sampleVehicles = [
    const Vehicle(
      id: 101,
      plateNumber: 'PRV 101',
      make: 'Mercedes-Benz',
      model: 'S 500 [Preview]',
      year: 2024,
      color: 'Obsidian Black',
      vin: 'WDD2230631A000001',
      branch: 1,
      branchName: 'Al Sewar Riyadh Olaya [Preview]',
      createdAt: '2026-01-15T10:00:00Z',
      updatedAt: '2026-10-14T12:00:00Z',
    ),
    const Vehicle(
      id: 102,
      plateNumber: 'PRV 202',
      make: 'Porsche',
      model: 'Cayenne GTS [Preview]',
      year: 2023,
      color: 'Chalk White',
      vin: 'WP1AA2AY8PDA00002',
      branch: 2,
      branchName: 'Al Sewar Jeddah Corniche [Preview]',
      createdAt: '2026-03-20T10:00:00Z',
      updatedAt: '2026-09-28T12:00:00Z',
    ),
    // Third vehicle has no service history to preview the "No service yet" card badge
    const Vehicle(
      id: 103,
      plateNumber: 'PRV 303',
      make: 'Lexus',
      model: 'LX 600 [Preview]',
      year: 2025,
      color: 'Sand Pearl',
      vin: 'JTJHY7AX8R4000003',
      branch: 1,
      branchName: 'Al Sewar Riyadh Olaya [Preview]',
      createdAt: '2026-10-01T10:00:00Z',
      updatedAt: '2026-10-01T10:00:00Z',
    ),
  ];

  // ─── 3. Sample Services Catalogue ────────────────────────────────────────
  static const List<ServiceItem> sampleServices = [
    ServiceItem(
      id: 1,
      name: 'Executive Hydro-Wash [Preview]',
      description: '4-stage pH-balanced wash with wheel de-ironing and paint gloss sealant.',
    ),
    ServiceItem(
      id: 2,
      name: 'Ceramic Shield Detailing [Preview]',
      description: 'Clay-bar decontamination, 2-stage paint correction, and 9H ceramic coating.',
    ),
    ServiceItem(
      id: 3,
      name: 'Interior Ozone Sanitization [Preview]',
      description: 'Deep steam extraction, leather conditioning, and anti-bacterial ozone air purification.',
    ),
    ServiceItem(
      id: 4,
      name: 'Engine Bay Steam Rejuvenation [Preview]',
      description: 'Precision degreasing, steam cleansing, and protective electrical component dressing.',
    ),
    ServiceItem(
      id: 5,
      name: 'Headlight Lens Restoration [Preview]',
      description: 'Multi-stage wet sanding, compounding polish, and UV anti-yellowing sealant layer.',
    ),
    ServiceItem(
      id: 6,
      name: 'Underbody Anti-Corrosion Treatment [Preview]',
      description: 'High-pressure undercarriage flush and salt-resistant protective barrier coat.',
    ),
  ];

  // ─── 4. Sample Service Visits (History) ───────────────────────────────────
  static final List<ServiceVisit> sampleVisits = [
    // Visit 1: Completed visit linked to Vehicle 101 (Used for Last Service Date: 2026-10-14)
    const ServiceVisit(
      id: 201,
      visitNumber: 'PRV-VISIT-2026-001',
      vehicleDetails: {
        'id': 101,
        'plate_number': 'PRV 101',
        'make': 'Mercedes-Benz',
        'model': 'S 500 [Preview]',
      },
      branchDetails: {
        'id': 1,
        'name': 'Al Sewar Riyadh Olaya [Preview]',
        'city': 'Riyadh',
      },
      currentStage: VisitStage(
        name: 'Completed',
        description: 'Vehicle fully detailed, quality inspected, and delivered',
        isTerminal: true,
      ),
      services: [
        VisitServiceEntry(
          id: 1,
          name: 'Executive Hydro-Wash [Preview]',
          description: 'Full exterior wash',
        ),
        VisitServiceEntry(
          id: 2,
          name: 'Ceramic Shield Detailing [Preview]',
          description: 'Ceramic coating application',
        ),
      ],
      statusHistory: [
        VisitStatusHistory(
          id: 1,
          stageName: 'Checked In',
          createdAt: '2026-10-14T09:00:00Z',
        ),
        VisitStatusHistory(
          id: 2,
          stageName: 'In Progress',
          createdAt: '2026-10-14T09:30:00Z',
        ),
        VisitStatusHistory(
          id: 3,
          stageName: 'Completed',
          createdAt: '2026-10-14T11:45:00Z',
        ),
      ],
      notes: 'Customer requested special attention on front rims and exhaust tips.',
      createdAt: '2026-10-14T09:00:00Z',
      updatedAt: '2026-10-14T11:45:00Z',
    ),

    // Visit 2: Completed visit linked to Vehicle 102 (Used for Last Service Date: 2026-09-28)
    const ServiceVisit(
      id: 202,
      visitNumber: 'PRV-VISIT-2026-002',
      vehicleDetails: {
        'id': 102,
        'plate_number': 'PRV 202',
        'make': 'Porsche',
        'model': 'Cayenne GTS [Preview]',
      },
      branchDetails: {
        'id': 2,
        'name': 'Al Sewar Jeddah Corniche [Preview]',
        'city': 'Jeddah',
      },
      currentStage: VisitStage(
        name: 'Completed',
        description: 'Interior detailing finished',
        isTerminal: true,
      ),
      services: [
        VisitServiceEntry(
          id: 3,
          name: 'Interior Ozone Sanitization [Preview]',
          description: 'Deep leather and carpet steam',
        ),
      ],
      statusHistory: [
        VisitStatusHistory(
          id: 4,
          stageName: 'Completed',
          createdAt: '2026-09-28T14:30:00Z',
        ),
      ],
      createdAt: '2026-09-28T13:00:00Z',
      updatedAt: '2026-09-28T14:30:00Z',
    ),

    // Visit 3: In Progress visit for Vehicle 101 to preview active status badges
    const ServiceVisit(
      id: 203,
      visitNumber: 'PRV-VISIT-2026-003',
      vehicleDetails: {
        'id': 101,
        'plate_number': 'PRV 101',
        'make': 'Mercedes-Benz',
        'model': 'S 500 [Preview]',
      },
      branchDetails: {
        'id': 1,
        'name': 'Al Sewar Riyadh Olaya [Preview]',
        'city': 'Riyadh',
      },
      currentStage: VisitStage(
        name: 'In Progress',
        description: 'Engine bay degreasing and dressing',
        isTerminal: false,
      ),
      services: [
        VisitServiceEntry(
          id: 4,
          name: 'Engine Bay Steam Rejuvenation [Preview]',
          description: 'Precision under-hood detailing',
        ),
      ],
      statusHistory: [
        VisitStatusHistory(
          id: 5,
          stageName: 'Checked In',
          createdAt: '2026-10-20T10:00:00Z',
        ),
        VisitStatusHistory(
          id: 6,
          stageName: 'In Progress',
          createdAt: '2026-10-20T10:30:00Z',
        ),
      ],
      notes: 'Customer waiting in executive lounge.',
      createdAt: '2026-10-20T10:00:00Z',
      updatedAt: '2026-10-20T10:30:00Z',
    ),
  ];

  static ServiceVisit getVisitById(int id) {
    return sampleVisits.firstWhere(
      (v) => v.id == id,
      orElse: () => sampleVisits.first,
    );
  }

  // ─── 5. Sample Branches ──────────────────────────────────────────────────
  static const List<Branch> sampleBranches = [
    Branch(
      id: 1,
      name: 'Al Sewar Riyadh Olaya [Preview]',
      code: 'OLY01',
      address: 'King Fahd Road, Al Olaya District',
      city: 'Riyadh',
      phone: '+966 50 123 4567',
      email: 'olaya.preview@alsewar.com',
      latitude: 24.7136,
      longitude: 46.6753,
      isActive: true,
    ),
    Branch(
      id: 2,
      name: 'Al Sewar Jeddah Corniche [Preview]',
      code: 'JED01',
      address: 'Corniche Road, Ash Shati',
      city: 'Jeddah',
      phone: '+966 55 987 6543',
      email: 'corniche.preview@alsewar.com',
      latitude: 21.5433,
      longitude: 39.1728,
      isActive: true,
    ),
    Branch(
      id: 3,
      name: 'Al Sewar Dammam Express [Preview]',
      code: 'DMM01',
      address: 'Prince Mohammad Bin Fahd Road',
      city: 'Dammam',
      phone: '+966 53 111 2233',
      email: 'dammam.preview@alsewar.com',
      latitude: 26.4207,
      longitude: 50.0888,
      isActive: true,
    ),
  ];

  static Branch getBranchById(int id) {
    return sampleBranches.firstWhere(
      (b) => b.id == id,
      orElse: () => sampleBranches.first,
    );
  }

  // ─── 6. Sample Business Hours ────────────────────────────────────────────
  static const List<BusinessHour> sampleBusinessHours = [
    BusinessHour(
      id: 1,
      dayOfWeek: 1,
      dayName: 'Monday',
      openingTime: '08:00',
      closingTime: '22:00',
      isClosed: false,
    ),
    BusinessHour(
      id: 2,
      dayOfWeek: 2,
      dayName: 'Tuesday',
      openingTime: '08:00',
      closingTime: '22:00',
      isClosed: false,
    ),
    BusinessHour(
      id: 3,
      dayOfWeek: 3,
      dayName: 'Wednesday',
      openingTime: '08:00',
      closingTime: '22:00',
      isClosed: false,
    ),
    BusinessHour(
      id: 4,
      dayOfWeek: 4,
      dayName: 'Thursday',
      openingTime: '08:00',
      closingTime: '22:00',
      isClosed: false,
    ),
    BusinessHour(
      id: 5,
      dayOfWeek: 5,
      dayName: 'Friday',
      openingTime: '13:00',
      closingTime: '22:00',
      isClosed: false,
    ),
    BusinessHour(
      id: 6,
      dayOfWeek: 6,
      dayName: 'Saturday',
      openingTime: '08:00',
      closingTime: '22:00',
      isClosed: false,
    ),
    BusinessHour(
      id: 7,
      dayOfWeek: 7,
      dayName: 'Sunday',
      openingTime: '08:00',
      closingTime: '22:00',
      isClosed: false,
    ),
  ];

  // ─── 7. Sample Customer Reviews ──────────────────────────────────────────
  static const List<CustomerReview> sampleReviews = [
    CustomerReview(
      id: 1,
      visitId: 201,
      visitDetails: {'visit_number': 'PRV-VISIT-2026-001'},
      branchDetails: {'name': 'Al Sewar Riyadh Olaya [Preview]'},
      rating: 5,
      comment: 'Flawless ceramic coat and mirror finish on my S-Class! Excellent attention to detail. [PREVIEW]',
      isApproved: true,
      createdAt: '2026-10-14T14:00:00Z',
    ),
    CustomerReview(
      id: 2,
      visitId: 202,
      visitDetails: {'visit_number': 'PRV-VISIT-2026-002'},
      branchDetails: {'name': 'Al Sewar Jeddah Corniche [Preview]'},
      rating: 5,
      comment: 'Interior ozone treatment removed all odors. Showroom fresh feel. [PREVIEW]',
      isApproved: true,
      createdAt: '2026-09-28T16:00:00Z',
    ),
  ];
}
