/// Google Maps / Places API key for Dart-side HTTP calls.
///
/// Pass the same key as [MAPS_API_KEY] in android/local.properties:
/// `flutter run --dart-define=MAPS_API_KEY=your_key`
abstract final class MapsConfig {
  static const String apiKey = String.fromEnvironment('MAPS_API_KEY');

  static bool get hasApiKey => apiKey.isNotEmpty;
}
