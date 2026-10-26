import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/features/home/models/membership_tier.dart';

void main() {
  group('MembershipTier & CustomerMembership Rules Tests', () {
    test(
      'Boundary 1: 0 points resolves to Silver with 25,001 points remaining',
      () {
        final membership = CustomerMembership.fromUser(
          memberName: 'Ali Al-Hassan',
          points: 0,
        );

        expect(membership.tier, MembershipTier.silver);
        expect(membership.isPlatinum, isFalse);
        expect(membership.tier.displayName, 'Silver Member');
        expect(membership.tier.tierName, 'Silver');
        expect(membership.nextTierName, 'Gold');
        expect(membership.nextTierRequiredPoints, 25001);
        expect(membership.pointsRemainingToNextTier, 25001);
        expect(membership.progressToNextTier, 0.0);
      },
    );

    test('Boundary 2: 25,000 points is the upper limit of Silver', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'Fahad Al-Mutairi',
        points: 25000,
      );

      expect(membership.tier, MembershipTier.silver);
      expect(membership.isPlatinum, isFalse);
      expect(membership.nextTierName, 'Gold');
      expect(membership.nextTierRequiredPoints, 25001);
      expect(membership.pointsRemainingToNextTier, 1);
      // Progress = 25000 / 25001 ≈ 0.99996
      expect(membership.progressToNextTier, closeTo(25000 / 25001, 0.0001));
    });

    test('Boundary 3: 25,001 points enters Gold tier', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'Noura Al-Dosari',
        points: 25001,
      );

      expect(membership.tier, MembershipTier.gold);
      expect(membership.isPlatinum, isFalse);
      expect(membership.tier.displayName, 'Gold Member');
      expect(membership.nextTierName, 'Platinum');
      expect(membership.nextTierRequiredPoints, 50001);
      // Remaining = 50001 - 25001 = 25000
      expect(membership.pointsRemainingToNextTier, 25000);
      // Progress in Gold span: (25001 - 25000) / (50001 - 25000) = 1 / 25001
      expect(membership.progressToNextTier, closeTo(1 / 25001, 0.0001));
    });

    test('Boundary 4: 50,000 points is the upper limit of Gold', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'Rashid Al-Kuwari',
        points: 50000,
      );

      expect(membership.tier, MembershipTier.gold);
      expect(membership.isPlatinum, isFalse);
      expect(membership.nextTierName, 'Platinum');
      expect(membership.nextTierRequiredPoints, 50001);
      expect(membership.pointsRemainingToNextTier, 1);
      // Progress in Gold span: (50000 - 25000) / 25001 = 25000 / 25001 ≈ 0.99996
      expect(membership.progressToNextTier, closeTo(25000 / 25001, 0.0001));
    });

    test('Boundary 5: 50,001 points achieves Platinum membership', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'Sultan Al-Otaibi',
        points: 50001,
      );

      expect(membership.tier, MembershipTier.platinum);
      expect(membership.isPlatinum, isTrue);
      expect(membership.tier.displayName, 'Platinum Member');
      expect(membership.nextTierName, isNull);
      expect(membership.nextTierRequiredPoints, isNull);
      expect(membership.pointsRemainingToNextTier, isNull);
      expect(membership.progressToNextTier, isNull);
      expect(membership.progressDescription, 'Platinum membership achieved');
    });

    test('Platinum with 100,000 points does not calculate negative remaining points', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'Tariq Al-Hamad',
        points: 100000,
      );

      expect(membership.tier, MembershipTier.platinum);
      expect(membership.isPlatinum, isTrue);
      expect(membership.pointsRemainingToNextTier, isNull);
      expect(membership.progressToNextTier, isNull);
    });

    test('Backend explicit tier string overrides inferred points tier', () {
      // Backend grants Gold even if points are 500
      final membership = CustomerMembership.fromUser(
        memberName: 'VIP Customer',
        points: 500,
        backendTier: 'GOLD',
      );

      expect(membership.tier, MembershipTier.gold);
      expect(membership.nextTierName, 'Platinum');
      expect(membership.nextTierRequiredPoints, 50001);
      expect(membership.pointsRemainingToNextTier, 50001 - 500);
    });

    test('Membership ID is properly preserved when supplied', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'Sarah Khan',
        membershipId: 'AS-88129',
        points: 12500,
      );

      expect(membership.membershipId, 'AS-88129');
    });

    test('Null points defaults safely to 0 points (Silver Member)', () {
      final membership = CustomerMembership.fromUser(
        memberName: 'New Customer',
        points: null,
      );

      expect(membership.points, 0);
      expect(membership.tier, MembershipTier.silver);
    });

    test('formatPoints handles small and large point numbers with commas', () {
      expect(CustomerMembership.formatPoints(0), '0');
      expect(CustomerMembership.formatPoints(500), '500');
      expect(CustomerMembership.formatPoints(25000), '25,000');
      expect(CustomerMembership.formatPoints(25001), '25,001');
      expect(CustomerMembership.formatPoints(50000), '50,000');
      expect(CustomerMembership.formatPoints(50001), '50,001');
      expect(CustomerMembership.formatPoints(1250450), '1,250,450');
    });
  });
}
