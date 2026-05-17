/// Google Maps / Places API key for Dart-side HTTP calls.
abstract final class MapsConfig {
  static const String apiKey = 'AIzaSyBKl2Yi_q3alDUTMYVDBKOQONKECW0ONL4';

  static bool get hasApiKey => apiKey.isNotEmpty;
}
