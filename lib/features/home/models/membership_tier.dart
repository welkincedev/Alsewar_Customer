/// Al Sewar Auto Center — Client Membership Tiers & Rules.
///
/// Official Client Rules:
/// - Every AED 100 spent earns 1 point.
/// - Silver: 0–25,000 points.
/// - Gold: 25,001–50,000 points.
/// - Platinum: 50,001 points and above.
///
/// Progression Rules:
/// - Silver progresses towards Gold at 25,001 points.
/// - Gold progresses towards Platinum at 50,001 points.
/// - Platinum is the highest tier (no progress bar, no negative points).
enum MembershipTier {
  silver,
  gold,
  platinum;

  // Exact client tier thresholds
  static const int silverMin = 0;
  static const int silverMax = 25000;
  static const int goldMin = 25001;
  static const int goldMax = 50000;
  static const int platinumMin = 50001;

  // Next-tier target thresholds
  static const int goldThreshold = 25001; // Silver -> Gold at 25,001 points
  static const int platinumThreshold =
      50001; // Gold -> Platinum at 50,001 points

  /// Client earning rule constant
  static const int spendAedPerPoint = 100;

  /// Display title for the tier badge (e.g. "SILVER MEMBER")
  String get displayName {
    switch (this) {
      case MembershipTier.silver:
        return 'Silver Member';
      case MembershipTier.gold:
        return 'Gold Member';
      case MembershipTier.platinum:
        return 'Platinum Member';
    }
  }

  /// Compact uppercase tier name for headers and badges (e.g. "SILVER")
  String get tierName {
    switch (this) {
      case MembershipTier.silver:
        return 'Silver';
      case MembershipTier.gold:
        return 'Gold';
      case MembershipTier.platinum:
        return 'Platinum';
    }
  }

  /// Next tier, or null if already at the highest tier (Platinum)
  MembershipTier? get nextTier {
    switch (this) {
      case MembershipTier.silver:
        return MembershipTier.gold;
      case MembershipTier.gold:
        return MembershipTier.platinum;
      case MembershipTier.platinum:
        return null;
    }
  }

  /// Points required to reach the next tier, or null for Platinum
  int? get nextTierPointsRequired {
    switch (this) {
      case MembershipTier.silver:
        return goldThreshold; // 25,001
      case MembershipTier.gold:
        return platinumThreshold; // 50,001
      case MembershipTier.platinum:
        return null; // Highest tier achieved
    }
  }

  /// Resolve tier from backend string value (e.g. "SILVER", "Gold", "Platinum Member")
  static MembershipTier? fromString(String? tierStr) {
    if (tierStr == null || tierStr.trim().isEmpty) return null;
    final lower = tierStr.trim().toLowerCase();
    if (lower.contains('plat')) return MembershipTier.platinum;
    if (lower.contains('gold')) return MembershipTier.gold;
    if (lower.contains('silv')) return MembershipTier.silver;
    return null;
  }

  /// Resolve tier from points based strictly on client membership rules:
  /// - 0–25,000 points: Silver
  /// - 25,001–50,000 points: Gold
  /// - 50,001+ points: Platinum
  static MembershipTier fromPoints(int points) {
    if (points >= platinumMin) {
      return MembershipTier.platinum;
    } else if (points >= goldMin) {
      return MembershipTier.gold;
    } else {
      return MembershipTier.silver;
    }
  }
}

/// Domain model encapsulating customer membership status and tier progression.
class CustomerMembership {
  final String memberName;
  final String? membershipId;
  final int points;
  final MembershipTier tier;

  const CustomerMembership({
    required this.memberName,
    this.membershipId,
    required this.points,
    required this.tier,
  });

  /// Factory constructor resolving from customer profile data.
  /// If the backend supplies an explicit tier, it is honored.
  /// Otherwise, the tier is computed from [points] using client rules.
  factory CustomerMembership.fromUser({
    required String memberName,
    String? membershipId,
    int? points,
    String? backendTier,
  }) {
    final validPoints = points != null && points >= 0 ? points : 0;
    final parsedTier = MembershipTier.fromString(backendTier);
    final resolvedTier = parsedTier ?? MembershipTier.fromPoints(validPoints);

    return CustomerMembership(
      memberName: memberName,
      membershipId: membershipId != null && membershipId.trim().isNotEmpty
          ? membershipId.trim()
          : null,
      points: validPoints,
      tier: resolvedTier,
    );
  }

  /// Whether the customer has unlocked the highest membership tier
  bool get isPlatinum => tier == MembershipTier.platinum;

  /// Progress fraction towards the next tier (0.0 to 1.0).
  /// Returns null for Platinum members (no progress bar towards a nonexistent tier).
  double? get progressToNextTier {
    if (isPlatinum) return null;

    if (tier == MembershipTier.silver) {
      // Silver progresses towards Gold at 25,001 points (0 to 25,001)
      if (MembershipTier.goldThreshold <= 0) return 0.0;
      return (points / MembershipTier.goldThreshold.toDouble()).clamp(0.0, 1.0);
    } else if (tier == MembershipTier.gold) {
      // Gold progresses towards Platinum at 50,001 points
      // Span in current tier: 25,001 to 50,001 (span = 25,000 points)
      final pointsInCurrentTier = points - MembershipTier.silverMax;
      const totalPointsInSpan =
          MembershipTier.platinumThreshold - MembershipTier.silverMax;
      if (totalPointsInSpan <= 0) return 0.0;
      return (pointsInCurrentTier / totalPointsInSpan.toDouble()).clamp(
        0.0,
        1.0,
      );
    }
    return null;
  }

  /// Points remaining to the next tier threshold.
  /// Returns null for Platinum members (do not calculate negative remaining points).
  int? get pointsRemainingToNextTier {
    final target = tier.nextTierPointsRequired;
    if (target == null) return null;
    final remaining = target - points;
    return remaining > 0 ? remaining : 0;
  }

  /// Target points required for the next tier
  int? get nextTierRequiredPoints => tier.nextTierPointsRequired;

  /// Next tier name (e.g. "Gold", "Platinum")
  String? get nextTierName => tier.nextTier?.tierName;

  /// Human-readable progress description for bottom sheet or cards
  String get progressDescription {
    if (isPlatinum) {
      return 'Platinum membership achieved';
    }
    final remaining = pointsRemainingToNextTier ?? 0;
    final next = nextTierName ?? '';
    return '${_formattedPoints(remaining)} pts to $next';
  }

  /// Helper to format integers with thousands commas (e.g. 25,001)
  static String formatPoints(int value) => _formattedPoints(value);

  static String _formattedPoints(int value) {
    if (value >= 1000) {
      final str = value.toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        buffer.write(str[i]);
        count++;
        if (count % 3 == 0 && i != 0) {
          buffer.write(',');
        }
      }
      return buffer.toString().split('').reversed.join('');
    }
    return value.toString();
  }
}
