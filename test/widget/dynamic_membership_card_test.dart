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
      'Renders Silver Card at 0 points with branding, name, points, and affordance',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Sarah Al-Mansoor',
          points: 0,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        // Branding
        expect(find.text('AL SEWAR'), findsOneWidget);
        // Tier Badge
        expect(find.text('SILVER MEMBER'), findsOneWidget);
        // Points
        expect(find.text('0'), findsOneWidget);
        expect(find.text('Points'), findsOneWidget);
        // Customer name without greeting
        expect(find.text('Sarah Al-Mansoor'), findsOneWidget);
        expect(find.textContaining('Welcome'), findsNothing);
        // Tap Affordance
        expect(find.text('Card Details'), findsOneWidget);
        // Progress Bar present for Silver
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    testWidgets('Renders Gold Card at 25,001 points with Membership ID', (
      tester,
    ) async {
      final membership = CustomerMembership.fromUser(
        memberName: 'Khalid Al-Ghamdi',
        membershipId: 'AS-77401',
        points: 25001,
      );

      await tester.pumpWidget(wrapWidget(LoyaltyCard(membership: membership)));
      await tester.pumpAndSettle();

      expect(find.text('AL SEWAR'), findsOneWidget);
      expect(find.text('GOLD MEMBER'), findsOneWidget);
      expect(find.text('25,001'), findsOneWidget);
      expect(find.text('Khalid Al-Ghamdi'), findsOneWidget);
      expect(find.text('ID: AS-77401'), findsOneWidget);
      expect(find.text('Card Details'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'Renders Platinum Card at 50,001 points without progress bar towards nonexistent tier',
      (tester) async {
        final membership = CustomerMembership.fromUser(
          memberName: 'Dr. Sultan Al-Otaibi',
          points: 50001,
        );

        await tester.pumpWidget(
          wrapWidget(LoyaltyCard(membership: membership)),
        );
        await tester.pumpAndSettle();

        expect(find.text('AL SEWAR'), findsOneWidget);
        expect(find.text('PLATINUM MEMBER'), findsOneWidget);
        expect(find.text('50,001'), findsOneWidget);
        expect(find.text('Dr. Sultan Al-Otaibi'), findsOneWidget);
        expect(find.text('Platinum Privileges Unlocked'), findsOneWidget);
        // No progress bar on card for Platinum
        expect(find.byType(LinearProgressIndicator), findsNothing);
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
        expect(find.text('AVAILABLE BALANCE'), findsOneWidget); // Card
        expect(find.text('AVAILABLE POINTS'), findsOneWidget); // Sheet
        expect(find.text('25,000'), findsNWidgets(2)); // Card + sheet
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
  });
}
