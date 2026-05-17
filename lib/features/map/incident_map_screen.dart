import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_hackathon_app/utils/alert_marker_icon.dart';

class IncidentMapScreen extends StatefulWidget {
  const IncidentMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.title,
  });

  final double latitude;
  final double longitude;
  final String title;

  @override
  State<IncidentMapScreen> createState() => _IncidentMapScreenState();
}

class _IncidentMapScreenState extends State<IncidentMapScreen> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadMarker();
  }

  Future<void> _loadMarker() async {
    final BitmapDescriptor icon = await createFloodAlertMarkerIcon();
    if (!mounted) return;
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('incident'),
          position: LatLng(widget.latitude, widget.longitude),
          icon: icon,
          infoWindow: InfoWindow(title: widget.title),
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incident location')),
      body:GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15,
        ),
        markers: _markers,
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
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        { "color": "#000000" }
      ]
    }
  ]
  ''',
      ),
    );
  }
}
