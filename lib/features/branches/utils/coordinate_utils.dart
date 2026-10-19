import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/branch.dart';

/// Utilities for validating geographic coordinates and computing map camera bounds.
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

    final points =
        validBranches
            .map((b) => LatLng(b.latitude!, b.longitude!))
            .toList(growable: false);

    return LatLngBounds.fromPoints(points);
  }
}
