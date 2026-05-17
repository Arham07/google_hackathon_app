import 'package:dio/dio.dart';
import 'package:google_hackathon_app/config/api_config.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';

/// Shared Dio wrapper — no interceptors, no auth headers (open APIs).
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl}) : _dio = dio ?? _createDio(baseUrl);

  final Dio _dio;

  static Dio _createDio(String? baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: const <String, String>{'Accept': 'application/json'},
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return _asJsonMap(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        path,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
      return _asJsonMap(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required FormData formData,
  }) async {
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        path,
        data: formData,
      );
      return _asJsonMap(response.data);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException(message: 'Unexpected response format');
  }

  ApiException _mapException(DioException e) {
    final int? status = e.response?.statusCode;
    final dynamic body = e.response?.data;
    String message = e.message ?? 'Network request failed';

    if (body is Map) {
      final dynamic err = body['error'];
      if (err is String && err.isNotEmpty) {
        message = err;
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Request timed out. Check your connection.';
      case DioExceptionType.connectionError:
        message = 'Cannot reach server. Is the backend running?';
      default:
        break;
    }

    return ApiException(message: message, statusCode: status);
  }
}
