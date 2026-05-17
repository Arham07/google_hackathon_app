import 'package:google_hackathon_app/config/api_config.dart';
import 'package:google_hackathon_app/core/api/api_client.dart';

class NearestAreaInfo {
  const NearestAreaInfo({
    this.city,
    this.area,
    this.areaLat,
    this.areaLng,
    this.distanceKm,
  });

  final String? city;
  final String? area;
  final double? areaLat;
  final double? areaLng;
  final double? distanceKm;

  factory NearestAreaInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const NearestAreaInfo();
    return NearestAreaInfo(
      city: json['city'] as String?,
      area: json['area'] as String?,
      areaLat: (json['area_lat'] as num?)?.toDouble(),
      areaLng: (json['area_lng'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );
  }
}

class EventsListResponse {
  const EventsListResponse({
    required this.count,
    required this.events,
    this.nearestArea,
  });

  final int count;
  final List<Map<String, dynamic>> events;
  final NearestAreaInfo? nearestArea;
}

/// GET /api/events and /api/events/nearest.
class EventsApi {
  EventsApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<EventsListResponse> fetchAll({
    String city = ApiConfig.defaultCity,
    int limit = ApiConfig.eventsLimit,
  }) async {
    final Map<String, dynamic> body = await _client.get(
      '/api/events',
      queryParameters: <String, dynamic>{
        'city': city,
        'limit': limit,
      },
    );
    return _parseList(body);
  }

  Future<EventsListResponse> fetchNearest({
    required double lat,
    required double lng,
    String city = ApiConfig.defaultCity,
    int limit = ApiConfig.eventsLimit,
  }) async {
    final Map<String, dynamic> body = await _client.get(
      '/api/events/nearest',
      queryParameters: <String, dynamic>{
        'city': city,
        'lat': lat,
        'lng': lng,
        'limit': limit,
      },
    );
    final EventsListResponse list = _parseList(body);
    return EventsListResponse(
      count: list.count,
      events: list.events,
      nearestArea: NearestAreaInfo.fromJson(
        body['nearest_area'] as Map<String, dynamic>?,
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchById(String eventId) async {
    final Map<String, dynamic> body = await _client.get(
      '/api/events',
      queryParameters: <String, dynamic>{
        'event_id': eventId,
        'view': 'full',
      },
    );
    final List<dynamic> events = body['events'] as List<dynamic>? ?? [];
    if (events.isEmpty) return null;
    final dynamic first = events.first;
    if (first is Map<String, dynamic>) return first;
    if (first is Map) return Map<String, dynamic>.from(first);
    return null;
  }

  EventsListResponse _parseList(Map<String, dynamic> body) {
    final int count = (body['count'] as num?)?.toInt() ?? 0;
    final List<dynamic> raw = body['events'] as List<dynamic>? ?? [];
    final List<Map<String, dynamic>> events = raw.map((dynamic e) {
      if (e is Map<String, dynamic>) return e;
      if (e is Map) return Map<String, dynamic>.from(e);
      return <String, dynamic>{};
    }).where((Map<String, dynamic> m) => m.isNotEmpty).toList();

    return EventsListResponse(count: count, events: events);
  }
}
