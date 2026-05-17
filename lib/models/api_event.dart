import 'dart:convert';

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
  final Map<String, dynamic>? payload = _resolvePayload(full);

  final String summary = full['ai_summary'] as String? ??
      payload?['display_reasoning']?.toString() ??
      incident.summary;

  final List<String> precautions = _extractPrecautions(full, payload) ??
      incident.precautions;

  final List<String> resources = _extractResources(full, payload) ??
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
    final List<String> items = value
        .map((dynamic e) => e.toString().trim())
        .where((String s) => s.isNotEmpty)
        .toList();
    return items.isEmpty ? null : items;
  }
  if (value is String && value.trim().isNotEmpty) {
    return <String>[value.trim()];
  }
  return null;
}

Map<String, dynamic>? _resolvePayload(Map<String, dynamic> full) {
  final dynamic raw = full['payload'];
  if (raw is Map<String, dynamic>) return raw;
  if (raw is Map) return Map<String, dynamic>.from(raw);
  if (raw is String && raw.trim().startsWith('{')) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

List<String>? _extractPrecautions(
  Map<String, dynamic> full,
  Map<String, dynamic>? payload,
) {
  final Map<String, dynamic>? p = payload ?? _resolvePayload(full);

  final List<String>? fromBullets = _stringList(p?['display_reasoning']);
  if (fromBullets != null && fromBullets.isNotEmpty) return fromBullets;

  final String? peopleSafety = p?['people_safety'] as String? ??
      full['people_safety'] as String?;
  if (peopleSafety != null && peopleSafety.trim().isNotEmpty) {
    return <String>[peopleSafety.trim()];
  }

  return _stringList(p?['precautions']) ?? _stringList(full['precautions']);
}

List<String>? _extractResources(
  Map<String, dynamic> full,
  Map<String, dynamic>? payload,
) {
  final Map<String, dynamic>? p = payload ?? _resolvePayload(full);

  final List<String>? assets = _stringList(p?['assigned_assets']) ??
      _stringList(full['assigned_assets']);
  if (assets != null && assets.isNotEmpty) {
    return assets.where((String a) => a != 'SYSTEM_UPDATE').toList();
  }

  return _stringList(p?['resources']) ?? _stringList(full['resources']);
}
