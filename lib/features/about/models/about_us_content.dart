import 'package:flutter/material.dart';

/// Al Sewar Auto Center — About Us Content Domain Models.
///
/// Designed with a clean, decoupled architecture:
/// - Provides structured immutable models reflecting verified company profile data.
/// - Fully decouples presentation from UI widgets.
/// - Enables smooth drop-in replacement by a backend content API / CMS.

/// Brand Hero Section Content
class CompanyHeroContent {
  final String tag;
  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String logoAsset;

  const CompanyHeroContent({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.logoAsset,
  });
}

/// Quantitative and Qualitative Fact/Metric Item
class CompanyFact {
  final String value;
  final String label;
  final IconData icon;

  const CompanyFact({
    required this.value,
    required this.label,
    required this.icon,
  });
}

/// Who We Are Section Content with Expandable Story
class WhoWeAreContent {
  final String badge;
  final String headline;
  final String shortSummary;
  final String extendedStory;
  final List<CompanyFact> keyFacts;

  const WhoWeAreContent({
    required this.badge,
    required this.headline,
    required this.shortSummary,
    required this.extendedStory,
    required this.keyFacts,
  });
}

/// Mission & Vision Statements from Company Profile
class MissionVisionContent {
  final String missionTitle;
  final String missionMotto;
  final String missionBody;
  final IconData missionIcon;
  final String visionTitle;
  final String visionMotto;
  final String visionBody;
  final IconData visionIcon;

  const MissionVisionContent({
    required this.missionTitle,
    required this.missionMotto,
    required this.missionBody,
    required this.missionIcon,
    required this.visionTitle,
    required this.visionMotto,
    required this.visionBody,
    required this.visionIcon,
  });
}

/// Core Service Division from Company Profile
class ServiceDivision {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? tag;
  final List<String> highlights;

  const ServiceDivision({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.tag,
    required this.highlights,
  });
}

/// Verified Contact & Headquarters Information
class CompanyContactContent {
  final String sectionTitle;
  final String sectionSubtitle;
  final String primaryPhone;
  final String secondaryPhone;
  final String email;
  final String? websiteUrl;
  final String operatingHoursTitle;
  final String operatingHours;
  final String headquarters;

  const CompanyContactContent({
    required this.sectionTitle,
    required this.sectionSubtitle,
    required this.primaryPhone,
    required this.secondaryPhone,
    required this.email,
    this.websiteUrl,
    required this.operatingHoursTitle,
    required this.operatingHours,
    required this.headquarters,
  });
}

/// Root Aggregate Model for About Us
class AboutUsContent {
  final CompanyHeroContent hero;
  final WhoWeAreContent whoWeAre;
  final MissionVisionContent missionVision;
  final List<ServiceDivision> services;
  final CompanyContactContent contact;

  const AboutUsContent({
    required this.hero,
    required this.whoWeAre,
    required this.missionVision,
    required this.services,
    required this.contact,
  });
}
