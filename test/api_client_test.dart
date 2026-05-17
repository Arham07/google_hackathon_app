import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_hackathon_app/core/api/api_client.dart';
import 'package:google_hackathon_app/core/api/api_exception.dart';

void main() {
  test('get returns JSON map', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = _JsonAdapter(
      statusCode: 200,
      body: <String, dynamic>{'count': 1, 'events': <dynamic>[]},
    );

    final ApiClient client = ApiClient(dio: dio);
    final Map<String, dynamic> result = await client.get('/api/events');

    expect(result['count'], 1);
  });

  test('maps server error body to ApiException', () async {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.httpClientAdapter = _JsonAdapter(
      statusCode: 500,
      body: <String, dynamic>{'error': 'Supabase query failed'},
    );

    final ApiClient client = ApiClient(dio: dio);

    expect(
      () => client.get('/api/events'),
      throwsA(
        isA<ApiException>().having(
          (ApiException e) => e.message,
          'message',
          'Supabase query failed',
        ),
      ),
    );
  });
}

class _JsonAdapter implements HttpClientAdapter {
  _JsonAdapter({required this.statusCode, required this.body});

  final int statusCode;
  final Map<String, dynamic> body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json'],
      },
    );
  }
}
