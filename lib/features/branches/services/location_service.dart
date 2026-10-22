import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationResultStatus {
  success,
  servicesDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  gpsUnavailable,
  error,
}

class LocationResult {
  final LocationResultStatus status;
  final LatLng? position;
  final String? errorMessage;

  const LocationResult({
    required this.status,
    this.position,
    this.errorMessage,
  });

  bool get isSuccess =>
      status == LocationResultStatus.success && position != null;
}

/// Service that coordinates device GPS location retrieval and permissions.
class LocationService {
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Obtains the current device GPS position with full permission and service checks.
  Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult(
          status: LocationResultStatus.servicesDisabled,
          errorMessage: 'Location services are disabled on your device. Please enable GPS to locate nearby branches.',
        );
      }

      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          return const LocationResult(
            status: LocationResultStatus.permissionDenied,
            errorMessage: 'Location permission was denied. Please allow location access to find the nearest branches.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(
          status: LocationResultStatus.permissionPermanentlyDenied,
          errorMessage: 'Location permission is permanently denied. Please enable it in device settings to use this feature.',
        );
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ),
        );

        return LocationResult(
          status: LocationResultStatus.success,
          position: LatLng(position.latitude, position.longitude),
        );
      } on TimeoutException {
        // Fallback to last known location if GPS acquisition timed out
        try {
          final lastKnown = await Geolocator.getLastKnownPosition();
          if (lastKnown != null) {
            return LocationResult(
              status: LocationResultStatus.success,
              position: LatLng(lastKnown.latitude, lastKnown.longitude),
            );
          }
        } catch (_) {}

        return const LocationResult(
          status: LocationResultStatus.gpsUnavailable,
          errorMessage: 'GPS signal is weak or unavailable. Please ensure you are outdoors or near a window.',
        );
      }
    } catch (e) {
      return LocationResult(
        status: LocationResultStatus.error,
        errorMessage: 'Failed to obtain location: $e',
      );
    }
  }
}
