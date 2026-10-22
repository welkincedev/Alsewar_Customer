import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../models/branch.dart';
import '../utils/coordinate_utils.dart';

/// Modal bottom sheet displaying selected branch details with WhatsApp and Google Maps directions actions.
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
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

    // Use branch.whatsappNumber strictly for WhatsApp. Do not substitute regular phone.
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

    // Calculate dynamic distance if userLocation is available and branch coordinates are valid
    final formattedDistance = CoordinateUtils.getFormattedBranchDistance(
      branch,
      userLocation,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Row: Branch Icon, Name, Code, Distance Badge, and Close
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondaryGold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront,
                    color: AppColors.secondaryGold,
                    size: 26,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
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
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                'Branch Code: ${branch.code}',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          // Dynamic Distance Label (Desert Luxe styling with Champagne Gold accent)
                          if (formattedDistance != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlack,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.secondaryGold.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.near_me_outlined,
                                    size: 12,
                                    color: AppColors.secondaryGold,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDistance,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondaryGold,
                                      letterSpacing: 0.2,
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
                  icon: const Icon(Icons.close, color: AppColors.textLight),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 16),

            // Branch Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.secondaryGold,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Full Address',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              branch.fullAddress.isNotEmpty
                                  ? branch.fullAddress
                                  : 'Address not available',
                              style: AppTextStyles.bodyPrimary.copyWith(
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Phone Number
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        color: AppColors.secondaryGold,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Phone',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasPhone ? rawPhone : 'Not available',
                              style: AppTextStyles.bodyPrimary.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasPhone)
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          color: AppColors.secondaryGold,
                          tooltip: 'Copy Phone',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rawPhone));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Phone number copied.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                    ],
                  ),

                  // WhatsApp Number (if available)
                  if (hasWhatsApp) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFF25D366),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WhatsApp Contact',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rawWhatsApp,
                                style: AppTextStyles.bodyPrimary.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          color: AppColors.secondaryGold,
                          tooltip: 'Copy WhatsApp',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rawWhatsApp));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('WhatsApp number copied.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],

                  // Email Address (if available)
                  if (hasEmail) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.secondaryGold,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email Address',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rawEmail,
                                style: AppTextStyles.bodyPrimary.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          color: AppColors.secondaryGold,
                          tooltip: 'Copy Email',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: rawEmail));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email copied.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Two Prominent Side-by-Side Action Buttons: WhatsApp & Get Directions
            Row(
              children: [
                // WhatsApp Button
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: isWhatsAppAvailable
                            ? const Color(0xFF25D366)
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: isWhatsAppAvailable ? 2 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.chat, size: 18),
                      label: Text(
                        isWhatsAppAvailable
                            ? 'WhatsApp'
                            : 'WhatsApp Unavailable',
                        style: const TextStyle(
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

                // Get Directions Button
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: hasValidCoords
                            ? AppColors.primaryBlack
                            : Colors.grey.shade400,
                        foregroundColor: hasValidCoords
                            ? AppColors.secondaryGold
                            : Colors.white,
                        side: hasValidCoords
                            ? BorderSide(
                                color: AppColors.secondaryGold.withValues(
                                  alpha: 0.6,
                                ),
                                width: 1.2,
                              )
                            : BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: hasValidCoords ? 2 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: Icon(
                        Icons.directions,
                        size: 18,
                        color: hasValidCoords
                            ? AppColors.secondaryGold
                            : Colors.white,
                      ),
                      label: const Text(
                        'Get Directions',
                        style: TextStyle(
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
    );
  }
}
