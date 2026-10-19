import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/features/auth/models/auth_user.dart';

void main() {
  group('AuthUser Model Tests', () {
    test('fromJson correctly parses complete user data', () {
      final json = {
        'id': 5,
        'username': 'john_doe',
        'email': 'john@example.com',
        'role': 'CUSTOMER',
        'phone': '+971500000002',
        'first_name': 'John',
        'last_name': 'Doe',
        'is_active': true,
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 5);
      expect(user.username, 'john_doe');
      expect(user.email, 'john@example.com');
      expect(user.role, 'CUSTOMER');
      expect(user.phone, '+971500000002');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.isActive, true);
      expect(user.displayName, 'John Doe');
    });

    test('fromJson handles null or missing optional fields safely', () {
      final json = {
        'id': '12',
        'username': 'minimal_user',
        'email': 'min@example.com',
        'role': 'CUSTOMER',
      };

      final user = AuthUser.fromJson(json);

      expect(user.id, 12);
      expect(user.username, 'minimal_user');
      expect(user.phone, isNull);
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.isActive, true);
      expect(user.displayName, 'minimal_user');
    });

    test('fromJson handles inactive account boolean', () {
      final json = {
        'id': 3,
        'username': 'inactive_user',
        'email': 'inactive@example.com',
        'role': 'CUSTOMER',
        'is_active': false,
      };

      final user = AuthUser.fromJson(json);

      expect(user.isActive, false);
    });
  });
}
