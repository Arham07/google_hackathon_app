import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:google_hackathon_app/config/maps_config.dart';
import 'package:google_hackathon_app/models/place_suggestion.dart';

/// Google Places Autocomplete + Place Details (Karachi-biased).
class PlacesSearchService {
  PlacesSearchService({String? apiKey}) : _apiKey = apiKey ?? MapsConfig.apiKey;

  final String _apiKey;
  String? _sessionToken;

  static const String _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  void _ensureSession() {
    _sessionToken ??= DateTime.now().microsecondsSinceEpoch.toString();
  }

  void resetSession() {
    _sessionToken = null;
  }

  Future<List<PlaceSuggestion>> search(String query) async {
    final String trimmed = query.trim();
    if (_apiKey.isEmpty || trimmed.length < 2) {
      return const [];
    }

    _ensureSession();

    final Uri uri = Uri.parse(_autocompleteUrl).replace(
      queryParameters: <String, String>{
        'input': trimmed,
        'key': _apiKey,
        'sessiontoken': _sessionToken!,
        // Bias results toward Karachi / Pakistan
        'location': '24.8607,67.0011',
        'radius': '50000',
        'components': 'country:pk',
      },
    );

    final http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      return const [];
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK' && body['status'] != 'ZERO_RESULTS') {
      return const [];
    }

    final List<dynamic> predictions = body['predictions'] as List<dynamic>? ?? [];
    return predictions.map((dynamic item) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      return PlaceSuggestion(
        placeId: map['place_id'] as String,
        description: map['description'] as String,
      );
    }).toList();
  }

  Future<SelectedPlace?> getPlaceDetails(String placeId) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    _ensureSession();

    final Uri uri = Uri.parse(_detailsUrl).replace(
      queryParameters: <String, String>{
        'place_id': placeId,
        'key': _apiKey,
        'sessiontoken': _sessionToken!,
        'fields': 'place_id,name,formatted_address,geometry',
      },
    );

    final http.Response response = await http.get(uri);
    resetSession();

    if (response.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    if (body['status'] != 'OK') {
      return null;
    }

    final Map<String, dynamic> result = body['result'] as Map<String, dynamic>;
    final Map<String, dynamic> geometry =
        result['geometry'] as Map<String, dynamic>;
    final Map<String, dynamic> location =
        geometry['location'] as Map<String, dynamic>;

    return SelectedPlace(
      placeId: result['place_id'] as String? ?? placeId,
      name: result['name'] as String? ?? '',
      address: result['formatted_address'] as String? ?? '',
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
    );
  }
}
