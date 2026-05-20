import 'package:flutter/foundation.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';
import 'package:google_hackathon_app/core/api/events_api.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/models/api_event.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum IncidentListMode { all, nearby, priority }

/// Thrown when Nearby mode cannot load without a GPS fix.
class NearbyLocationRequired implements Exception {
  const NearbyLocationRequired(this.status);

  final LocationAccessStatus status;

  String get message => LocationService.messageForStatus(status);
}

/// Loads events from API; priority chips filter/sort on device only.
class IncidentsController extends ChangeNotifier {
  IncidentsController({
    EventsApi? eventsApi,
  }) : _eventsApi = eventsApi ?? EventsApi();

  final EventsApi _eventsApi;

  IncidentListMode mode = IncidentListMode.all;
  final Set<IncidentPriority> activePriorityFilters = <IncidentPriority>{};

  List<Incident> _allIncidents = <Incident>[];
  List<Incident> mapEvents = <Incident>[];
  NearestAreaInfo? nearestArea;

  bool isLoading = false;
  bool mapEventsLoading = false;
  String? errorMessage;
  String? mapEventsError;

  /// Set when Nearby tab fails due to missing GPS / permission.
  LocationAccessStatus? nearbyLocationStatus;

  /// Bumped on each [load]; stale responses are ignored after tab/mode switches.
  int _loadGeneration = 0;

  /// When set, [MapTabScreen] should fly the camera here and show the peek card.
  Incident? pendingMapFocus;

  bool _switchToMapTabPending = false;

  /// One-shot: [MainShell] switches bottom navigation to the Map tab, then clears via [clearSwitchToMapTabPending].
  bool get switchToMapTabPending => _switchToMapTabPending;

  bool get isNearbyLocationBlocked =>
      mode == IncidentListMode.nearby &&
      nearbyLocationStatus != null &&
      nearbyLocationStatus != LocationAccessStatus.granted;

  /// Incidents with valid coordinates for map markers.
  List<Incident> get mapEventsWithCoordinates => mapEvents
      .where((Incident i) => i.latitude != 0 || i.longitude != 0)
      .toList();

  List<Incident> get visibleIncidents {
    List<Incident> list = List<Incident>.from(_allIncidents);
    if (mode == IncidentListMode.priority) {
      sortIncidentsByPriority(list);
      if (activePriorityFilters.isEmpty) {
        list = list
            .where(
              (Incident i) =>
                  i.priority != IncidentPriority.low &&
                  i.priority != IncidentPriority.unknown,
            )
            .toList();
      }
    }
    return filterIncidentsByPriorities(list, activePriorityFilters);
  }

  Future<void> load() async {
    final int generation = ++_loadGeneration;
    isLoading = true;
    errorMessage = null;
    if (mode != IncidentListMode.nearby) {
      nearbyLocationStatus = null;
    }
    notifyListeners();

    try {
      final EventsListResponse response = await _fetchForMode();
      if (!_isStaleLoad(generation)) {
        _allIncidents = incidentsFromApiList(response.events);
        nearestArea = response.nearestArea;
        errorMessage = null;
        if (mode == IncidentListMode.nearby) {
          nearbyLocationStatus = LocationAccessStatus.granted;
        }
      }
    } on NearbyLocationRequired catch (e) {
      if (!_isStaleLoad(generation)) {
        nearbyLocationStatus = e.status;
        errorMessage = e.message;
        _allIncidents = <Incident>[];
        nearestArea = null;
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
    if (mode == newMode &&
        _allIncidents.isNotEmpty &&
        errorMessage == null &&
        !isNearbyLocationBlocked) {
      notifyListeners();
      return;
    }
    mode = newMode;
    _loadGeneration++;
    _allIncidents = <Incident>[];
    nearestArea = null;
    errorMessage = null;
    if (newMode != IncidentListMode.nearby) {
      nearbyLocationStatus = null;
    }
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
        final LocationAccess access =
            await LocationService.getCurrentLocationForNearby();
        nearbyLocationStatus = access.status;
        final LatLng? position = access.position;
        if (!access.isSuccess || position == null) {
          throw NearbyLocationRequired(
            access.status == LocationAccessStatus.granted
                ? LocationAccessStatus.unavailable
                : access.status,
          );
        }
        return _eventsApi.fetchNearest(
          lat: position.latitude,
          lng: position.longitude,
        );
      case IncidentListMode.priority:
      case IncidentListMode.all:
        return _eventsApi.fetchAll();
    }
  }
}
