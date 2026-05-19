import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/features/incidents/incident_detail_screen.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/models/place_suggestion.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/utils/alert_marker_icon.dart';
import 'package:google_hackathon_app/widgets/map_incident_peek_card.dart';
import 'package:google_hackathon_app/widgets/map_search_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

/// Map tab: user GPS first, Places search, API event markers.
class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  static final CameraPosition _fallbackCamera = CameraPosition(
    target: LocationService.fallbackCenter,
    zoom: 11.5,
  );

  CameraPosition? _initialCamera;
  BitmapDescriptor? _alertIcon;
  Set<Marker> _incidentMarkers = {};
  Marker? _searchMarker;
  bool _locationReady = false;
  bool _mapReady = false;
  Incident? _selectedMapIncident;

  IncidentsController? _incidentsController;

  Set<Marker> get _allMarkers => {..._incidentMarkers, ?_searchMarker};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final IncidentsController c = context.read<IncidentsController>();
      _incidentsController = c;
      c.addListener(_onIncidentsControllerChanged);
      _drainPendingMapFocus();
      _bootstrapMap();
    });
  }

  @override
  void dispose() {
    _incidentsController?.removeListener(_onIncidentsControllerChanged);
    super.dispose();
  }

  void _onIncidentsControllerChanged() {
    if (!mounted) return;
    _drainPendingMapFocus();
  }

  void _drainPendingMapFocus() {
    final IncidentsController? c = _incidentsController;
    if (c == null || !mounted) return;
    final Incident? pending = c.pendingMapFocus;
    if (pending == null) return;
    if (!_mapReady) return;
    c.clearPendingMapFocus();
    setState(() => _selectedMapIncident = pending);
    unawaited(_animateToIncident(pending));
  }

  Future<void> _bootstrapMap() async {
    final IncidentsController incidents = context.read<IncidentsController>();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      createFloodAlertMarkerIcon(),
      incidents.loadMapEvents(),
    ]);

    if (!mounted) return;

    final LatLng? position =
        await LocationService.obtainCurrentLocation(context);
    if (!mounted) return;

    final BitmapDescriptor icon = results[0] as BitmapDescriptor;

    final LatLng cameraTarget = position ?? _fallbackCamera.target;
    if (position != null) {
      _locationReady = true;
    } else {
      _locationReady = false;
    }

    if (incidents.mapEventsError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(incidents.mapEventsError!)));
    }

    setState(() {
      _initialCamera = CameraPosition(target: cameraTarget, zoom: 14);
      _alertIcon = icon;
      _incidentMarkers = _buildMarkersFromIncidents(incidents.mapEventsWithCoordinates, icon);
      _mapReady = true;
    });

    _drainPendingMapFocus();
  }

  Set<Marker> _buildMarkersFromIncidents(List<Incident> incidents, BitmapDescriptor icon) {
    return incidents.map((Incident incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        icon: icon,
        infoWindow: InfoWindow.noText,
        consumeTapEvents: true,
        onTap: () {
          setState(() => _selectedMapIncident = incident);
          unawaited(_animateToIncident(incident));
        },
      );
    }).toSet();
  }

  void _syncMarkersFromController(IncidentsController incidents) {
    if (_alertIcon == null) return;
    setState(() {
      _incidentMarkers = _buildMarkersFromIncidents(incidents.mapEventsWithCoordinates, _alertIcon!);
    });
  }

  Future<void> _animateToIncident(Incident incident) async {
    final double lat = incident.mapLatitude;
    final double lng = incident.mapLongitude;
    if (lat == 0 && lng == 0) return;
    if (!_mapController.isCompleted) return;
    final GoogleMapController controller = await _mapController.future;
    if (!mounted) return;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(lat, lng), zoom: 15)),
    );
  }

  void _openSelectedDetail() {
    final Incident? i = _selectedMapIncident;
    if (i == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => IncidentDetailScreen(incident: i)),
    );
  }

  void _dismissPeek() => setState(() => _selectedMapIncident = null);

  Future<void> _onPlaceSelected(SelectedPlace place) async {
    setState(() => _selectedMapIncident = null);
    final LatLng target = LatLng(place.latitude, place.longitude);
    setState(() {
      _searchMarker = Marker(
        markerId: const MarkerId('search_result'),
        position: target,
        infoWindow: InfoWindow(title: place.name.isNotEmpty ? place.name : 'Selected place', snippet: place.address),
      );
    });

    if (_mapController.isCompleted) {
      final GoogleMapController controller = await _mapController.future;
      await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 15)));
    }

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${place.latitude.toStringAsFixed(6)}, ${place.longitude.toStringAsFixed(6)}')));
  }

  Future<void> _goToMyLocation() async {
    final LatLng? position = await LocationService.obtainCurrentLocation(context);
    if (position == null) return;
    setState(() {
      _selectedMapIncident = null;
      _locationReady = true;
    });
    if (!_mapController.isCompleted) return;
    final GoogleMapController controller = await _mapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: position, zoom: 16)));
  }

  Future<void> _fitAllAlerts() async {
    final IncidentsController incidents = context.read<IncidentsController>();

    if (incidents.mapEventsLoading) return;

    if (incidents.mapEventsWithCoordinates.isEmpty) {
      await incidents.loadMapEvents();
      if (!mounted) return;
      if (incidents.mapEventsError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(incidents.mapEventsError!)));
        return;
      }
      _syncMarkersFromController(incidents);
    }

    final List<Incident> plot = incidents.mapEventsWithCoordinates;
    if (plot.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No alerts to display on the map.')));
      return;
    }

    if (!_mapController.isCompleted) return;
    final GoogleMapController controller = await _mapController.future;

    double minLat = plot.first.latitude;
    double maxLat = minLat;
    double minLng = plot.first.longitude;
    double maxLng = minLng;

    for (final Incident incident in plot) {
      minLat = minLat < incident.latitude ? minLat : incident.latitude;
      maxLat = maxLat > incident.latitude ? maxLat : incident.latitude;
      minLng = minLng < incident.longitude ? minLng : incident.longitude;
      maxLng = maxLng > incident.longitude ? maxLng : incident.longitude;
    }

    setState(() => _selectedMapIncident = null);
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng)), 80),
    );
  }

  @override
  Widget build(BuildContext context) {
    final IncidentsController incidents = context.watch<IncidentsController>();
    final bool canShowAllAlerts = _mapReady && _alertIcon != null && !incidents.mapEventsLoading;

    if (!_mapReady || _initialCamera == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera!,
            markers: _allMarkers,
            myLocationEnabled: _locationReady,
            myLocationButtonEnabled: false,
            style: '''
  [
    {
      "elementType": "geometry",
      "stylers": [
        { "color": "#212121" }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        { "visibility": "off" }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        { "color": "#757575" }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        { "color": "#212121" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [
        { "color": "#383838" }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [
        { "color": "#1f1f1f" }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        { "color": "#000000" }
      ]
    }
  ]
  ''',
            onTap: (_) => _dismissPeek(),
            onMapCreated: (GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppDimens.space8,
            left: AppDimens.space12,
            right: AppDimens.space12,
            child: MapSearchBar(onPlaceSelected: _onPlaceSelected),
          ),
          if (_selectedMapIncident != null)
            Positioned(
              left: AppDimens.space12,
              right: AppDimens.space12,
              bottom: 168 + MediaQuery.paddingOf(context).bottom,
              child: MapIncidentPeekCard(
                incident: _selectedMapIncident!,
                onSeeDetails: _openSelectedDetail,
                onDismiss: _dismissPeek,
              ),
            ),
          if (incidents.mapEventsLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: LinearProgressIndicator(minHeight: 2.h),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'map_my_location',
            tooltip: 'My location',
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
          SizedBox(height: AppDimens.space12),
          FloatingActionButton.extended(
            heroTag: 'map_all_alerts',
            onPressed: canShowAllAlerts ? _fitAllAlerts : null,
            label: const Text('Show all alerts'),
            icon: const Icon(Icons.warning_amber_rounded),
          ),
        ],
      ),
    );
  }
}
