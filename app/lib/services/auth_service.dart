import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_config.dart';
import 'auth_state.dart';

class AuthException implements Exception {
  AuthException(this.message, {this.fieldErrors});

  final String message;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => message;
}

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _completedStepKey = 'auth_completed_step';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    final response = await _post(ApiConfig.register, {
      'name': name,
      'email': email,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });

    final body = _decode(response);
    if (response.statusCode == 201) {
      await _persistSession(body);
      return body;
    }
    throw _toException(response, body);
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _post(ApiConfig.login, {
      'email': email,
      'password': password,
      'device_name': 'mobile',
    });

    final body = _decode(response);
    if (response.statusCode == 200) {
      await _persistSession(body);
      return body;
    }
    throw _toException(response, body);
  }

  /// Kicks off the password-reset flow. The API responds 200 whether or not the
  /// email is registered, so callers should always advance to the code screen.
  static Future<String> requestPasswordReset({required String email}) async {
    final response = await _post(ApiConfig.passwordForgot, {'email': email});
    final body = _decode(response);
    if (response.statusCode == 200) {
      return (body['message'] as String?) ??
          'If an account exists for that email, a reset code has been sent.';
    }
    throw _toException(response, body);
  }

  /// Submits the emailed code plus a new password. On success the server
  /// revokes existing tokens, so the caller must send the user to /login.
  static Future<String> resetPassword({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _post(ApiConfig.passwordReset, {
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final body = _decode(response);
    if (response.statusCode == 200) {
      return (body['message'] as String?) ??
          'Password updated. Please sign in with your new password.';
    }
    throw _toException(response, body);
  }

  static Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await http
            .post(
              Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logout}'),
              headers: _authHeaders(token),
            )
            .timeout(ApiConfig.receiveTimeout);
      } catch (_) {
        // Even if the request fails, clear local session.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_completedStepKey);
    AuthState.instance.markUnauthenticated();
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<Map<String, dynamic>?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<int> getCompletedStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedStepKey) ?? 0;
  }

  static Future<void> setCompletedStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_completedStepKey, step);
    AuthState.instance.updateCompletedStep(step);
  }

  /// Pulls a fresh `{user, profile}` snapshot from `/api/me` and updates
  /// SharedPreferences + AuthState. Used to re-hydrate state after launch or
  /// after a profile mutation succeeds out-of-band.
  static Future<Map<String, dynamic>?> refreshMe({bool throwOnUnauth = false}) async {
    final token = await getToken();
    if (token == null) return null;
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.me}'),
            headers: _authHeaders(token),
          )
          .timeout(ApiConfig.receiveTimeout);
      if (response.statusCode == 401) {
        if (throwOnUnauth) throw AuthException('Unauthenticated.');
        return null;
      }
      if (response.statusCode != 200) return null;
      final body = _decode(response);
      await _persistSession({
        'token': token,
        'user': body['user'],
        'profile': body['profile'],
      });
      return body;
    } on AuthException {
      rethrow;
    } catch (_) {
      // Network unavailable — caller uses cached state.
      return null;
    }
  }

  static Future<http.Response> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      return await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}$path'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.receiveTimeout);
    } on TimeoutException {
      throw AuthException(
        'The server took too long to respond. Check your connection.',
      );
    } catch (e) {
      throw AuthException('Could not reach the server. ($e)');
    }
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

  static Future<void> _persistSession(Map<String, dynamic> body) async {
    final token = body['token'] as String?;
    final user = body['user'];
    final profile = body['profile'];
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (user is Map) {
      await prefs.setString(_userKey, jsonEncode(user));
    }
    int? completedStep;
    if (profile is Map && profile['completed_step'] is int) {
      completedStep = profile['completed_step'] as int;
      await prefs.setInt(_completedStepKey, completedStep);
    }
    AuthState.instance.markAuthenticated(completedStep: completedStep);
  }

  static Map<String, String> _authHeaders(String token) => {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  static AuthException _toException(
    http.Response response,
    Map<String, dynamic> body,
  ) {
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
    return AuthException(message, fieldErrors: fieldErrors);
  }
}
