import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';

/// Specification for a single item in [FloatingPillNavBar].
class PillNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? tooltip;

  const PillNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.tooltip,
  });
}

/// A premium floating pill-style bottom navigation bar styled for the
/// Desert Luxe design system.
///
/// Features:
/// - Deep Charcoal background (#1C1C1B) with rounded full-pill shape.
/// - Smooth animated white indicator that slides under the active tab.
/// - Inactive icons/labels in soft Sand Beige (#E9E0D2).
/// - Champagne Gold (#C6A66B) micro-accents for active-state details.
/// - Fully responsive across 320px to large tablet widths.
/// - Minimum 48x48px comfortable touch targets.
class FloatingPillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PillNavItem> items;
  final double height;
  final Color backgroundColor;
  final Color activeIndicatorColor;
  final Color activeContentColor;
  final Color inactiveColor;
  final Color accentColor;

  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = 62.0,
    this.backgroundColor = AppColors.deepCharcoal,
    this.activeIndicatorColor = AppColors.pureWhite,
    this.activeContentColor = AppColors.deepCharcoal,
    this.inactiveColor = AppColors.sandBeige,
    this.accentColor = AppColors.champagneGold,
  }) : assert(
         items.length >= 2,
         'FloatingPillNavBar requires at least 2 items.',
       );

  @override
  Widget build(BuildContext context) {
    final clampedIndex = currentIndex.clamp(0, items.length - 1);

    return Listener(
      behavior: HitTestBehavior.deferToChild,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            // Keep max width bounded for large phones and tablets
            final pillWidth = availableWidth > 440 ? 440.0 : availableWidth;

            return Align(
              alignment: Alignment.center,
              child: Container(
                width: pillWidth,
                height: height,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(height / 2),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.22),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.deepCharcoal.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // ── Animated Sliding Active Indicator ────────────────
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment(
                        items.length > 1
                            ? -1.0 + (2.0 * clampedIndex / (items.length - 1))
                            : 0.0,
                        0.0,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: 1.0 / items.length,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 5.0,
                          ),
                          child: Container(
                            height: height - 12.0,
                            decoration: BoxDecoration(
                              color: activeIndicatorColor,
                              borderRadius: BorderRadius.circular(
                                (height - 12.0) / 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Interactive Navigation Items Row ──────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = index == clampedIndex;

                        return Expanded(
                          child: Tooltip(
                            message: item.tooltip ?? item.label,
                            child: Semantics(
                              selected: isSelected,
                              button: true,
                              label: item.label,
                              child: InkResponse(
                                onTap: () => onTap(index),
                                containedInkWell: true,
                                highlightShape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(height / 2),
                                splashColor: accentColor.withValues(
                                  alpha: 0.15,
                                ),
                                highlightColor: Colors.transparent,
                                child: _NavItemContent(
                                  item: item,
                                  isSelected: isSelected,
                                  activeContentColor: activeContentColor,
                                  inactiveColor: inactiveColor,
                                  isCompact:
                                      items.length >= 5 || pillWidth < 340,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItemContent extends StatelessWidget {
  final PillNavItem item;
  final bool isSelected;
  final Color activeContentColor;
  final Color inactiveColor;
  final bool isCompact;

  const _NavItemContent({
    required this.item,
    required this.isSelected,
    required this.activeContentColor,
    required this.inactiveColor,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    final iconColor = isSelected ? activeContentColor : inactiveColor;
    final textColor = isSelected
        ? activeContentColor
        : inactiveColor.withValues(alpha: 0.85);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: isSelected ? 1.05 : 0.95,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Icon(
            iconData,
            size: isCompact ? 18.0 : 20.0,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 2.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTextStyles.bodyFont,
                    fontSize: isCompact
                        ? (isSelected ? 9.5 : 9.0)
                        : (isSelected ? 10.5 : 10.0),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A custom [FloatingActionButtonLocation] that positions the FloatingActionButton
/// with responsive clearance directly above the floating pill navigation bar.
///
/// Responsive positioning:
/// - In LTR layouts, positions the FAB at the trailing/right edge with [endOffset].
/// - In RTL layouts, positions the FAB at the trailing/left edge with [endOffset].
/// - Vertical position clears the 62px pill height, the 12px pill bottom margin,
///   the device bottom safe area, plus an extra 12px clearance gap ([bottomOffset] defaults to 86.0px).
/// - When the on-screen keyboard is visible, smoothly floats above the keyboard insets.
class FloatingAbovePillNavBarLocation extends FloatingActionButtonLocation {
  /// The distance from the bottom of the scaffold (excluding safe area) to the
  /// bottom edge of the FAB. Default is 86.0, which clears the 62px pill + 12px bottom
  /// margin + 12px clearance spacing.
  final double bottomOffset;

  /// The horizontal inset from the trailing edge (right in LTR, left in RTL). Default is 16.0.
  final double endOffset;

  const FloatingAbovePillNavBarLocation({
    this.bottomOffset = 86.0,
    this.endOffset = 16.0,
  });

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Determine horizontal position respecting text direction (LTR vs RTL)
    final double fabX;
    if (scaffoldGeometry.textDirection == TextDirection.rtl) {
      fabX = endOffset;
    } else {
      fabX =
          scaffoldGeometry.scaffoldSize.width -
          scaffoldGeometry.floatingActionButtonSize.width -
          endOffset;
    }

    // Account for safe area padding and keyboard insets
    final double keyboardOffset = scaffoldGeometry.minInsets.bottom;
    final double safeBottom = scaffoldGeometry.minViewPadding.bottom;
    final double effectiveBottom = keyboardOffset > 0
        ? keyboardOffset + 16.0
        : bottomOffset + safeBottom;

    final double fabY =
        scaffoldGeometry.scaffoldSize.height -
        scaffoldGeometry.floatingActionButtonSize.height -
        effectiveBottom;

    return Offset(fabX, fabY);
  }
}

/// Layout and spacing utilities for screens hosted within [CustomerMainShell].
///
/// Ensures scrollable screen content and floating map controls maintain proper
/// clearance above the floating pill navigation bar without solid barriers.
abstract final class FloatingPillNavBarUtils {
  /// Standard height of the floating pill navigation bar.
  static const double pillHeight = 62.0;

  /// Bottom margin applied to the floating pill inside [CustomerMainShell].
  static const double pillBottomMargin = 12.0;

  /// Default breathing clearance between the floating pill and scrollable content.
  static const double defaultClearance = 32.0;

  /// Calculates the dynamic bottom clearance for scrollable screens
  /// (such as Home and About Us), respecting the pill height, bottom margin,
  /// device bottom safe area, and desired clearance.
  static double calculateBottomClearance(
    BuildContext context, {
    double clearance = defaultClearance,
  }) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return pillHeight + pillBottomMargin + bottomInset + clearance;
  }

  /// Calculates the dynamic bottom positioning offset for interactive floating
  /// controls (such as Map zoom and recenter buttons) to sit comfortably
  /// above the floating pill navigation bar.
  static double calculateControlsBottomOffset(
    BuildContext context, {
    double clearance = 16.0,
  }) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return pillHeight + pillBottomMargin + bottomInset + clearance;
  }
}
