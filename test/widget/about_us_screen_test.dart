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
      name: 'Al Sewar Riyadh Olaya',
      code: 'RUH-01',
      address: 'King Fahd Rd, Olaya',
      city: 'Riyadh',
      phone: '+966 11 000 0001',
      email: 'olaya@alsewar.com',
      latitude: 24.7136,
      longitude: 46.6753,
      isActive: true,
    ),
    const Branch(
      id: 2,
      name: 'Al Sewar Jeddah Corniche',
      code: 'JED-01',
      address: 'Corniche Rd, Al Shati',
      city: 'Jeddah',
      phone: '+966 12 000 0002',
      email: 'corniche@alsewar.com',
      latitude: 21.5433,
      longitude: 39.1728,
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
        customerServicesProvider
            .overrideWith((ref) => Future.value(<ServiceItem>[])),
        branchDetailProvider(1).overrideWith(
          (ref) => Future.value(sampleBranches.first),
        ),
        branchHoursProvider(1).overrideWith(
          (ref) => Future.value(<BusinessHour>[]),
        ),
        branchListViewModelProvider.overrideWith(() {
          final notifier = _MockBranchViewModel(
            branches: branches ?? sampleBranches,
            isLoading: isLoadingBranches,
            error: branchError,
          );
          return notifier;
        }),
      ],
      child: MaterialApp(
        home: AboutUsScreen(
          floatingActionButton: fab,
        ),
      ),
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
      expect(content.hero.subtitle, equals('Excellence in Automotive Care'));
      expect(content.hero.tag, isNotEmpty);
      expect(content.hero.imageAsset, contains('banner_auto_care.png'));

      // Overview
      expect(content.overview.headline, isNotEmpty);
      expect(content.overview.pillars.length, equals(3));

      // Key Metrics
      expect(content.stats.length, equals(4));
      expect(content.stats[0].value, equals('10+'));
      expect(content.stats[1].value, equals('3'));
      expect(content.stats[2].value, equals('25k+'));
      expect(content.stats[3].value, equals('99%'));

      // Mission & Vision
      expect(content.missionVision.missionTitle, equals('Our Mission'));
      expect(content.missionVision.visionTitle, equals('Our Vision'));

      // Service Divisions
      expect(content.services.length, equals(4));
      expect(content.services[0].title, equals('Express Wash & Detailing'));
      expect(content.services[1].title, equals('Interior Preservation'));
      expect(content.services[2].title, equals('Ceramic & Paint Protection'));
      expect(content.services[3].title, equals('Diagnostics & Maintenance'));

      // Contact & Support
      expect(content.contact.phoneTitle, equals('Customer Helpline'));
      expect(content.contact.phoneNumber, isNotEmpty);
      expect(content.contact.emailTitle, equals('Support Email'));
      expect(content.contact.emailAddress, contains('@'));
      expect(content.contact.whatsappTitle, equals('WhatsApp Concierge'));
    });
  });

  group('AboutUsScreen UI Rendering & Navigation Tests', () {
    testWidgets('renders all 7 required Desert Luxe sections cleanly',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      // Section 1: Brand Hero
      expect(find.text('AL SEWAR AUTO CENTER'), findsOneWidget);
      expect(find.text('Excellence in Automotive Care'), findsOneWidget);

      // Section 2: Overview & Pillars
      expect(find.text('HERITAGE & CRAFTSMANSHIP'), findsOneWidget);
      expect(find.text('Pioneering Luxury Automotive Care'), findsOneWidget);
      expect(find.text('Precision Detailing'), findsOneWidget);
      expect(find.text('Certified Technicians'), findsOneWidget);
      expect(find.text('Digital Transparency'), findsOneWidget);

      // Section 3: Metrics At a Glance
      expect(find.text('At a Glance'), findsOneWidget);
      expect(find.text('10+'), findsOneWidget);
      expect(find.text('Years of Excellence'), findsOneWidget);
      expect(find.text('25k+'), findsOneWidget);
      expect(find.text('Vehicles Serviced'), findsOneWidget);
      expect(find.text('99%'), findsOneWidget);

      // Section 4: Mission & Vision
      expect(find.text('Our Mission'), findsOneWidget);
      expect(find.text('Our Vision'), findsOneWidget);

      // Section 5: Core Services
      expect(find.text('Core Services'), findsOneWidget);
      expect(find.text('VIEW ALL'), findsOneWidget);
      expect(find.text('Express Wash & Detailing'), findsOneWidget);
      expect(find.text('Interior Preservation'), findsOneWidget);
      expect(find.text('Ceramic & Paint Protection'), findsOneWidget);
      expect(find.text('Diagnostics & Maintenance'), findsOneWidget);

      // Section 6: Our Branches
      expect(find.text('Al Sewar Branch Network'), findsOneWidget);
      expect(find.text('2 Locations Active'), findsOneWidget);
      expect(find.text('Al Sewar Riyadh Olaya'), findsOneWidget);
      expect(find.text('Al Sewar Jeddah Corniche'), findsOneWidget);
      expect(find.text('Explore on Map'), findsOneWidget);
      expect(find.text('View All Service Centers'), findsOneWidget);

      // Section 7: Verified Support
      expect(find.text('Verified Support'), findsOneWidget);
      expect(find.text('Direct Concierge & Helpdesk'), findsOneWidget);
      expect(find.text('Customer Helpline'), findsOneWidget);
      expect(find.text('Support Email'), findsOneWidget);
      expect(find.text('WhatsApp Concierge'), findsOneWidget);
      expect(find.text('Operating Hours'), findsOneWidget);
    });

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

    testWidgets('Tapping Explore on Map navigates to BranchMapScreen',
        (tester) async {
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
    });

    testWidgets('Tapping branch mini card navigates to BranchDetailScreen',
        (tester) async {
      await tester.pumpWidget(buildTestableScreen());
      await tester.pumpAndSettle();

      final branchCard = find.text('Al Sewar Riyadh Olaya');
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

    testWidgets('Renders properly without overflow on 320px width device',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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
