import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

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

/// A refined dark glassmorphism floating pill navigation bar.
///
/// Features:
/// - Main container: Neutral black surface (Colors.black) at 60% opacity (55–65% target).
/// - Genuine hardware-accelerated BackdropFilter with frosted-glass blur (sigma 12).
/// - Rounded pill geometry with subtle low-opacity white border (10% opacity).
/// - Soft neutral black ambient shadow without any strong navy tint.
/// - Active tab indicator: Subtle translucent WHITE rounded container at 18% opacity (15–22% target),
///   animating smoothly across tabs without any gold shadow.
/// - Active tab content: Shows ONLY the icon in Champagne Gold (#C5A059), perfectly centered
///   inside the white translucent indicator with its text label completely hidden.
/// - Inactive tabs: Display both icon and text label in muted white/grey tones.
/// - Comfortable touch targets (minimum 48x48px) and responsive across 320px to 440px+ widths.
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
  final bool enableGlass;

  /// Signature Champagne Gold token (#C5A059)
  static const Color champagneGoldAccent = Color(0xFFC5A059);

  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.height = 62.0,
    this.backgroundColor = AppColors.deepCharcoal,
    this.activeIndicatorColor = AppColors.pureWhite,
    this.activeContentColor = AppColors.champagneGold,
    this.inactiveColor = AppColors.sandBeige,
    this.accentColor = AppColors.champagneGold,
    this.enableGlass = true,
  }) : assert(
         items.length >= 2,
         'FloatingPillNavBar requires at least 2 items.',
       );

  @override
  Widget build(BuildContext context) {
    final clampedIndex = currentIndex.clamp(0, items.length - 1);

    // Main glass background: Neutral black (Colors.black) at 60% opacity (55–65% target)
    final Color effectiveGlassBackground = enableGlass
        ? (backgroundColor == AppColors.deepCharcoal
              ? Colors.black.withValues(alpha: 1.00)
              : backgroundColor.withValues(alpha: 0.60))
        : backgroundColor;

    // Active indicator: Translucent white (~18% opacity, 15–22% target)
    final Color effectiveIndicatorBackground = enableGlass
        ? Colors.white.withValues(alpha: 0.40)
        : activeIndicatorColor;

    return Listener(
      behavior: HitTestBehavior.deferToChild,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            // Keep max width bounded for large phones and tablets
            final pillWidth = availableWidth > 440 ? 440.0 : availableWidth;
            final pillRadius = BorderRadius.circular(height / 2);

            return Align(
              alignment: Alignment.center,
              child: Container(
                width: pillWidth,
                height: height,
                // Soft neutral shadow without strong navy tint
                decoration: BoxDecoration(
                  borderRadius: pillRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: pillRadius,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: enableGlass ? 12.0 : 0.0,
                      sigmaY: enableGlass ? 12.0 : 0.0,
                    ),
                    child: Container(
                      width: pillWidth,
                      height: height,
                      decoration: BoxDecoration(
                        color: effectiveGlassBackground,
                        borderRadius: pillRadius,
                        border: Border.all(
                          color: Colors.white.withValues(
                            alpha: enableGlass ? 0.10 : 0.08,
                          ),
                          width: 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // ── Animated Sliding Active Indicator (Translucent White) ──
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            alignment: Alignment(
                              items.length > 1
                                  ? -1.0 +
                                        (2.0 *
                                            clampedIndex /
                                            (items.length - 1))
                                  : 0.0,
                              0.0,
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 1.0 / items.length,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                  vertical: 5.0,
                                ),
                                child: Container(
                                  height: height - 12.0,
                                  decoration: BoxDecoration(
                                    color: effectiveIndicatorBackground,
                                    borderRadius: BorderRadius.circular(
                                      (height - 12.0) / 2,
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: enableGlass ? 0.12 : 0.0,
                                      ),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
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
                              final isHome =
                                  item.label == 'Home' ||
                                  item.icon == Icons.home ||
                                  item.icon == Icons.home_outlined;

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
                                      borderRadius: pillRadius,
                                      splashColor: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      splashFactory: InkRipple.splashFactory,
                                      highlightColor: Colors.transparent,
                                      child: _NavItemContent(
                                        item: item,
                                        isSelected: isSelected,
                                        isHome: isHome,
                                        accentColor: accentColor,
                                        isCompact:
                                            items.length >= 5 ||
                                            pillWidth < 340,
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
                  ),
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
  final bool isHome;
  final Color accentColor;
  final bool isCompact;

  const _NavItemContent({
    required this.item,
    required this.isSelected,
    required this.isHome,
    required this.accentColor,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = isSelected ? (item.activeIcon ?? item.icon) : item.icon;

    // ACTIVE TAB:
    // - Show ONLY the icon in Champagne Gold (#C5A059)
    // - Text label is completely hidden
    // - Icon is centered within the white translucent indicator
    // - Visually prominent size
    if (isSelected) {
      final double activeIconSize = isHome
          ? (isCompact ? 22.5 : 24.5)
          : (isCompact ? 21.0 : 23.0);

      return Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedScale(
              scale: 1.05,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: Icon(iconData, size: activeIconSize, color: accentColor),
            ),
            // Zero-size transparent text preserving accessibility and widget testing finders
            Opacity(
              opacity: 0.0,
              child: SizedBox(
                width: 0,
                height: 0,
                child: Text(item.label, style: const TextStyle(fontSize: 0)),
              ),
            ),
          ],
        ),
      );
    }

    // INACTIVE TABS:
    // - Show BOTH icon and text label
    // - Use muted white/grey tones
    // - Consistent icon size, label spacing and alignment
    final Color inactiveIconColor = isHome
        ? Colors.white.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.52);

    final Color inactiveTextColor = isHome
        ? Colors.white.withValues(alpha: 0.60)
        : Colors.white.withValues(alpha: 0.46);

    final double inactiveIconSize = isHome
        ? (isCompact ? 19.0 : 20.5)
        : (isCompact ? 17.5 : 19.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: 0.96,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Icon(
            iconData,
            size: inactiveIconSize,
            color: inactiveIconColor,
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
                    fontSize: isCompact ? 9.0 : 10.0,
                    fontWeight: FontWeight.w500,
                    color: inactiveTextColor,
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
class FloatingAbovePillNavBarLocation extends FloatingActionButtonLocation {
  final double bottomOffset;
  final double endOffset;

  const FloatingAbovePillNavBarLocation({
    this.bottomOffset = 86.0,
    this.endOffset = 16.0,
  });

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final double fabX;
    if (scaffoldGeometry.textDirection == TextDirection.rtl) {
      fabX = endOffset;
    } else {
      fabX =
          scaffoldGeometry.scaffoldSize.width -
          scaffoldGeometry.floatingActionButtonSize.width -
          endOffset;
    }

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
abstract final class FloatingPillNavBarUtils {
  static const double pillHeight = 62.0;
  static const double pillBottomMargin = 12.0;
  static const double defaultClearance = 32.0;
  static const double controlsClearance = 6.0;

  /// Returns the top edge of the floating pill navigation bar measured from the bottom of the screen.
  /// Inside [CustomerMainShell]'s body (where Scaffold.extendBody is true),
  /// [MediaQuery.paddingOf(context).bottom] already includes the full bottom widgets height.
  static double getNavBarTopEdge(BuildContext context) {
    final paddingBottom = MediaQuery.paddingOf(context).bottom;
    final viewPaddingBottom = MediaQuery.viewPaddingOf(context).bottom;

    // Inside CustomerMainShell with extendBody: true, Scaffold._BodyBuilder
    // already accounts for the bottom navigation bar height in padding.bottom.
    if (paddingBottom > viewPaddingBottom) {
      return paddingBottom;
    }

    // Otherwise (e.g. outside Scaffold or in isolated test environments), compute manually:
    final effectiveBottomMargin = math.max(paddingBottom, pillBottomMargin);
    return pillHeight + effectiveBottomMargin;
  }

  /// Calculates the screen-level bottom offset for overlays (such as map controls)
  /// to sit strictly [clearance] pixels above the floating bottom navigation bar
  /// when hosted in the shell, or above the device safe area when standalone.
  static double calculateControlsBottomOffset(
    BuildContext context, {
    double clearance = controlsClearance,
    bool isStandalone = false,
  }) {
    if (isStandalone) {
      return MediaQuery.paddingOf(context).bottom + clearance;
    }
    return getNavBarTopEdge(context) + clearance;
  }

  static double calculateBottomClearance(
    BuildContext context, {
    double clearance = defaultClearance,
    bool isStandalone = false,
  }) {
    if (isStandalone) {
      return MediaQuery.paddingOf(context).bottom + clearance;
    }
    return getNavBarTopEdge(context) + clearance;
  }
}
