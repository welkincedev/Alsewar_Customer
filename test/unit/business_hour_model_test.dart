import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/features/branches/models/business_hour.dart';

void main() {
  group('BusinessHour Model & Time Formatting Tests', () {
    test('formattedHours formats 24h string to 12h AM/PM format correctly', () {
      const hour = BusinessHour(
        id: 1,
        dayOfWeek: 1,
        dayName: 'Monday',
        openingTime: '08:30:00',
        closingTime: '21:00:00',
        isClosed: false,
      );

      expect(hour.formattedHours, '8:30 AM - 9:00 PM');
    });

    test('formattedHours formats noon and midnight times correctly', () {
      const noonHour = BusinessHour(
        id: 2,
        dayOfWeek: 2,
        dayName: 'Tuesday',
        openingTime: '12:00:00',
        closingTime: '00:00:00',
        isClosed: false,
      );

      expect(noonHour.formattedHours, '12:00 PM - 12:00 AM');
    });

    test('formattedHours returns "Closed" when isClosed is true or times are missing', () {
      const closedHour = BusinessHour(
        id: 3,
        dayOfWeek: 7,
        dayName: 'Sunday',
        openingTime: null,
        closingTime: null,
        isClosed: true,
      );

      expect(closedHour.formattedHours, 'Closed');
    });
  });
}
