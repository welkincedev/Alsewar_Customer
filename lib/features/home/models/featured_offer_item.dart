import '../../../core/constants/api_constants.dart';
import '../../services/models/service_item.dart';

/// Al Sewar Featured Offer Data Model.
///
/// Encapsulates promotional offers and package showcases for the Home Screen.
/// Supports:
/// - Real backend promotional poster image URLs (`posterUrl`)
/// - Verified local fallback automotive photography (`imageAsset`)
/// - 2:3 portrait aspect ratio presentation
/// - Associated [ServiceItem] navigation destination
class FeaturedOfferItem {
  final int id;
  final String title;
  final String description;
  final int points;
  final bool isFree;
  final String? badge;
  final String? savingText;
  final String imageAsset;
  final String? posterUrl;
  final ServiceItem? service;

  const FeaturedOfferItem({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.isFree = false,
    this.badge,
    this.savingText,
    required this.imageAsset,
    this.posterUrl,
    this.service,
  });

  /// Formatted points with comma separator (e.g. 1,200).
  String get formattedPoints {
    if (points >= 1000) {
      final thousands = points ~/ 1000;
      final remainder = points % 1000;
      return '$thousands,${remainder.toString().padLeft(3, '0')}';
    }
    return points.toString();
  }

  /// Resolves the full network URL for the poster image if available.
  String? get effectivePosterUrl {
    if (posterUrl != null && posterUrl!.trim().isNotEmpty) {
      return resolvePosterUrl(posterUrl);
    }
    if (service != null &&
        service!.imageAsset != null &&
        service!.imageAsset!.trim().isNotEmpty) {
      return resolvePosterUrl(service!.imageAsset);
    }
    return null;
  }

  /// Helper to convert relative or absolute image path to full URL.
  static String? resolvePosterUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final trimmed = raw.trim();
    if (trimmed.startsWith('assets/')) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '${ApiConstants.baseUrl}$trimmed';
    }
    return '${ApiConstants.baseUrl}/$trimmed';
  }

  /// Resolves the fallback local asset for an offer item.
  static String resolveImageAsset(
    String? raw,
    String name, [
    String? category,
  ]) {
    if (raw != null && raw.trim().startsWith('assets/')) {
      return raw.trim();
    }
    return ServiceItem.resolveImageByName(name, category);
  }

  /// Maps a dynamic backend [ServiceItem] into a [FeaturedOfferItem].
  factory FeaturedOfferItem.fromServiceItem(ServiceItem service) {
    final lower =
        '${service.name.toLowerCase()} ${service.category?.toLowerCase() ?? ''}';
    final int points;
    final bool isFree;
    final String? badge;
    final String? savingText;
    final String offerTitle;

    if (lower.contains('wash') || lower.contains('hydro')) {
      points = 1200;
      isFree = true;
      badge = 'FREE';
      savingText = 'Save 20%';
      offerTitle = 'Full Exterior & Polish';
    } else if (lower.contains('ac') ||
        lower.contains('air') ||
        lower.contains('cooling')) {
      points = 800;
      isFree = true;
      badge = 'FREE';
      savingText = 'Special Value';
      offerTitle = 'AC Ozone Purification';
    } else if (lower.contains('inspect') || lower.contains('diagnostic')) {
      points = 600;
      isFree = true;
      badge = 'FREE';
      savingText = 'Complimentary';
      offerTitle = 'Multi-Point Inspection';
    } else if (lower.contains('oil') || lower.contains('battery')) {
      points = 2500;
      isFree = false;
      badge = 'POPULAR';
      savingText = 'Complimentary Wax';
      offerTitle = 'Oil & Filter Care';
    } else if (lower.contains('ceramic') ||
        lower.contains('detail') ||
        lower.contains('polish') ||
        lower.contains('ppf')) {
      points = 3500;
      isFree = false;
      badge = 'EXCLUSIVE';
      savingText = 'Special Value';
      offerTitle = 'Ceramic Shield Polish';
    } else if (lower.contains('tyre') ||
        lower.contains('tire') ||
        lower.contains('wheel')) {
      points = 1500;
      isFree = false;
      badge = 'SPECIAL';
      savingText = 'Quick Turnaround';
      offerTitle = '3D Wheel Balancing';
    } else {
      points = 2000;
      isFree = false;
      badge = 'FEATURED';
      savingText = null;
      offerTitle = service.displayShortName;
    }

    final rawImage = service.imageAsset;
    final posterUrl = resolvePosterUrl(rawImage);
    final imageAsset = resolveImageAsset(
      rawImage,
      service.name,
      service.category,
    );

    return FeaturedOfferItem(
      id: service.id,
      title: offerTitle,
      description: service.tagline != null && service.tagline!.isNotEmpty
          ? service.tagline!
          : service.description,
      points: points,
      isFree: isFree,
      badge: badge,
      savingText: savingText,
      imageAsset: imageAsset,
      posterUrl: posterUrl,
      service: service,
    );
  }

  /// Constructs a [FeaturedOfferItem] from a backend JSON map.
  factory FeaturedOfferItem.fromJson(Map<String, dynamic> json) {
    final rawImage =
        (json['image'] ??
                json['poster'] ??
                json['poster_image'] ??
                json['poster_url'] ??
                json['image_url'] ??
                json['image_asset'])
            ?.toString();

    final title = (json['title'] ?? json['name'] ?? '').toString();
    final category = json['category']?.toString();
    final posterUrl = resolvePosterUrl(rawImage);
    final imageAsset = resolveImageAsset(rawImage, title, category);

    return FeaturedOfferItem(
      id: (json['id'] as num? ?? 0).toInt(),
      title: title,
      description: (json['description'] ?? '').toString(),
      points: (json['points'] as num? ?? 0).toInt(),
      isFree: json['is_free'] == true,
      badge: json['badge']?.toString(),
      savingText: json['saving_text']?.toString(),
      imageAsset: imageAsset,
      posterUrl: posterUrl,
      service: json.containsKey('service') && json['service'] is Map
          ? ServiceItem.fromJson(json['service'] as Map<String, dynamic>)
          : null,
    );
  }
}
