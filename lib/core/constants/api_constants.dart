class ApiConstants {
  // ─────────────────────────────────────────────────────────────
  // HOST & BASE URL CONFIGURATION
  // ─────────────────────────────────────────────────────────────
  // Android Emulator        : 'http://10.0.2.2:8001'
  // iOS Simulator/Localhost : 'http://127.0.0.1:8001'
  // LAN / Physical Device   : 'http://192.168.1.3:8001'
  // Production              : 'https://api.alsewarcarwash.com'
  static const String baseUrl = 'http://192.168.1.6:8001';

  // ─── AUTHENTICATION ENDPOINTS (port 8001) ───────────────────
  static const String customerSignup = '/api/customer/signup/';
  static const String customerLogin = '/api/customer/login/';
  static const String tokenRefresh = '/api/auth/token/refresh/';
  static const String customerMe = '/api/customer/me/';
  static const String logout = '/api/auth/logout/';

  // ─── BRANCH ENDPOINTS (port 8001) ───────────────────────────
  static const String customerBranches = '/api/customer/branches/';
  static String customerBranchDetail(int id) => '/api/customer/branches/$id/';
  static String customerBranchHours(int id) =>
      '/api/customer/branches/$id/hours/';
  static String customerBranchServices(int branchId) =>
      '/api/customer/branches/$branchId/services/';

  // ─── VEHICLE ENDPOINTS (port 8001) ──────────────────────────
  static const String customerVehicles = '/api/customer/vehicles/';
  static String customerVehicleDetail(int id) => '/api/customer/vehicles/$id/';

  // ─── SERVICE CATALOGUE ENDPOINTS (port 8001) ────────────────
  static const String customerServices = '/api/customer/services/';

  // ─── SERVICE VISITS ENDPOINTS (port 8001) ───────────────────
  static const String customerVisits = '/api/customer/visits/';
  static String customerVisitDetail(int id) => '/api/customer/visits/$id/';

  // ─── REVIEW ENDPOINTS (port 8001) ──────────────────────────
  static const String customerReviews = '/api/customer/reviews/';
  static String customerReviewDetail(int id) => '/api/customer/reviews/$id/';

  // ─── SUPPORT & CONTACT CONFIGURATION ───────────────────────
  /// Configurable WhatsApp support number (International format, e.g. '+966500000000').
  /// Leave empty if pending official configuration from Al Sewar administration.
  static const String whatsappSupportNumber = '';
  static const String supportPhone = '+966 50 000 0000';
  static const String supportEmail = 'support@alsewarcarwash.com';

  // ─── TIMEOUTS ──────────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
