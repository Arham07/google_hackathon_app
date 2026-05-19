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
  List<Incident> mapEvents = <Incident>[];
  NearestAreaInfo? nearestArea;

  bool isLoading = false;
  bool mapEventsLoading = false;
  String? errorMessage;
  String? mapEventsError;

  /// Bumped on each [load]; stale responses are ignored after tab/mode switches.
  int _loadGeneration = 0;

  /// When set, [MapTabScreen] should fly the camera here and show the peek card.
  Incident? pendingMapFocus;

  bool _switchToMapTabPending = false;

  /// One-shot: [MainShell] switches bottom navigation to the Map tab, then clears via [clearSwitchToMapTabPending].
  bool get switchToMapTabPending => _switchToMapTabPending;

  /// Incidents with valid coordinates for map markers.
  List<Incident> get mapEventsWithCoordinates => mapEvents
      .where((Incident i) => i.latitude != 0 || i.longitude != 0)
      .toList();

  List<Incident> get visibleIncidents {
    List<Incident> list = List<Incident>.from(_allIncidents);
    if (mode == IncidentListMode.priority) {
      sortIncidentsByPriority(list);
    }
    return filterIncidentsByPriorities(list, activePriorityFilters);
  }

  Future<void> load() async {
    final int generation = ++_loadGeneration;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final EventsListResponse response = await _fetchForMode();
      if (!_isStaleLoad(generation)) {
        _allIncidents = incidentsFromApiList(response.events);
        nearestArea = response.nearestArea;
        errorMessage = null;
      }
    } on ApiException catch (e) {
      if (!_isStaleLoad(generation)) {
        errorMessage = e.message;
        _allIncidents = <Incident>[];
      }
    } catch (_) {
      if (!_isStaleLoad(generation)) {
        errorMessage = 'Failed to load incidents';
        _allIncidents = <Incident>[];
      }
    }

    if (!_isStaleLoad(generation)) {
      isLoading = false;
      notifyListeners();
    }
  }

  bool _isStaleLoad(int generation) => generation != _loadGeneration;

  void requestMapFocus(Incident incident, {bool switchToMapTab = false}) {
    pendingMapFocus = incident;
    if (switchToMapTab) {
      _switchToMapTabPending = true;
    }
    notifyListeners();
  }

  void clearSwitchToMapTabPending() {
    _switchToMapTabPending = false;
  }

  void clearPendingMapFocus() {
    if (pendingMapFocus == null) return;
    pendingMapFocus = null;
    notifyListeners();
  }

  Future<void> setMode(IncidentListMode newMode) async {
    if (mode == newMode && _allIncidents.isNotEmpty && errorMessage == null) {
      notifyListeners();
      return;
    }
    mode = newMode;
    _loadGeneration++;
    _allIncidents = <Incident>[];
    nearestArea = null;
    errorMessage = null;
    isLoading = true;
    notifyListeners();
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

  /// Loads all events for the map tab (`GET /api/events`), independent of list mode.
  Future<void> loadMapEvents() async {
    mapEventsLoading = true;
    mapEventsError = null;
    notifyListeners();

    try {
      final EventsListResponse response = await _eventsApi.fetchAll();
      mapEvents = incidentsFromApiList(response.events);
      mapEventsError = null;
    } on ApiException catch (e) {
      mapEventsError = e.message;
      mapEvents = <Incident>[];
    } catch (_) {
      mapEventsError = 'Failed to load map alerts';
      mapEvents = <Incident>[];
    } finally {
      mapEventsLoading = false;
      notifyListeners();
    }
  }

  Future<EventsListResponse> _fetchForMode() async {
    switch (mode) {
      case IncidentListMode.nearby:
        final LocationAccess access = await LocationService.getCurrentLocation();
        final LatLng? position = access.position;
        final double lat = position?.latitude ?? _karachiFallback.latitude;
        final double lng = position?.longitude ?? _karachiFallback.longitude;
        return _eventsApi.fetchNearest(lat: lat, lng: lng);
      case IncidentListMode.priority:
      case IncidentListMode.all:
        return _eventsApi.fetchAll();
    }
  }
}
