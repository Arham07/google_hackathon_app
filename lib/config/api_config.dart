/// Backend base URL for CIRO Events + user-reports APIs.
abstract final class ApiConfig {
  /// Android emulator → host machine.
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String defaultCity = 'Karachi';
  static const int eventsLimit = 500;
}
