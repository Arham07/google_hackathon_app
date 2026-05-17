import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs request payload and response body for every API call (debug/profile builds).
class ApiLoggingInterceptor extends Interceptor {
  static const String _tag = 'CIRO_API';
  static const int _maxLogChars = 8000;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldLog) {
      final StringBuffer log = StringBuffer()
        ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
        ..writeln('→ REQUEST ${options.method} ${options.uri}')
        ..writeln('Headers: ${_safeJson(options.headers)}');

      if (options.queryParameters.isNotEmpty) {
        log.writeln('Query: ${_safeJson(options.queryParameters)}');
      }

      final dynamic data = options.data;
      if (data != null) {
        log.writeln('Payload:\n${_formatRequestData(data)}');
      } else {
        log.writeln('Payload: (none)');
      }

      _emit(log.toString());
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (_shouldLog) {
      final StringBuffer log = StringBuffer()
        ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
        ..writeln(
          '← RESPONSE ${response.statusCode} '
          '${response.requestOptions.method} ${response.requestOptions.uri}',
        )
        ..writeln('Response body:\n${_formatResponseData(response.data)}');

      _emit(log.toString());
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldLog) {
      final Response<dynamic>? response = err.response;
      final StringBuffer log = StringBuffer()
        ..writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━')
        ..writeln('✕ ERROR ${err.requestOptions.method} ${err.requestOptions.uri}')
        ..writeln('Type: ${err.type}')
        ..writeln('Message: ${err.message}');

      if (response != null) {
        log
          ..writeln('Status: ${response.statusCode}')
          ..writeln('Error response:\n${_formatResponseData(response.data)}');
      }

      _emit(log.toString(), level: 1000);
    }
    handler.next(err);
  }

  bool get _shouldLog => kDebugMode || kProfileMode;

  void _emit(String message, {int level = 0}) {
    final String trimmed = message.length > _maxLogChars
        ? '${message.substring(0, _maxLogChars)}\n… (truncated)'
        : message;
    developer.log(trimmed, name: _tag, level: level);
    debugPrint('[$_tag]\n$trimmed');
  }

  String _formatRequestData(dynamic data) {
    if (data is FormData) {
      final Map<String, dynamic> fields = <String, dynamic>{};
      for (final MapEntry<String, String> field in data.fields) {
        fields[field.key] = field.value;
      }
      for (final MapEntry<String, MultipartFile> file in data.files) {
        fields[file.key] =
            '(file: ${file.value.filename ?? 'unnamed'}, ${file.value.length} bytes)';
      }
      return _safeJson(fields);
    }
    if (data is Map || data is List) {
      return _safeJson(data);
    }
    return data.toString();
  }

  String _formatResponseData(dynamic data) {
    if (data == null) return 'null';
    if (data is Map || data is List) {
      return _safeJson(data);
    }
    if (data is String) {
      try {
        final dynamic decoded = jsonDecode(data);
        return _safeJson(decoded);
      } catch (_) {
        return data.length > _maxLogChars
            ? '${data.substring(0, _maxLogChars)}…'
            : data;
      }
    }
    return data.toString();
  }

  String _safeJson(dynamic value) {
    try {
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
