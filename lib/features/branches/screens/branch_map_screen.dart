import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../models/branch.dart';
import '../utils/coordinate_utils.dart';
import '../viewmodels/branch_viewmodel.dart';
import '../widgets/branch_details_bottom_sheet.dart';

/// Interactive OpenStreetMap screen displaying active Al Sewar Auto Center branches.
class BranchMapScreen extends ConsumerStatefulWidget {
  const BranchMapScreen({super.key});

  @override
  ConsumerState<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends ConsumerState<BranchMapScreen> {
  final MapController _mapController = MapController();
  Branch? _selectedBranch;
  bool _hasInitialFitted = false;
  bool _hasTileError = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _refreshAll() async {
    setState(() {
      _hasInitialFitted = false;
      _hasTileError = false;
    });
    await ref.read(branchListViewModelProvider.notifier).refresh();
  }

  void _fitCameraToBounds(List<Branch> validBranches) {
    if (validBranches.isEmpty) return;

    if (validBranches.length == 1) {
      final b = validBranches.first;
      _mapController.move(LatLng(b.latitude!, b.longitude!), 14.0);
    } else {
      final bounds = CoordinateUtils.computeBounds(validBranches);
      if (bounds != null) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.only(
              left: 48,
              right: 48,
              top: 96,
              bottom: 96,
            ),
          ),
        );
      }
    }
  }

  List<Marker> _buildMarkers(List<Branch> validBranches) {
    return validBranches
        .map((branch) {
          final isSelected = _selectedBranch?.id == branch.id;
          return Marker(
            point: LatLng(branch.latitude!, branch.longitude!),
            width: 46,
            height: 46,
            alignment: Alignment.center,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleBranchSelected(branch),
              child: Tooltip(
                message: branch.name,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlack
                        : AppColors.secondaryGold,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.secondaryGold
                          : AppColors.primaryBlack,
                      width: isSelected ? 3.0 : 2.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.storefront,
                    size: 22,
                    color: isSelected
                        ? AppColors.secondaryGold
                        : AppColors.primaryBlack,
                  ),
                ),
              ),
            ),
          );
        })
        .toList(growable: false);
  }

  void _handleBranchSelected(Branch branch) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedBranch = branch);
    BranchDetailsBottomSheet.show(context, branch);
  }

  @override
  Widget build(BuildContext context) {
    final branchAsync = ref.watch(branchListViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Branch Locations'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Branches',
            onPressed: _refreshAll,
          ),
        ],
      ),
      body: branchAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.secondaryGold),
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
                    backgroundColor: AppColors.primaryBlack,
                  ),
                  icon: const Icon(
                    Icons.refresh,
                    color: AppColors.secondaryGold,
                  ),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(color: AppColors.secondaryGold),
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
                      color: AppColors.secondaryGold,
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
                        backgroundColor: AppColors.primaryBlack,
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.secondaryGold,
                      ),
                      label: const Text(
                        'Refresh',
                        style: TextStyle(color: AppColors.secondaryGold),
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

    return Stack(
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
            onMapReady: () {
              if (!_hasInitialFitted) {
                _hasInitialFitted = true;
                _fitCameraToBounds(validBranches);
              }
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
            MarkerLayer(markers: _buildMarkers(validBranches)),
            RichAttributionWidget(
              animationConfig: const ScaleRAWA(),
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://openstreetmap.org/copyright',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),

        // Floating Header: Branch Count & Summary
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlack.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.secondaryGold.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.storefront,
                      size: 16,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${validBranches.length} ${validBranches.length == 1 ? "Branch Available" : "Branches Available"}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    'Tap marker for details',
                    style: TextStyle(
                      color: AppColors.secondaryGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tile loading warning notice (if offline or tiles slow)
        if (_hasTileError)
          Positioned(
            top: 76,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.8),
                  ),
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
                        'Map tiles loading slowly. Branch markers remain active.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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
                      onPressed: () => setState(() => _hasTileError = false),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Floating Action Buttons: Zoom Controls & Recenter
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'osm_zoom_in_btn',
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: AppColors.secondaryGold,
                tooltip: 'Zoom In',
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(
                    _mapController.camera.center,
                    currentZoom + 1.0,
                  );
                },
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.small(
                heroTag: 'osm_zoom_out_btn',
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: AppColors.secondaryGold,
                tooltip: 'Zoom Out',
                onPressed: () {
                  final currentZoom = _mapController.camera.zoom;
                  _mapController.move(
                    _mapController.camera.center,
                    currentZoom - 1.0,
                  );
                },
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'osm_recenter_map_btn',
                backgroundColor: AppColors.primaryBlack,
                foregroundColor: AppColors.secondaryGold,
                elevation: 4,
                tooltip: 'Fit All Branches',
                onPressed: () => _fitCameraToBounds(validBranches),
                child: const Icon(Icons.center_focus_strong),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoValidCoordinatesLayout(List<Branch> branches) {
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
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://openstreetmap.org/copyright',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),

        // Bottom sheet card with branches for direct contact
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          top: 16,
          child: SafeArea(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.borderLight),
              ),
              elevation: 6,
              color: AppColors.backgroundLight,
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
                    const Divider(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: branches.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) {
                          final branch = branches[i];
                          final hasPhone =
                              WhatsAppHelper.normalizePhone(branch.phone) !=
                              null;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.storefront,
                                  color: AppColors.secondaryGold,
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
                                    backgroundColor: hasPhone
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
