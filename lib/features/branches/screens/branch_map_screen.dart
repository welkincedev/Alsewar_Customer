import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../home/screens/customer_home_screen.dart';
import '../../home/widgets/floating_pill_nav_bar.dart';
import '../models/branch.dart';
import '../services/location_service.dart';
import '../utils/coordinate_utils.dart';
import '../viewmodels/branch_providers.dart';
import '../viewmodels/branch_viewmodel.dart';
import '../widgets/branch_details_bottom_sheet.dart';

/// Interactive OpenStreetMap screen displaying active Al Sewar Auto Center branches
/// with current-location GPS centering, distance calculation, and branch selection.
class BranchMapScreen extends ConsumerStatefulWidget {
  const BranchMapScreen({super.key});

  @override
  ConsumerState<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends ConsumerState<BranchMapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<double> _rotationNotifier = ValueNotifier<double>(0.0);
  String _searchQuery = '';
  Branch? _selectedBranch;
  bool _hasInitialFitted = false;
  bool _isMapReady = false;
  bool _hasTileError = false;

  Timer? _snackbarTimer;
  String? _activeSnackbarMessage;
  SnackBarAction? _activeSnackbarAction;
  Color _snackbarBgColor = AppColors.deepNavy;
  String? _lastSnackbarMessage;
  DateTime? _lastSnackbarShownTime;

  bool get _isInShell =>
      context.findAncestorWidgetOfExactType<CustomerMainShell>() != null ||
      !Navigator.canPop(context);

  bool get _isStandalone => !_isInShell;

  /// Dedicated screen-level bottom offset for all map floating controls and overlays.
  /// Exactly 6px above the floating bottom navigation bar when hosted in shell (4–6px target gap),
  /// or above device safe area when standalone. Single source of truth.
  double get _controlsBottomOffset =>
      FloatingPillNavBarUtils.calculateControlsBottomOffset(
        context,
        clearance: 6.0,
        isStandalone: _isStandalone,
      );

  LatLng? _currentLocation;
  bool _isLocating = false;

  @override
  void deactivate() {
    _dismissOverlaySnackBar();
    super.deactivate();
  }

  @override
  void dispose() {
    _snackbarTimer?.cancel();
    _rotationNotifier.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dismiss snackbar when switching away from this tab in IndexedStack
    // ignore: deprecated_member_use
    if (!TickerMode.of(context)) {
      _dismissOverlaySnackBar();
    }
    // When the screen becomes active or visible (e.g. in IndexedStack / tab switch)
    if (_isMapReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final size = _mapController.camera.nonRotatedSize;
        if (size.width > 0 && size.height > 0) {
          _mapController.move(
            _mapController.camera.center,
            _mapController.camera.zoom,
          );
        }
      });
    }
  }

  Future<void> _refreshAll() async {
    setState(() {
      _hasInitialFitted = false;
      _hasTileError = false;
    });
    await ref.read(branchListViewModelProvider.notifier).refresh();
  }

  void _tryFitCamera(List<Branch> validBranches) {
    if (!_isMapReady || validBranches.isEmpty) return;

    final size = _mapController.camera.nonRotatedSize;
    if (size.width <= 0 || size.height <= 0) {
      // Dimensions not measured yet (e.g. offstage or pre-layout), wait for layout
      return;
    }

    _hasInitialFitted = true;
    _fitCameraToBounds(validBranches);
    // Explicitly nudge camera to trigger immediate TileLayer calculation & rendering
    _mapController.move(
      _mapController.camera.center,
      _mapController.camera.zoom,
    );
  }

  void _fitCameraToBounds(List<Branch> validBranches) {
    if (validBranches.isEmpty) return;

    if (validBranches.length == 1) {
      final b = validBranches.first;
      _mapController.move(LatLng(b.latitude!, b.longitude!), 14.0);
    } else {
      final bounds = CoordinateUtils.computeBounds(validBranches);
      if (bounds != null) {
        final bottomCameraPadding =
            FloatingPillNavBarUtils.calculateBottomClearance(
              context,
              clearance: 20.0,
              isStandalone: _isStandalone,
            );
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: EdgeInsets.only(
              left: 48,
              right: 48,
              top: 100,
              bottom: bottomCameraPadding,
            ),
          ),
        );
      }
    }
  }

  /// Displays an independent floating overlay notification positioned strictly 16px above the navigation bar.
  /// Automatically dismissed after 3 seconds, cancelled on navigation, and prevents
  /// duplicate notifications from repeated requests.
  void _showOverlaySnackBar(
    String message, {
    Color backgroundColor = AppColors.deepNavy,
    BorderSide? borderSide,
    SnackBarAction? action,
  }) {
    if (!mounted) return;

    final now = DateTime.now();
    if (_lastSnackbarShownTime != null &&
        now.difference(_lastSnackbarShownTime!) < const Duration(seconds: 3) &&
        _lastSnackbarMessage == message) {
      return; // Prevent duplicate snackbars from repeated location requests
    }

    _lastSnackbarMessage = message;
    _lastSnackbarShownTime = now;
    _snackbarTimer?.cancel();

    setState(() {
      _activeSnackbarMessage = message;
      _activeSnackbarAction = action;
      _snackbarBgColor = backgroundColor;
    });

    _snackbarTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _activeSnackbarMessage = null;
          _activeSnackbarAction = null;
        });
      }
    });
  }

  void _dismissOverlaySnackBar() {
    _snackbarTimer?.cancel();
    if (_activeSnackbarMessage != null && mounted) {
      setState(() {
        _activeSnackbarMessage = null;
        _activeSnackbarAction = null;
      });
    }
  }

  Widget _buildSnackbarOverlay() {
    if (_activeSnackbarMessage == null) return const SizedBox.shrink();

    return Positioned(
      left: 16.0,
      right: 84.0,
      bottom: _controlsBottomOffset,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _snackbarBgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.champagneGold, width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _activeSnackbarMessage!,
                  style: const TextStyle(
                    color: AppColors.pureWhite,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_activeSnackbarAction != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final action = _activeSnackbarAction;
                    _dismissOverlaySnackBar();
                    action?.onPressed();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      _activeSnackbarAction!.label,
                      style: const TextStyle(
                        color: AppColors.champagneGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Obtains current GPS position, adds user marker, moves map camera,
  /// and calculates distance to branches.
  Future<void> _handleMyLocation(List<Branch> validBranches) async {
    if (_isLocating) return;
    setState(() => _isLocating = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final result = await locationService.getCurrentLocation();

      if (!mounted) return;

      switch (result.status) {
        case LocationResultStatus.success:
          final pos = result.position!;
          setState(() {
            _currentLocation = pos;
          });

          // Move camera to user's current GPS position
          _mapController.move(pos, 14.0);

          // Find nearest branch if valid branches exist
          if (validBranches.isNotEmpty) {
            final sorted = CoordinateUtils.sortByDistance(validBranches, pos);
            final nearest = sorted.first;
            final distStr = CoordinateUtils.getFormattedBranchDistance(
              nearest,
              pos,
            );

            final message = distStr != null
                ? 'Located! Nearest branch: ${nearest.name} ($distStr)'
                : 'Located! Nearest branch: ${nearest.name}';

            _showOverlaySnackBar(
              message,
              action: SnackBarAction(
                label: 'View',
                textColor: AppColors.champagneGold,
                onPressed: () => _handleBranchSelected(nearest),
              ),
            );
          } else {
            _showOverlaySnackBar('Position updated. No nearby branches found.');
          }
          break;

        case LocationResultStatus.servicesDisabled:
          _showLocationDialog(
            title: 'Location Services Disabled',
            message: result.errorMessage ?? 'Please enable GPS on your device to see your location and find nearby branches.',
            actionLabel: 'Settings',
            onAction: () => locationService.openLocationSettings(),
          );
          break;

        case LocationResultStatus.permissionDenied:
          _showOverlaySnackBar(
            result.errorMessage ?? 'Location permission was denied. Please allow access to find nearby branches.',
            backgroundColor: AppColors.warning,
            borderSide: BorderSide.none,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.pureWhite,
              onPressed: () => _handleMyLocation(validBranches),
            ),
          );
          break;

        case LocationResultStatus.permissionPermanentlyDenied:
          _showLocationDialog(
            title: 'Permission Denied',
            message: result.errorMessage ?? 'Location permissions are permanently denied. Please enable them in app settings.',
            actionLabel: 'Settings',
            onAction: () => locationService.openAppSettings(),
          );
          break;

        case LocationResultStatus.gpsUnavailable:
        case LocationResultStatus.error:
          _showOverlaySnackBar(
            result.errorMessage ?? 'Unable to determine your GPS location. Please check your signal and try again.',
            backgroundColor: AppColors.error,
            borderSide: BorderSide.none,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.pureWhite,
              onPressed: () => _handleMyLocation(validBranches),
            ),
          );
          break;
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _showLocationDialog({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    _dismissOverlaySnackBar();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          title,
          style: AppTextStyles.title.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        content: Text(message, style: AppTextStyles.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textLight),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              foregroundColor: AppColors.champagneGold,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onAction();
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<Branch> branches) {
    final markers = <Marker>[];

    // Current location marker (Al Sewar theme: Deep Navy core with Champagne Gold border & aura)
    if (_currentLocation != null) {
      markers.add(
        Marker(
          point: _currentLocation!,
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: Tooltip(
            message: 'My Location',
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer subtle glowing aura
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.champagneGold.withValues(alpha: 0.22),
                  ),
                ),
                // Inner solid pin
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.deepNavy,
                    border: Border.all(
                      color: AppColors.champagneGold,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.my_location,
                    size: 16,
                    color: AppColors.champagneGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Branch markers with consistent Al Sewar visual style
    for (final branch in branches) {
      final isSelected = _selectedBranch?.id == branch.id;
      markers.add(
        Marker(
          point: LatLng(branch.latitude!, branch.longitude!),
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _handleBranchSelected(branch),
            child: Tooltip(
              message: branch.name,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.deepNavy : AppColors.pureWhite,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.champagneGold
                        : AppColors.deepNavy,
                    width: isSelected ? 2.8 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.storefront,
                  size: 20,
                  color: isSelected
                      ? AppColors.champagneGold
                      : AppColors.deepNavy,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _handleBranchSelected(Branch branch) {
    FocusManager.instance.primaryFocus?.unfocus();
    _dismissOverlaySnackBar();
    setState(() => _selectedBranch = branch);
    BranchDetailsBottomSheet.show(
      context,
      branch,
      userLocation: _currentLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final branchAsync = ref.watch(branchListViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      resizeToAvoidBottomInset: false,
      body: branchAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.signatureGold),
              SizedBox(height: 16),
              Text(
                'Locating Al Sewar Branches...',
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
        ),
        error: (err, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text('Could Not Load Branches', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text(
                  err.toString().replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.deepBlack,
                    foregroundColor: AppColors.signatureGold,
                  ),
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.signatureGold,
                  ),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(
                      color: AppColors.signatureGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _refreshAll,
                ),
              ],
            ),
          ),
        ),
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      size: 72,
                      color: AppColors.champagneGold,
                    ),
                    const SizedBox(height: 20),
                    Text('No Branches Found', style: AppTextStyles.heading),
                    const SizedBox(height: 8),
                    const Text(
                      'Branch locations are currently being updated. Please check back shortly.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.deepBlack,
                        foregroundColor: AppColors.signatureGold,
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.signatureGold,
                      ),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(
                          color: AppColors.signatureGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _refreshAll,
                    ),
                  ],
                ),
              ),
            );
          }

          final validBranches = CoordinateUtils.filterValidBranches(branches);

          // If no branches have valid coordinates, show map at default location
          // with a bottom panel of branches for direct WhatsApp contact.
          if (validBranches.isEmpty) {
            return _buildNoValidCoordinatesLayout(branches);
          }

          return _buildMapWithBranchesLayout(validBranches, branches);
        },
      ),
    );
  }

  Widget _buildMapWithBranchesLayout(
    List<Branch> validBranches,
    List<Branch> allBranches,
  ) {
    final initialTarget = LatLng(
      validBranches.first.latitude!,
      validBranches.first.longitude!,
    );

    final query = _searchQuery.trim().toLowerCase();
    final displayedBranches = query.isEmpty
        ? validBranches
        : validBranches.where((b) {
            return b.name.toLowerCase().contains(query) ||
                b.city.toLowerCase().contains(query) ||
                b.fullAddress.toLowerCase().contains(query);
          }).toList();

    // Compute nearest branch if user location is available
    Branch? nearestBranch;
    String? nearestDistance;
    if (_currentLocation != null && validBranches.isNotEmpty) {
      final sorted = CoordinateUtils.sortByDistance(
        validBranches,
        _currentLocation!,
      );
      nearestBranch = sorted.first;
      nearestDistance = CoordinateUtils.getFormattedBranchDistance(
        nearestBranch,
        _currentLocation,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 0 &&
            constraints.maxHeight > 0 &&
            _isMapReady &&
            !_hasInitialFitted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _tryFitCamera(validBranches);
            }
          });
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Interactive OpenStreetMap using flutter_map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialTarget,
                initialZoom: CoordinateUtils.defaultZoom,
                minZoom: 3.0,
                maxZoom: 18.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
                onPositionChanged: (camera, hasGesture) {
                  if ((camera.rotation - _rotationNotifier.value).abs() > 0.5) {
                    _rotationNotifier.value = camera.rotation;
                  }
                },
                onMapReady: () {
                  _isMapReady = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _tryFitCamera(validBranches);
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.carwashapp',
                  maxZoom: 19,
                  errorTileCallback: (tile, error, stackTrace) {
                    if (!_hasTileError && mounted) {
                      setState(() => _hasTileError = true);
                    }
                  },
                ),
                MarkerLayer(markers: _buildMarkers(displayedBranches)),
              ],
            ),

            // Sleek Top Header: Floating Search Bar & Status Row
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Floating Search Bar Card
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.champagneGold.withValues(alpha: 0.4),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // if (isStandalone)
                          //   IconButton(
                          //     icon: const Icon(
                          //       Icons.arrow_back_ios_new,
                          //       size: 18,
                          //       color: AppColors.deepNavy,
                          //     ),
                          //     tooltip: 'Back',
                          //     onPressed: () => Navigator.maybePop(context),
                          //   )
                          // else
                          Padding(
                            padding: EdgeInsets.only(left: 14, right: 6),
                            child: Icon(
                              Icons.search,
                              size: 20,
                              color: AppColors.champagneGold,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                color: AppColors.charcoal,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Search branches or areas...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF536471),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 4,
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF536471),
                              ),
                              tooltip: 'Clear',
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              size: 20,
                              color: AppColors.deepNavy,
                            ),
                            tooltip: 'Refresh Branches',
                            onPressed: _refreshAll,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Compact Status & Location Summary Bar
                    Row(
                      children: [
                        // Available branch badge (matches expected text '1 Branch Available' / 'X Branches Available')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.deepNavy,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.champagneGold.withValues(
                                alpha: 0.5,
                              ),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.storefront,
                                size: 14,
                                color: AppColors.champagneGold,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${displayedBranches.length} ${displayedBranches.length == 1 ? "Branch Available" : "Branches Available"}',
                                style: const TextStyle(
                                  color: AppColors.pureWhite,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Nearest branch info or 'Tap marker for details'
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite.withValues(
                                alpha: 0.95,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.subtleBorder,
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              nearestBranch != null && nearestDistance != null
                                  ? 'Nearest: ${nearestBranch.name} ($nearestDistance)'
                                  : 'Tap marker for details',
                              style: const TextStyle(
                                color: Color(0xFF536471),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Dropdown results when searching
                    if (_searchQuery.isNotEmpty) ...[
                      if (displayedBranches.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.champagneGold.withValues(
                                alpha: 0.4,
                              ),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: displayedBranches.length,
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              color: AppColors.subtleBorder,
                            ),
                            itemBuilder: (context, index) {
                              final b = displayedBranches[index];
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                leading: const Icon(
                                  Icons.location_on,
                                  size: 18,
                                  color: AppColors.champagneGold,
                                ),
                                title: Text(
                                  b.name,
                                  style: const TextStyle(
                                    color: AppColors.charcoal,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: b.fullAddress.isNotEmpty
                                    ? Text(
                                        b.fullAddress,
                                        style: const TextStyle(
                                          color: Color(0xFF536471),
                                          fontSize: 11,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _mapController.move(
                                    LatLng(b.latitude!, b.longitude!),
                                    15.0,
                                  );
                                  _handleBranchSelected(b);
                                },
                              );
                            },
                          ),
                        )
                      else
                        // Empty / No-results state
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pureWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.subtleBorder,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 20,
                                color: Color(0xFF536471),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No branches found for "$_searchQuery"',
                                      style: const TextStyle(
                                        color: AppColors.charcoal,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Try searching with a different name or city',
                                      style: TextStyle(
                                        color: Color(0xFF536471),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Tile loading warning notice (if offline or tiles slow)
            if (_hasTileError)
              Positioned(
                top: 96,
                left: 16,
                right: 16,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.deepNavy.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.8),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_queue,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'We are coming soon',
                            style: TextStyle(
                              color: AppColors.pureWhite,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white70,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () =>
                              setState(() => _hasTileError = false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Dedicated Screen-Level Controls Overlay (Vertically centered along the right edge)
            _buildControlsOverlay(validBranches),

            // Independent Floating Snackbar Overlay
            _buildSnackbarOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildControlsOverlay(List<Branch> validBranches) {
    return Positioned(
      right: 16.0,
      bottom: _controlsBottomOffset,
      child: SizedBox(
        width: 56.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. North-Centred Compass Button
            FloatingActionButton.small(
              heroTag: 'osm_compass_btn',
              backgroundColor: AppColors.deepNavy,
              foregroundColor: AppColors.champagneGold,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.champagneGold.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              tooltip: 'Reset North',
              onPressed: () {
                _mapController.rotate(0.0);
                _rotationNotifier.value = 0.0;
              },
              child: ValueListenableBuilder<double>(
                valueListenable: _rotationNotifier,
                builder: (context, rotation, _) {
                  return Transform.rotate(
                    angle: (rotation * math.pi / 180),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: 15,
                          color: AppColors.champagneGold,
                        ),
                        Text(
                          'N',
                          style: TextStyle(
                            color: AppColors.champagneGold,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8.0),

            // 2. Zoom In Button
            FloatingActionButton.small(
              heroTag: 'osm_zoom_in_btn',
              backgroundColor: AppColors.pureWhite,
              foregroundColor: AppColors.deepNavy,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: AppColors.subtleBorder,
                  width: 1.0,
                ),
              ),
              tooltip: 'Zoom In',
              onPressed: () {
                final currentZoom = _mapController.camera.zoom;
                _mapController.move(
                  _mapController.camera.center,
                  currentZoom + 1.0,
                );
              },
              child: const Icon(Icons.add, size: 20),
            ),
            const SizedBox(height: 8.0),

            // 3. Zoom Out Button
            FloatingActionButton.small(
              heroTag: 'osm_zoom_out_btn',
              backgroundColor: AppColors.pureWhite,
              foregroundColor: AppColors.deepNavy,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(
                  color: AppColors.subtleBorder,
                  width: 1.0,
                ),
              ),
              tooltip: 'Zoom Out',
              onPressed: () {
                final currentZoom = _mapController.camera.zoom;
                _mapController.move(
                  _mapController.camera.center,
                  currentZoom - 1.0,
                );
              },
              child: const Icon(Icons.remove, size: 20),
            ),
            const SizedBox(height: 8.0),

            // 4. Location FAB (bottom)
            FloatingActionButton(
              heroTag: 'osm_my_location_btn',
              backgroundColor: AppColors.deepNavy,
              foregroundColor: AppColors.champagneGold,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                  color: AppColors.champagneGold,
                  width: 1.2,
                ),
              ),
              tooltip: 'My Location',
              onPressed: () => _handleMyLocation(validBranches),
              child: _isLocating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.champagneGold,
                      ),
                    )
                  : const Icon(Icons.my_location),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoValidCoordinatesLayout(List<Branch> branches) {
    final bottomOffset = _controlsBottomOffset;

    return Stack(
      children: [
        // Base OpenStreetMap centered on default region
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: CoordinateUtils.defaultLocation,
            initialZoom: 8.0,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.carwashapp',
            ),
          ],
        ),

        // Bottom sheet card with branches for direct contact
        Positioned(
          left: 16,
          right: 16,
          bottom: bottomOffset,
          top: 16,
          child: SafeArea(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.subtleBorder),
              ),
              elevation: 6,
              color: AppColors.pureWhite,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_off_outlined,
                          color: AppColors.warning,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Coordinates Unavailable',
                            style: AppTextStyles.title.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Map coordinates are currently being updated. You can connect with any branch directly via WhatsApp below:',
                      style: AppTextStyles.bodySecondary,
                    ),
                    const Divider(height: 20, color: AppColors.subtleBorder),
                    Expanded(
                      child: ListView.separated(
                        itemCount: branches.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final branch = branches[i];
                          final rawWhatsApp =
                              branch.whatsappNumber?.trim() ?? '';
                          final hasWhatsApp =
                              WhatsAppHelper.normalizePhone(rawWhatsApp) !=
                              null;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.softWhite,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.subtleBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.storefront,
                                  color: AppColors.champagneGold,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        branch.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.deepNavy,
                                        ),
                                      ),
                                      if (branch.fullAddress.isNotEmpty)
                                        Text(
                                          branch.fullAddress,
                                          style: AppTextStyles.caption,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasWhatsApp
                                        ? const Color(0xFF25D366)
                                        : Colors.grey.shade400,
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                  ),
                                  icon: const Icon(Icons.chat, size: 14),
                                  label: const Text(
                                    'WhatsApp',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () =>
                                      BranchDetailsBottomSheet.show(
                                        context,
                                        branch,
                                        userLocation: _currentLocation,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
