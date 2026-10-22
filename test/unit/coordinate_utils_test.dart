import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/utils/coordinate_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('CoordinateUtils Validation Tests', () {
    test('identifies valid coordinates correctly', () {
      expect(CoordinateUtils.isValid(24.7136, 46.6753), isTrue); // Riyadh
      expect(CoordinateUtils.isValid(25.2048, 55.2708), isTrue); // Dubai
      expect(CoordinateUtils.isValid(-33.8688, 151.2093), isTrue); // Sydney
    });

    test('rejects null coordinates', () {
      expect(CoordinateUtils.isValid(null, 46.6753), isFalse);
      expect(CoordinateUtils.isValid(24.7136, null), isFalse);
      expect(CoordinateUtils.isValid(null, null), isFalse);
    });

    test('rejects out-of-range coordinates', () {
      expect(CoordinateUtils.isValid(95.0, 46.6753), isFalse); // Lat > 90
      expect(CoordinateUtils.isValid(-95.0, 46.6753), isFalse); // Lat < -90
      expect(CoordinateUtils.isValid(24.7136, 185.0), isFalse); // Lng > 180
      expect(CoordinateUtils.isValid(24.7136, -185.0), isFalse); // Lng < -180
    });

    test('rejects Null Island (0.0, 0.0) placeholder coordinates', () {
      expect(CoordinateUtils.isValid(0.0, 0.0), isFalse);
    });
  });

  group('CoordinateUtils Filter and Bounds Tests', () {
    const validBranch1 = Branch(
      id: 1,
      name: 'Riyadh Main',
      code: 'RUH01',
      address: 'King Fahd Road',
      city: 'Riyadh',
      phone: '+966112345678',
      email: 'ruh@alsewar.com',
      latitude: 24.7136,
      longitude: 46.6753,
    );

    const validBranch2 = Branch(
      id: 2,
      name: 'Jeddah Corniche',
      code: 'JED01',
      address: 'Corniche Road',
      city: 'Jeddah',
      phone: '+966122345678',
      email: 'jed@alsewar.com',
      latitude: 21.5433,
      longitude: 39.1728,
    );

    const invalidBranchNull = Branch(
      id: 3,
      name: 'Dammam Branch',
      code: 'DMM01',
      address: 'Khobar Road',
      city: 'Dammam',
      phone: '+966132345678',
      email: 'dmm@alsewar.com',
      latitude: null,
      longitude: null,
    );

    const invalidBranchZero = Branch(
      id: 4,
      name: 'Unset Branch',
      code: 'UNS01',
      address: 'Unknown Road',
      city: 'Riyadh',
      phone: '+966119999999',
      email: 'unset@alsewar.com',
      latitude: 0.0,
      longitude: 0.0,
    );

    test(
      'filterValidBranches retains only branches with valid coordinates',
      () {
        final list = [
          validBranch1,
          invalidBranchNull,
          validBranch2,
          invalidBranchZero,
        ];
        final filtered = CoordinateUtils.filterValidBranches(list);

        expect(filtered.length, equals(2));
        expect(filtered, contains(validBranch1));
        expect(filtered, contains(validBranch2));
        expect(filtered, isNot(contains(invalidBranchNull)));
        expect(filtered, isNot(contains(invalidBranchZero)));
      },
    );

    test('computeBounds returns null when branch list is empty', () {
      expect(CoordinateUtils.computeBounds([]), isNull);
    });

    test('computeBounds correctly computes enclosing bounding box', () {
      final bounds = CoordinateUtils.computeBounds([
        validBranch1,
        validBranch2,
      ]);
      expect(bounds, isNotNull);
      expect(bounds!.southWest.latitude, closeTo(21.5433, 0.001));
      expect(bounds.northEast.latitude, closeTo(24.7136, 0.001));
      expect(bounds.southWest.longitude, closeTo(39.1728, 0.001));
      expect(bounds.northEast.longitude, closeTo(46.6753, 0.001));
    });
  });

  group('CoordinateUtils Haversine & Distance Formatting Tests', () {
    test('calculateDistanceInMeters calculates accurate distance between known points', () {
      // Riyadh (24.7136, 46.6753) to Jeddah (21.5433, 39.1728) is ~845 km
      final dist = CoordinateUtils.calculateDistanceInMeters(
        24.7136,
        46.6753,
        21.5433,
        39.1728,
      );
      expect(dist / 1000, closeTo(845.0, 10.0));
    });

    test('calculateDistanceInMeters returns 0 for identical coordinates', () {
      final dist = CoordinateUtils.calculateDistanceInMeters(
        24.7136,
        46.6753,
        24.7136,
        46.6753,
      );
      expect(dist, closeTo(0.0, 0.001));
    });

    test('formatDistance formats distances below 1 km as metres', () {
      expect(CoordinateUtils.formatDistance(650.0), '650 m away');
      expect(CoordinateUtils.formatDistance(50.4), '50 m away');
      expect(CoordinateUtils.formatDistance(999.0), '999 m away');
    });

    test(
      'formatDistance formats distances 1 km or above with decimal or integer',
      () {
        expect(CoordinateUtils.formatDistance(2400.0), '2.4 km away');
        expect(CoordinateUtils.formatDistance(5800.0), '5.8 km away');
        expect(CoordinateUtils.formatDistance(12000.0), '12 km away');
        expect(CoordinateUtils.formatDistance(12340.0), '12.3 km away');
        expect(CoordinateUtils.formatDistance(105000.0), '105 km away');
      },
    );

    test('getBranchDistance returns null when user location is null', () {
      const branch = Branch(
        id: 1,
        name: 'Test',
        code: 'T1',
        address: 'Addr',
        city: 'City',
        phone: '123',
        email: 't@t.com',
        latitude: 24.7136,
        longitude: 46.6753,
      );

      expect(CoordinateUtils.getBranchDistance(branch, null), isNull);
      expect(CoordinateUtils.getFormattedBranchDistance(branch, null), isNull);
    });

    test('getBranchDistance returns null when branch coordinates are invalid or missing', () {
      const branchInvalid = Branch(
        id: 2,
        name: 'No Coords',
        code: 'T2',
        address: 'Addr',
        city: 'City',
        phone: '123',
        email: 't@t.com',
        latitude: null,
        longitude: null,
      );

      const userLoc = LatLng(24.7136, 46.6753);
      expect(CoordinateUtils.getBranchDistance(branchInvalid, userLoc), isNull);
      expect(
        CoordinateUtils.getFormattedBranchDistance(branchInvalid, userLoc),
        isNull,
      );
    });

    test('sortByDistance correctly orders branches by ascending distance', () {
      const userLoc = LatLng(24.7136, 46.6753); // Riyadh user

      const nearBranch = Branch(
        id: 1,
        name: 'Olaya Near',
        code: 'NEAR',
        address: 'Olaya St',
        city: 'Riyadh',
        phone: '111',
        email: 'n@a.com',
        latitude: 24.7200,
        longitude: 46.6800, // ~1 km from user
      );

      const farBranch = Branch(
        id: 2,
        name: 'Jeddah Far',
        code: 'FAR',
        address: 'Corniche',
        city: 'Jeddah',
        phone: '222',
        email: 'f@a.com',
        latitude: 21.5433,
        longitude: 39.1728, // ~845 km from user
      );

      const noCoordsBranch = Branch(
        id: 3,
        name: 'Unmapped',
        code: 'UNM',
        address: 'Somewhere',
        city: 'City',
        phone: '333',
        email: 'u@a.com',
        latitude: null,
        longitude: null,
      );

      final sorted = CoordinateUtils.sortByDistance([
        farBranch,
        noCoordsBranch,
        nearBranch,
      ], userLoc);

      expect(sorted.first.id, equals(1)); // Near branch first
      expect(sorted[1].id, equals(2)); // Far branch second
      expect(sorted.last.id, equals(3)); // Unmapped branch last
    });
  });
}
