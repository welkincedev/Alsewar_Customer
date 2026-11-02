import 'package:carwashapp/core/constants/api_constants.dart';
import 'package:carwashapp/features/home/models/featured_offer_item.dart';
import 'package:carwashapp/features/home/widgets/featured_offers.dart';
import 'package:carwashapp/features/services/models/service_item.dart';
import 'package:carwashapp/features/services/screens/service_detail_screen.dart';
import 'package:carwashapp/features/services/screens/services_screen.dart';
import 'package:carwashapp/features/services/viewmodels/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Featured Offers Poster Redesign Tests', () {
    test('FeaturedOfferItem URL and Asset resolution', () {
      // 1. Full HTTP URL
      final item1 = FeaturedOfferItem.fromJson({
        'id': 1,
        'title': 'Ceramic Polish',
        'image': 'http://192.168.1.8:8001/media/offers/ceramic.jpg',
      });
      expect(
        item1.effectivePosterUrl,
        equals('http://192.168.1.8:8001/media/offers/ceramic.jpg'),
      );

      // 2. Relative media path
      final item2 = FeaturedOfferItem.fromJson({
        'id': 2,
        'name': 'Wheel Care',
        'poster': '/media/offers/wheel.jpg',
      });
      expect(
        item2.effectivePosterUrl,
        equals('${ApiConstants.baseUrl}/media/offers/wheel.jpg'),
      );

      // 3. Local asset path
      final item3 = FeaturedOfferItem.fromJson({
        'id': 3,
        'name': 'Car Wash',
        'image_asset': 'assets/images/service_wash.jpg',
      });
      expect(item3.effectivePosterUrl, isNull);
      expect(item3.imageAsset, equals('assets/images/service_wash.jpg'));

      // 4. Mapping from ServiceItem with backend image URL
      const serviceWithUrl = ServiceItem(
        id: 10,
        name: 'Oil Change',
        description: 'Complete oil maintenance',
        imageAsset: 'http://cdn.alsewar.com/oil.jpg',
      );
      final mappedItem = FeaturedOfferItem.fromServiceItem(serviceWithUrl);
      expect(
        mappedItem.effectivePosterUrl,
        equals('http://cdn.alsewar.com/oil.jpg'),
      );
    });

    testWidgets(
      'Renders 2:3 aspect ratio posters vertically without old card UI elements',
      (tester) async {
        const testOffers = [
          FeaturedOfferItem(
            id: 1,
            title: 'Full Exterior Wash',
            description: 'Triple foam hand wash',
            points: 1200,
            isFree: true,
            badge: 'FREE',
            savingText: 'Save 20%',
            imageAsset: 'assets/images/service_wash.jpg',
          ),
          FeaturedOfferItem(
            id: 2,
            title: 'Ceramic Coating',
            description: 'High gloss protection',
            points: 3500,
            isFree: false,
            badge: 'EXCLUSIVE',
            imageAsset: 'assets/images/service_ceramic.jpg',
          ),
        ];

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: FeaturedOffers(offers: testOffers),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Section Header is present
        expect(find.text('Featured Offers'), findsOneWidget);
        expect(find.text('See All'), findsOneWidget);

        // 2. Exactly 2 posters rendered
        final aspectRatioFinders = find.byWidgetPredicate(
          (w) =>
              w is AspectRatio && (w.aspectRatio - (2.0 / 3.0)).abs() < 0.001,
        );
        expect(aspectRatioFinders, findsNWidgets(2));

        // 3. Old UI is completely absent
        expect(find.text('POINTS'), findsNothing);
        expect(find.text('1,200'), findsNothing);
        expect(find.text('3,500'), findsNothing);
        expect(find.text('FREE'), findsNothing);
        expect(find.text('EXCLUSIVE'), findsNothing);
        expect(find.text('Save 20%'), findsNothing);
        expect(find.text('Full Exterior Wash'), findsNothing);
        expect(find.text('Triple foam hand wash'), findsNothing);

        // 4. Posters are arranged vertically
        final firstPosterRect = tester.getRect(aspectRatioFinders.at(0));
        final secondPosterRect = tester.getRect(aspectRatioFinders.at(1));
        expect(
          secondPosterRect.top,
          greaterThanOrEqualTo(firstPosterRect.bottom),
        );

        // 5. Posters have consistent 2:3 aspect ratio geometry
        expect(firstPosterRect.width, equals(secondPosterRect.width));
        expect(firstPosterRect.height, equals(secondPosterRect.height));
        expect(
          (firstPosterRect.height / firstPosterRect.width - 1.5).abs(),
          lessThan(0.01),
        );
      },
    );

    testWidgets('Tapping See All navigates to ServicesScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [customerServicesProvider.overrideWith((ref) => const [])],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: SingleChildScrollView(child: FeaturedOffers()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('See All'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ServicesScreen), findsOneWidget);
    });

    testWidgets('Tapping a poster navigates to ServiceDetailScreen', (
      tester,
    ) async {
      const sampleService = ServiceItem(
        id: 104,
        name: 'Full Exterior & Polish',
        description: 'Comprehensive exterior hand wash and gloss polish.',
        imageAsset: 'assets/images/service_wash.jpg',
      );

      final testOffers = [FeaturedOfferItem.fromServiceItem(sampleService)];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: FeaturedOffers(offers: testOffers),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the poster
      final posterFinder = find.byType(AspectRatio);
      expect(posterFinder, findsOneWidget);

      await tester.tap(posterFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ServiceDetailScreen), findsOneWidget);
    });

    testWidgets('Empty state renders when offers list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: FeaturedOffers(offers: [])),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No featured offers currently available'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.local_offer_outlined), findsOneWidget);
    });

    testWidgets('Image error placeholder renders gracefully', (tester) async {
      const invalidOffer = FeaturedOfferItem(
        id: 999,
        title: 'Special Track Tune-Up',
        description: 'High performance tuning',
        points: 5000,
        imageAsset: 'assets/images/non_existent_image.jpg',
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: FeaturedOffers(offers: [invalidOffer]),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Placeholder appears
      expect(find.text('Special Track Tune-Up'), findsOneWidget);
      expect(find.text('Al Sewar Auto Center'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    });
  });
}
