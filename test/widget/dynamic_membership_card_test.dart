import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carwashapp/features/home/models/membership_tier.dart';
import 'package:carwashapp/features/home/widgets/loyalty_card.dart';
import 'package:carwashapp/features/home/widgets/membership_details_bottom_sheet.dart';

void main() {
  Widget wrapWidget(Widget widget) {
    return MaterialApp(
      theme: ThemeData(splashFactory: InkRipple.splashFactory),
      home: Scaffold(body: SingleChildScrollView(child: widget)),
    );
  }

  group('Dynamic Membership Card UI & Theme Tests', () {
    testWidgets(
      'Renders Silver Card at 0 points with greeting, tier chip, and coin balance',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Sarah Al-Mansoor',
          points: 0,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi, Sarah Al-Mansoor'), findsOneWidget);
        expect(find.text('SILVER'), findsOneWidget);
        expect(find.text('0 Coins'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders Gold Card at 25,001 points with greeting, tier chip, and coin balance',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Khalid Al-Ghamdi',
          membershipId: 'AS-77401',
          points: 25001,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi, Khalid Al-Ghamdi'), findsOneWidget);
        expect(find.text('GOLD'), findsOneWidget);
        expect(find.text('25,001 Coins'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders Platinum Card at 50,001 points with greeting, tier chip, and coin balance',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Dr. Sultan Al-Otaibi',
          points: 50001,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hi, Dr. Sultan Al-Otaibi'), findsOneWidget);
        expect(find.text('PLATINUM'), findsOneWidget);
        expect(find.text('50,001 Coins'), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Silver Card opens bottom sheet with progression and earning rule',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Fahad Al-Mutairi',
          points: 25000,
        );

        bool rewardsOpened = false;

        await tester.pumpWidget(
          wrapWidget(
            LoyaltyCard(
              membership: membership,
              onExploreRewards: () => rewardsOpened = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap card
        await tester.tap(find.byType(LoyaltyCard));
        await tester.pumpAndSettle();

        // Bottom sheet is visible
        expect(find.byType(MembershipDetailsBottomSheet), findsOneWidget);
        expect(find.text('Membership Details'), findsOneWidget);
        expect(find.text('25,000 Coins'), findsOneWidget); // Card
        expect(find.text('AVAILABLE POINTS'), findsOneWidget); // Sheet
        expect(find.text('25,000'), findsOneWidget); // Sheet points
        expect(find.text('Next Tier: Gold'), findsOneWidget);
        expect(find.text('Required Points'), findsOneWidget);
        expect(find.text('25,001'), findsOneWidget);
        expect(find.text('Points Remaining'), findsOneWidget);
        expect(
          find.text('1'),
          findsOneWidget,
        ); // 25,001 - 25,000 = 1 pt remaining
        expect(
          find.textContaining('Every AED 100 spent earns 1 point'),
          findsOneWidget,
        );

        // Tap View Rewards
        await tester.ensureVisible(find.text('View Rewards'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('View Rewards'));
        await tester.pumpAndSettle();

        expect(rewardsOpened, isTrue);
        expect(
          find.byType(MembershipDetailsBottomSheet),
          findsNothing,
        ); // Sheet dismissed
      },
    );

    testWidgets(
      'Tapping Gold Card at boundary 50,000 points shows 1 pt remaining to Platinum',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Noura Al-Dosari',
          points: 50000,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(LoyaltyCard));
        await tester.pumpAndSettle();

        expect(find.text('Next Tier: Platinum'), findsOneWidget);
        expect(find.text('50,001'), findsOneWidget);
        expect(
          find.text('1'),
          findsOneWidget,
        ); // 50,001 - 50,000 = 1 pt remaining
      },
    );

    testWidgets(
      'Tapping Platinum Card shows achieved state without progress bar or negative points',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Tariq Al-Hamad',
          points: 75000,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(LoyaltyCard));
        await tester.pumpAndSettle();

        expect(find.text('Platinum Membership Achieved'), findsOneWidget);
        expect(
          find.textContaining('You have achieved the highest membership tier'),
          findsOneWidget,
        );
        // No next tier progression or negative remaining points
        expect(find.text('Next Tier:'), findsNothing);
        expect(find.text('Points Remaining'), findsNothing);
        expect(find.byType(LinearProgressIndicator), findsNothing);
        expect(
          find.textContaining('Every AED 100 spent earns 1 point'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Renders exact new background images for Silver, Gold, and Platinum',
      (tester) async {
        // 1. Silver tier uses assets/images/slbg.png
        await tester.pumpWidget(
          wrapWidget(
            LoyaltyCard(
              membership: CustomerMembership.fromUser(
                memberName: 'Silver User',
                points: 1000,
                backendTier: 'Silver',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        var imageWidget = tester.widget<Image>(find.byType(Image));
        expect(
          (imageWidget.image as AssetImage).assetName,
          'assets/images/slbg.png',
        );

        // 2. Gold tier uses assets/images/gdbg.png
        await tester.pumpWidget(
          wrapWidget(
            LoyaltyCard(
              membership: CustomerMembership.fromUser(
                memberName: 'Gold User',
                points: 30000,
                backendTier: 'Gold',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        imageWidget = tester.widget<Image>(find.byType(Image));
        expect(
          (imageWidget.image as AssetImage).assetName,
          'assets/images/gdbg.png',
        );

        // 3. Platinum tier uses assets/images/plbg.png
        await tester.pumpWidget(
          wrapWidget(
            LoyaltyCard(
              membership: CustomerMembership.fromUser(
                memberName: 'Platinum User',
                points: 75000,
                backendTier: 'Platinum',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        imageWidget = tester.widget<Image>(find.byType(Image));
        expect(
          (imageWidget.image as AssetImage).assetName,
          'assets/images/plbg.png',
        );
      },
    );
  });
}
