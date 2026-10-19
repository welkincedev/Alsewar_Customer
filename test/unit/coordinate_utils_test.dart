import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/utils/coordinate_utils.dart';
import 'package:flutter_test/flutter_test.dart';

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
      // minLat is Jeddah (21.5433), maxLat is Riyadh (24.7136)
      expect(bounds!.southWest.latitude, closeTo(21.5433, 0.001));
      expect(bounds.northEast.latitude, closeTo(24.7136, 0.001));
      // minLng is Jeddah (39.1728), maxLng is Riyadh (46.6753)
      expect(bounds.southWest.longitude, closeTo(39.1728, 0.001));
      expect(bounds.northEast.longitude, closeTo(46.6753, 0.001));
    });
  });
}
