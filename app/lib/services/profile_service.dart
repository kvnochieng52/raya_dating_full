import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import 'auth_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await _request('GET', ApiConfig.profile);
    return _handle(response, expected: 200);
  }

  /// Sends a partial profile patch. Pass `step` to advance the
  /// server's `completed_step` ratchet after this slice saves.
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> fields, {
    int? step,
  }) async {
    final body = Map<String, dynamic>.from(fields);
    if (step != null) body['completed_step'] = step;

    final response = await _request(
      'PATCH',
      ApiConfig.profile,
      jsonBody: body,
    );
    final result = _handle(response, expected: 200);
    final profile = result['profile'];
    if (profile is Map && profile['completed_step'] is int) {
      await AuthService.setCompletedStep(profile['completed_step'] as int);
    }
    return result;
  }

  static Future<Map<String, dynamic>> uploadPhoto(
    File file, {
    required int position,
    bool isMain = false,
  }) async {
    final response = await _multipart(
      ApiConfig.profilePhotos,
      fields: {
        'position': position.toString(),
        'is_main': isMain ? '1' : '0',
      },
      files: {'photo': file},
    );
    return _handle(response, expected: 201);
  }

  static Future<void> deletePhoto(int photoId) async {
    final response = await _request('DELETE', '${ApiConfig.profilePhotos}/$photoId');
    _handle(response, expected: 200);
  }

  static Future<Map<String, dynamic>> setMainPhoto(int photoId) async {
    final response = await _request(
      'PATCH',
      '${ApiConfig.profilePhotos}/$photoId/main',
    );
    return _handle(response, expected: 200);
  }

  /// Asks the server to email a fresh 6-digit verification code to the
  /// currently-authenticated user.
  static Future<Map<String, dynamic>> requestEmailCode() async {
    final response = await _request('POST', ApiConfig.requestEmailCode);
    return _handle(response, expected: 200);
  }

  /// Verifies the email by submitting the 6-digit code the user received.
  static Future<Map<String, dynamic>> verifyEmail(String code) async {
    final response = await _request(
      'POST',
      ApiConfig.verifyEmail,
      jsonBody: {'code': code},
    );
    return _handle(response, expected: 200);
  }

  static Future<Map<String, dynamic>> uploadSelfie(File file) async {
    final response = await _multipart(
      ApiConfig.verifySelfie,
      files: {'selfie': file},
    );
    return _handle(response, expected: 200);
  }

  static Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? jsonBody,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
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
        case 'PATCH':
          return await http
              .patch(uri, headers: headers, body: body)
              .timeout(ApiConfig.receiveTimeout);
        case 'DELETE':
          return await http.delete(uri, headers: headers).timeout(ApiConfig.receiveTimeout);
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

  static Future<http.Response> _multipart(
    String path, {
    Map<String, String> fields = const {},
    required Map<String, File> files,
  }) async {
    final token = await AuthService.getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    for (final entry in files.entries) {
      request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
    }

    try {
      final streamed = await request.send().timeout(ApiConfig.receiveTimeout);
      return await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw AuthException('Upload timed out. Check your connection.');
    } catch (e) {
      throw AuthException('Upload failed. ($e)');
    }
  }

  static Map<String, dynamic> _handle(http.Response response, {required int expected}) {
    final body = _decode(response);
    if (response.statusCode == expected) return body;

    final message = (body['message'] as String?) ??
        'Request failed (HTTP ${response.statusCode}).';
    Map<String, List<String>>? fieldErrors;
    final rawErrors = body['errors'];
    if (rawErrors is Map) {
      fieldErrors = rawErrors.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as List).map((e) => e.toString()).toList(),
        ),
      );
    }
    throw AuthException(message, fieldErrors: fieldErrors);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}
