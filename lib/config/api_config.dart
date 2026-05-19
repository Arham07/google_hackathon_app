/// Backend base URL for CIRO Events + user-reports APIs.
abstract final class ApiConfig {
  static const String baseUrl = 'https://ciro-backeend-app.netlify.app';

  /// Local user-reports API (Android emulator → host `localhost:3000`).
  static const String userReportsBaseUrl = 'http://10.0.2.2:3000';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String defaultCity = 'Karachi';
  static const int eventsLimit = 500;

  /// Resolves relative asset paths (e.g. `/event-thumbnails/...`) to full URLs.
  static String? resolveAssetUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }
}
