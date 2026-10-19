# Al Sewar Carwash — Customer Mobile App

A Flutter mobile application for the **Al Sewar Carwash** customer loyalty platform. Customers can log in, register, view nearby carwash branches, track service history, manage vehicles, and redeem loyalty rewards.

This is the **customer-facing app only**. The backend is a separate Django REST Framework project.

---

## Table of Contents

1. [Tech Stack](#tech-stack)
2. [Architecture Overview](#architecture-overview)
3. [Project Folder Structure](#project-folder-structure)
4. [Core Layer](#core-layer)
5. [App Layer (Theme & Navigation)](#app-layer-theme--navigation)
6. [Feature: Authentication](#feature-authentication)
7. [Feature: Branches](#feature-branches)
8. [Feature: Home Dashboard](#feature-home-dashboard)
9. [Upcoming Features](#upcoming-features)
10. [API Configuration & Backend Ports](#api-configuration--backend-ports)
11. [Running the App](#running-the-app)
12. [Test Suite](#test-suite)

---

## Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter 3.47.6** | Mobile UI framework |
| **Dart 3.13.5** | Programming language |
| **Riverpod 3.x** (`flutter_riverpod`) | State management via `AsyncNotifier` |
| **Dio 5.x** | HTTP client for API requests |
| **flutter_secure_storage 9.x** | Encrypted JWT token storage |
| **Material 3** | UI component system |

---

## Architecture Overview

The app follows **MVVM (Model-View-ViewModel)** using Riverpod for state management. Each feature is self-contained and communicates through well-defined layers:

```
┌─────────────────────────────────────────────────────────┐
│  UI Layer (Screens & Widgets)                           │
│  Shows data, handles inputs, reads ViewModel state      │
└─────────────────────┬───────────────────────────────────┘
                      │ watches / reads providers
┌─────────────────────▼───────────────────────────────────┐
│  ViewModel Layer (Riverpod AsyncNotifier)               │
│  Manages state, orchestrates workflows                  │
└─────────────────────┬───────────────────────────────────┘
                      │ calls methods
┌─────────────────────▼───────────────────────────────────┐
│  Service Layer                                          │
│  Makes API calls via Dio, parses responses              │
└─────────────────────┬───────────────────────────────────┘
                      │ returns / throws
┌─────────────────────▼───────────────────────────────────┐
│  Model Layer                                            │
│  Immutable data classes with fromJson / toJson          │
└─────────────────────────────────────────────────────────┘
```

**Rules:**
- Screens never call Dio or APIs directly.
- ViewModels never contain widget/UI code.
- Services never touch Riverpod state.
- Models are pure data classes.

---

## Project Folder Structure

```
carwashapp/
├── lib/
│   ├── main.dart                       # App entry point
│   ├── app/
│   │   ├── app.dart                    # Root MaterialApp + auth-based navigation
│   │   ├── screens/
│   │   │   └── splashscreen.dart       # Loading screen shown at startup
│   │   └── theme/
│   │       ├── app_colors.dart         # Brand color palette & gradients
│   │       ├── app_text_styles.dart    # Typography tokens
│   │       └── app_theme.dart          # Material 3 ThemeData
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart      # API base URLs, ports, endpoint paths
│   │   ├── network/
│   │   │   └── api_client.dart         # Dio HTTP client factory
│   │   └── storage/
│   │       └── token_storage.dart      # flutter_secure_storage JWT wrapper
│   └── features/
│       ├── auth/                       # Authentication feature
│       ├── branches/                   # Branch listing & details feature
│       ├── home/                       # Customer home dashboard
│       ├── profile/                    # (Planned) Customer profile
│       └── vehicles/                   # (Planned) Vehicle management
└── test/
    ├── widget_test.dart                # App smoke test
    ├── unit/                           # Unit tests
    └── widget/                         # Widget tests
```

---

## Core Layer

### `lib/core/constants/api_constants.dart`

The **single source of truth** for all URLs and endpoint strings.

```
Key Constants
─────────────────────────────────────────────────

baseUrl         baseUrl = `http://127.0.0.1:8001`
```

**Auth Endpoints**

| Constant | Path |
|---|---|
| `customerSignup` | `POST /api/customer/signup/` |
| `customerLogin` | `POST /api/customer/login/` |
| `tokenRefresh` | `POST /api/auth/token/refresh/` |
| `customerMe` | `GET /api/customer/me/` |
| `logout` | `POST /api/auth/logout/` |

**Branch Endpoints**

| Constant / Helper | Path |
|---|---|
| `customerBranches` | `GET /api/customer/branches/` |
| `customerBranchDetail(id)` | `GET /api/customer/branches/{id}/` |
| `customerBranchHours(id)` | `GET /api/customer/branches/{id}/hours/` |

> **Changing environments:** Edit only `host`, `authPort`, and `branchPort` in this file. No other file needs to change.

---

### `lib/core/network/api_client.dart`

A thin wrapper around **Dio** that applies the base URL, timeouts, and default JSON headers.

```dart
// Auth client (default — port 8000)
ApiClient()

// Branch client (port 8001)
ApiClient(baseUrl: ApiConstants.branchBaseUrl)

// Custom Dio for testing
ApiClient(customDio: mockDio)
```

---

### `lib/core/storage/token_storage.dart`

Wraps `flutter_secure_storage` with named methods for safe JWT token management.

| Method | What it does |
|---|---|
| `saveTokens(access, refresh)` | Writes both tokens after login |
| `getAccessToken()` | Reads the stored access token |
| `getRefreshToken()` | Reads the stored refresh token |
| `updateAccessToken(access, refresh?)` | Replaces access token; updates refresh if provided |
| `clearTokens()` | Deletes both tokens on logout |
| `hasAccessToken()` | Returns `true` if an access token exists |

> Tokens are **never** stored in SharedPreferences or hardcoded anywhere.

---

## App Layer (Theme & Navigation)

### `lib/app/app.dart` — Root App Widget

`CarWashApp` is a `ConsumerWidget` that watches `authViewModelProvider`. It switches between screens reactively based on authentication state:

```
AsyncLoading  →  SplashScreen
Authenticated →  CustomerHomeScreen
Unauthenticated / Error  →  CustomerLoginScreen
```

This means there is **no manual navigation to handle logout** — clearing auth state automatically takes the user back to the login screen.

---

### `lib/app/screens/splashscreen.dart`

Displayed while the app checks for a saved session. Shows the Al Sewar logo, app name, and a loading indicator over the gold radial gradient.

**Session Restoration Flow:**
1. App starts → `SplashScreen` appears.
2. `AuthViewModel.build()` runs `restoreSession()`.
3. If a valid access token exists → calls `/api/customer/me/` to verify it.
4. If expired → attempts `/api/auth/token/refresh/` with the stored refresh token.
5. If refresh succeeds → updates tokens and proceeds authenticated.
6. If all fails → clears tokens and navigates to login.

---

### `lib/app/theme/` — Brand Design System

| File | Purpose |
|---|---|
| `app_colors.dart` | Brand palette (Black `#000000`, Gold `#D4AF37`), gradients, semantic colors |
| `app_text_styles.dart` | Typography tokens (`display`, `heading`, `title`, `bodyPrimary`, `bodySecondary`, `button`, `caption`) |
| `app_theme.dart` | Material 3 `ThemeData` wiring all tokens into Flutter's component system |

**Brand Colors:**

| Name | Color | Usage |
|---|---|---|
| `primaryBlack` | `#000000` | AppBar, buttons, primary text |
| `secondaryGold` | `#D4AF37` | Accents, icons, avatars |
| `backgroundLight` | `#FFFFFF` | Screen backgrounds |
| `surfaceLight` | `#F8F9FA` | Card fills |
| `error` | `#DC3545` | Error messages, closed day indicators |
| `success` | `#198754` | Success SnackBars |

---

## Feature: Authentication

**Location:** `lib/features/auth/`

Handles customer registration, login, session management, token refresh, and logout.

---

### Models

#### `models/auth_user.dart` — Customer Profile

Represents the authenticated customer returned by the backend.

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Customer database ID |
| `username` | `String` | Login username |
| `email` | `String` | Email address |
| `role` | `String` | Must be `"CUSTOMER"` to authenticate |
| `phone` | `String?` | Optional, nullable |
| `firstName` | `String` | May be empty |
| `lastName` | `String` | May be empty |
| `isActive` | `bool` | Inactive accounts are rejected |

**Helper getter:** `displayName` → returns `"First Last"` or falls back to `username`.

---

#### `models/login_request.dart` — Login Payload

Simple model wrapping `username` and `password` into JSON for `POST /api/customer/login/`.

---

#### `models/login_response.dart` — Login API Response

Parses the successful login response:

```json
{
  "access": "<JWT access token>",
  "refresh": "<JWT refresh token>",
  "user": { ...AuthUser fields... }
}
```

---

#### `models/signup_request.dart` — Registration Payload

Builds the JSON body for `POST /api/customer/signup/`.

- Includes `username`, `email`, `password`.
- Optionally includes `phone`, `first_name`, `last_name` (only if non-empty).
- **Never sends** `role` or `confirm_password` — role is assigned by the backend automatically.

---

### Service

#### `services/auth_service.dart`

All HTTP calls for authentication. Each method uses the shared `ApiClient` (port 8000).

| Method | Endpoint | Notes |
|---|---|---|
| `signup(request)` | `POST /api/customer/signup/` | Returns `AuthUser`, no tokens |
| `login(request)` | `POST /api/customer/login/` | Returns `LoginResponse` with tokens |
| `refreshToken(refresh)` | `POST /api/auth/token/refresh/` | Returns new access + rotated refresh token |
| `getCurrentCustomer(token)` | `GET /api/customer/me/` | Returns `AuthUser` using Bearer header |
| `logout(access, refresh)` | `POST /api/auth/logout/` | Errors are silently swallowed |

**Error handling:** The private `_handleDioError()` method maps Dio exception types to user-readable messages. DRF field validation errors (e.g. `{"username": ["Already exists."]}`) are parsed and formatted as `"Username: Already exists."`.

---

### ViewModels & Providers

#### `viewmodels/auth_state.dart` — Auth State Object

Immutable state class with three statuses:

```
AuthStatus.initial        → App is starting / checking session
AuthStatus.authenticated  → Valid customer is logged in
AuthStatus.unauthenticated → Not logged in (includes error messages)
```

Convenience getters: `isAuthenticated`, `isUnauthenticated`, `isInitial`.

---

#### `viewmodels/auth_providers.dart` — Riverpod Providers

| Provider | Type | What it provides |
|---|---|---|
| `tokenStorageProvider` | `Provider<TokenStorage>` | Shared token storage instance |
| `apiClientProvider` | `Provider<ApiClient>` | Shared auth Dio client |
| `authServiceProvider` | `Provider<AuthService>` | AuthService using the auth client |

---

#### `viewmodels/auth_viewmodel.dart` — Auth Logic

`AuthViewModel extends AsyncNotifier<AuthState>`

| Method | What it does |
|---|---|
| `build()` | Runs `restoreSession()` on startup |
| `restoreSession()` | Validates stored token; refreshes if expired; clears if invalid |
| `login(username, password)` | Authenticates; checks `CUSTOMER` role and `isActive`; saves tokens |
| `signup(request)` | Registers via service; does not log in automatically |
| `logout()` | Calls logout API; always clears local tokens |

**Security checks in `login()`:**
1. `user.isActive == false` → rejected with "Account is inactive."
2. `user.role != "CUSTOMER"` → rejected with "Access restricted to customer accounts only."
3. Both checks happen **before** storing tokens.

---

### Screens & Widgets

#### `screens/customer_login_screen.dart`

Clean login screen with Al Sewar logo, heading, and `LoginForm`. Compact white card on light background.

#### `screens/customer_signup_screen.dart`

Registration screen with logo, subtitle, and `SignupForm`. Navigates back to login on success, passing a success SnackBar message.

#### `widgets/login_form.dart`

Stateful form widget. Responsibilities:
- Username and password inputs with validation.
- Password show/hide toggle.
- Calls `authViewModelProvider.notifier.login()` on submit.
- Shows error banner if `authState.value?.errorMessage` is non-null.
- Shows loading spinner inside the Sign In button.
- "Don't have an account? Sign Up" link that pushes `CustomerSignupScreen` and shows a SnackBar on return.

#### `widgets/signup_form.dart`

Stateful form widget. Responsibilities:
- First name, last name, username, email, phone (optional), password, confirm password fields.
- Client-side validation: email regex, username ≥ 3 chars, password ≥ 6 chars, passwords match.
- Does **not** send `confirm_password` to the API.
- Calls `authViewModelProvider.notifier.signup()`.
- Formats and displays DRF field errors returned from the backend.

---

## Feature: Branches

**Location:** `lib/features/branches/`

Allows authenticated customers to browse active carwash locations, view contact details, and check weekly operating hours.

---

### Models

#### `models/branch.dart` — Branch Location

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Branch database ID |
| `name` | `String` | Display name |
| `code` | `String` | Short branch code (e.g. `"BR001"`) |
| `address` | `String` | Street address |
| `city` | `String` | City name |
| `phone` | `String` | Contact phone number |
| `email` | `String` | Contact email |
| `latitude` | `double?` | GPS latitude, nullable |
| `longitude` | `double?` | GPS longitude, nullable |
| `isActive` | `bool` | Inactive branches are filtered out in the service |

**Helper getter:** `fullAddress` → returns `"address, city"` (avoids duplicate city if already in address).

---

#### `models/business_hour.dart` — Weekly Opening Hours

| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Record ID |
| `dayOfWeek` | `int` | `1` = Monday … `7` = Sunday |
| `dayName` | `String` | Human-readable name (e.g. `"Friday"`) |
| `openingTime` | `String?` | 24h time string (e.g. `"08:30:00"`), nullable |
| `closingTime` | `String?` | 24h time string, nullable |
| `isClosed` | `bool` | `true` means closed that day |

**Helper getter:** `formattedHours`

| Scenario | Output |
|---|---|
| Normal day | `"8:30 AM - 9:00 PM"` |
| Noon / Midnight | `"12:00 PM - 12:00 AM"` |
| Closed or null times | `"Closed"` |

Hours list is **sorted by `dayOfWeek`** in the service before being returned.

---

### Service

#### `services/branch_service.dart`

Uses a **separate `ApiClient` pointing to port 8001** (Branch API). The Bearer token is read from `TokenStorage` on every request.

| Method | Endpoint | Notes |
|---|---|---|
| `getBranches()` | `GET /api/customer/branches/` | Filters `isActive == true` before returning |
| `getBranchById(id)` | `GET /api/customer/branches/{id}/` | Returns single `Branch` |
| `getBranchHours(id)` | `GET /api/customer/branches/{id}/hours/` | Sorted by `dayOfWeek` |

**Error responses handled:**

| HTTP Code | Error Message |
|---|---|
| `401` | "Session expired. Please log in again to view …" |
| `403` | "Access forbidden. Customer permissions required." |
| `404` | "The requested … could not be found." |
| Timeout | "Connection timed out … check your network." |

---

### ViewModels & Providers

#### `viewmodels/branch_providers.dart`

| Provider | Type | What it provides |
|---|---|---|
| `branchApiClientProvider` | `Provider<ApiClient>` | Dio client targeting port 8001 |
| `branchServiceProvider` | `Provider<BranchService>` | BranchService with branch client + token storage |
| `branchDetailProvider(id)` | `FutureProvider.family<Branch, int>` | Loads single branch by ID |
| `branchHoursProvider(id)` | `FutureProvider.family<List<BusinessHour>, int>` | Loads operating hours by branch ID |

---

#### `viewmodels/branch_viewmodel.dart`

`BranchListViewModel extends AsyncNotifier<List<Branch>>`

| Method | What it does |
|---|---|
| `build()` | Fetches branch list on first use |
| `refresh()` | Re-fetches branches (used by pull-to-refresh) |

---

### Screens

#### `screens/branch_list_screen.dart`

Displays a scrollable list of active carwash branches.

**States handled:**

| State | UI |
|---|---|
| Loading | Gold `CircularProgressIndicator` |
| Data (branches found) | `ListView` of `_BranchCard` widgets |
| Data (empty) | Illustration, message, Refresh button |
| Error | Error icon, message, Try Again button |

**Features:**
- Pull-to-refresh (`RefreshIndicator`).
- Each card shows branch name, code badge, address, and phone.
- Tapping a card navigates to `BranchDetailScreen`.

---

#### `screens/branch_detail_screen.dart`

Displays full details for a single branch and its weekly hours.

**Section 1 — Header Card (gold gradient):** Branch name and code.

**Section 2 — Contact & Location Card:**

| Field | Icon |
|---|---|
| City | `Icons.location_city_outlined` |
| Address | `Icons.map_outlined` |
| Phone | `Icons.phone_outlined` |
| Email | `Icons.email_outlined` |
| GPS Coordinates | `Icons.my_location_outlined` (only if available) |

**Section 3 — Weekly Operating Hours:**
- Each day shown as a row: Day Name ↔ Hours Badge.
- Open days → gold-tinted badge with black text.
- Closed days → red-tinted badge with `"Closed"` text.
- Both sections load independently with their own loading/error states.

---

## Feature: Home Dashboard

**Location:** `lib/features/home/screens/customer_home_screen.dart`

The first screen customers see after logging in.

**Sections:**

1. **Welcome Card** — Shows customer avatar initial, display name, and account info.
2. **Our Branches tile** — Tappable card linking to `BranchListScreen`.
3. **Loyalty Platform placeholder** — Reserved area for future modules (points, rewards, vehicle history).

The home screen uses `SingleChildScrollView` to be responsive across all screen sizes.

---

## Upcoming Features

The following features are **structurally planned** (folders exist) but not yet implemented — they will be connected once the backend endpoints are finalized.

| Feature | Location | Status |
|---|---|---|
| Customer Profile | `features/profile/` | 📋 Planned |
| Vehicles | `features/vehicles/` | 📋 Planned |
| Loyalty Points | `features/home/models/` | 📋 Planned |
| Service History | (to be created) | 📋 Planned |
| Reviews | (to be created) | 📋 Planned |
| Notifications | (to be created) | 📋 Planned |

> No fake data or placeholder API calls exist for these features. They will be implemented with real backend endpoints only.

---

## API Configuration & Backend Ports

The backend runs as two Django services on different ports:

| Service | Port | Configured In |
|---|---|---|
| Auth & Customer API | `8000` | `ApiConstants.authBaseUrl` |
| Branch API | `8001` | `ApiConstants.branchBaseUrl` |

### Switching Environments

Edit only `lib/core/constants/api_constants.dart`:

```dart
// Android Emulator
static const String host = 'http://10.0.2.2';

// iOS Simulator or browser
static const String host = 'http://127.0.0.1';

// Physical device (use your computer's LAN IP)
static const String host = 'http://192.168.x.x';

// Production
static const String host = 'https://api.alsewarcarwash.com';
```

### Android HTTP (Development Only)

For Android emulator HTTP traffic, `res/xml/network_security_config.xml` should allow cleartext for the emulator host. In production always use HTTPS.

---

## Running the App

### Prerequisites

- Flutter SDK `3.47.6` or later
- Dart `3.13.5` or later
- Android emulator or physical device
- Django backend running on ports `8000` (auth) and `8001` (branches)

### Steps

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app (Android emulator)
flutter run

# 3. To run on a physical device, update the host in api_constants.dart first
```

---

## Test Suite

All tests live in `test/`. Run the full suite with:

```bash
dart format .          # Format all files
flutter analyze        # Static analysis (must report 0 issues)
flutter test           # Run all tests
```

### Test Files

#### Unit Tests — `test/unit/`

| File | Tests |
|---|---|
| `auth_user_test.dart` | `AuthUser` JSON parsing, nullable fields, `isActive` |
| `auth_service_test.dart` | Login, signup, token refresh using mock Dio adapter |
| `auth_viewmodel_test.dart` | Role validation, inactive account rejection, logout, token saving |
| `signup_request_test.dart` | Payload serialization, optional field omission, no `role` or `confirm_password` |
| `branch_model_test.dart` | `Branch` JSON parsing, nullable coordinates, serialization |
| `business_hour_model_test.dart` | 12h time formatting, noon/midnight edge cases, closed day detection |
| `branch_service_test.dart` | Bearer header attachment, active branch filtering, 401/404 error messages |

#### Widget Tests — `test/widget/`

| File | Tests |
|---|---|
| `signup_form_test.dart` | Required field validation, error message display |
| `branch_screens_test.dart` | `BranchListScreen` card rendering, `BranchDetailScreen` hours display |

#### Smoke Test — `test/widget_test.dart`

Verifies `CarWashApp` mounts correctly inside `ProviderScope`.

### Current Test Results

```
✅  26 tests passed
✅  0 errors
✅  0 warnings (flutter analyze)
```

---

## Dependency Reference

| Package | Version | Purpose |
|---|---|---|
| `flutter_riverpod` | `^3.4.3` | State management |
| `dio` | `^5.4.3` | HTTP client |
| `flutter_secure_storage` | `^9.0.0` | Encrypted JWT storage |
| `cupertino_icons` | `^1.0.8` | iOS-style icons |
| `flutter_lints` | `^6.0.0` | Lint rules (dev) |

---

*This documentation reflects the state of the app as of October 2026.*
