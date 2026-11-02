import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../models/branch.dart';
import '../utils/coordinate_utils.dart';

/// Minimal, premium modal bottom sheet displaying selected branch details
/// with official WhatsApp chat and Google Maps driving directions actions.
class BranchDetailsBottomSheet extends StatelessWidget {
  final Branch branch;
  final LatLng? userLocation;

  const BranchDetailsBottomSheet({
    super.key,
    required this.branch,
    this.userLocation,
  });

  static Future<void> show(
    BuildContext context,
    Branch branch, {
    LatLng? userLocation,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          BranchDetailsBottomSheet(branch: branch, userLocation: userLocation),
    );
  }

  Future<void> _launchDirections(BuildContext context) async {
    final hasValidCoords = CoordinateUtils.isValid(
      branch.latitude,
      branch.longitude,
    );
    if (!hasValidCoords) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Directions unavailable: Branch coordinates are missing or invalid.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${branch.latitude},${branch.longitude}&travelmode=driving';
    final uri = Uri.parse(url);

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open map directions: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawPhone = branch.phone.trim();
    final hasPhone = rawPhone.isNotEmpty;

    final rawWhatsApp = branch.whatsappNumber?.trim() ?? '';
    final hasWhatsApp = rawWhatsApp.isNotEmpty;
    final normalizedWhatsApp = hasWhatsApp
        ? WhatsAppHelper.normalizePhone(rawWhatsApp)
        : null;
    final isWhatsAppAvailable = normalizedWhatsApp != null;

    final rawEmail = branch.email.trim();
    final hasEmail = rawEmail.isNotEmpty;

    final hasValidCoords = CoordinateUtils.isValid(
      branch.latitude,
      branch.longitude,
    );

    final formattedDistance = CoordinateUtils.getFormattedBranchDistance(
      branch,
      userLocation,
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtle Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header Row: Branch Icon, Name, Code, Distance Badge & Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.champagneGold.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                    ),
                    child: const Icon(
                      Icons.storefront,
                      color: AppColors.champagneGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: AppTextStyles.title.copyWith(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: AppColors.deepNavy,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (branch.code.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.subtleBorder,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  'Branch Code: ${branch.code}',
                                  style: AppTextStyles.caption.copyWith(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: const Color(0xFF536471),
                                  ),
                                ),
                              ),
                            if (formattedDistance != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.offWhite,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.champagneGold.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.near_me_outlined,
                                      size: 11,
                                      color: AppColors.champagneGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      formattedDistance,
                                      style: const TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.champagneGold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFF536471),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close',
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Contact & Location Details Surface
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.subtleBorder, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Address
                    _buildDetailRow(
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.champagneGold,
                      label: 'Full Address',
                      value: branch.fullAddress.isNotEmpty
                          ? branch.fullAddress
                          : 'Olaya Street, Al Olaya District, Riyadh',
                    ),

                    // Phone Number
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, color: AppColors.subtleBorder),
                    ),
                    _buildDetailRow(
                      icon: Icons.phone_outlined,
                      iconColor: AppColors.champagneGold,
                      label: 'Contact Phone',
                      value: hasPhone ? rawPhone : 'Not available',
                      onCopy: hasPhone
                          ? () => _copyToClipboard(
                              context,
                              rawPhone,
                              'Phone number copied.',
                            )
                          : null,
                      copyTooltip: 'Copy Phone',
                    ),

                    // WhatsApp Contact (if available)
                    if (hasWhatsApp) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          color: AppColors.subtleBorder,
                        ),
                      ),
                      _buildDetailRow(
                        icon: Icons.chat_bubble_outline,
                        iconColor: const Color(0xFF25D366),
                        label: 'WhatsApp Contact',
                        value: rawWhatsApp,
                        onCopy: () => _copyToClipboard(
                          context,
                          rawWhatsApp,
                          'WhatsApp number copied.',
                        ),
                        copyTooltip: 'Copy WhatsApp',
                      ),
                    ],

                    // Email Address (if available)
                    if (hasEmail) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          color: AppColors.subtleBorder,
                        ),
                      ),
                      _buildDetailRow(
                        icon: Icons.email_outlined,
                        iconColor: AppColors.champagneGold,
                        label: 'Email Address',
                        value: rawEmail,
                        onCopy: () => _copyToClipboard(
                          context,
                          rawEmail,
                          'Email copied.',
                        ),
                        copyTooltip: 'Copy Email',
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Side-by-Side Action Buttons: WhatsApp & Get Directions
              Row(
                children: [
                  // Official WhatsApp Green Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: isWhatsAppAvailable
                              ? const Color(0xFF25D366)
                              : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: const Icon(Icons.chat, size: 18),
                        label: Text(
                          isWhatsAppAvailable
                              ? 'WhatsApp'
                              : 'WhatsApp Unavailable',
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: isWhatsAppAvailable
                            ? () => WhatsAppHelper.launchWhatsApp(
                                context,
                                rawWhatsApp,
                                branchName: branch.name,
                              )
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'No WhatsApp contact number is available for ${branch.name}.',
                                    ),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Deep Navy Get Directions Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: hasValidCoords
                              ? AppColors.deepNavy
                              : Colors.grey.shade400,
                          foregroundColor: hasValidCoords
                              ? AppColors.champagneGold
                              : Colors.white,
                          side: hasValidCoords
                              ? BorderSide(
                                  color: AppColors.champagneGold.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 1.0,
                                )
                              : BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        icon: Icon(
                          Icons.directions,
                          size: 18,
                          color: hasValidCoords
                              ? AppColors.champagneGold
                              : Colors.white,
                        ),
                        label: const Text(
                          'Get Directions',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: hasValidCoords
                            ? () => _launchDirections(context)
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Directions unavailable: Branch coordinates are missing or invalid.',
                                    ),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                              },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    VoidCallback? onCopy,
    String? copyTooltip,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF536471),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (onCopy != null)
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 16),
            color: AppColors.champagneGold,
            tooltip: copyTooltip,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onCopy,
          ),
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
