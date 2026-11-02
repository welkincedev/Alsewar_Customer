import 'dart:typed_data';

import 'package:carwashapp/core/storage/token_storage.dart';
import 'package:carwashapp/core/widgets/app_snack_bar.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';
import 'package:carwashapp/features/auth/models/login_request.dart';
import 'package:carwashapp/features/auth/models/login_response.dart';
import 'package:carwashapp/features/auth/models/signup_request.dart';
import 'package:carwashapp/features/auth/services/auth_service.dart';
import 'package:carwashapp/features/auth/viewmodels/auth_providers.dart';
import 'package:carwashapp/features/profile/screens/edit_profile_screen.dart';
import 'package:carwashapp/features/profile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class _FakeTokenStorage implements TokenStorage {
  String? token = 'mock_jwt_token';
  @override
  Future<void> clearTokens() async => token = null;
  @override
  Future<String?> getAccessToken() async => token;
  @override
  Future<String?> getRefreshToken() async => 'mock_refresh';
  @override
  Future<bool> hasAccessToken() async => token != null;
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    token = accessToken;
  }

  @override
  Future<void> updateAccessToken({
    required String accessToken,
    String? newRefreshToken,
  }) async {
    token = accessToken;
  }
}

class _FakeAuthService implements AuthService {
  AuthUser mockUser;
  bool shouldThrowError = false;
  String errorMessage = 'Email: A user with this email already exists.';
  bool shouldThrowOnRefresh = false;
  int getCurrentCustomerCallCount = 0;
  List<int>? lastUploadedBytes;
  String? lastUploadedFilename;

  _FakeAuthService({required this.mockUser});

  @override
  Future<AuthUser> getCurrentCustomer(String accessToken) async {
    getCurrentCustomerCallCount++;
    if (shouldThrowOnRefresh) {
      throw Exception('Connection timed out while refreshing profile');
    }
    return mockUser;
  }

  @override
  Future<LoginResponse> login(LoginRequest request) async =>
      throw UnimplementedError();

  @override
  Future<AuthUser> signup(SignupRequest request) async =>
      throw UnimplementedError();

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async => {};

  @override
  Future<void> logout({
    required String accessToken,
    required String refreshToken,
  }) async {}

  @override
  Future<AuthUser> updateProfile({
    required String accessToken,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    List<int>? profilePictureBytes,
    String? profilePictureFilename,
    String? profilePicturePath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    lastUploadedBytes = profilePictureBytes;
    lastUploadedFilename = profilePictureFilename;

    mockUser = mockUser.copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      profilePicture: profilePictureFilename != null
          ? 'http://10.0.2.2:8001/media/profile_pictures/$profilePictureFilename'
          : mockUser.profilePicture,
    );
    return mockUser;
  }

  @override
  Future<AuthUser> uploadProfilePicture({
    required String accessToken,
    required List<int> imageBytes,
    required String filename,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    return updateProfile(
      accessToken: accessToken,
      profilePictureBytes: imageBytes,
      profilePictureFilename: filename,
      onSendProgress: onSendProgress,
    );
  }

  @override
  Future<void> removeProfilePicture({required String accessToken}) async {}
}

class _FakeImagePicker extends ImagePicker {
  XFile? mockFile;
  Exception? exceptionToThrow;

  _FakeImagePicker({this.mockFile, this.exceptionToThrow});

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return mockFile;
  }
}

const List<int> _kValidPngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

void main() {
  const testUser = AuthUser(
    id: 15,
    username: 'salman_k',
    email: 'salman@example.com',
    role: 'CUSTOMER',
    phone: '+968 9123 4567',
    firstName: 'Salman',
    lastName: 'Khan',
    isActive: true,
    loyaltyPoints: 12500,
    membershipTier: 'Gold',
    membershipId: 'AS-88301',
  );

  group('EditProfileScreen Widget & Integration Tests', () {
    testWidgets(
      'Loads existing customer information into form fields and displays read-only identifiers',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: EditProfileScreen(user: testUser)),
          ),
        );
        await tester.pump();

        // Form text fields have customer values
        expect(find.widgetWithText(TextFormField, 'Salman'), findsOneWidget);
        expect(find.widgetWithText(TextFormField, 'Khan'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'salman@example.com'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(TextFormField, '+968 9123 4567'),
          findsOneWidget,
        );

        // Read-only identifiers
        expect(find.text('salman_k'), findsOneWidget);
        expect(find.text('CUSTOMER'), findsOneWidget);
        expect(find.text('Gold'), findsOneWidget);

        // Top-right Save action exists
        expect(find.widgetWithText(TextButton, 'Save'), findsOneWidget);

        // Bottom action row has both Cancel and Save Changes
        expect(find.widgetWithText(OutlinedButton, 'Cancel'), findsOneWidget);
        expect(
          find.widgetWithText(FilledButton, 'Save Changes'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Shows validation errors on invalid input and prevents submission',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: EditProfileScreen(user: testUser)),
          ),
        );
        await tester.pump();

        // Enter invalid email and short first name
        final emailFinder = find.widgetWithText(
          TextFormField,
          'salman@example.com',
        );
        await tester.enterText(emailFinder, 'invalid-email');

        final firstNameFinder = find.widgetWithText(TextFormField, 'Salman');
        await tester.enterText(firstNameFinder, 'A');

        // Scroll to Save Changes button if needed and tap
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Save Changes'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
        await tester.pump();

        expect(find.text('Minimum 2 characters'), findsOneWidget);
        expect(find.text('Enter a valid email address'), findsOneWidget);
      },
    );

    testWidgets('Tapping top-right Save triggers profile update', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeToken = _FakeTokenStorage();
      final fakeAuth = _FakeAuthService(mockUser: testUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(fakeToken),
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(user: testUser),
                    ),
                  ),
                  child: const Text('Open Edit'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Open Edit Profile
      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // Update last name
      final lastNameFinder = find.widgetWithText(TextFormField, 'Khan');
      await tester.enterText(lastNameFinder, 'Al Balushi');

      // Tap top-right Save
      await tester.tap(find.widgetWithText(TextButton, 'Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Popped back to root
      expect(find.text('Open Edit'), findsOneWidget);
      expect(find.text('Profile updated successfully!'), findsOneWidget);
    });

    testWidgets(
      'Cancel without modifications pops immediately without confirmation dialog',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(user: testUser),
                      ),
                    ),
                    child: const Text('Open Edit'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('Open Edit'));
        await tester.pumpAndSettle();

        // Tap Cancel in bottom action row
        await tester.ensureVisible(
          find.widgetWithText(OutlinedButton, 'Cancel'),
        );
        await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
        await tester.pumpAndSettle();

        // Directly popped back without dialog
        expect(find.text('Discard Changes?'), findsNothing);
        expect(find.text('Open Edit'), findsOneWidget);
      },
    );

    testWidgets('Cancel with unsaved changes prompts confirmation dialog', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeToken = _FakeTokenStorage();
      final fakeAuth = _FakeAuthService(mockUser: testUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(fakeToken),
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(user: testUser),
                    ),
                  ),
                  child: const Text('Open Edit'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Open Edit'));
      await tester.pumpAndSettle();

      // Modify first name
      final firstNameFinder = find.widgetWithText(TextFormField, 'Salman');
      await tester.enterText(firstNameFinder, 'Sami');

      // Tap Cancel in bottom action row
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();

      // Discard confirmation dialog is visible
      expect(find.text('Discard Changes?'), findsOneWidget);
      expect(find.text('Keep Editing'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);

      // Tap Keep Editing
      await tester.tap(find.text('Keep Editing'));
      await tester.pumpAndSettle();
      expect(find.text('Discard Changes?'), findsNothing);
      expect(find.text('Edit Profile'), findsOneWidget);

      // Tap Cancel again and choose Discard
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      // Popped back to root
      expect(find.text('Open Edit'), findsOneWidget);
    });

    testWidgets(
      'Tapping Change Photo shows bottom sheet with Gallery, Camera and Cancel',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: EditProfileScreen(user: testUser)),
          ),
        );
        await tester.pump();

        // Tap Change Photo
        await tester.tap(find.text('Change Photo'));
        await tester.pumpAndSettle();

        expect(find.text('Profile Photo'), findsOneWidget);
        expect(find.text('Choose from Gallery'), findsOneWidget);
        expect(find.text('Take a Photo'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(BottomSheet),
            matching: find.text('Cancel'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Picking photo from Gallery updates avatar image preview immediately',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);
        final mockImageBytes = Uint8List.fromList(_kValidPngBytes);
        final fakePicker = _FakeImagePicker(
          mockFile: XFile.fromData(
            mockImageBytes,
            name: 'avatar.png',
            path: 'avatar.png',
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: MaterialApp(
              home: EditProfileScreen(user: testUser, imagePicker: fakePicker),
            ),
          ),
        );
        await tester.pump();

        // Open bottom sheet
        await tester.tap(find.text('Change Photo'));
        await tester.pumpAndSettle();

        // Tap Choose from Gallery
        await tester.tap(find.text('Choose from Gallery'));
        await tester.pumpAndSettle();

        // Label updates to 'Replace Photo'
        expect(find.text('Replace Photo'), findsOneWidget);

        // CircleAvatar now has a MemoryImage background
        final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        expect(avatar.backgroundImage, isA<MemoryImage>());
      },
    );

    testWidgets('Selecting an image exceeding 2 MB displays error message', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeToken = _FakeTokenStorage();
      final fakeAuth = _FakeAuthService(mockUser: testUser);
      // 2.5 MB fake bytes
      final largeBytes = Uint8List(2500000);
      final fakePicker = _FakeImagePicker(
        mockFile: XFile.fromData(largeBytes, name: 'large_photo.jpg'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(fakeToken),
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            home: EditProfileScreen(user: testUser, imagePicker: fakePicker),
          ),
        ),
      );
      await tester.pump();

      // Tap Change Photo
      await tester.tap(find.text('Change Photo'));
      await tester.pumpAndSettle();

      // Select from gallery
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pumpAndSettle();

      // Exceeds 2 MB error
      expect(find.textContaining('exceeds the 2 MB limit'), findsOneWidget);
    });

    testWidgets('Handles camera permission denial gracefully', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeToken = _FakeTokenStorage();
      final fakeAuth = _FakeAuthService(mockUser: testUser);
      final fakePicker = _FakeImagePicker(
        exceptionToThrow: Exception('Camera permission denied by user'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tokenStorageProvider.overrideWithValue(fakeToken),
            authServiceProvider.overrideWithValue(fakeAuth),
          ],
          child: MaterialApp(
            home: EditProfileScreen(user: testUser, imagePicker: fakePicker),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Change Photo'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Take a Photo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Permission denied'), findsOneWidget);
    });

    testWidgets(
      'Submits valid profile update with photo to backend and displays success SnackBar',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);
        final mockImageBytes = Uint8List.fromList(_kValidPngBytes);
        final fakePicker = _FakeImagePicker(
          mockFile: XFile.fromData(
            mockImageBytes,
            name: 'salman_new.png',
            path: 'salman_new.png',
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          user: testUser,
                          imagePicker: fakePicker,
                        ),
                      ),
                    ),
                    child: const Text('Open Edit'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        // Open Edit Profile
        await tester.tap(find.text('Open Edit'));
        await tester.pumpAndSettle();

        // Pick photo
        await tester.tap(find.text('Change Photo'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Choose from Gallery'));
        await tester.pumpAndSettle();

        // Update name
        final lastNameFinder = find.widgetWithText(TextFormField, 'Khan');
        await tester.enterText(lastNameFinder, 'Al Balushi');

        // Tap Save Changes in bottom action row
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Save Changes'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
        await tester.pump();

        // Wait for async update to complete
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Popped back to root
        expect(find.text('Open Edit'), findsOneWidget);
        expect(find.text('Profile updated successfully!'), findsOneWidget);
        expect(fakeAuth.lastUploadedFilename, 'salman_new.png');
        expect(fakeAuth.lastUploadedBytes, mockImageBytes);
      },
    );

    testWidgets(
      'Displays backend error response cleanly in banner and SnackBar on API failure',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser)
          ..shouldThrowError = true;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: EditProfileScreen(user: testUser)),
          ),
        );
        await tester.pump();

        // Tap Save Changes
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Save Changes'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Error message is displayed
        expect(
          find.textContaining('Email: A user with this email already exists.'),
          findsWidgets,
        );
      },
    );

    testWidgets(
      'Complete Flow: Changes name & email, saves, refreshes from backend, returns to ProfileScreen with new values immediately, and values remain updated upon reopen',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: ProfileScreen(user: testUser)),
          ),
        );
        await tester.pumpAndSettle();

        // Initial ProfileScreen shows testUser values
        expect(find.text('Salman Khan'), findsOneWidget);
        expect(find.text('salman@example.com'), findsOneWidget);

        // Tap Edit Profile button on summary card
        await tester.tap(find.byTooltip('Edit Profile'));
        await tester.pumpAndSettle();

        // Verify we are on Edit Profile
        expect(find.text('Edit Profile'), findsOneWidget);

        // 1. Change customer name and email
        final firstFinder = find.widgetWithText(TextFormField, 'Salman');
        await tester.enterText(firstFinder, 'Tariq');

        final lastFinder = find.widgetWithText(TextFormField, 'Khan');
        await tester.enterText(lastFinder, 'Al-Balushi');

        final emailFinder = find.widgetWithText(
          TextFormField,
          'salman@example.com',
        );
        await tester.enterText(emailFinder, 'tariq.albalushi@alsewar.com');

        // 2. Tap Save Changes
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Save Changes'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
        await tester.pump();

        // 3. Confirm update API succeeds & 4. Confirm profile refresh API is called
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        expect(fakeAuth.getCurrentCustomerCallCount, greaterThan(0));

        // 5. Return to Profile screen & 6. Verify new values appear immediately
        expect(find.text('Edit Profile'), findsNothing);
        expect(find.text('Tariq Al-Balushi'), findsOneWidget);
        expect(find.text('tariq.albalushi@alsewar.com'), findsOneWidget);
        expect(find.text('Profile updated successfully!'), findsOneWidget);

        // 7. Reopen Profile and confirm the values remain updated
        await tester.tap(find.byTooltip('Edit Profile'));
        await tester.pumpAndSettle();

        expect(find.widgetWithText(TextFormField, 'Tariq'), findsOneWidget);
        expect(
          find.widgetWithText(TextFormField, 'Al-Balushi'),
          findsOneWidget,
        );
        expect(
          find.widgetWithText(TextFormField, 'tariq.albalushi@alsewar.com'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'When save succeeds but refresh fails: remains on Edit Profile, displays error message, and tapping Retry Refresh completes flow',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: ProfileScreen(user: testUser)),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Edit Profile
        await tester.tap(find.byTooltip('Edit Profile'));
        await tester.pumpAndSettle();

        // Now set shouldThrowOnRefresh for the save-refresh step
        fakeAuth.shouldThrowOnRefresh = true;

        // Modify first name
        final firstFinder = find.widgetWithText(TextFormField, 'Salman');
        await tester.enterText(firstFinder, 'Rashid');

        // Tap Save Changes
        await tester.ensureVisible(
          find.widgetWithText(FilledButton, 'Save Changes'),
        );
        await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Still on Edit Profile
        expect(find.text('Edit Profile'), findsOneWidget);
        expect(
          find.textContaining('failed to fetch latest data'),
          findsOneWidget,
        );
        expect(find.text('Retry Refresh'), findsOneWidget);

        // Dismiss SnackBar so bottom button is unobstructed
        ScaffoldMessenger.of(tester.element(find.byType(EditProfileScreen)))
            .hideCurrentSnackBar();
        await tester.pumpAndSettle();

        // Now fix the refresh error and tap Retry Refresh
        fakeAuth.shouldThrowOnRefresh = false;
        final retryButton = find.widgetWithText(FilledButton, 'Retry Refresh');
        await tester.ensureVisible(retryButton);
        await tester.tap(retryButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Now popped to ProfileScreen and updated!
        expect(find.text('Edit Profile'), findsNothing);
        expect(find.text('Rashid Khan'), findsOneWidget);
        expect(find.text('Profile updated successfully!'), findsOneWidget);
      },
    );

    testWidgets(
      'ProfileScreen pull-to-refresh calls refreshProfile and updates display',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 844 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final fakeToken = _FakeTokenStorage();
        final fakeAuth = _FakeAuthService(mockUser: testUser);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              tokenStorageProvider.overrideWithValue(fakeToken),
              authServiceProvider.overrideWithValue(fakeAuth),
            ],
            child: const MaterialApp(home: ProfileScreen(user: testUser)),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Salman Khan'), findsOneWidget);

        // Backend user changes externally
        fakeAuth.mockUser = testUser.copyWith(
          firstName: 'Sultan',
          lastName: 'Al-Harthi',
        );

        // Trigger pull-to-refresh
        await tester.fling(
          find.byType(SingleChildScrollView),
          const Offset(0.0, 300.0),
          1000.0,
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();

        // Displays updated external name
        expect(find.text('Sultan Al-Harthi'), findsOneWidget);
      },
    );
  });

  group('AppSnackBar Widget Tests', () {
    testWidgets(
      'showSuccess renders floating SnackBar with Champagne Gold accent and hides previous',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => Column(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          AppSnackBar.showSuccess(context, 'First Message'),
                      child: const Text('Show 1'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          AppSnackBar.showSuccess(context, 'Second Message'),
                      child: const Text('Show 2'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show 1'));
        await tester.pump();
        expect(find.text('First Message'), findsOneWidget);

        // Showing second immediately dismisses the first, preventing duplicate queuing
        await tester.tap(find.text('Show 2'));
        await tester.pump();
        expect(find.text('First Message'), findsNothing);
        expect(find.text('Second Message'), findsOneWidget);
      },
    );

    testWidgets('showError renders error styling and sanitized message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AppSnackBar.showError(
                  context,
                  'Exception: Connection timed out. Please try again.',
                ),
                child: const Text('Trigger Error'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Error'));
      await tester.pump();

      // Cleaned of 'Exception: '
      expect(
        find.text('Connection timed out. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'hasBottomNav adjusts bottom margin to clear floating navigation bar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => AppSnackBar.showSuccess(
                    context,
                    'Cleared Bottom Nav',
                    hasBottomNav: true,
                  ),
                  child: const Text('Trigger Nav SnackBar'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Trigger Nav SnackBar'));
        await tester.pump();

        final snackBarFinder = find.byType(SnackBar);
        expect(snackBarFinder, findsOneWidget);
        final snackBar = tester.widget<SnackBar>(snackBarFinder);
        expect(snackBar.behavior, SnackBarBehavior.floating);
        expect((snackBar.margin as EdgeInsets).bottom, 96.0);
      },
    );
  });
}
