import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_hackathon_app/features/incidents/incidents_controller.dart';
import 'package:google_hackathon_app/theme/app_dimens.dart';
import 'package:google_hackathon_app/features/incidents/models/incident.dart';
import 'package:google_hackathon_app/models/place_suggestion.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/utils/alert_marker_icon.dart';
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

  static const CameraPosition _kKarachi = CameraPosition(target: LatLng(24.8607, 67.0011), zoom: 11.5);

  CameraPosition? _initialCamera;
  BitmapDescriptor? _alertIcon;
  Set<Marker> _incidentMarkers = {};
  Marker? _searchMarker;
  LatLng? _currentPosition;
  bool _locationReady = false;
  bool _mapReady = false;

  Set<Marker> get _allMarkers => {..._incidentMarkers, ?_searchMarker};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapMap());
  }

  Future<void> _bootstrapMap() async {
    final IncidentsController incidents = context.read<IncidentsController>();

    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      LocationService.getCurrentLatLng(),
      createFloodAlertMarkerIcon(),
      incidents.loadMapEvents(),
    ]);

    if (!mounted) return;

    final LatLng? position = results[0] as LatLng?;
    final BitmapDescriptor icon = results[1] as BitmapDescriptor;

    final LatLng cameraTarget = position ?? _kKarachi.target;
    if (position != null) {
      _currentPosition = position;
      _locationReady = true;
    } else {
      _locationReady = false;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location unavailable — showing Karachi. Enable GPS for your position.')));
      }
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
  }

  Set<Marker> _buildMarkersFromIncidents(List<Incident> incidents, BitmapDescriptor icon) {
    return incidents.map((Incident incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        icon: icon,
        infoWindow: InfoWindow(title: incident.title, snippet: incident.address ?? incident.area),
      );
    }).toSet();
  }

  void _syncMarkersFromController(IncidentsController incidents) {
    if (_alertIcon == null) return;
    setState(() {
      _incidentMarkers = _buildMarkersFromIncidents(incidents.mapEventsWithCoordinates, _alertIcon!);
    });
  }

  Future<void> _onPlaceSelected(SelectedPlace place) async {
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
    final LatLng? position = _currentPosition ?? await LocationService.getCurrentLatLng();
    if (position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get your location.')));
      return;
    }
    setState(() {
      _currentPosition = position;
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
