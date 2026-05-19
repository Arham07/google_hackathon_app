import 'package:flutter/material.dart';
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
      status == LocationAccessStatus.granted && position != null;
}

/// Android location permission flow and current-position lookup.
class LocationService {
  /// Map camera fallback when GPS is unavailable (Karachi centre).
  static const LatLng fallbackCenter = LatLng(24.8607, 67.0011);

  /// Reads GPS without showing dialogs. Requests permission when still [denied].
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

  /// Returns current [LatLng], prompting to enable GPS or grant permission when needed.
  static Future<LatLng?> obtainCurrentLocation(BuildContext context) async {
    LocationAccess access = await getCurrentLocation();

    while (!access.isSuccess) {
      if (!context.mounted) return null;

      final _LocationDialogAction? action =
          await _showResolutionDialog(context, access.status);
      if (action == null || action == _LocationDialogAction.cancel) {
        return null;
      }

      switch (access.status) {
        case LocationAccessStatus.serviceDisabled:
          await Geolocator.openLocationSettings();
          break;
        case LocationAccessStatus.permissionDenied:
          if (action == _LocationDialogAction.allow) {
            await Geolocator.requestPermission();
          }
          break;
        case LocationAccessStatus.permissionDeniedForever:
          await Geolocator.openAppSettings();
          break;
        case LocationAccessStatus.unavailable:
        case LocationAccessStatus.granted:
          break;
      }

      // Brief pause so settings/permission changes apply after returning to the app.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!context.mounted) return null;
      access = await getCurrentLocation(requestPermission: false);
    }

    return access.position;
  }

  /// Silent lookup (no dialogs). Prefer [obtainCurrentLocation] in UI code.
  static Future<LatLng?> getCurrentLatLng() async {
    final LocationAccess access = await getCurrentLocation();
    return access.position;
  }

  static Future<_LocationDialogAction?> _showResolutionDialog(
    BuildContext context,
    LocationAccessStatus status,
  ) {
    late final String title;
    late final String message;
    late final String primaryLabel;
    late final _LocationDialogAction primaryAction;

    switch (status) {
      case LocationAccessStatus.serviceDisabled:
        title = 'Turn on location';
        message =
            'Device location is turned off. Enable GPS so CIRO can show your position on the map.';
        primaryLabel = 'Open location settings';
        primaryAction = _LocationDialogAction.openSettings;
      case LocationAccessStatus.permissionDenied:
        title = 'Location permission';
        message =
            'CIRO needs your location to pin incident reports and centre the map on you.';
        primaryLabel = 'Allow';
        primaryAction = _LocationDialogAction.allow;
      case LocationAccessStatus.permissionDeniedForever:
        title = 'Location blocked';
        message =
            'Location access was denied permanently. Open app settings and allow location for CIRO.';
        primaryLabel = 'Open app settings';
        primaryAction = _LocationDialogAction.openSettings;
      case LocationAccessStatus.unavailable:
        title = 'Location unavailable';
        message =
            'Could not determine your position. Check GPS signal and try again.';
        primaryLabel = 'Try again';
        primaryAction = _LocationDialogAction.retry;
      case LocationAccessStatus.granted:
        return Future<_LocationDialogAction?>.value(null);
    }

    return showDialog<_LocationDialogAction>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(_LocationDialogAction.cancel),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(primaryAction),
              child: Text(primaryLabel),
            ),
          ],
        );
      },
    );
  }
}

enum _LocationDialogAction { allow, openSettings, retry, cancel }
