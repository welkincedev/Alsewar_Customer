---
name: alsewar-premium-ui
description: Design system and Flutter UI guidance for every Al Sewar Auto Center customer-app screen, using the approved Home Screen and Desert Luxe visual language.
---

# Al Sewar Auto Center — Premium UI Skill

## 1. Purpose
Build a consistent, premium, customer-friendly **auto center** app (not car-wash-only). The current Home Screen is the primary visual reference for all other customer-app screens. Transfer its visual language—not its exact layout—to each screen's purpose.

Priorities: clear hierarchy, easy task completion, premium automotive identity, responsive/accessibile UI, reusable components, and truthful data. Use existing Al Sewar logos/assets; never redraw or distort the logo.

## 2. Approved Desert Luxe palette

Use central theme/AppColors tokens. Do not scatter new colour literals across widgets.

| Token | Hex | Use |
|---|---|---|
| `pureWhite` | `#FFFFFF` | Dominant page background, clean cards |
| `deepBlack` | `#171717` | Main text, strong icons, premium dark surfaces |
| `signatureGold` | `#D9B152` | Stronger gold accent, selected states, small highlights |
| `champagneGold` | `#C6A66B` | Main soft gold, buttons and accents |
| `richMetallicGold` | `#B38B45` | Deeper gold details, subtle borders and gradient depth |
| `softWhite` | `#F8F8F8` | Secondary surfaces |
| `subtleBorder` | `#E6E6E6` | Dividers and outlines |
| `textSecondary` | `#555555` | Supporting text |
| `textLight` | `#8A8A8A` | Metadata/captions |

Keep existing aliases compatible:
- `primaryBlack`, `deepCharcoal` → `deepBlack`
- `warmPorcelain`, `backgroundLight` → `pureWhite`
- `surfaceLight` → `softWhite`
- `cardLight` → `pureWhite`
- `sandBeige`, `borderLight` → `subtleBorder`
- `secondaryGold` → `champagneGold`

Gold rules:
- White remains dominant; gold is an accent, not a page background.
- Use champagne gold for the softer gold treatment, signature gold for selective stronger emphasis, and rich metallic gold for deeper details.
- Approved Home quick actions use a refined champagne/signature-gold treatment with dark icons and labels (Option A).
- Avoid bright yellow, mustard-heavy surfaces, and large saturated gold blocks.
- Check text contrast on gold; use deep black for labels/icons where appropriate.

**Blue is not currently approved.** `#021C4B` is only a possible future option. Do not use blue unless the user explicitly asks to explore or apply it.

## 3. Surfaces, effects and imagery
- Predominantly white backgrounds; clean white cards with subtle borders.
- Reserve dark premium surfaces for meaningful hierarchy, especially membership.
- Use restrained shadows, controlled highlights, polished automotive imagery and subtle material depth.
- Glassmorphism only for appropriate floating controls/overlays, not every card.
- Neumorphism/inset effects are not the default; use only if explicitly requested and maintain contrast.
- Avoid excessive gradients, heavy shadows, decorative borders, generic SaaS grids, clutter, cartoonish coin art, and unrelated stock imagery.
- Use approved Al Sewar assets and relevant automotive imagery. Preserve aspect ratio and provide image fallbacks.

## 4. Typography
Reuse the project's configured fonts; do not add duplicate declarations:
- **Manrope:** page/section headings, important numbers, prominent card titles.
- **DM Sans:** body, labels, buttons, helper text and metadata.

Keep a clear hierarchy and concise customer-friendly copy. Avoid tiny microcopy and unnecessary all-caps. Support text scaling; never hide layout problems by shrinking all text.

## 5. Home Screen — source of truth

Inspect the current implementation before editing because code may differ from older plans. Latest approved Home structure:

1. **Compact greeting/header:** customer context; notification only if supported. Avoid duplicate profile actions.
2. **Membership/loyalty card:** primary visual anchor; premium dark surface with restrained gold; actual backend points/tier only; concise details; opens existing membership/rewards flow.
3. **Quick actions:** exactly **Branches, Services, History, Vehicles**, in that order. Use Option A gold buttons; equal tile dimensions; consistent icons, labels, gaps, and touch feedback; preserve routes/callbacks.
4. **Promotional banners:** horizontal carousel before Featured Offers. Active backend banners take priority. If none exist, show approved local fallback banners rather than an unexplained blank area. Concepts: Premium Auto Care, Complete Auto Care, Loyalty. Do not invent prices, discounts, or claims. Target source ratio around 1080×400 (2.7:1), cropped responsively.
5. **Featured Offers:** concise, relevant offers; backend data where available; no invented values, expiry, savings, or eligibility.

Latest exclusions:
- Do not reintroduce separate **My Vehicles** or **Recent Services** sections on Home unless the user changes this decision.
- Vehicles and History remain accessible through quick actions.
- Avoid duplicate promotional sections and competing dark cards.

Membership styling:
- Silver: brushed-metal silver.
- Gold: dark premium surface with champagne-gold foil accents.
- Platinum: graphite/platinum with restrained silver.
- Tier and points are backend-driven; never customer-editable.
- Preview tiers/sample points are development-only and must not alter production data.

Quick-action details:
- Refined champagne/signature gold, dark readable icons/text.
- Equal visible widths/heights. Put spacing between `Expanded` children, not asymmetric padding inside only some tiles.
- Consistent radius, internal padding, icon size, label baseline and subtle press feedback.

Home layout:
- No excessive blank space above greeting.
- Consistent margins and section gaps.
- Keep content clear of bottom navigation.
- No negative padding or arbitrary spacer hacks.
- Verify initial/loading/empty/error states.

## 6. Reusable rules for every page

**Headers:** compact and consistent; Manrope title, DM Sans supporting text; aligned actions; no duplicate navigation actions; respect safe areas.

**Cards:** use only to group related content. Prefer white surfaces/subtle borders; reserve dark surfaces for important anchors. Keep padding/radii consistent. Avoid unnecessary nested cards.

**Buttons:** clear primary/secondary hierarchy; gold selectively for primary/selected actions; short action labels; target at least 44×44 logical px where practical; implement loading/disabled/error feedback. Do not make every text link look like a primary button.

**Lists/history:** scan-friendly title, supporting line and useful metadata; consistent rows/dividers; truthful dates/status/points. Never display nulls, fake statistics or placeholder data as live. Do not rely on colour alone for status.

**Forms:** consistent field height, borders, focus and validation; only expose fields supported by requirements/API; preserve keyboard scrolling and safe areas.

**Navigation/insets:** preserve existing routes and navigation structure; do not add/remove tabs without instruction; maintain active/inactive states; use existing bottom-clearance utilities; prevent content being covered by navigation.

## 7. Responsive design and accessibility
Test at minimum:
- Compact: 320×568
- Standard: 390×844
- Large: 480×900

Use flexible constraints/LayoutBuilder where useful. Avoid fixed widths causing overflow. Adapt grids; handle long names/addresses; test large text scaling, keyboard-open layouts and long content. Maintain contrast, semantic labels, TalkBack/native touch feedback. Verify iOS too if targeted. Do not solve overflow by hiding information or globally shrinking text.

## 8. Flutter engineering constraints
Project conventions: Flutter/Dart, Riverpod (`AsyncNotifier` where it matches existing state), MVVM-style feature organization, Dio through existing API client, existing secure JWT/session handling.

Before editing:
1. Inspect the target screen, child widgets, routes, providers, models, theme and API contracts.
2. Identify what must be preserved and the exact requested scope.
3. Audit hierarchy, spacing, responsiveness, accessibility and states.
4. Reuse existing components/state owners.

During implementation:
- Preserve working routes, callbacks, APIs, auth and business logic.
- Do not rewrite architecture or unrelated features for a visual task.
- Do not add dependencies without a concrete need.
- Do not invent endpoints, fields, business rules or capabilities.
- Handle loading/data/empty/error states explicitly.
- Keep components focused; avoid unnecessary abstraction.
- Centralize theme/content values rather than scattering literals.

## 9. Data integrity
Use API data only where the existing endpoint/provider supports it. Static content is appropriate only when explicitly intended (e.g. approved company-profile copy or fallback banner artwork). Never invent balances, tiers, visits, branches, coordinates, ratings, hours, prices, offers, contact details or company claims. Hide unavailable values or show a truthful empty state. Do not create fake APIs. For future backend-managed content, use a simple model/provider boundary so the source can be swapped later without redesigning the UI.

## 10. Screen-specific guidance
These rules do not authorize adding unsupported features:
- **About Us:** match Home typography, spacing, palette and imagery. Keep company-profile content concise and centralized/static for now; use existing branch API for live branches. Structure content so an API source can replace static content later without redesign.
- **Branches/Map:** readable branch details and bottom sheets; preserve existing OpenStreetMap integration/attribution; never invent coordinates or distances.
- **Services:** real service categories/details; no unsupported booking.
- **History/Visits:** service, date, vehicle, branch, status and points only where available; compact scan-friendly list.
- **Vehicles:** clear identity/registration; respect existing customer permissions and supported CRUD.
- **Rewards/Membership:** dynamic Silver/Gold/Platinum styling and actual backend values; no invented redemption rules.
- **Profile/Settings:** clear organization; only supported actions.
- **Support:** verified contact details and existing branch/WhatsApp data; hide/disable actions if required data is missing.

## 11. Workflow for every redesign
**Inspect → Audit/plan → Implement → Verify.**
- Inspect current code and Home Screen reference first.
- Produce a focused plan; avoid scope creep.
- Implement using approved tokens/shared components and preserve data/navigation.
- Run `dart format .`, `flutter analyze`, and relevant tests.
- Review rendered UI at all target sizes; check overflow, clipping, contrast, touch targets, keyboard, scrolling and bottom clearance.
- Report exact files changed, test results, and anything still needing physical-device/backend verification. Passing tests alone do not prove visual quality.

## 12. Installed design skills
Use relevant installed skills where available:
- `frontend-design`: visual direction.
- `improve-ui`: audit and focused plan.
- `better-ui` / `impeccable`: surface polish.
- `frontend-ui-engineering`: responsive implementation/accessibility.
- `ponytail`: simplest complete solution; avoid overengineering.
- `android-native-ui`: Android insets, ripple, semantics and back behavior.
- `ui-review`: rendered visual review.
- `apple-native-ui`: only when iOS behavior is relevant.

Do not invoke skills mechanically if unavailable. Their advice must not override the approved Al Sewar palette, project constraints or explicit user decisions.

## 13. Acceptance checklist
- [ ] Screen feels part of the Al Sewar Home Screen/Desert Luxe system.
- [ ] Approved palette is used; no unapproved blue or unrelated accent colours.
- [ ] Existing Manrope and DM Sans are reused.
- [ ] White remains dominant; gold is selective and readable.
- [ ] Dark surfaces have a clear purpose.
- [ ] Spacing, typography, radii, icons and buttons are consistent.
- [ ] Existing navigation, providers, APIs and business logic are preserved.
- [ ] No fake data, invented claims or unsupported functionality.
- [ ] Loading, empty and error states are handled.
- [ ] Compact, standard and large layouts are checked.
- [ ] Safe areas, keyboard and bottom navigation do not obscure content.
- [ ] Formatting, analyzer and relevant tests are run and results reported.
- [ ] Rendered UI is visually reviewed; tests alone are not treated as visual proof.
