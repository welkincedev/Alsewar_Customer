import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/branch.dart';

/// Utilities for validating geographic coordinates, computing map camera bounds,
/// and calculating distances using the Haversine formula.
class CoordinateUtils {
  CoordinateUtils._();

  /// Sensible default camera location (Riyadh / Central GCC region).
  static const LatLng defaultLocation = LatLng(24.7136, 46.6753);
  static const double defaultZoom = 11.0;

  /// Checks if latitude and longitude form a valid, usable coordinate.
  ///
  /// - Latitude must be between -90.0 and +90.0.
  /// - Longitude must be between -180.0 and +180.0.
  /// - Excludes 0.0, 0.0 ("Null Island") which indicates unconfigured backend data.
  static bool isValid(double? latitude, double? longitude) {
    if (latitude == null || longitude == null) return false;
    if (latitude < -90.0 || latitude > 90.0) return false;
    if (longitude < -180.0 || longitude > 180.0) return false;
    // Exclude 0,0 uninitialized coordinates
    if (latitude == 0.0 && longitude == 0.0) return false;
    return true;
  }

  /// Filters a list of branches to only those with valid geographic coordinates.
  static List<Branch> filterValidBranches(List<Branch> branches) {
    return branches.where((b) => isValid(b.latitude, b.longitude)).toList();
  }

  /// Computes a [LatLngBounds] bounding box enclosing all valid branches.
  ///
  /// Returns `null` if the list of valid branches is empty.
  static LatLngBounds? computeBounds(List<Branch> validBranches) {
    if (validBranches.isEmpty) return null;

    final points = validBranches
        .map((b) => LatLng(b.latitude!, b.longitude!))
        .toList(growable: false);

    return LatLngBounds.fromPoints(points);
  }

  /// Calculates the great-circle distance between two geographic coordinates in meters
  /// using the Haversine formula.
  static double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMeters = 6371000.0;
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Formats distance in meters into a user-friendly Desert Luxe label:
  /// - Below 1 km: e.g. `650 m away`
  /// - 1 km or more: e.g. `2.4 km away`, `5.8 km away`, `12 km away`
  static String formatDistance(double meters) {
    if (meters < 0) return '';
    if (meters < 1000) {
      return '${meters.round()} m away';
    }
    final km = meters / 1000.0;
    if (km >= 100) {
      return '${km.round()} km away';
    }
    final fixed1 = km.toStringAsFixed(1);
    if (fixed1.endsWith('.0')) {
      return '${km.toStringAsFixed(0)} km away';
    }
    return '$fixed1 km away';
  }

  /// Calculates the distance in meters between [userLocation] and a [branch].
  ///
  /// Returns `null` if [userLocation] is null or [branch] coordinates are invalid/missing.
  static double? getBranchDistance(Branch branch, LatLng? userLocation) {
    if (userLocation == null) return null;
    if (!isValid(branch.latitude, branch.longitude)) return null;
    return calculateDistanceInMeters(
      userLocation.latitude,
      userLocation.longitude,
      branch.latitude!,
      branch.longitude!,
    );
  }

  /// Returns a formatted distance string (e.g. `2.4 km away`) for [branch],
  /// or `null` if [userLocation] is null or [branch] coordinates are invalid/missing.
  static String? getFormattedBranchDistance(
    Branch branch,
    LatLng? userLocation,
  ) {
    final dist = getBranchDistance(branch, userLocation);
    if (dist == null) return null;
    return formatDistance(dist);
  }

  /// Returns a copy of [branches] sorted by ascending distance from [userLocation].
  /// Branches with invalid or missing coordinates are placed at the end.
  static List<Branch> sortByDistance(
    List<Branch> branches,
    LatLng userLocation,
  ) {
    final list = List<Branch>.from(branches);
    list.sort((a, b) {
      final aValid = isValid(a.latitude, a.longitude);
      final bValid = isValid(b.latitude, b.longitude);
      if (!aValid && !bValid) return 0;
      if (!aValid) return 1;
      if (!bValid) return -1;
      final distA = calculateDistanceInMeters(
        userLocation.latitude,
        userLocation.longitude,
        a.latitude!,
        a.longitude!,
      );
      final distB = calculateDistanceInMeters(
        userLocation.latitude,
        userLocation.longitude,
        b.latitude!,
        b.longitude!,
      );
      return distA.compareTo(distB);
    });
    return list;
  }
}
