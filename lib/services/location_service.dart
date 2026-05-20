import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Why [LocationService] could not return a GPS fix.
enum LocationAccessStatus {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

/// Result of a location lookup (no UI).
class LocationAccess {
  const LocationAccess({
    required this.status,
    this.position,
  });

  final LocationAccessStatus status;
  final LatLng? position;

  bool get isSuccess =>
      status == LocationAccessStatus.granted &&
      LocationService.isValidUserCoordinates(position);
}

/// Android location permission flow and current-position lookup.
class LocationService {
  /// Map camera fallback when GPS is unavailable (Karachi centre).
  static const LatLng fallbackCenter = LatLng(24.8607, 67.0011);

  /// Reads GPS without custom dialogs. Requests permission when still [denied].
  static Future<LocationAccess> getCurrentLocation({
    bool requestPermission = true,
  }) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationAccess(status: LocationAccessStatus.serviceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationAccess(
        status: LocationAccessStatus.permissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationAccess(
        status: LocationAccessStatus.permissionDeniedForever,
      );
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LocationAccess(
        status: LocationAccessStatus.granted,
        position: LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      final Position? last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        return LocationAccess(
          status: LocationAccessStatus.granted,
          position: LatLng(last.latitude, last.longitude),
        );
      }
      return const LocationAccess(status: LocationAccessStatus.unavailable);
    }
  }

  /// Returns current [LatLng] when available (system permission prompt only).
  static Future<LatLng?> getCurrentLatLng() async {
    final LocationAccess access = await getCurrentLocation();
    return access.position;
  }

  /// Nearby list: requires a live GPS fix — no cached last-known position.
  static Future<LocationAccess> getCurrentLocationForNearby({
    bool requestPermission = true,
  }) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const LocationAccess(status: LocationAccessStatus.serviceDisabled);
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const LocationAccess(
        status: LocationAccessStatus.permissionDenied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const LocationAccess(
        status: LocationAccessStatus.permissionDeniedForever,
      );
    }

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final LatLng latLng = LatLng(position.latitude, position.longitude);
      if (!isValidUserCoordinates(latLng)) {
        return const LocationAccess(status: LocationAccessStatus.unavailable);
      }
      return LocationAccess(
        status: LocationAccessStatus.granted,
        position: latLng,
      );
    } catch (_) {
      return const LocationAccess(status: LocationAccessStatus.unavailable);
    }
  }

  static bool isValidUserCoordinates(LatLng? position) {
    if (position == null) return false;
    if (position.latitude == 0 && position.longitude == 0) return false;
    if (position.latitude.abs() > 90 || position.longitude.abs() > 180) {
      return false;
    }
    return true;
  }

  /// User-facing copy when nearby alerts cannot load without GPS.
  static String messageForStatus(LocationAccessStatus status) {
    switch (status) {
      case LocationAccessStatus.granted:
        return '';
      case LocationAccessStatus.serviceDisabled:
        return 'Location services are turned off. Enable GPS to see nearby alerts.';
      case LocationAccessStatus.permissionDenied:
        return 'Location access is required for nearby alerts. Allow location permission to continue.';
      case LocationAccessStatus.permissionDeniedForever:
        return 'Location permission was denied. Open Settings and allow location for BaKhabar Alerts.';
      case LocationAccessStatus.unavailable:
        return 'Could not determine your location. Enable GPS and try again.';
    }
  }

  static Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  static Future<bool> openAppSettings() => Geolocator.openAppSettings();
}
