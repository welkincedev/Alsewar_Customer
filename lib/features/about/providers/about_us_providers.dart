import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/about_us_content.dart';

/// Al Sewar Auto Center — Verified Static Content Repository.
///
/// Houses authentic brand information, company history, mission/vision statements,
/// core service divisions, and verified contact credentials directly from the
/// official Al Sewar Company Profile.
abstract class AboutUsStaticData {
  static const AboutUsContent content = AboutUsContent(
    hero: CompanyHeroContent(
      tag: 'ABOUT AL SEWAR',
      title: 'AL SEWAR AUTO CENTER',
      subtitle: 'Complete Vehicle Care Across UAE',
      description: 'Built on over 20 years of combined automotive industry expertise, proudly serving customers across the UAE for more than 11 years.',
      imageAsset: 'assets/images/banner_auto_care.png',
      logoAsset: 'assets/logos/AlSewar_logoonly.png',
    ),
    whoWeAre: WhoWeAreContent(
      badge: 'ABOUT OUR COMPANY',
      headline: 'Best Car Repair Service in Northern Emirates',
      shortSummary: 'Built on over 20 years of combined automotive industry expertise, Al Sewar Auto Center has proudly served customers across the UAE for more than 11 years. Headquartered in Kalba, Sharjah, we deliver complete vehicle care for private, commercial, and fleet customers.',
      extendedStory: 'Our experienced technicians, supported by modern diagnostic equipment and quality parts, provide reliable mechanical repairs, tire services, bodywork, painting, and detailing—all under one roof. Every service is guided by our commitment to quality workmanship, transparent communication, and long-term customer relationships.',
      keyFacts: [
        CompanyFact(
          value: '11+ Years',
          label: 'Serving UAE',
          icon: Icons.calendar_month_outlined,
        ),
        CompanyFact(
          value: '20+ Years',
          label: 'Combined Experience',
          icon: Icons.workspace_premium_outlined,
        ),
        CompanyFact(
          value: '10 Locations',
          label: 'Across UAE',
          icon: Icons.location_on_outlined,
        ),
        CompanyFact(
          value: 'One-Stop',
          label: 'Under One Roof',
          icon: Icons.directions_car_outlined,
        ),
      ],
    ),
    missionVision: MissionVisionContent(
      missionTitle: 'Our Mission',
      missionMotto: 'Deliver Quality. Earn Trust. Keep You Moving.',
      missionBody: 'To stand out as a top-choice destination for high-quality vehicle care, excelling in the special care that vehicles need while ensuring every client feels safe and confident on the road.',
      missionIcon: Icons.track_changes_outlined,
      visionTitle: 'Our Vision',
      visionMotto: 'Driven by Excellence. Focused on the Future.',
      visionBody: 'To solidify our role as a leading, trusted auto service provider in the region through cutting-edge equipment, fair pricing, and expert craftsmanship.',
      visionIcon: Icons.visibility_outlined,
    ),
    services: [
      ServiceDivision(
        title: 'Tyre Services',
        subtitle: 'Fitting, alignment & TPMS',
        icon: Icons.tire_repair,
        tag: '01',
        highlights: [
          'Tyre Changing',
          'Wheel Alignment',
          'Nitrogen Filling',
          'TPMS Servicing',
        ],
      ),
      ServiceDivision(
        title: 'Mechanical',
        subtitle: 'Diagnostics, engine & AC',
        icon: Icons.build_outlined,
        tag: '02',
        highlights: [
          'Auto Repair',
          'Engine Diagnostics',
          'AC Servicing',
          'Oil & Battery',
        ],
      ),
      ServiceDivision(
        title: 'Body Services',
        subtitle: 'Accident repair & painting',
        icon: Icons.format_paint_outlined,
        tag: '03',
        highlights: [
          'Accident Repair',
          'Car Painting',
          'Panel Repair',
          'Window Tinting',
        ],
      ),
      ServiceDivision(
        title: 'Detailing',
        subtitle: 'Wash, polish, ceramic & PPF',
        icon: Icons.auto_awesome_outlined,
        tag: '04',
        highlights: [
          'Car Wash',
          'Car Polishing',
          'Ceramic Coating',
          'PPF Protection',
        ],
      ),
    ],
    contact: CompanyContactContent(
      sectionTitle: 'Contact Us',
      sectionSubtitle: 'Direct Helpline & Information',
      primaryPhone: '+971 9 277 7291',
      secondaryPhone: '+971 56 167 1673',
      email: 'info@alsewarauto.com',
      websiteUrl: 'https://www.alsewarauto.com',
      operatingHoursTitle: 'Business Hours',
      operatingHours: 'Saturday – Thursday: 8:00 AM – 10:00 PM',
      headquarters: 'Kalba, Sharjah, UAE',
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
