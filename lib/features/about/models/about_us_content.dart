import 'package:flutter/material.dart';

/// Al Sewar Auto Center — About Us Content Domain Models.
///
/// Designed with a hybrid architecture:
/// - Provides structured immutable data for the About Us screen.
/// - Decouples copy and presentation from UI widgets.
/// - Readily supports transition to remote CMS or backend endpoints.

/// Brand Hero Section Content
class CompanyHeroContent {
  final String tag;
  final String title;
  final String subtitle;
  final String imageAsset;
  final String logoAsset;

  const CompanyHeroContent({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.logoAsset,
  });
}

/// Core Pillar or Value Item
class CompanyPillar {
  final String title;
  final String description;
  final IconData icon;

  const CompanyPillar({
    required this.title,
    required this.description,
    required this.icon,
  });
}

/// Company Overview Section Content
class CompanyOverviewContent {
  final String badge;
  final String headline;
  final String description;
  final List<CompanyPillar> pillars;

  const CompanyOverviewContent({
    required this.badge,
    required this.headline,
    required this.description,
    required this.pillars,
  });
}

/// Quantitative Key Performance & Trust Metrics
class CompanyStat {
  final String value;
  final String label;
  final String? subLabel;
  final IconData icon;

  const CompanyStat({
    required this.value,
    required this.label,
    this.subLabel,
    required this.icon,
  });
}

/// Mission & Vision Statements
class MissionVisionContent {
  final String missionTitle;
  final String missionBody;
  final IconData missionIcon;
  final String visionTitle;
  final String visionBody;
  final IconData visionIcon;

  const MissionVisionContent({
    required this.missionTitle,
    required this.missionBody,
    required this.missionIcon,
    required this.visionTitle,
    required this.visionBody,
    required this.visionIcon,
  });
}

/// Core Service Division
class ServiceDivision {
  final String title;
  final String description;
  final IconData icon;
  final String? tag;

  const ServiceDivision({
    required this.title,
    required this.description,
    required this.icon,
    this.tag,
  });
}

/// Verified Concierge & Support Details
class ContactSupportContent {
  final String sectionTitle;
  final String sectionSubtitle;
  final String phoneTitle;
  final String phoneNumber;
  final String emailTitle;
  final String emailAddress;
  final String whatsappTitle;
  final String whatsappSubtitle;
  final String operatingHoursTitle;
  final String operatingHours;

  const ContactSupportContent({
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.phoneTitle,
    required this.phoneNumber,
    required this.emailTitle,
    required this.emailAddress,
    required this.whatsappTitle,
    required this.whatsappSubtitle,
    required this.operatingHoursTitle,
    required this.operatingHours,
  });
}

/// Root Aggregate Model for About Us
class AboutUsContent {
  final CompanyHeroContent hero;
  final CompanyOverviewContent overview;
  final List<CompanyStat> stats;
  final MissionVisionContent missionVision;
  final List<ServiceDivision> services;
  final ContactSupportContent contact;

  const AboutUsContent({
    required this.hero,
    required this.overview,
    required this.stats,
    required this.missionVision,
    required this.services,
    required this.contact,
  });
}
