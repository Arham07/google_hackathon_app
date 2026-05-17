import 'package:flutter/foundation.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/events_api.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/models/api_event.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum IncidentListMode { nearby, priority, all }

/// Loads events from API; priority chips filter/sort on device only.
class IncidentsController extends ChangeNotifier {
  IncidentsController({
    EventsApi? eventsApi,
  }) : _eventsApi = eventsApi ?? EventsApi();

  final EventsApi _eventsApi;

  static const LatLng _karachiFallback = LatLng(24.8607, 67.0011);

  IncidentListMode mode = IncidentListMode.nearby;
  final Set<IncidentPriority> activePriorityFilters = <IncidentPriority>{};

  List<Incident> _allIncidents = <Incident>[];
  NearestAreaInfo? nearestArea;

  bool isLoading = false;
  String? errorMessage;

  List<Incident> get visibleIncidents {
    List<Incident> list = List<Incident>.from(_allIncidents);
    if (mode == IncidentListMode.priority) {
      sortIncidentsByPriority(list);
    }
    return filterIncidentsByPriorities(list, activePriorityFilters);
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final EventsListResponse response = await _fetchForMode();
      _allIncidents = incidentsFromApiList(response.events);
      nearestArea = response.nearestArea;
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
      _allIncidents = <Incident>[];
    } catch (_) {
      errorMessage = 'Failed to load incidents';
      _allIncidents = <Incident>[];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setMode(IncidentListMode newMode) async {
    if (mode == newMode && _allIncidents.isNotEmpty && errorMessage == null) {
      notifyListeners();
      return;
    }
    mode = newMode;
    await load();
  }

  void togglePriorityFilter(IncidentPriority priority) {
    if (activePriorityFilters.contains(priority)) {
      activePriorityFilters.remove(priority);
    } else {
      activePriorityFilters.add(priority);
    }
    notifyListeners();
  }

  void clearPriorityFilters() {
    activePriorityFilters.clear();
    notifyListeners();
  }

  Future<EventsListResponse> _fetchForMode() async {
    switch (mode) {
      case IncidentListMode.nearby:
        final LatLng? position = await LocationService.getCurrentLatLng();
        final double lat = position?.latitude ?? _karachiFallback.latitude;
        final double lng = position?.longitude ?? _karachiFallback.longitude;
        return _eventsApi.fetchNearest(lat: lat, lng: lng);
      case IncidentListMode.priority:
      case IncidentListMode.all:
        return _eventsApi.fetchAll();
    }
  }
}
