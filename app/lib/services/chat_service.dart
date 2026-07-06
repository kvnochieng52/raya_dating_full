import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import 'auth_service.dart';

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.body,
    required this.createdAt,
  });

  final int id;
  final int matchId;
  final int senderId;
  final String body;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as int,
        matchId: json['match_id'] as int,
        senderId: json['sender_id'] as int,
        body: json['body'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool isMine(int myUserId) => senderId == myUserId;
}

class ChatService {
  /// `afterId == null` returns the most recent batch (oldest first).
  /// Passing `afterId` returns only messages strictly newer than that id —
  /// suitable for polling.
  static Future<List<ChatMessage>> fetchMessages(
    int matchId, {
    int? afterId,
    int limit = 50,
  }) async {
    final query = <String, String>{'limit': '$limit'};
    if (afterId != null) query['after_id'] = '$afterId';

    final response = await _request(
      'GET',
      '/matches/$matchId/messages',
      query: query,
    );
    final body = _handle(response, expected: 200);
    final raw = (body['messages'] as List?) ?? const [];
    return raw
        .cast<Map<String, dynamic>>()
        .map(ChatMessage.fromJson)
        .toList();
  }

  static Future<ChatMessage> sendMessage(int matchId, String text) async {
    final response = await _request(
      'POST',
      '/matches/$matchId/messages',
      jsonBody: {'body': text},
    );
    final body = _handle(response, expected: 201);
    return ChatMessage.fromJson(body['message'] as Map<String, dynamic>);
  }

  /// Marks every message in this thread sent by the OTHER party as read.
  /// Returns the number of newly-marked messages.
  static Future<int> markRead(int matchId) async {
    final response = await _request('POST', '/matches/$matchId/read');
    final body = _handle(response, expected: 200);
    return (body['marked_read'] as int?) ?? 0;
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
