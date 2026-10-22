# Al Sewar Screen Blueprints & Structural UX

This document provides exact structural specifications for each major screen across both the **Customer App** and **Manager App**.

---

## 1. Customer Application Blueprints

### 1.1 Home Dashboard (`HomeScreen`)
- **Structure (Top to Bottom)**:
  1. `HomeHeader`:
     - 44x44px Al Sewar logo (`assets/logos/AlSewar_logoonly.png`).
     - Notification bell with unread badge counter.
     - Warm customer greeting: `"Welcome back, [First Name]"` + subtitle `"Al Sewar Auto Care"`.
  2. `LoyaltyCard`:
     - High visual elevation (22px padding, charcoal gradient, 18px radius).
     - Membership tier badge (`GOLD MEMBER`), available points balance (30px Manrope bold), progress bar to next tier, and `"Explore rewards ->"` action.
  3. `ServiceCategories` (Our Services):
     - Section heading: `"Our Services"` with `"VIEW ALL"` link.
     - 4-column responsive grid of rounded square tiles (Pure White surface, Sand Beige border, 12px padding).
     - Category icon in Deep Charcoal, 12px DM Sans semibold label below.
  4. `PromotionalBanner` (Special Campaigns):
     - Horizontal carousel with 0.92 viewport fraction.
     - Deep Charcoal cards with metallic Champagne Gold badge, title, subtitle, and indicator dots below.
  5. `ActiveVisitTracker` (Live Service Status):
     - Shown when an active visit exists in `customerVisitsProvider`.
     - Displays `SV-...` number, vehicle model, current stage badge (`Received`, `In Progress`, etc.), and `"Track Live Status ->"`.
  6. `FeaturedOffers`:
     - Horizontal list of curated value packages with savings tags.
  7. Bottom clearance for `FloatingPillNavBar` (`FloatingPillNavBarUtils.calculateBottomClearance`).

---

### 1.2 Rewards & Loyalty Screen (`RewardsScreen`)
- **Goal**: Gamified loyalty progression, points redemption, and voucher collection.
- **Structure**:
  1. Header: Compact AppBar with title `"Loyalty & Rewards"`.
  2. Hero Loyalty Card: Large glossy card showing active tier, coin counter, and expiration policy notice.
  3. Tier Progress Section:
     - Visual step indicator: Silver -> Gold -> Platinum.
     - Points needed to reach next tier with dynamic calculation.
  4. Quick Actions:
     - `"Redeem Vouchers"`, `"Earn History"`, `"Refer a Friend"`.
  5. Available Rewards Grid:
     - Voucher cards with dashed coupon border, discount value (e.g. `"20% OFF"` or `"Free Wax"`), cost in coins (e.g. `"500 Coins"`), and `"Redeem"` CTA button.
  6. Transaction History Tab:
     - List of visits where points were accrued or redeemed.

---

### 1.3 Profile & Account Screen (`ProfileScreen`)
- **Structure**:
  1. User Profile Header:
     - Avatar circle with user initials or profile image.
     - Full display name (18px Manrope semibold).
     - Username & tier badge chip.
  2. Grouped Card Section 1: `"MY PROFILE"`
     - Full Name, Username, Phone Number, Email Address.
  3. Grouped Card Section 2: `"MY ACTIVITIES"`
     - Registered Vehicles (`VehiclesScreen` link + count badge).
     - Service Visits History (`VisitsScreen` link).
     - My Reviews (`ReviewsScreen` link).
     - Service Catalog (`ServicesScreen` link).
  4. Grouped Card Section 3: `"SUPPORT & PREFERENCES"`
     - Service Centres & Locations (`BranchListScreen` link).
     - WhatsApp Concierge (`WhatsAppSupportScreen` link).
     - Privacy Policy & Terms of Service.
  5. Destructive Action:
     - `"Sign Out"` tile or button with confirmation modal bottom sheet.

---

### 1.4 Service Visits & Live Tracking (`VisitsScreen` & `VisitDetailScreen`)
- **Structure**:
  1. Tab Filter: `"Active Visits"` / `"Past Visits"`.
  2. Visit Card:
     - Top row: Visit reference number (e.g. `SV-2026-0042`) and stage status badge.
     - Middle row: Vehicle make, model, and plate number (`12345 - DXB`).
     - Branch name and date/time timestamp.
     - Points earned indicator (`+120 Coins`).
  3. Detail Screen Milestone Timeline:
     - Vertical timeline with connected node dots.
     - Milestones: `1. Check-In / Received` -> `2. Wash & Detailing` -> `3. Quality Inspection` -> `4. Ready for Delivery` -> `5. Completed`.
     - Active stage highlighted in Champagne Gold with pulsing indicator.
     - Itemized services list and invoice download button.

---

### 1.5 Service Centres & Map (`BranchListScreen` & `BranchMapScreen`)
- **Structure**:
  1. Top View Switcher: List view toggle / Map view toggle.
  2. Map View:
     - Branded map layer (light tiles matching Warm Porcelain).
     - Custom pins: Champagne Gold pins for active branches.
  3. Interactive Bottom Sheet:
     - Pull-up card on branch selection.
     - Branch name, address, distance (e.g. `"2.4 km away"`).
     - Operating hours badge (`"Open Now · Closes 9:00 PM"`).
     - Quick action buttons: `"Directions"` (launch Google/Apple Maps), `"Call"`, and `"WhatsApp Concierge"`.

---

## 2. Manager Application Blueprints

### 2.1 Operational Dashboard
- **Goal**: Maximum operational visibility, queue management, and service velocity.
- **Structure**:
  1. Top Bar: Branch selector dropdown, manager profile, and active shift indicator.
  2. KPI Metric Cards (4-up or 2x2 grid):
     - `Active in Bays`: count with live indicator.
     - `Queue / Waiting`: count.
     - `Completed Today`: count.
     - `Today's Revenue`: AED currency display.
  3. Quick Operational Actions:
     - `"Check-In Vehicle"` (Scan QR / Plate input).
     - `"Assign Technician"`.
     - `"Emergency Broadcast"`.
  4. Live Bay Grid:
     - Visual representation of service bays (Bay 1: Wash, Bay 2: Detailing, Bay 3: Inspection).
     - Vehicle plate, time in bay, progress bar, and status tag.

---

### 2.2 Vehicle Check-In & Service Assignment
- **Structure**:
  1. Search / Scan Bar (instant customer lookup by mobile number or plate).
  2. Customer Verification Card: Name, Tier status, previous visits summary.
  3. Vehicle Details Card: Make, model, color, plate.
  4. Service Selector: Multi-select checklist of services with dynamic price & estimated completion duration.
  5. Assigned Technician & Bay selector.
  6. Confirmation CTA: `"Start Service & Notify Customer via SMS/WhatsApp"`.
