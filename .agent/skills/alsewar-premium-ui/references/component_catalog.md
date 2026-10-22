# Al Sewar Reusable Component Catalog

This document indexes existing reusable components across the codebase. **Always check this catalog before creating a new widget** to prevent duplicate code and ensure UI consistency.

---

## 1. Core Component Index

| Component | File Path | Primary Use Case | Key Props |
|---|---|---|---|
| `LoyaltyCard` | `lib/features/home/widgets/loyalty_card.dart` | Hero membership & points balance card | `memberName`, `membershipCategory`, `pointsBalance`, `pointsLabel`, `progressToNextTier`, `nextTierLabel`, `onExploreRewards` |
| `FloatingPillNavBar` | `lib/features/home/widgets/floating_pill_nav_bar.dart` | Floating bottom navigation bar | `currentIndex`, `onTap`, `items: List<PillNavItem>`, `height` |
| `HomeHeader` | `lib/features/home/widgets/home_header.dart` | Top dashboard header with logo & badges | `user: AuthUser`, `onNotificationTap` |
| `PromotionalBanner` | `lib/features/home/widgets/promotional_banner.dart` | Swipeable campaign carousel with dots | Self-contained, accepts campaign list |
| `FeaturedOffers` | `lib/features/home/widgets/featured_offers.dart` | Curated deals & package promos | Self-contained, displays offer cards with badges |
| `ServiceCategories` | `lib/features/home/widgets/service_categories.dart` | 4-column responsive service shortcut grid | Connects to `customerServicesProvider` with dynamic fallback icons |
| `BranchDetailsBottomSheet` | `lib/features/branches/widgets/branch_details_bottom_sheet.dart` | Modal sheet showing branch details & WhatsApp | `branch: Branch`, `onGetDirections`, `onCall`, `onWhatsApp` |

---

## 2. Component Usage Specifications

### `LoyaltyCard`
```dart
import 'package:carwashapp/features/home/widgets/loyalty_card.dart';

LoyaltyCard(
  memberName: user.displayName,
  membershipCategory: 'GOLD MEMBER',
  pointsBalance: 2450,
  pointsLabel: 'Coins',
  benefitsText: 'Your loyalty, rewarded.',
  progressToNextTier: 0.70,
  nextTierLabel: '550 points to Platinum',
  isDevelopmentPlaceholder: false,
  onExploreRewards: () {
    Navigator.pushNamed(context, '/rewards');
  },
  onCardTap: () {
    Navigator.pushNamed(context, '/rewards');
  },
)
```

---

### `FloatingPillNavBar` & `CustomerMainShell`
```dart
import 'package:carwashapp/features/home/widgets/floating_pill_nav_bar.dart';

FloatingPillNavBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  items: const [
    PillNavItem(icon: Icons.info_outline, activeIcon: Icons.info, label: 'About Us'),
    PillNavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    PillNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'WhatsApp'),
  ],
)
```
*Note: Always reserve bottom scroll clearance using `FloatingPillNavBarUtils.calculateBottomClearance(context, clearance: 32.0)`.*

---

### Standard Section Header Pattern
Standard pattern used across all screens:
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text('Section Title', style: AppTextStyles.sectionHeading),
      if (onViewAll != null)
        GestureDetector(
          onTap: onViewAll,
          child: const Text(
            'VIEW ALL',
            style: TextStyle(
              fontFamily: AppTextStyles.bodyFont,
              color: AppColors.champagneGold,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
    ],
  ),
)
```

---

### Standard Status Badge
Used in Service Visits, Order Trackers, and History:
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: statusColor.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.0),
  ),
  child: Text(
    statusLabel.toUpperCase(),
    style: TextStyle(
      fontFamily: AppTextStyles.bodyFont,
      color: statusColor,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  ),
)
```
- Active / In-Progress: `AppColors.champagneGold`
- Completed: `AppColors.success`
- Cancelled / Error: `AppColors.error`
- Pending / Queued: `AppColors.textSecondary`
