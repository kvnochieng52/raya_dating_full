import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/match_summary.dart';
import '../utils/api_config.dart';
import 'auth_service.dart';

class DiscoveryService {
  static Future<List<Map<String, dynamic>>> fetchFeed({
    int? minAge,
    int? maxAge,
    String? showMe,
    List<String>? interests,
    bool? verifiedOnly,
    int limit = 20,
  }) async {
    final params = <String, dynamic>{
      'limit': limit.toString(),
      if (minAge != null) 'min_age': minAge.toString(),
      if (maxAge != null) 'max_age': maxAge.toString(),
      if (showMe != null) 'show_me': showMe,
      if (interests != null && interests.isNotEmpty) 'interests[]': interests,
      if (verifiedOnly == true) 'verified_only': '1',
    };

    final token = await AuthService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/discovery')
        .replace(queryParameters: params);
    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final http.Response response;
    try {
      response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.receiveTimeout);
    } on TimeoutException {
      throw AuthException('The server took too long to respond.');
    } catch (e) {
      throw AuthException('Could not reach the server. ($e)');
    }

    final body = _handle(response, expected: 200);
    final list = (body['profiles'] as List?) ?? const [];
    return list.cast<Map<String, dynamic>>();
  }

  /// Returns `{is_match: bool, match: Map?}`.
  static Future<Map<String, dynamic>> swipe({
    required int targetUserId,
    required String action,
  }) async {
    final response = await _request(
      'POST',
      '/swipes',
      jsonBody: {'target_user_id': targetUserId, 'action': action},
    );
    return _handle(response, expected: 200);
  }

  static Future<List<Map<String, dynamic>>> sentLikes() async {
    final response = await _request('GET', '/likes/sent');
    final body = _handle(response, expected: 200);
    return ((body['likes'] as List?) ?? const []).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> receivedLikes() async {
    final response = await _request('GET', '/likes/received');
    final body = _handle(response, expected: 200);
    return ((body['likes'] as List?) ?? const []).cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> matches() async {
    final response = await _request('GET', '/matches');
    final body = _handle(response, expected: 200);
    return ((body['matches'] as List?) ?? const []).cast<Map<String, dynamic>>();
  }

  /// Strongly-typed variant of [matches] used by MatchesScreen / ChatScreen.
  static Future<List<MatchSummary>> fetchMatchSummaries() async {
    final raw = await matches();
    return raw
        .where((row) => row['profile'] is Map<String, dynamic>)
        .map(MatchSummary.fromJson)
        .toList();
  }

  /// Map of matches keyed by partner's user_id (as a string, to match
  /// [UserProfile.id]). Useful for "is this profile a match?" lookups
  /// when rendering discovery cards or likes tiles.
  static Future<Map<String, MatchSummary>> fetchMatchesByPartnerId() async {
    final list = await fetchMatchSummaries();
    return {for (final m in list) m.partner.id: m};
  }

  static Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? jsonBody,
    Map<String, String>? query,
  }) async {
    final token = await AuthService.getToken();
    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (query != null && query.isNotEmpty) {
      uri = uri.replace(queryParameters: query);
    }
    final headers = <String, String>{
      'Accept': 'application/json',
      if (jsonBody != null) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final body = jsonBody != null ? jsonEncode(jsonBody) : null;
      switch (method) {
        case 'GET':
          return await http.get(uri, headers: headers).timeout(ApiConfig.receiveTimeout);
        case 'POST':
          return await http
              .post(uri, headers: headers, body: body)
              .timeout(ApiConfig.receiveTimeout);
        default:
          throw AuthException('Unsupported method: $method');
      }
    } on TimeoutException {
      throw AuthException('The server took too long to respond.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Could not reach the server. ($e)');
    }
  }

  static Map<String, dynamic> _handle(http.Response response, {required int expected}) {
    final body = _decode(response);
    if (response.statusCode == expected) return body;
    final message = (body['message'] as String?) ??
        'Request failed (HTTP ${response.statusCode}).';
    Map<String, List<String>>? fieldErrors;
    final raw = body['errors'];
    if (raw is Map) {
      fieldErrors = raw.map(
        (k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList()),
      );
    }
    throw AuthException(message, fieldErrors: fieldErrors);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final d = jsonDecode(response.body);
      if (d is Map<String, dynamic>) return d;
      return {};
    } catch (_) {
      return {};
    }
  }
}
