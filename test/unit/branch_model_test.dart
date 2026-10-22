import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Branch Model Tests', () {
    test(
      'fromJson correctly parses complete Branch data with whatsapp_number',
      () {
        final json = {
          'id': 1,
          'name': 'Muscat Grand Centre',
          'code': 'MCT-01',
          'address': 'Sultan Qaboos St, Building 10',
          'city': 'Muscat',
          'phone': '+96824123456',
          'whatsapp_number': '+96891234567',
          'email': 'muscat@alsewar.com',
          'latitude': '23.5880310',
          'longitude': '58.3829150',
          'is_active': true,
        };

        final branch = Branch.fromJson(json);

        expect(branch.id, 1);
        expect(branch.name, 'Muscat Grand Centre');
        expect(branch.code, 'MCT-01');
        expect(branch.address, 'Sultan Qaboos St, Building 10');
        expect(branch.city, 'Muscat');
        expect(branch.phone, '+96824123456');
        expect(branch.whatsappNumber, '+96891234567');
        expect(branch.email, 'muscat@alsewar.com');
        expect(branch.latitude, closeTo(23.588031, 0.0001));
        expect(branch.longitude, closeTo(58.382915, 0.0001));
        expect(branch.isActive, true);
        expect(branch.fullAddress, 'Sultan Qaboos St, Building 10, Muscat');
      },
    );

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
          'whatsapp_number': null,
        };

        final branch = Branch.fromJson(json);

        expect(branch.id, 2);
        expect(branch.latitude, isNull);
        expect(branch.longitude, isNull);
        expect(branch.whatsappNumber, isNull);
        expect(branch.isActive, true);
      },
    );

    test('toJson produces valid Map structure with whatsapp_number', () {
      const branch = Branch(
        id: 3,
        name: 'Sharjah Branch',
        code: 'BR003',
        address: 'Al Majaz',
        city: 'Sharjah',
        phone: '065000000',
        whatsappNumber: '+971500000000',
        email: 'sharjah@alsewar.com',
        latitude: 25.3463,
        longitude: 55.4209,
        isActive: false,
      );

      final json = branch.toJson();

      expect(json['id'], 3);
      expect(json['name'], 'Sharjah Branch');
      expect(json['city'], 'Sharjah');
      expect(json['phone'], '065000000');
      expect(json['whatsapp_number'], '+971500000000');
      expect(json['is_active'], false);
    });

    test('copyWith creates clone with updated fields', () {
      const original = Branch(
        id: 4,
        name: 'Original Branch',
        code: 'ORG01',
        address: 'Main St',
        city: 'Riyadh',
        phone: '123',
        email: 'orig@alsewar.com',
      );

      final updated = original.copyWith(
        whatsappNumber: '+966509999999',
        name: 'Updated Branch',
      );

      expect(updated.id, 4);
      expect(updated.name, 'Updated Branch');
      expect(updated.whatsappNumber, '+966509999999');
      expect(updated.city, 'Riyadh');
    });
  });
}
