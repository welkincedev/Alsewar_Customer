# Al Sewar Auto Center — Customer App Documentation & Progress Report

**Project:** Al Sewar Carwash (Customer Mobile Application)  
**Platform:** Flutter (Android & iOS)  
**Architecture:** Feature-first MVVM + Riverpod (`AsyncNotifier`)  
**Report Date:** October 13, 2026 (Covers work completed through yesterday, October 12, 2026)

---

## 1. Executive Summary

The **Al Sewar Carwash Customer App** is a customer-facing mobile application integrated with the Al Sewar Django REST Framework backend. Up through yesterday (**October 12, 2026**), all core customer modules documented in the backend API specification have been built, connected to their respective API services, and integrated into the **Al Sewar Auto Center** Home Dashboard and Bottom Navigation shell.

---

## 2. Work Completed Till Yesterday (Chronological Breakdown)

### Phase 1: Project Foundation & Customer Authentication
* **Core Setup & Theme (`lib/app/theme/`, `lib/core/`):**
  * Configured Material 3 theme using the Al Sewar Black (`#000000`) & Metallic Gold (`#D4AF37`) brand identity (`app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`).
  * Built `ApiClient` (`lib/core/network/api_client.dart`) using **Dio** with configurable base URLs and timeouts.
  * Built `TokenStorage` (`lib/core/storage/token_storage.dart`) using `flutter_secure_storage` for encrypted JWT access & refresh token persistence.
* **Authentication Flow (`lib/features/auth/`):**
  * **Models:** `AuthUser` (with `is_active` and `CUSTOMER` role enforcement), `LoginRequest`, `LoginResponse`, `SignupRequest`.
  * **Service (`AuthService`):** Connected `POST /api/customer/signup/`, `POST /api/customer/login/`, `GET /api/customer/me/`, `POST /api/auth/token/refresh/`, and `POST /api/auth/logout/`.
  * **Session Restoration (`AuthViewModel`):** Automatic session validation on startup via `SplashScreen`, with silent token refresh fallback and role/active-status security checks.
  * **UI Screens:** `SplashScreen`, `CustomerLoginScreen`, `CustomerSignupScreen`, `LoginForm`, and `SignupForm` with field-level DRF error parsing.

---

### Phase 2: Customer Branches Module
* **Branch Discovery & Operating Hours (`lib/features/branches/`):**
  * **Models:** `Branch` (with coordinates and `fullAddress` helper) and `BusinessHour` (with 24h-to-12h AM/PM formatting and closed-day indicators).
  * **Service (`BranchService`):** Connected `GET /api/customer/branches/`, `GET /api/customer/branches/{id}/`, and `GET /api/customer/branches/{id}/hours/`.
  * **State Management:** `BranchListViewModel` (`AsyncNotifier`), `branchDetailProvider`, and `branchHoursProvider`.
  * **Screens:** `BranchListScreen` (pull-to-refresh, active branch filtering) and `BranchDetailScreen` (contact card, location info, weekly operating schedule).

---

### Phase 3: Full Customer API Expansion & New Modules (Completed Yesterday — Oct 12, 2026)

1. **Centralized Dual-Port / LAN API Configuration (`lib/core/constants/api_constants.dart`):**
   * Added support for Auth port (`8000`) and Feature/LAN port (`8001` at `http://192.168.1.2:8001` or `http://10.0.2.2`).
   * Registered all customer endpoints for Vehicles, Services, Service Visits, and Reviews.

2. **Customer Vehicles Self-Service Module (`lib/features/vehicles/`):**
   * **Models:** `Vehicle` and `VehicleRequest`.
   * **Service (`VehicleService`):**
     * `GET /api/customer/vehicles/` — List own registered vehicles.
     * `POST /api/customer/vehicles/` — Register a new vehicle.
     * `PATCH /api/customer/vehicles/{id}/` — Update vehicle details.
     * `DELETE /api/customer/vehicles/{id}/` — Delete a vehicle.
   * **UI (`VehiclesScreen`):** Displays registered vehicles, modal bottom sheet to register a new vehicle, and confirmation dialog to remove a vehicle.

3. **Service Catalogue & Branch Services Module (`lib/features/services/`):**
   * **Model:** `ServiceItem`.
   * **Service (`ServiceCatalogueService`):**
     * `GET /api/customer/services/` — Browse active global services (with optional search).
     * `GET /api/customer/branches/{branchId}/services/` — List services available at a specific branch.
   * **UI (`ServicesScreen`):** Displays all active carwash, detailing, and maintenance services with retry and empty states.

4. **Service Visits & Live Status Tracking Module (`lib/features/visits/`):**
   * **Models:** `ServiceVisit`, `VisitStage`, `VisitServiceEntry`, and `VisitStatusHistory`.
   * **Service (`VisitApiService`):**
     * `GET /api/customer/visits/` — List customer's active and past visits.
     * `GET /api/customer/visits/{id}/` — Fetch detailed visit status and milestone audit history.
   * **UI (`VisitsScreen` & `VisitDetailScreen`):**
     * Shows visit number (`SV-...`), current stage badge (`Received`, `In Progress`, `Completed`, etc.), vehicle plate/model, performed services, and a vertical chronological **Status Timeline**.

5. **Customer Reviews Module (`lib/features/reviews/`):**
   * **Models:** `CustomerReview` and `ReviewRequest`.
   * **Service (`ReviewService`):**
     * `GET /api/customer/reviews/` — Fetch all reviews submitted by the customer.
     * `POST /api/customer/reviews/` — Submit a 1–5 star rating and comment for a completed visit.
   * **UI (`ReviewsScreen`):** Displays star ratings, visit references, branch names, and written feedback.

6. **Al Sewar Auto Center Home UI & Bottom Navigation (`lib/features/home/screens/customer_home_screen.dart`):**
   * Built `CustomerMainShell` with a 4-tab `BottomNavigationBar`: **Home**, **Services**, **Reviews**, and **Profile**.
   * **Home Tab Sections:**
     * **Top Bar:** Al Sewar logo, title, location button, and notification bell with badge.
     * **Search Bar:** Search input with dark/gold filter button.
     * **Loyalty Card:** Dark container with `"GOLD MEMBER"` badge, `"AVAILABLE BALANCE"`, `"2,450 Coins"` display, and `"Explore rewards ->"` footer.
     * **Offers for You:** Horizontal promotional carousel (`EXCLUSIVE`, `NEW`, `SPECIAL` badges).
     * **Your Service (Live Active Visit Card):** Connected to `GET /api/customer/visits/` to display the customer's active in-progress vehicle visit and link directly to `VisitDetailScreen`.
     * **Our Services (Category Grid):** Dynamically populated from `GET /api/customer/services/` with a `"More"` shortcut to the full catalogue.
     * **Service Centers (Horizontal List):** Dynamically populated from `GET /api/customer/branches/` with `"Get Directions"` cards linking to `BranchDetailScreen`.
   * **Profile Tab:** Displays customer profile details (`GET /api/customer/me/`) and quick navigation links to **My Vehicles**, **Service History**, **My Reviews**, **Service Centers**, and **Sign Out**.

---

## 3. Current Project Status (As of Today — Oct 13, 2026)

### Module & API Integration Matrix

| Module | Feature Folder | Backend Endpoint(s) | UI Screen(s) | Status |
|---|---|---|---|---|
| **Authentication & Session** | `lib/features/auth/` | `POST /api/customer/login/`<br>`POST /api/customer/signup/`<br>`GET /api/customer/me/`<br>`POST /api/auth/token/refresh/`<br>`POST /api/auth/logout/` | `SplashScreen`<br>`CustomerLoginScreen`<br>`CustomerSignupScreen` | ✅ **Completed & Tested** |
| **Home Dashboard & Nav** | `lib/features/home/` | Aggregates `/me/`, `/visits/`, `/services/`, `/branches/` | `CustomerMainShell` (4 tabs) | ✅ **Completed** |
| **Branches / Centers** | `lib/features/branches/` | `GET /api/customer/branches/`<br>`GET /api/customer/branches/{id}/`<br>`GET /api/customer/branches/{id}/hours/` | `BranchListScreen`<br>`BranchDetailScreen` | ✅ **Completed & Tested** |
| **Customer Vehicles** | `lib/features/vehicles/` | `GET /api/customer/vehicles/`<br>`POST /api/customer/vehicles/`<br>`PATCH /api/customer/vehicles/{id}/`<br>`DELETE /api/customer/vehicles/{id}/` | `VehiclesScreen` (+ Add Vehicle Bottom Sheet) | ✅ **Completed** |
| **Service Catalogue** | `lib/features/services/` | `GET /api/customer/services/`<br>`GET /api/customer/branches/{id}/services/` | `ServicesScreen` | ✅ **Completed** |
| **Visits & Live Tracking** | `lib/features/visits/` | `GET /api/customer/visits/`<br>`GET /api/customer/visits/{id}/` | `VisitsScreen`<br>`VisitDetailScreen` | ✅ **Completed** |
| **Customer Reviews** | `lib/features/reviews/` | `GET /api/customer/reviews/`<br>`POST /api/customer/reviews/` | `ReviewsScreen` | ✅ **Completed** |

---

### Code Quality & Verification Status

* **Static Analysis (`flutter analyze`):** ✅ **0 errors, 0 warnings**
* **Code Formatting (`dart format .`):** ✅ **Formatted across all 51 files**
* **Automated Tests (`flutter test`):** ✅ **26 / 26 tests passing**
  * Unit tests for `AuthUser`, `SignupRequest`, `AuthService`, `AuthViewModel`, `Branch`, `BusinessHour`, and `BranchService`.
  * Widget tests for `SignupForm` and `BranchListScreen` / `BranchDetailScreen`.

---

### What Remains / Next Steps

1. **Interactive Review Submission UI on Completed Visits:**
   * `ReviewService.submitReview()` (`POST /api/customer/reviews/`) is implemented in the service and viewmodel layers. Adding a *"Write a Review"* button/modal directly inside `VisitDetailScreen` when `visit.isCompleted == true` will let customers submit reviews straight from a completed visit.
2. **Search & Filter Wiring on Home Screen:**
   * Connect the Home Screen search text field to filter `ServicesScreen` (`?search=`) or `BranchListScreen`.
3. **Loyalty Coins & Rewards Backend Endpoint (Deferred by Backend):**
   * Per backend documentation (Section 11.1), loyalty points/redemption APIs are currently deferred on the backend. The Loyalty Card UI is in place and ready to bind once the backend exposes a loyalty endpoint.
4. **Unit & Widget Tests for New Modules:**
   * Add unit and widget test files for `VehicleService`, `VisitApiService`, `ServiceCatalogueService`, and `ReviewService`.
