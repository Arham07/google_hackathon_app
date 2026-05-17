import 'package:google_hackathon_app/config/api_config.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

/// Maps compact API event JSON to [Incident].
Incident incidentFromApiJson(Map<String, dynamic> json) {
  final String id = json['event_id'] as String? ?? '';
  final String category = json['category'] as String? ?? 'Incident';
  final bool isUserSubmitted = json['is_user_submitted'] == true;

  final double lat = (json['lat'] as num?)?.toDouble() ?? 0;
  final double lng = (json['lng'] as num?)?.toDouble() ?? 0;

  final String city = json['city'] as String? ?? ApiConfig.defaultCity;
  final String area = json['area'] as String? ?? '';
  final String? address = json['address'] as String?;

  final String summary = json['ai_summary'] as String? ??
      json['category'] as String? ??
      '';

  final String? thumbnail = json['thumbnail'] as String?;
  final String? thumbnailUrl = _resolveThumbnailUrl(thumbnail);

  return Incident(
    id: id,
    title: category,
    category: category,
    city: city,
    area: area,
    address: address,
    latitude: lat,
    longitude: lng,
    priority: IncidentPriorityX.fromString(json['priority'] as String?),
    scanDatetime: _parseDateTime(json['scan_datetime']),
    summary: summary,
    precautions: const <String>[],
    resources: const <String>[],
    isUserSubmitted: isUserSubmitted,
    authenticity: isUserSubmitted
        ? AuthenticityTier.unverifiedCitizen
        : AuthenticityTier.establishedAccount,
    thumbnailUrl: thumbnailUrl,
  );
}

/// Enrich [incident] from a full `view=full` row when available.
Incident mergeFullEvent(Incident incident, Map<String, dynamic> full) {
  final Map<String, dynamic>? payload =
      full['payload'] is Map ? Map<String, dynamic>.from(full['payload'] as Map) : null;

  final String summary = full['ai_summary'] as String? ??
      payload?['display_reasoning']?.toString() ??
      incident.summary;

  final List<String> precautions = _stringList(payload?['precautions']) ??
      _stringList(full['precautions']) ??
      incident.precautions;

  final List<String> resources = _stringList(payload?['resources']) ??
      _stringList(full['assigned_assets']) ??
      incident.resources;

  return Incident(
    id: incident.id,
    title: incident.title,
    category: incident.category,
    city: incident.city,
    area: incident.area,
    address: incident.address ?? full['address'] as String?,
    latitude: incident.latitude,
    longitude: incident.longitude,
    priority: IncidentPriorityX.fromString(
      full['priority'] as String? ?? incident.priority.label,
    ),
    scanDatetime: incident.scanDatetime,
    summary: summary,
    precautions: precautions,
    resources: resources,
    isUserSubmitted: incident.isUserSubmitted,
    authenticity: incident.authenticity,
    thumbnailUrl: incident.thumbnailUrl ??
        _resolveThumbnailUrl(full['thumbnail'] as String?),
  );
}

List<Incident> incidentsFromApiList(List<Map<String, dynamic>> events) {
  return events.map(incidentFromApiJson).toList();
}

int prioritySortRank(IncidentPriority p) {
  switch (p) {
    case IncidentPriority.critical:
      return 0;
    case IncidentPriority.high:
      return 1;
    case IncidentPriority.medium:
      return 2;
    case IncidentPriority.low:
      return 3;
    case IncidentPriority.unknown:
      return 4;
  }
}

void sortIncidentsByPriority(List<Incident> list) {
  list.sort((Incident a, Incident b) {
    final int byPriority =
        prioritySortRank(a.priority).compareTo(prioritySortRank(b.priority));
    if (byPriority != 0) return byPriority;
    return b.scanDatetime.compareTo(a.scanDatetime);
  });
}

List<Incident> filterIncidentsByPriorities(
  List<Incident> list,
  Set<IncidentPriority> filters,
) {
  if (filters.isEmpty) return list;
  return list.where((Incident i) => filters.contains(i.priority)).toList();
}

String? _resolveThumbnailUrl(String? thumbnail) {
  if (thumbnail == null || thumbnail.isEmpty) return null;
  if (thumbnail.startsWith('http')) return thumbnail;
  if (thumbnail.startsWith('/')) {
    return '${ApiConfig.baseUrl}$thumbnail';
  }
  return thumbnail;
}

DateTime _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

List<String>? _stringList(dynamic value) {
  if (value is List) {
    return value.map((dynamic e) => e.toString()).toList();
  }
  return null;
}
