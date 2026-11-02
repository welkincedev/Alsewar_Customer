import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

/// Al Sewar Full-Screen Edit Profile Screen.
///
/// Provides complete customer profile editing capabilities:
/// - Validation for First Name, Last Name, and Email
/// - Read-only display of immutable Phone Number, Username, Role, and Membership Tier
/// - Bottom sheet for profile photo selection from Gallery or Camera
/// - Immediate image preview with replacement support and max 2MB validation
/// - Unified save via top-right 'Save' and bottom 'Save Changes'
/// - Confirmation dialog on discard if unsaved edits exist
/// - Single atomic multipart/form-data upload when profile image is modified
/// - Adheres strictly to the Al Sewar Desert Luxe visual language
class EditProfileScreen extends ConsumerStatefulWidget {
  final AuthUser user;
  final ImagePicker? imagePicker;

  const EditProfileScreen({super.key, required this.user, this.imagePicker});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final ImagePicker _imagePicker;

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isImageRemoved = false;

  bool _isLoading = false;
  String? _errorMessage;
  String? _loadingMessage;
  bool _hasSavedSuccessfully = false;
  bool _refreshFailed = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _emailController = TextEditingController(text: widget.user.email);
    _imagePicker = widget.imagePicker ?? ImagePicker();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges() {
    if (_hasSavedSuccessfully) return false;
    final firstChanged =
        _firstNameController.text.trim() != widget.user.firstName.trim();
    final lastChanged =
        _lastNameController.text.trim() != widget.user.lastName.trim();
    final emailChanged =
        _emailController.text.trim() != widget.user.email.trim();
    final imageChanged = _selectedImage != null || _isImageRemoved;
    return firstChanged || lastChanged || emailChanged || imageChanged;
  }

  Future<void> _handleCancel() async {
    if (_isLoading) return;
    if (!_hasUnsavedChanges()) {
      Navigator.pop(context);
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Discard Changes?',
          style: TextStyle(
            fontFamily: AppTextStyles.headingFont,
            color: AppColors.deepBlack,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'You have unsaved edits. Are you sure you want to discard them?',
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(
                fontFamily: AppTextStyles.bodyFont,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE02424),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Discard',
              style: TextStyle(
                fontFamily: AppTextStyles.headingFont,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (discard == true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      // User cancelled picker dialog
      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      // 1. Validate file size (max 2 MB = 2,097,152 bytes)
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        if (mounted) {
          final sizeMb = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(
            2,
          );
          AppSnackBar.showError(
            context,
            'Image size ($sizeMb MB) exceeds the 2 MB limit. Please select a smaller photo.',
          );
        }
        return;
      }

      // 2. Validate format (JPEG, PNG, WEBP)
      final resolvedName = picked.name.isNotEmpty
          ? picked.name
          : (picked.path.isNotEmpty
                ? picked.path.split(RegExp(r'[\\/]')).last
                : '');
      final nameLower = resolvedName.toLowerCase();
      final mime = picked.mimeType?.toLowerCase() ?? '';
      final isValidFormat =
          nameLower.endsWith('.jpg') ||
          nameLower.endsWith('.jpeg') ||
          nameLower.endsWith('.png') ||
          nameLower.endsWith('.webp') ||
          mime.contains('jpeg') ||
          mime.contains('png') ||
          mime.contains('webp') ||
          (resolvedName.isEmpty &&
              bytes.lengthInBytes >= 4 &&
              ((bytes[0] == 0xFF && bytes[1] == 0xD8) || // JPEG
                  (bytes[0] == 0x89 &&
                      bytes[1] == 0x50 &&
                      bytes[2] == 0x4E &&
                      bytes[3] == 0x47) || // PNG
                  (bytes[0] == 0x52 &&
                      bytes[1] == 0x49 &&
                      bytes[2] == 0x46 &&
                      bytes[3] == 0x46))); // WEBP RIFF

      if (!isValidFormat) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Unsupported image format. Allowed formats are JPEG, PNG, or WEBP.',
          );
        }
        return;
      }

      setState(() {
        _selectedImage = picked;
        _selectedImageBytes = bytes;
        _isImageRemoved = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('permission') || errorStr.contains('denied')) {
          AppSnackBar.showError(
            context,
            'Permission denied. Please enable camera/photos permission in device settings.',
          );
        } else {
          AppSnackBar.showError(
            context,
            'Unable to access ${source == ImageSource.camera ? "camera" : "gallery"}. Please try again.',
          );
        }
      }
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    if (_refreshFailed && _hasSavedSuccessfully) {
      await _handleRetryRefresh();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Saving changes...';
      _errorMessage = null;
      _refreshFailed = false;
    });

    try {
      final filename = _selectedImage != null
          ? (_selectedImage!.name.isNotEmpty
                ? _selectedImage!.name
                : (_selectedImage!.path.isNotEmpty
                      ? _selectedImage!.path.split(RegExp(r'[\\/]')).last
                      : 'profile_photo.jpg'))
          : null;

      // 1. Complete profile details & picture API update
      await ref
          .read(authViewModelProvider.notifier)
          .updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            profilePictureBytes: _selectedImageBytes,
            profilePictureFilename: filename,
            profilePicturePath: _selectedImage?.path,
          );
      _hasSavedSuccessfully = true;
    } catch (e) {
      if (mounted) {
        final cleanError = e.toString().replaceAll('Exception: ', '').trim();
        setState(() {
          _errorMessage = cleanError;
          _isLoading = false;
          _loadingMessage = null;
        });
        AppSnackBar.showError(context, cleanError);
      }
      return;
    }

    // 2. Fetch the latest customer profile from backend using profile/me API
    if (mounted) {
      setState(() {
        _loadingMessage = 'Refreshing profile...';
      });
    }

    AuthUser latestUser;
    try {
      latestUser = await ref
          .read(authViewModelProvider.notifier)
          .refreshProfile();
    } catch (refreshErr) {
      if (mounted) {
        final clean = refreshErr
            .toString()
            .replaceAll('Exception: ', '')
            .trim();
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
          _refreshFailed = true;
          _errorMessage =
              'Profile was saved, but failed to fetch latest data ($clean). Tap "Retry Refresh" to complete.';
        });
        AppSnackBar.showError(
          context,
          'Profile saved, but unable to refresh latest data. Tap Retry Refresh.',
        );
      }
      return;
    }

    // 3. Both save and refresh succeeded!
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
      AppSnackBar.showSuccess(context, 'Profile updated successfully!');
      Navigator.pop(context, latestUser);
    }
  }

  Future<void> _handleRetryRefresh() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _loadingMessage = 'Refreshing profile...';
      _errorMessage = null;
    });

    try {
      final latestUser = await ref
          .read(authViewModelProvider.notifier)
          .refreshProfile();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
          _refreshFailed = false;
        });
        AppSnackBar.showSuccess(context, 'Profile updated successfully!');
        Navigator.pop(context, latestUser);
      }
    } catch (e) {
      if (mounted) {
        final clean = e.toString().replaceAll('Exception: ', '').trim();
        setState(() {
          _isLoading = false;
          _loadingMessage = null;
          _errorMessage =
              'Refresh failed ($clean). Please check your connection and tap "Retry Refresh".';
        });
        AppSnackBar.showError(context, 'Unable to refresh profile: $clean');
      }
    }
  }

  void _showAvatarBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: AppColors.pureWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.subtleBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Profile Photo',
                style: TextStyle(
                  fontFamily: AppTextStyles.headingFont,
                  color: AppColors.deepNavy,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Choose an image for your Al Sewar customer profile',
                style: TextStyle(
                  fontFamily: AppTextStyles.bodyFont,
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.deepNavy,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: AppColors.deepBlack,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.offWhite,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.deepNavy,
                    size: 22,
                  ),
                ),
                title: const Text(
                  'Take a Photo',
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                    color: AppColors.deepBlack,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  await _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImageBytes != null ||
                  (!_isImageRemoved &&
                      widget.user.profilePicture != null &&
                      widget.user.profilePicture!.isNotEmpty)) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFE02424),
                      size: 22,
                    ),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: Color(0xFFE02424),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedImage = null;
                      _selectedImageBytes = null;
                      _isImageRemoved = true;
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.subtleBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: AppTextStyles.bodyFont,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.user.displayName.isNotEmpty
        ? widget.user.displayName[0].toUpperCase()
        : 'C';

    final hasNetworkImage =
        !_isImageRemoved &&
        widget.user.profilePicture != null &&
        widget.user.profilePicture!.isNotEmpty;

    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleCancel();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              fontFamily: AppTextStyles.headingFont,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlack,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.pureWhite,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.deepBlack,
              size: 18,
            ),
            onPressed: _handleCancel,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TextButton(
                onPressed: _isLoading
                    ? null
                    : (_refreshFailed ? _handleRetryRefresh : _handleSave),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.deepNavy,
                  disabledForegroundColor: AppColors.textLight,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.deepNavy,
                          ),
                        ),
                      )
                    : Text(
                        _refreshFailed ? 'Retry' : 'Save',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.headingFont,
                          color: AppColors.deepNavy,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Avatar & Change Photo ──────────────────────────────
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.champagneGold,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.deepNavy.withValues(
                                  alpha: 0.08,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 46,
                            backgroundColor: AppColors.deepNavy,
                            backgroundImage: _selectedImageBytes != null
                                ? MemoryImage(_selectedImageBytes!)
                                : (hasNetworkImage
                                      ? NetworkImage(
                                          widget.user.profilePicture!,
                                        ) as ImageProvider
                                      : null),
                            child:
                                (_selectedImageBytes == null &&
                                    !hasNetworkImage)
                                ? Text(
                                    initials,
                                    style: const TextStyle(
                                      fontFamily: AppTextStyles.headingFont,
                                      color: AppColors.champagneGold,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: GestureDetector(
                            onTap: _showAvatarBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.deepNavy,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.pureWhite,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: AppColors.champagneGold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton.icon(
                      onPressed: _showAvatarBottomSheet,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.champagneGold,
                      ),
                      label: Text(
                        _selectedImageBytes != null
                            ? 'Replace Photo'
                            : 'Change Photo',
                        style: const TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          color: AppColors.champagneGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Error Message Banner ───────────────────────────────
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF8B4B4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _refreshFailed
                                ? Icons.sync_problem_rounded
                                : Icons.error_outline,
                            color: const Color(0xFFE02424),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontFamily: AppTextStyles.bodyFont,
                                color: Color(0xFF9B1C1C),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_refreshFailed) ...[
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: _isLoading
                                  ? null
                                  : _handleRetryRefresh,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(
                                Icons.refresh_rounded,
                                size: 16,
                                color: Color(0xFF9B1C1C),
                              ),
                              label: const Text(
                                'Retry',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.headingFont,
                                  color: Color(0xFF9B1C1C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Form Card ──────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.subtleBorder,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepNavy.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PERSONAL DETAILS',
                          style: TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.deepNavy,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // First Name
                        _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          hint: 'Enter your first name',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'First name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Minimum 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Last Name
                        _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          hint: 'Enter your last name',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Last name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Minimum 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email Address
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'name@domain.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email address is required';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number (Read-only / protected)
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: '+966 50 123 4567',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          readOnly: true,
                          suffixIcon: const Tooltip(
                            message: 'Phone number is verified and cannot be edited online',
                            child: Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: AppColors.textLight,
                            ),
                          ),
                          helperText: 'Verified account phone (read-only)',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Read-Only Account Identity Card ────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.subtleBorder,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ACCOUNT IDENTIFIERS',
                          style: TextStyle(
                            fontFamily: AppTextStyles.headingFont,
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildReadOnlyRow(
                          label: 'Username',
                          value: widget.user.username,
                          icon: Icons.account_circle_outlined,
                        ),
                        const Divider(
                          height: 20,
                          color: AppColors.subtleBorder,
                        ),
                        _buildReadOnlyRow(
                          label: 'Account Role',
                          value: widget.user.role.toUpperCase(),
                          icon: Icons.verified_user_outlined,
                        ),
                        if (widget.user.membershipTier != null) ...[
                          const Divider(
                            height: 20,
                            color: AppColors.subtleBorder,
                          ),
                          _buildReadOnlyRow(
                            label: 'Membership Tier',
                            value: widget.user.membershipTier!,
                            icon: Icons.workspace_premium_outlined,
                            isGold: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Bottom Action Row (Cancel & Save Changes in one row) ─
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              side: const BorderSide(
                                color: AppColors.subtleBorder,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: AppTextStyles.bodyFont,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Save Changes Button
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 50,
                          child: FilledButton(
                            onPressed: _isLoading
                                ? null
                                : (_refreshFailed
                                      ? _handleRetryRefresh
                                      : _handleSave),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              backgroundColor: AppColors.deepNavy,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                AppColors.champagneGold,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          _loadingMessage ?? 'Saving...',
                                          style: const TextStyle(
                                            fontFamily:
                                                AppTextStyles.headingFont,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.pureWhite,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (_refreshFailed) ...[
                                        const Icon(
                                          Icons.refresh_rounded,
                                          size: 18,
                                          color: AppColors.champagneGold,
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Flexible(
                                        child: Text(
                                          _refreshFailed
                                              ? 'Retry Refresh'
                                              : 'Save Changes',
                                          style: const TextStyle(
                                            fontFamily:
                                                AppTextStyles.headingFont,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.pureWhite,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    Widget? suffixIcon,
    String? helperText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.deepBlack,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          validator: validator,
          style: TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: readOnly ? AppColors.textSecondary : AppColors.deepBlack,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.textLight,
              fontSize: 13,
            ),
            helperText: helperText,
            helperStyle: const TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.textLight,
              fontSize: 11,
            ),
            prefixIcon: Icon(icon, size: 19, color: AppColors.deepNavy),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF3F4F6) : AppColors.offWhite,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.subtleBorder,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.subtleBorder,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: readOnly ? AppColors.subtleBorder : AppColors.deepNavy,
                width: readOnly ? 1.0 : 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE02424),
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyRow({
    required String label,
    required String value,
    required IconData icon,
    bool isGold = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isGold ? AppColors.champagneGold : AppColors.textLight,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppTextStyles.bodyFont,
            fontSize: 13,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isGold ? AppColors.richMetallicGold : AppColors.deepBlack,
            ),
          ),
        ),
      ],
    );
  }
}
