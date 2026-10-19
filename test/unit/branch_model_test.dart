import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/features/branches/models/branch.dart';

void main() {
  group('Branch Model Tests', () {
    test('fromJson correctly parses complete Branch data', () {
      final json = {
        'id': 1,
        'name': 'Main Branch',
        'code': 'BR001',
        'address': '123 Main Street',
        'city': 'Dubai',
        'phone': '+97140000000',
        'email': 'main@alsewar.com',
        'latitude': 25.2048,
        'longitude': 55.2708,
        'is_active': true,
      };

      final branch = Branch.fromJson(json);

      expect(branch.id, 1);
      expect(branch.name, 'Main Branch');
      expect(branch.code, 'BR001');
      expect(branch.address, '123 Main Street');
      expect(branch.city, 'Dubai');
      expect(branch.phone, '+97140000000');
      expect(branch.email, 'main@alsewar.com');
      expect(branch.latitude, 25.2048);
      expect(branch.longitude, 55.2708);
      expect(branch.isActive, true);
      expect(branch.fullAddress, '123 Main Street, Dubai');
    });

    test(
      'fromJson handles null coordinates and missing optional fields safely',
      () {
        final json = {
          'id': 2,
          'name': 'Branch Two',
          'code': 'BR002',
          'address': '456 Secondary Rd',
          'city': 'Abu Dhabi',
          'phone': '',
          'email': '',
          'latitude': null,
          'longitude': null,
        };

        final branch = Branch.fromJson(json);

        expect(branch.id, 2);
        expect(branch.latitude, isNull);
        expect(branch.longitude, isNull);
        expect(branch.isActive, true);
      },
    );

    test('toJson produces valid Map structure', () {
      const branch = Branch(
        id: 3,
        name: 'Sharjah Branch',
        code: 'BR003',
        address: 'Al Majaz',
        city: 'Sharjah',
        phone: '065000000',
        email: 'sharjah@alsewar.com',
        latitude: 25.3463,
        longitude: 55.4209,
        isActive: false,
      );

      final json = branch.toJson();

      expect(json['id'], 3);
      expect(json['name'], 'Sharjah Branch');
      expect(json['city'], 'Sharjah');
      expect(json['is_active'], false);
    });
  });
}
