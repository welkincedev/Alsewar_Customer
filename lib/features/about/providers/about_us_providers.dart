import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../models/about_us_content.dart';

/// Al Sewar Auto Center — Verified Static Content Repository.
///
/// Houses verified brand information, mission/vision statements,
/// core service divisions, quantitative benchmarks, and support credentials.
abstract class AboutUsStaticData {
  static const AboutUsContent content = AboutUsContent(
    hero: CompanyHeroContent(
      tag: 'EST. 2014',
      title: 'AL SEWAR AUTO CENTER',
      subtitle: 'Excellence in Automotive Care',
      imageAsset: 'assets/images/banner_auto_care.png',
      logoAsset: 'assets/logos/AlSewar_logoonly.png',
    ),
    overview: CompanyOverviewContent(
      badge: 'HERITAGE & CRAFTSMANSHIP',
      headline: 'Pioneering Luxury Automotive Care',
      description:
          'Founded on a commitment to precision engineering and elite client service, '
          'Al Sewar Auto Center delivers uncompromising quality in car care, express detailing, '
          'and automotive preservation across our expanding Gulf network.',
      pillars: [
        CompanyPillar(
          title: 'Precision Detailing',
          description: 'State-of-the-art touchless high-pressure systems and bespoke vehicle care.',
          icon: Icons.auto_awesome_outlined,
        ),
        CompanyPillar(
          title: 'Certified Technicians',
          description: 'Trained master specialists adhering to strict international detailing benchmarks.',
          icon: Icons.verified_user_outlined,
        ),
        CompanyPillar(
          title: 'Digital Transparency',
          description: 'Live bay queue tracking, instant service milestones, and seamless loyalty rewards.',
          icon: Icons.smartphone_outlined,
        ),
      ],
    ),
    stats: [
      CompanyStat(
        value: '10+',
        label: 'Years of Excellence',
        subLabel: 'Craftsmanship',
        icon: Icons.workspace_premium_outlined,
      ),
      CompanyStat(
        value: '3',
        label: 'Active Centers',
        subLabel: 'Gulf Network',
        icon: Icons.storefront_outlined,
      ),
      CompanyStat(
        value: '25k+',
        label: 'Vehicles Serviced',
        subLabel: 'Client Trust',
        icon: Icons.directions_car_outlined,
      ),
      CompanyStat(
        value: '99%',
        label: 'Satisfaction',
        subLabel: 'Top Rated',
        icon: Icons.star_outline,
      ),
    ],
    missionVision: MissionVisionContent(
      missionTitle: 'Our Mission',
      missionBody:
          'To deliver the pinnacle benchmark of vehicle care and customer satisfaction, '
          'combining advanced cleaning technologies, certified technicians, and seamless digital service tracking.',
      missionIcon: Icons.track_changes_outlined,
      visionTitle: 'Our Vision',
      visionBody:
          'To stand as the most trusted and progressive luxury automotive care center in the region, '
          'recognized for service transparency, technological innovation, and craftsmanship.',
      visionIcon: Icons.visibility_outlined,
    ),
    services: [
      ServiceDivision(
        title: 'Express Wash & Detailing',
        description:
            'Touchless high-pressure wash, foaming, and gloss sealant.',
        icon: Icons.local_car_wash_outlined,
        tag: 'SIGNATURE',
      ),
      ServiceDivision(
        title: 'Interior Preservation',
        description:
            'Leather conditioning, ozone purification, and deep extraction.',
        icon: Icons.airline_seat_recline_extra_outlined,
        tag: 'INTERIOR',
      ),
      ServiceDivision(
        title: 'Ceramic & Paint Protection',
        description:
            '9H nano-ceramic coatings and scratch-resistant gloss shields.',
        icon: Icons.shield_outlined,
        tag: 'PROTECTION',
      ),
      ServiceDivision(
        title: 'Diagnostics & Maintenance',
        description:
            'Comprehensive multi-point vehicle inspection and fluid checks.',
        icon: Icons.build_outlined,
        tag: 'CARE',
      ),
    ],
    contact: ContactSupportContent(
      sectionTitle: 'Verified Support',
      sectionSubtitle: 'Direct Concierge & Helpdesk',
      phoneTitle: 'Customer Helpline',
      phoneNumber: ApiConstants.supportPhone,
      emailTitle: 'Support Email',
      emailAddress: ApiConstants.supportEmail,
      whatsappTitle: 'WhatsApp Concierge',
      whatsappSubtitle: 'Direct Branch & Customer Assistance',
      operatingHoursTitle: 'Operating Hours',
      operatingHours: 'Saturday – Thursday: 8:00 AM – 10:00 PM',
    ),
  );
}

/// Riverpod provider for About Us content.
///
/// Serves verified content today and allows effortless substitution
/// with remote API / CMS providers in the future without modifying UI widgets.
final aboutUsContentProvider = Provider<AboutUsContent>((ref) {
  return AboutUsStaticData.content;
});
