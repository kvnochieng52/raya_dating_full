import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import 'auth_service.dart';

class MatchRequestService {
  /// Submits a "Want to be Matched" form. The backend persists the row and
  /// emails the matchmaking team for follow-up.
  static Future<Map<String, dynamic>> submit({
    required String gender,
    required String bodyType,
    required String religion,
    required String phone,
    required String email,
    required String lookingForDetails,
  }) async {
    final body = <String, dynamic>{
      'gender': gender,
      'body_type': bodyType,
      'religion': religion,
      'phone': phone,
      'email': email,
      'looking_for_details': lookingForDetails,
    };

    final token = await AuthService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.matchRequests}');
    final http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.receiveTimeout);
    } on TimeoutException {
      throw AuthException('The server took too long to respond.');
    } catch (e) {
      throw AuthException('Could not reach the server. ($e)');
    }

    final decoded = response.body.isNotEmpty
        ? (jsonDecode(response.body) as Map<String, dynamic>)
        : <String, dynamic>{};
    if (response.statusCode == 201) return decoded;

    final message = (decoded['message'] as String?) ??
        'Request failed (HTTP ${response.statusCode}).';
    Map<String, List<String>>? fieldErrors;
    final raw = decoded['errors'];
    if (raw is Map) {
      fieldErrors = raw.map(
        (k, v) =>
            MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()),
      );
    }
    throw AuthException(message, fieldErrors: fieldErrors);
  }
}
