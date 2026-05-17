import 'dart:convert';

import 'package:google_hackathon_app/config/api_config.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/features/incidents/models/incident_source.dart';
import 'package:google_hackathon_app/theme/priority_styles.dart';

/// Typed view of a CIRO event row from `/api/events`.
class ApiEvent {
  const ApiEvent({
    required this.eventId,
    required this.type,
    required this.category,
    required this.priority,
    required this.status,
    required this.city,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.areaLatitude,
    required this.areaLongitude,
    required this.eventTags,
    required this.sourceTrail,
    required this.aiSummary,
    required this.scanDatetime,
    required this.isUserSubmitted,
    this.address,
    this.thumbnailPath,
    this.roadLatitude,
    this.roadLongitude,
    this.updatedAt,
  });

  final String eventId;
  final String type;
  final String category;
  final String priority;
  final String status;
  final String city;
  final String area;
  final double latitude;
  final double longitude;
  final double? areaLatitude;
  final double? areaLongitude;
  final String? address;
  final List<String> eventTags;
  final List<IncidentSourceTrail> sourceTrail;
  final double? roadLatitude;
  final double? roadLongitude;
  final String aiSummary;
  final String? thumbnailPath;
  final DateTime scanDatetime;
  final DateTime? updatedAt;
  final bool isUserSubmitted;

  String? get thumbnailUrl => ApiConfig.resolveAssetUrl(thumbnailPath);

  factory ApiEvent.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? roadCoords =
        _asMap(json['road_coords']);

    return ApiEvent(
      eventId: json['event_id'] as String? ?? '',
      type: json['type'] as String? ?? 'TEXT',
      category: json['category'] as String? ?? 'Incident',
      priority: json['priority'] as String? ?? 'UNKNOWN',
      status: json['status'] as String? ?? '',
      city: json['city'] as String? ?? ApiConfig.defaultCity,
      area: json['area'] as String? ?? '',
      areaLatitude: (json['area_lat'] as num?)?.toDouble(),
      areaLongitude: (json['area_lng'] as num?)?.toDouble(),
      latitude: (json['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['lng'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String?,
      eventTags: _stringList(json['event_tags']) ?? const <String>[],
      sourceTrail: _parseSourceTrail(json['source_trail']),
      roadLatitude: (roadCoords?['lat'] as num?)?.toDouble(),
      roadLongitude: (roadCoords?['lng'] as num?)?.toDouble(),
      aiSummary: json['ai_summary'] as String? ??
          json['category'] as String? ??
          '',
      thumbnailPath: json['thumbnail'] as String?,
      scanDatetime: _parseDateTime(json['scan_datetime']),
      updatedAt: _parseOptionalDateTime(json['updated_at']),
      isUserSubmitted: json['is_user_submitted'] == true,
    );
  }

  Incident toIncident() => incidentFromApiEvent(this);
}

/// Maps API event JSON to [Incident].
Incident incidentFromApiJson(Map<String, dynamic> json) {
  return ApiEvent.fromJson(json).toIncident();
}

Incident incidentFromApiEvent(ApiEvent event) {
  final bool isUserSubmitted = event.isUserSubmitted;

  return Incident(
    id: event.eventId,
    title: event.category,
    category: event.category,
    city: event.city,
    area: event.area,
    address: event.address,
    latitude: event.latitude,
    longitude: event.longitude,
    priority: IncidentPriorityX.fromString(event.priority),
    scanDatetime: event.scanDatetime,
    summary: event.aiSummary,
    precautions: const <String>[],
    resources: const <String>[],
    isUserSubmitted: isUserSubmitted,
    authenticity: isUserSubmitted
        ? AuthenticityTier.unverifiedCitizen
        : AuthenticityTier.establishedAccount,
    thumbnailUrl: event.thumbnailUrl,
    status: event.status.isNotEmpty ? event.status : null,
    type: event.type,
    eventTags: event.eventTags,
    sourceTrail: event.sourceTrail,
    areaLatitude: event.areaLatitude,
    areaLongitude: event.areaLongitude,
    roadLatitude: event.roadLatitude,
    roadLongitude: event.roadLongitude,
  );
}

/// Enrich [incident] from a full `view=full` row when available.
Incident mergeFullEvent(Incident incident, Map<String, dynamic> full) {
  final ApiEvent parsed = ApiEvent.fromJson(full);
  final Map<String, dynamic>? payload = _resolvePayload(full);

  final String? payloadReasoning = payload?['display_reasoning']?.toString();
  final String summary = full['ai_summary'] as String? ??
      (payloadReasoning != null && payloadReasoning.isNotEmpty
          ? payloadReasoning
          : null) ??
      (parsed.aiSummary.isNotEmpty ? parsed.aiSummary : incident.summary);

  final List<String> precautions = _extractPrecautions(full, payload) ??
      incident.precautions;

  final List<String> resources = _extractResources(full, payload) ??
      incident.resources;

  final Incident merged = incidentFromApiEvent(parsed);

  return Incident(
    id: incident.id,
    title: merged.title,
    category: merged.category,
    city: merged.city,
    area: merged.area,
    address: merged.address ?? incident.address,
    latitude: merged.latitude != 0 ? merged.latitude : incident.latitude,
    longitude: merged.longitude != 0 ? merged.longitude : incident.longitude,
    priority: IncidentPriorityX.fromString(
      full['priority'] as String? ?? incident.priority.label,
    ),
    scanDatetime: merged.scanDatetime,
    summary: summary,
    precautions: precautions,
    resources: resources,
    isUserSubmitted: merged.isUserSubmitted,
    authenticity: merged.authenticity,
    thumbnailUrl: merged.thumbnailUrl ?? incident.thumbnailUrl,
    status: merged.status ?? incident.status,
    type: merged.type ?? incident.type,
    eventTags: merged.eventTags.isNotEmpty ? merged.eventTags : incident.eventTags,
    sourceTrail:
        merged.sourceTrail.isNotEmpty ? merged.sourceTrail : incident.sourceTrail,
    areaLatitude: merged.areaLatitude ?? incident.areaLatitude,
    areaLongitude: merged.areaLongitude ?? incident.areaLongitude,
    roadLatitude: merged.roadLatitude ?? incident.roadLatitude,
    roadLongitude: merged.roadLongitude ?? incident.roadLongitude,
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

List<IncidentSourceTrail> _parseSourceTrail(dynamic raw) {
  if (raw is! List) return const <IncidentSourceTrail>[];

  return raw
      .map((dynamic entry) {
        if (entry is! Map) return null;
        final Map<String, dynamic> map = Map<String, dynamic>.from(entry);
        final String type = map['type'] as String? ?? '';
        final dynamic dump = map['json_dump_response'];

        if (type == 'news') {
          return IncidentSourceTrail(
            type: type,
            newsArticles: _parseNewsArticles(dump),
          );
        }
        if (type == 'weather') {
          return IncidentSourceTrail(
            type: type,
            weather: _parseWeatherSnapshot(dump),
          );
        }
        return null;
      })
      .whereType<IncidentSourceTrail>()
      .toList();
}

List<IncidentNewsArticle> _parseNewsArticles(dynamic dump) {
  if (dump is! List) return const <IncidentNewsArticle>[];

  return dump
      .map((dynamic item) {
        if (item is! Map) return null;
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        final String headline = map['headline'] as String? ?? '';
        if (headline.isEmpty) return null;
        return IncidentNewsArticle(
          headline: headline,
          url: map['url'] as String?,
          thumbnailUrl: ApiConfig.resolveAssetUrl(map['thumbnail'] as String?),
          publishedAt: map['published_at'] as String?,
          source: map['source'] as String?,
        );
      })
      .whereType<IncidentNewsArticle>()
      .toList();
}

IncidentWeatherSnapshot? _parseWeatherSnapshot(dynamic dump) {
  final Map<String, dynamic>? root = _asMap(dump);
  if (root == null) return null;

  final Map<String, dynamic>? current = _asMap(root['current']);
  final Map<String, dynamic>? forecast = _asMap(root['forecast_day1']);
  if (current == null && forecast == null) return null;

  return IncidentWeatherSnapshot(
    tempC: (current?['temp_c'] as num?)?.toDouble(),
    humidity: (current?['humidity'] as num?)?.toInt(),
    windKph: (current?['wind_kph'] as num?)?.toDouble(),
    condition: current?['condition'] as String?,
    day1Condition: forecast?['day1_condition'] as String?,
    day1PrecipMm: (forecast?['day1_precip_mm'] as num?)?.toDouble(),
    day1RainChance: (forecast?['day1_rain_chance'] as num?)?.toInt(),
  );
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
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

DateTime _parseDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

DateTime? _parseOptionalDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
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
