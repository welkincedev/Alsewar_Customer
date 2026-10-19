import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/features/auth/models/signup_request.dart';

void main() {
  group('SignupRequest Model Tests', () {
    test(
      'toJson produces correct payload without confirm_password or role',
      () {
        const request = SignupRequest(
          username: 'john_doe',
          email: 'john@example.com',
          password: 'SecretPassword123!',
          phone: '9876543210',
          firstName: 'John',
          lastName: 'Doe',
        );

        final json = request.toJson();

        expect(json, {
          'username': 'john_doe',
          'email': 'john@example.com',
          'password': 'SecretPassword123!',
          'phone': '9876543210',
          'first_name': 'John',
          'last_name': 'Doe',
        });
        expect(json.containsKey('role'), false);
        expect(json.containsKey('confirm_password'), false);
      },
    );

    test('toJson omits empty optional fields', () {
      const request = SignupRequest(
        username: 'jane_doe',
        email: 'jane@example.com',
        password: 'Password123',
        phone: '',
        firstName: '   ',
        lastName: null,
      );

      final json = request.toJson();

      expect(json, {
        'username': 'jane_doe',
        'email': 'jane@example.com',
        'password': 'Password123',
      });
    });
  });
}
