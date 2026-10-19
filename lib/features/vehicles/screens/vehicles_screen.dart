import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../visits/models/service_visit.dart';
import '../../visits/viewmodels/visit_providers.dart';
import '../models/vehicle.dart';
import '../models/vehicle_request.dart';
import '../viewmodels/vehicle_providers.dart';

class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  Future<void> _refreshAll() async {
    await Future.wait([
      ref.read(vehicleViewModelProvider.notifier).refresh(),
      ref.read(visitViewModelProvider.notifier).refresh(),
    ]);
  }

  String _getLastServiceDate(Vehicle vehicle, List<ServiceVisit>? visits) {
    if (visits == null || visits.isEmpty) {
      return 'No service yet';
    }

    final matching = visits.where((v) {
      if (v.vehicleId != null && v.vehicleId == vehicle.id) {
        return true;
      }
      final vPlate = v.vehiclePlate.trim().toLowerCase();
      final myPlate = vehicle.plateNumber.trim().toLowerCase();
      return vPlate.isNotEmpty && myPlate.isNotEmpty && vPlate == myPlate;
    }).toList();

    if (matching.isEmpty) {
      return 'No service yet';
    }

    matching.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt);
      final bDate = DateTime.tryParse(b.createdAt);
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });

    final mostRecent = matching.first;
    final dt = DateTime.tryParse(mostRecent.createdAt)?.toLocal();
    if (dt == null) {
      return 'No service yet';
    }
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehicleViewModelProvider);
    final visitsAsync = ref.watch(visitViewModelProvider);
    final visits = visitsAsync.asData?.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
      ),
      backgroundColor: AppColors.backgroundLight,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlack,
        foregroundColor: AppColors.secondaryGold,
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
        onPressed: () => _showVehicleFormSheet(context),
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.secondaryGold),
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
                Text('Could Not Load Vehicles', style: AppTextStyles.heading),
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
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 72,
                      color: AppColors.secondaryGold,
                    ),
                    const SizedBox(height: 20),
                    Text('No Vehicles Yet', style: AppTextStyles.heading),
                    const SizedBox(height: 8),
                    Text(
                      'Add your vehicle to track services and history.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlack,
                      ),
                      icon: const Icon(
                        Icons.add,
                        color: AppColors.secondaryGold,
                      ),
                      label: const Text(
                        'Add Vehicle',
                        style: TextStyle(color: AppColors.secondaryGold),
                      ),
                      onPressed: () => _showVehicleFormSheet(context),
                    ),
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.secondaryGold,
            onRefresh: _refreshAll,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: vehicles.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final v = vehicles[i];
                final lastDate = _getLastServiceDate(v, visits);
                return _VehicleCard(
                  vehicle: v,
                  lastServiceDate: lastDate,
                  onEdit: () => _showVehicleFormSheet(context, vehicle: v),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showVehicleFormSheet(BuildContext context, {Vehicle? vehicle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _VehicleFormSheet(vehicle: vehicle),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final String lastServiceDate;
  final VoidCallback onEdit;

  const _VehicleCard({
    required this.vehicle,
    required this.lastServiceDate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final vehicleName = vehicle.make.isNotEmpty ? vehicle.make : 'Vehicle';
    final modelText = [
      if (vehicle.model.isNotEmpty) vehicle.model,
      if (vehicle.year != null) '(${vehicle.year})',
    ].join(' ');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVehicleImage(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicleName,
                                  style: AppTextStyles.title.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (modelText.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    modelText,
                                    style: AppTextStyles.bodySecondary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            tooltip: 'Edit Vehicle',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onEdit,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPlateBadge(),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              height: 24,
              thickness: 1,
              color: AppColors.borderLight,
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppColors.secondaryGold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Last Service: ',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    lastServiceDate,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: lastServiceDate == 'No service yet'
                          ? AppColors.textLight
                          : AppColors.primaryBlack,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (vehicle.color != null && vehicle.color!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      vehicle.color!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleImage() {
    final hasValidUrl =
        vehicle.imageUrl != null &&
        vehicle.imageUrl!.isNotEmpty &&
        (vehicle.imageUrl!.startsWith('http://') ||
            vehicle.imageUrl!.startsWith('https://'));

    if (hasValidUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          vehicle.imageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPlaceholderContainer(),
        ),
      );
    }
    return _buildPlaceholderContainer();
  }

  Widget _buildPlaceholderContainer() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlack, Color(0xFF262626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryGold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_outlined,
          color: AppColors.secondaryGold,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildPlateBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.secondaryGold.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tag, size: 12, color: AppColors.secondaryGold),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              vehicle.plateNumber.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.primaryBlack,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleFormSheet extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const _VehicleFormSheet({this.vehicle});

  @override
  ConsumerState<_VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<_VehicleFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _plateCtrl;
  late final TextEditingController _makeCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _colorCtrl;
  bool _loading = false;
  String? _error;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    _plateCtrl = TextEditingController(text: widget.vehicle?.plateNumber ?? '');
    _makeCtrl = TextEditingController(text: widget.vehicle?.make ?? '');
    _modelCtrl = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearCtrl = TextEditingController(
      text: widget.vehicle?.year?.toString() ?? '',
    );
    _colorCtrl = TextEditingController(text: widget.vehicle?.color ?? '');
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final req = VehicleRequest(
        plateNumber: _plateCtrl.text.trim(),
        make: _makeCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: _yearCtrl.text.trim().isNotEmpty
            ? int.tryParse(_yearCtrl.text.trim())
            : null,
        color: _colorCtrl.text.trim().isNotEmpty
            ? _colorCtrl.text.trim()
            : null,
      );

      if (_isEditing) {
        await ref
            .read(vehicleViewModelProvider.notifier)
            .updateVehicle(widget.vehicle!.id, req);
      } else {
        await ref.read(vehicleViewModelProvider.notifier).addVehicle(req);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Vehicle updated successfully.'
                  : 'Vehicle registered successfully.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing ? 'Edit Vehicle' : 'Add Vehicle';
    final buttonText = _isEditing ? 'Update Vehicle' : 'Save Vehicle';

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.heading,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              TextFormField(
                controller: _plateCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Plate Number *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _makeCtrl,
                decoration: const InputDecoration(labelText: 'Make *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _modelCtrl,
                decoration: const InputDecoration(labelText: 'Model *'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Year'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorCtrl,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.secondaryGold,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          buttonText,
                          style: const TextStyle(
                            color: AppColors.secondaryGold,
                            fontSize: 16,
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
}
