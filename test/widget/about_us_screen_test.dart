import 'package:carwashapp/features/about/providers/about_us_providers.dart';
import 'package:carwashapp/features/about/screens/about_us_screen.dart';
import 'package:carwashapp/features/branches/models/branch.dart';
import 'package:carwashapp/features/branches/models/business_hour.dart';
import 'package:carwashapp/features/branches/screens/branch_detail_screen.dart';
import 'package:carwashapp/features/branches/screens/branch_list_screen.dart';
import 'package:carwashapp/features/branches/screens/branch_map_screen.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_providers.dart';
import 'package:carwashapp/features/branches/viewmodels/branch_viewmodel.dart';
import 'package:carwashapp/features/services/models/service_item.dart';
import 'package:carwashapp/features/services/screens/services_screen.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleBranches = [
    const Branch(
      id: 1,
      name: 'Al Sewar Kalba HQ',
      code: 'KLB-01',
      address: 'Near Stadium, Al Taraif 5',
      city: 'Kalba',
      phone: '+971 9 277 7291',
      email: 'kalba@alsewarauto.com',
      latitude: 25.0333,
      longitude: 56.3500,
      isActive: true,
    ),
    const Branch(
      id: 2,
      name: 'Al Sewar Fujairah Musalla',
      code: 'FUJ-01',
      address: 'Sohail Bldg, Eid Musalla Rd',
      city: 'Fujairah',
      phone: '+971 9 222 0000',
      email: 'fujairah@alsewarauto.com',
      latitude: 25.1288,
      longitude: 56.3265,
      isActive: true,
    ),
  ];

  Widget buildTestableScreen({
    List<Branch>? branches,
    bool isLoadingBranches = false,
    String? branchError,
    Widget? fab,
  }) {
    return ProviderScope(
      overrides: [
        customerServicesProvider.overrideWith(
          (ref) => Future.value(<ServiceItem>[]),
        ),
        branchDetailProvider(1)
            .overrideWith((ref) => Future.value(sampleBranches.first)),
        branchHoursProvider(1)
            .overrideWith((ref) => Future.value(<BusinessHour>[])),
        branchListViewModelProvider.overrideWith(() {
          final notifier = _MockBranchViewModel(
            branches: branches ?? sampleBranches,
            isLoading: isLoadingBranches,
            error: branchError,
          );
          return notifier;
        }),
      ],
      child: MaterialApp(home: AboutUsScreen(floatingActionButton: fab)),
    );
  }

  group('AboutUs Content & Architecture Tests', () {
    test(
      'aboutUsContentProvider provides complete verified Al Sewar profile data',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final content = container.read(aboutUsContentProvider);

        // Hero
        expect(content.hero.title, equals('AL SEWAR AUTO CENTER'));
        expect(
          content.hero.subtitle,
          equals('Complete Vehicle Care Across UAE'),
        );
        expect(content.hero.tag, equals('ABOUT AL SEWAR'));
        expect(content.hero.imageAsset, contains('banner_auto_care.png'));

        // Who We Are & Key Facts
        expect(
          content.whoWeAre.headline,
          equals('Best Car Repair Service in Northern Emirates'),
        );
        expect(content.whoWeAre.shortSummary, contains('11 years'));
        expect(content.whoWeAre.keyFacts.length, equals(4));
        expect(content.whoWeAre.keyFacts[0].value, equals('11+ Years'));
        expect(content.whoWeAre.keyFacts[1].value, equals('20+ Years'));
        expect(content.whoWeAre.keyFacts[2].value, equals('10 Locations'));
        expect(content.whoWeAre.keyFacts[3].value, equals('One-Stop'));

        // Mission & Vision
        expect(content.missionVision.missionTitle, equals('Our Mission'));
        expect(
          content.missionVision.missionMotto,
          equals('Deliver Quality. Earn Trust. Keep You Moving.'),
        );
        expect(content.missionVision.visionTitle, equals('Our Vision'));
        expect(
          content.missionVision.visionMotto,
          equals('Driven by Excellence. Focused on the Future.'),
        );

        // Service Divisions (Actual 4 from Company Profile)
        expect(content.services.length, equals(4));
        expect(content.services[0].title, equals('Tyre Services'));
        expect(content.services[1].title, equals('Mechanical'));
        expect(content.services[2].title, equals('Body Services'));
        expect(content.services[3].title, equals('Detailing'));

        // Contact & Support (Verified from Company Profile)
        expect(content.contact.primaryPhone, equals('+971 9 277 7291'));
        expect(content.contact.secondaryPhone, equals('+971 56 167 1673'));
        expect(content.contact.email, equals('info@alsewarauto.com'));
        expect(
          content.contact.websiteUrl,
          equals('https://www.alsewarauto.com'),
        );
        expect(content.contact.headquarters, equals('Kalba, Sharjah, UAE'));
      },
    );
  });

  group('AboutUsScreen UI Rendering & Navigation Tests', () {
    testWidgets('renders all verified minimal sections cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Section 1: Hero
      expect(find.text('ABOUT AL SEWAR'), findsOneWidget);
      expect(find.text('AL SEWAR AUTO CENTER'), findsOneWidget);
      expect(find.text('11+ YRS'), findsOneWidget);

      // Section 2: Who We Are
      expect(find.text('Who We Are'), findsOneWidget);
      expect(
        find.text('Best Car Repair Service in Northern Emirates'),
        findsOneWidget,
      );
      expect(find.text('11+ Years'), findsOneWidget);
      expect(find.text('20+ Years'), findsOneWidget);
      expect(find.text('10 Locations'), findsOneWidget);
      expect(find.text('One-Stop'), findsOneWidget);

      // Section 3: Mission & Vision
      expect(find.text('Mission & Vision'), findsOneWidget);
      expect(find.text('Our Mission'), findsOneWidget);
      expect(find.text('Our Vision'), findsOneWidget);

      // Section 4: Our Services
      expect(find.text('Our Services'), findsOneWidget);
      expect(find.text('VIEW ALL'), findsOneWidget);
      expect(find.text('Tyre Services'), findsOneWidget);
      expect(find.text('Mechanical'), findsOneWidget);
      expect(find.text('Body Services'), findsOneWidget);
      expect(find.text('Detailing'), findsOneWidget);

      // Section 5: Our Presence
      expect(find.text('Our Presence'), findsOneWidget);
      expect(find.text('Explore on Map'), findsOneWidget);
      expect(find.text('View All Service Centers'), findsOneWidget);
      expect(find.text('Al Sewar Kalba HQ'), findsOneWidget);

      // Section 6: Official Website
      expect(find.text('Visit Our Website'), findsOneWidget);
      expect(find.text('www.alsewarauto.com'), findsOneWidget);

      // Section 7: Contact & Support
      expect(find.text('Contact & Support'), findsOneWidget);
      expect(find.text('+971 9 277 7291'), findsOneWidget);
      expect(find.text('+971 56 167 1673'), findsOneWidget);
      expect(find.text('info@alsewarauto.com'), findsOneWidget);
    });

    testWidgets(
      'Tapping Read more expands the story and toggles to Read less',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        final readMore = find.text('Read more');
        expect(readMore, findsOneWidget);

        await tester.tap(readMore);
        await tester.pumpAndSettle();

        expect(find.text('Read less'), findsOneWidget);
        expect(
          find.textContaining('supported by modern diagnostic equipment'),
          findsOneWidget,
        );

        await tester.tap(find.text('Read less'));
        await tester.pumpAndSettle();

        expect(find.text('Read more'), findsOneWidget);
      },
    );

    testWidgets('Tapping VIEW ALL navigates to ServicesScreen', (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final viewAll = find.text('VIEW ALL');
      await tester.scrollUntilVisible(
        viewAll,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(viewAll);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ServicesScreen), findsOneWidget);
    });

    testWidgets('Tapping Explore on Map navigates to BranchMapScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final mapButton = find.text('Explore on Map');
      await tester.scrollUntilVisible(
        mapButton,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(mapButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BranchMapScreen), findsOneWidget);
    });

    testWidgets(
      'Tapping View All Service Centers navigates to BranchListScreen',
      (tester) async {
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        final listButton = find.text('View All Service Centers');
        await tester.scrollUntilVisible(
          listButton,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(listButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(BranchListScreen), findsOneWidget);
      },
    );

    testWidgets('Tapping branch mini card navigates to BranchDetailScreen', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final branchCard = find.text('Al Sewar Kalba HQ');
      await tester.scrollUntilVisible(
        branchCard,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(branchCard);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(BranchDetailScreen), findsOneWidget);
    });

    testWidgets('Renders properly without overflow on 320px width device', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders properly without overflow on 390px standard device', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders properly without overflow on 480px large device', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(480 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Supports custom FAB without visual collision', (tester) async {
      const fabKey = ValueKey('custom_about_fab');
      await tester.pumpWidget(
        buildTestableScreen(
          fab: FloatingActionButton(
            key: fabKey,
            onPressed: () {},
            child: const Icon(Icons.share),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(fabKey), findsOneWidget);
    });
  });
}

class _MockBranchViewModel extends BranchListViewModel {
  final List<Branch> branches;
  final bool isLoading;
  final String? error;

  _MockBranchViewModel({
    required this.branches,
    this.isLoading = false,
    this.error,
  });

  @override
  Future<List<Branch>> build() async {
    if (isLoading) {
      return [];
    }
    if (error != null) {
      throw Exception(error!);
    }
    return branches;
  }
}
