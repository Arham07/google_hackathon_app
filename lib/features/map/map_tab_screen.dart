import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_hackathon_app/features/incidents/data/mock_incidents.dart';
import 'package:google_hackathon_app/models/place_suggestion.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/utils/alert_marker_icon.dart';
import 'package:google_hackathon_app/widgets/map_search_bar.dart';

/// Map tab with Places search + demo markers from mock incidents.
class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kKarachi = CameraPosition(
    target: LatLng(24.8607, 67.0011),
    zoom: 11.5,
  );

  BitmapDescriptor? _alertIcon;
  Set<Marker> _incidentMarkers = {};
  Marker? _searchMarker;
  LatLng? _currentPosition;
  bool _locationReady = false;

  Set<Marker> get _allMarkers => {..._incidentMarkers, ?_searchMarker};

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _initUserLocation();
  }

  Future<void> _loadMarkers() async {
    final BitmapDescriptor icon = await createFloodAlertMarkerIcon();
    final Set<Marker> markers = mockIncidents.map((incident) {
      return Marker(
        markerId: MarkerId(incident.id),
        position: LatLng(incident.latitude, incident.longitude),
        icon: icon,
        infoWindow: InfoWindow(
          title: incident.title,
          snippet: incident.area,
        ),
      );
    }).toSet();

    if (!mounted) return;
    setState(() {
      _alertIcon = icon;
      _incidentMarkers = markers;
    });
  }

  Future<void> _onPlaceSelected(SelectedPlace place) async {
    final LatLng target = LatLng(place.latitude, place.longitude);
    setState(() {
      _searchMarker = Marker(
        markerId: const MarkerId('search_result'),
        position: target,
        infoWindow: InfoWindow(
          title: place.name.isNotEmpty ? place.name : 'Selected place',
          snippet: place.address,
        ),
      );
    });

    if (_controller.isCompleted) {
      final GoogleMapController mapController = await _controller.future;
      await mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15),
        ),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${place.latitude.toStringAsFixed(6)}, ${place.longitude.toStringAsFixed(6)}',
        ),
      ),
    );
  }

  Future<void> _initUserLocation() async {
    final LatLng? position = await LocationService.getCurrentLatLng();
    if (!mounted) return;
    if (position == null) return;

    setState(() {
      _currentPosition = position;
      _locationReady = true;
    });

    if (_controller.isCompleted) {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 14),
        ),
      );
    }
  }

  Future<void> _goToMyLocation() async {
    LatLng? position = _currentPosition ?? await LocationService.getCurrentLatLng();
    if (position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location.')),
      );
      return;
    }
    setState(() {
      _currentPosition = position;
      _locationReady = true;
    });
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  Future<void> _fitAllAlerts() async {
    if (mockIncidents.isEmpty || !_controller.isCompleted) return;
    final GoogleMapController controller = await _controller.future;
    double minLat = mockIncidents.first.latitude;
    double maxLat = minLat;
    double minLng = mockIncidents.first.longitude;
    double maxLng = minLng;

    for (final incident in mockIncidents) {
      minLat = minLat < incident.latitude ? minLat : incident.latitude;
      maxLat = maxLat > incident.latitude ? maxLat : incident.latitude;
      minLng = minLng < incident.longitude ? minLng : incident.longitude;
      maxLng = maxLng > incident.longitude ? maxLng : incident.longitude;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: _kKarachi,
            markers: _allMarkers,
            myLocationEnabled: _locationReady,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
          ),
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 12,
            right: 12,
            child: MapSearchBar(onPlaceSelected: _onPlaceSelected),
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
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'map_all_alerts',
            onPressed: _alertIcon == null ? null : _fitAllAlerts,
            label: const Text('Show all alerts'),
            icon: const Icon(Icons.warning_amber_rounded),
          ),
        ],
      ),
    );
  }
}
