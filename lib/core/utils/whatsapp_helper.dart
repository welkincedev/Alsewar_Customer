import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/app_colors.dart';

/// Helper for normalizing phone numbers and creating WhatsApp wa.me links.
class WhatsAppHelper {
  WhatsAppHelper._();

  /// Normalizes a raw phone number into an international numeric string for wa.me URLs.
  ///
  /// - Strips all non-digit characters (spaces, +, -, parentheses, etc.).
  /// - Strips leading '00' international prefix.
  /// - Expands Saudi local mobile format '05XXXXXXXX' (10 digits) to '9665XXXXXXXX'.
  /// - Ensures standard international length between 7 and 15 digits.
  /// - Returns null if the phone is null, empty, or cannot be normalized.
  static String? normalizePhone(String? rawPhone) {
    if (rawPhone == null) return null;
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) return null;

    // Remove all non-digit characters
    String digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;

    // Remove leading '00' international access code
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    // Convert Saudi Arabia local mobile prefix (05XXXXXXXX, 10 digits) -> 9665XXXXXXXX
    if (digits.startsWith('05') && digits.length == 10) {
      digits = '966${digits.substring(1)}';
    }

    // Standard E.164 phone numbers must be between 7 and 15 digits
    if (digits.length < 7 || digits.length > 15) {
      return null;
    }

    return digits;
  }

  /// Builds a valid `https://wa.me/<number>` URI from the given raw phone number.
  ///
  /// Returns `null` if the number cannot be normalized.
  static Uri? buildWhatsAppUri(String? rawPhone, {String? customMessage}) {
    final normalized = normalizePhone(rawPhone);
    if (normalized == null) return null;

    final queryParams = <String, String>{};
    if (customMessage != null && customMessage.trim().isNotEmpty) {
      queryParams['text'] = customMessage.trim();
    }

    return Uri(
      scheme: 'https',
      host: 'wa.me',
      path: normalized,
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  /// Opens the WhatsApp conversation for the given phone number with graceful error handling.
  static Future<bool> launchWhatsApp(
    BuildContext context,
    String? rawPhone, {
    String? branchName,
    String? customMessage,
  }) async {
    final uri = buildWhatsAppUri(rawPhone, customMessage: customMessage);

    if (uri == null) {
      if (context.mounted) {
        final label = (branchName != null && branchName.trim().isNotEmpty)
            ? 'for ${branchName.trim()}'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No valid WhatsApp contact number available $label.'.trim(),
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open WhatsApp. Please ensure WhatsApp is installed on your device.',
            ),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return launched;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to connect to WhatsApp: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return false;
    }
  }
}
