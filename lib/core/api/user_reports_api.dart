import 'package:dio/dio.dart';
import 'package:google_hackathon_app/config/api_config.dart';
import 'package:google_hackathon_app/core/api/api_client.dart';
import 'package:google_hackathon_app/core/api/api_endpoints.dart';

class UserReportSubmitResponse {
  const UserReportSubmitResponse({
    required this.status,
    this.eventId,
    this.isUserSubmitted,
    this.error,
    this.isDuplicate = false,
  });

  final String status;
  final String? eventId;
  final bool? isUserSubmitted;
  final String? error;
  final bool isDuplicate;

  factory UserReportSubmitResponse.fromJson(Map<String, dynamic> json) {
    final String status = json['status'] as String? ?? 'error';
    final Map<String, dynamic>? event =
        json['event'] as Map<String, dynamic>?;
    return UserReportSubmitResponse(
      status: status,
      eventId: event?['event_id'] as String?,
      isUserSubmitted: event?['is_user_submitted'] as bool?,
      error: json['error'] as String?,
      isDuplicate: status == 'duplicate',
    );
  }
}

/// POST /api/user-reports/submit (multipart).
class UserReportsApi {
  UserReportsApi({ApiClient? client})
      : _client = client ?? ApiClient(baseUrl: ApiConfig.baseUrl);

  final ApiClient _client;

  Future<UserReportSubmitResponse> submitReport({
    required String text,
    required double lat,
    required double lng,
    required String photoPath,
  }) async {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'text': text,
      'lat': lat.toString(),
      'lng': lng.toString(),
      'photo': await MultipartFile.fromFile(
        photoPath,
        filename: photoPath.split(RegExp(r'[/\\]')).last,
      ),
    });

    final Map<String, dynamic> body = await _client.postMultipart(
      ApiEndpoints.userReportsSubmit,
      formData: formData,
    );

    return UserReportSubmitResponse.fromJson(body);
  }
}
