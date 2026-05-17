import 'package:google_hackathon_app/theme/priority_styles.dart';

export 'package:google_hackathon_app/theme/priority_styles.dart' show IncidentPriority;

enum AuthenticityTier {
  verifiedMajorOutlet,
  establishedAccount,
  unverifiedCitizen,
}

extension AuthenticityTierX on AuthenticityTier {
  String get label {
    switch (this) {
      case AuthenticityTier.verifiedMajorOutlet:
        return 'Verified — major outlet';
      case AuthenticityTier.establishedAccount:
        return 'Established source';
      case AuthenticityTier.unverifiedCitizen:
        return 'Citizen report';
    }
  }
}

class Incident {
  const Incident({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.priority,
    required this.scanDatetime,
    required this.summary,
    required this.precautions,
    required this.resources,
    this.address,
    this.isUserSubmitted = false,
    this.authenticity = AuthenticityTier.establishedAccount,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String category;
  final String city;
  final String area;
  final String? address;
  final double latitude;
  final double longitude;
  final IncidentPriority priority;
  final DateTime scanDatetime;
  final String summary;
  final List<String> precautions;
  final List<String> resources;
  final bool isUserSubmitted;
  final AuthenticityTier authenticity;
  final String? thumbnailUrl;

  String get locationLabel {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    if (area.isNotEmpty) return '$area, $city';
    return city;
  }
}

/// Backward-compatible alias for mock data files.
typedef MockIncident = Incident;
