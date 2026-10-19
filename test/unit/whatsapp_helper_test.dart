import 'package:carwashapp/core/utils/whatsapp_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WhatsAppHelper Phone Normalization Tests', () {
    test('normalizes international number with + and spaces', () {
      expect(
        WhatsAppHelper.normalizePhone('+966 50 123 4567'),
        equals('966501234567'),
      );
    });

    test('normalizes international number with leading 00', () {
      expect(
        WhatsAppHelper.normalizePhone('00966501234567'),
        equals('966501234567'),
      );
    });

    test('normalizes UAE phone number', () {
      expect(
        WhatsAppHelper.normalizePhone('+971 4 123 4567'),
        equals('97141234567'),
      );
    });

    test('normalizes Saudi local 10-digit number starting with 05', () {
      expect(
        WhatsAppHelper.normalizePhone('0501234567'),
        equals('966501234567'),
      );
    });

    test('normalizes number with parentheses and dashes', () {
      expect(
        WhatsAppHelper.normalizePhone('+966-(50)-123-4567'),
        equals('966501234567'),
      );
    });

    test('returns null for empty or null strings', () {
      expect(WhatsAppHelper.normalizePhone(null), isNull);
      expect(WhatsAppHelper.normalizePhone(''), isNull);
      expect(WhatsAppHelper.normalizePhone('   '), isNull);
    });

    test('returns null for non-numeric or too short numbers', () {
      expect(WhatsAppHelper.normalizePhone('N/A'), isNull);
      expect(WhatsAppHelper.normalizePhone('12345'), isNull); // < 7 digits
    });
  });

  group('WhatsAppHelper URL Generation Tests', () {
    test('generates valid wa.me URL for valid phone', () {
      final uri = WhatsAppHelper.buildWhatsAppUri('+966501234567');
      expect(uri, isNotNull);
      expect(uri.toString(), equals('https://wa.me/966501234567'));
    });

    test('generates wa.me URL with custom text message query', () {
      final uri = WhatsAppHelper.buildWhatsAppUri(
        '+966501234567',
        customMessage: 'Hello Al Sewar Support',
      );
      expect(uri, isNotNull);
      expect(
        uri.toString(),
        equals('https://wa.me/966501234567?text=Hello+Al+Sewar+Support'),
      );
    });

    test('returns null URI for invalid or missing phone', () {
      expect(WhatsAppHelper.buildWhatsAppUri(null), isNull);
      expect(WhatsAppHelper.buildWhatsAppUri(''), isNull);
      expect(WhatsAppHelper.buildWhatsAppUri('invalid-phone'), isNull);
    });
  });
}
