/// HTTP / network failure from [ApiClient].
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      statusCode != null ? 'ApiException($statusCode): $message' : 'ApiException: $message';
}
