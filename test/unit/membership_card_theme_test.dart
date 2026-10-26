import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/app/theme/app_colors.dart';
import 'package:carwashapp/features/home/models/membership_card_theme.dart';
import 'package:carwashapp/features/home/models/membership_tier.dart';

void main() {
  group(
    'MembershipCardTheme Theme Structure & Tier Gradient Overlay Tests',
    () {
      test('Silver tier has dark charcoal overlay while preserving metallic silver identity', () {
        final theme = MembershipCardTheme.forTier(MembershipTier.silver);

        expect(theme.tier, equals(MembershipTier.silver));

        // 1. Dark charcoal/black gradient overlay applied to Silver card
        expect(theme.overlayGradient, isNotNull);
        expect(theme.overlayGradient, isA<LinearGradient>());
        final overlay = theme.overlayGradient as LinearGradient;
        expect(overlay.colors.length, equals(3));
        // First color is deep charcoal (alpha > 0.75)
        expect(overlay.colors.first.a, greaterThan(0.75));
        // Mid-tone allows metallic silver texture to shine through
        expect(overlay.colors[1].a, lessThan(0.60));
        // End color is deep charcoal floor
        expect(overlay.colors.last.a, greaterThan(0.70));

        // 2. Preserves metallic silver identity
        expect(theme.cardGradient, equals(AppColors.silverSurfaceGradient));
        expect(theme.badgeGradient, equals(AppColors.silverBadgeGradient));
        expect(theme.badgeTextColor, equals(AppColors.deepCharcoal));
        expect(theme.badgeBorder, isNotNull);
        expect(
          theme.backgroundImageAsset,
          equals('assets/images/voucher_silver_pass.png'),
        );
        expect(theme.passLabel, equals('SILVER VIP PASS'));

        // 3. Metallic silver accents
        expect(theme.progressIndicatorColor, equals(const Color(0xFFBAC4CF)));
        expect(theme.affordanceColor, equals(const Color(0xFFBAC4CF)));
        expect(theme.cardIdColor, equals(const Color(0xFFBAC4CF)));

        // 4. High-contrast, easily readable text against dark overlay
        expect(theme.memberNameColor, equals(Colors.white));
        expect(theme.pointsTextColor, equals(Colors.white));
        expect(theme.brandingColor, equals(const Color(0xFFF0F3F7)));
        expect(theme.balanceLabelColor, equals(const Color(0xFF9EABB9)));
        expect(theme.pointsShaderGradient, isNotNull);
        expect(theme.textEmbossShadow, isNotNull);
      });

      test('Gold tier styling and dark overlay are fully preserved', () {
        final theme = MembershipCardTheme.forTier(MembershipTier.gold);

        expect(theme.tier, equals(MembershipTier.gold));
        expect(theme.cardGradient, equals(AppColors.charcoalGradient));
        expect(theme.brandingColor, equals(AppColors.champagneGold));
        expect(theme.badgeGradient, equals(AppColors.goldGradient));
        expect(theme.badgeTextColor, equals(AppColors.deepCharcoal));
        expect(theme.progressIndicatorColor, equals(AppColors.champagneGold));
        expect(theme.affordanceColor, equals(AppColors.champagneGold));
        expect(
          theme.backgroundImageAsset,
          equals('assets/images/voucher_gold_pass.png'),
        );
        expect(theme.passLabel, equals('GOLD VIP PASS'));

        expect(theme.overlayGradient, isNotNull);
        final overlay = theme.overlayGradient as LinearGradient;
        expect(
          overlay.colors,
          equals(const [
            Color(0xD8141414),
            Color(0x88171717),
            Color(0xCC121212),
          ]),
        );
      });

      test('Platinum tier styling and dark overlay are fully preserved', () {
        final theme = MembershipCardTheme.forTier(MembershipTier.platinum);

        expect(theme.tier, equals(MembershipTier.platinum));
        expect(theme.cardGradient, equals(AppColors.platinumSurfaceGradient));
        expect(theme.badgeGradient, equals(AppColors.platinumBadgeGradient));
        expect(theme.badgeTextColor, equals(const Color(0xFF101216)));
        expect(theme.progressIndicatorColor, equals(const Color(0xFFE2E7EE)));
        expect(theme.affordanceColor, equals(const Color(0xFFD0D6E0)));
        expect(
          theme.backgroundImageAsset,
          equals('assets/images/voucher_platinum_pass.png'),
        );
        expect(theme.passLabel, equals('PLATINUM VIP PASS'));

        expect(theme.overlayGradient, isNotNull);
        final overlay = theme.overlayGradient as LinearGradient;
        expect(
          overlay.colors,
          equals(const [
            Color(0xDE16181D),
            Color(0x8C1B1E25),
            Color(0xD0111317),
          ]),
        );
      });
    },
  );
}
