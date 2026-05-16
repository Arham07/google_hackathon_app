import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_hackathon_app/services/location_service.dart';
import 'package:google_hackathon_app/utils/alert_marker_icon.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Karachi Flood Alerts',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapSample(),
    );
  }
}

/// Sample flood / emergency alert points across Karachi.
class FloodAlertPoint {
  const FloodAlertPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;

  LatLng get position => LatLng(latitude, longitude);
}

/// Karachi-area coordinates (approximate neighborhoods).
const List<FloodAlertPoint> karachiFloodAlerts = [
  FloodAlertPoint(id: '1', name: 'Clifton', latitude: 24.8138, longitude: 67.0299),
  FloodAlertPoint(id: '2', name: 'Saddar', latitude: 24.8546, longitude: 67.0205),
  FloodAlertPoint(id: '3', name: 'Gulshan-e-Iqbal', latitude: 24.9239, longitude: 67.0881),
  FloodAlertPoint(id: '4', name: 'Korangi', latitude: 24.8172, longitude: 67.1340),
  FloodAlertPoint(id: '5', name: 'Lyari', latitude: 24.8668, longitude: 66.9993),
  FloodAlertPoint(id: '6', name: 'Malir', latitude: 24.9056, longitude: 67.1388),
  FloodAlertPoint(id: '7', name: 'Orangi Town', latitude: 24.9467, longitude: 67.0056),
  FloodAlertPoint(id: '8', name: 'Keamari', latitude: 24.8267, longitude: 66.9756),
];

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kKarachi = CameraPosition(
    target: LatLng(24.8607, 67.0011),
    zoom: 11.5,
  );

  BitmapDescriptor? _alertIcon;
  Set<Marker> _markers = {};
  LatLng? _currentPosition;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
    _initUserLocation();
  }

  Future<void> _loadMarkers() async {
    final BitmapDescriptor icon = await createFloodAlertMarkerIcon();
    final Set<Marker> markers = karachiFloodAlerts.map((FloodAlertPoint point) {
      return Marker(
        markerId: MarkerId(point.id),
        position: point.position,
        icon: icon,
        infoWindow: InfoWindow(
          title: 'Flood alert',
          snippet: point.name,
        ),
      );
    }).toSet();

    if (!mounted) return;
    setState(() {
      _alertIcon = icon;
      _markers = markers;
    });
  }

  Future<void> _initUserLocation() async {
    final LatLng? position = await LocationService.getCurrentLatLng();
    if (!mounted) return;

    if (position == null) {
      _showLocationMessage(
        'Location unavailable. Enable GPS and grant location permission.',
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
        CameraPosition(target: position, zoom: 14),
      ),
    );
  }

  Future<void> _goToMyLocation() async {
    LatLng? position = _currentPosition;

    if (position == null) {
      position = await LocationService.getCurrentLatLng();
      if (position == null) {
        if (!mounted) return;
        _showLocationMessage(
          'Could not get your location. Check permissions and GPS.',
        );
        return;
      }
      setState(() {
        _currentPosition = position;
        _locationReady = true;
      });
    }

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16),
      ),
    );
  }

  void _showLocationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karachi flood alerts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kKarachi,
        markers: _markers,
        myLocationEnabled: _locationReady,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'my_location',
            tooltip: 'My location',
            onPressed: _goToMyLocation,
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'all_alerts',
            onPressed: _alertIcon == null ? null : _fitAllAlerts,
            label: const Text('Show all alerts'),
            icon: const Icon(Icons.warning_amber_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _fitAllAlerts() async {
    if (karachiFloodAlerts.isEmpty) return;

    final GoogleMapController controller = await _controller.future;
    double minLat = karachiFloodAlerts.first.latitude;
    double maxLat = minLat;
    double minLng = karachiFloodAlerts.first.longitude;
    double maxLng = minLng;

    for (final FloodAlertPoint point in karachiFloodAlerts) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
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
}
