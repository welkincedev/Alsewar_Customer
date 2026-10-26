import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../auth/models/auth_user.dart';
import '../../services/models/service_item.dart';
import '../../services/screens/service_detail_screen.dart';
import '../../services/screens/services_screen.dart';

/// Al Sewar Home Screen Service Shortcuts Grid.
///
/// Replaces generic quick actions with actual Al Sewar service categories
/// extracted directly from Al Sewar Company Profile.pdf.
///
/// Features a responsive 2×4 grid of 8 equal-sized shortcuts:
/// - 7 verified flagship services:
///     1. Tyre Services (Tyre Changing & Balancing)
///     2. Auto Repair & Maintenance (Mechanical)
///     3. Oil Change & Battery
///     4. Car Wash
///     5. Car Ceramic Coating
///     6. AC Repair & Servicing
///     7. Car Painting (Body Services)
/// - 8th "More" shortcut navigating to the complete Available Services catalogue.
///
/// Design attributes:
/// - Approved Option A Champagne Gold metallic gradient.
/// - Consistent outline icons with identical stroke weight (#171717).
/// - Glossy automotive clear-coat top highlight.
/// - Clear "Our Services" section heading with "VIEW ALL" link.
/// - Responsive tile dimensions with graceful text scaling across 320, 360, 390 and 480px.
class HomeQuickActions extends StatelessWidget {
  final AuthUser? user;
  final void Function(ServiceItem service)? onServiceTap;
  final VoidCallback? onMoreTap;
  final VoidCallback? onViewAllTap;

  // Legacy callbacks preserved for backwards compatibility with existing tests
  final VoidCallback? onBranchesTap;
  final VoidCallback? onServicesTap;
  final VoidCallback? onHistoryTap;
  final VoidCallback? onVehiclesTap;
  final String? selectedAction;

  const HomeQuickActions({
    super.key,
    this.user,
    this.onServiceTap,
    this.onMoreTap,
    this.onViewAllTap,
    this.onBranchesTap,
    this.onServicesTap,
    this.onHistoryTap,
    this.onVehiclesTap,
    this.selectedAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 16.0 : 20.0;
    final cardGap = screenWidth < 360 ? 6.0 : 8.0;

    final services = AlSewarServiceCatalog.homeShortcutServices;

    // 8 items arranged in 2 rows of 4 items
    final row1 = services.take(4).toList();
    final row2Services = services.skip(4).take(3).toList();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header: Title & "VIEW ALL" ─────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Our Services', style: AppTextStyles.sectionHeading),
                      const SizedBox(height: 2),
                      const Text(
                        'Certified care across UAE bays',
                        style: TextStyle(
                          fontFamily: AppTextStyles.bodyFont,
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap:
                      onViewAllTap ??
                      onServicesTap ??
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServicesScreen(),
                        ),
                      ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'VIEW ALL',
                          style: TextStyle(
                            fontFamily: AppTextStyles.bodyFont,
                            color: AppColors.champagneGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.champagneGold,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Row 1 (4 items) ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                for (int i = 0; i < row1.length; i++) ...[
                  Expanded(
                    child: _ServiceShortcutTile(
                      title: row1[i].displayShortName,
                      icon: row1[i].effectiveIcon,
                      onTap: () {
                        if (onServiceTap != null) {
                          onServiceTap!(row1[i]);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailScreen(service: row1[i]),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  if (i != row1.length - 1) SizedBox(width: cardGap),
                ],
              ],
            ),
          ),
          SizedBox(height: cardGap),

          // ── Row 2 (3 services + 1 "More" shortcut) ──────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                for (int i = 0; i < row2Services.length; i++) ...[
                  Expanded(
                    child: _ServiceShortcutTile(
                      title: row2Services[i].displayShortName,
                      icon: row2Services[i].effectiveIcon,
                      onTap: () {
                        if (onServiceTap != null) {
                          onServiceTap!(row2Services[i]);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ServiceDetailScreen(service: row2Services[i]),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: cardGap),
                ],
                // 8th item: "More" Shortcut
                Expanded(
                  child: _ServiceShortcutTile(
                    title: 'More',
                    icon: Icons.grid_view_rounded,
                    isMore: true,
                    onTap:
                        onMoreTap ??
                        onServicesTap ??
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ServicesScreen(),
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceShortcutTile extends StatefulWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMore;

  const _ServiceShortcutTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isMore = false,
  });

  @override
  State<_ServiceShortcutTile> createState() => _ServiceShortcutTileState();
}

class _ServiceShortcutTileState extends State<_ServiceShortcutTile> {
  bool _isPressed = false;

  static const Color champagneLight = Color(0xFFFFE5A3);
  static const Color champagne = Color(0xFFC6A66B);
  static const Color champagneDark = Color(0xFFE0B83F);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.title,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 82,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [champagneLight, champagne, champagneDark],
                stops: [0.0, 0.55, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8B76E), width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC6A66B)
                      .withValues(alpha: _isPressed ? 0.10 : 0.22),
                  blurRadius: _isPressed ? 4 : 10,
                  offset: Offset(0, _isPressed ? 1 : 4),
                ),
                const BoxShadow(
                  color: Colors.white54,
                  blurRadius: 2,
                  offset: Offset(-1, -1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle glossy top highlight simulating automotive clear coat
                Positioned(
                  top: 1,
                  left: 4,
                  right: 4,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.38),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 24,
                          color: const Color(0xFF171717),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF171717),
                              letterSpacing: -0.1,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
