/// Google Maps / Places API key for Dart-side HTTP calls.
abstract final class MapsConfig {
  static const String apiKey = 'Add-your-API-key-here';

  static bool get hasApiKey => apiKey.isNotEmpty;
}
