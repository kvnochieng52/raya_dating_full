import 'package:flutter/foundation.dart';

import 'auth_service.dart';

class AuthState extends ChangeNotifier {
  AuthState._();

  static final AuthState instance = AuthState._();

  /// Highest [completedStep] value before the user is considered "matchable".
  /// Step 4 = basic info + faith/background + photos + interests
  /// (verification is step 5 and optional).
  static const int _matchableStep = 4;

  bool _initialized = false;
  bool _isAuthenticated = false;
  int _completedStep = 0;

  bool get isInitialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  int get completedStep => _completedStep;
  bool get isProfileComplete => _completedStep >= _matchableStep;

  Future<void> bootstrap() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      _isAuthenticated = false;
      _completedStep = 0;
      _initialized = true;
      notifyListeners();
      return;
    }

    // Validate the stored token against the server.
    // On 401 → token is stale/invalid, clear session.
    // On network error → assume still logged in (offline mode).
    try {
      final me = await AuthService.refreshMe(throwOnUnauth: true);
      if (me != null) {
        final profile = me['profile'] as Map<String, dynamic>?;
        _completedStep = (profile?['completed_step'] as num?)?.toInt() ?? 0;
      } else {
        _completedStep = await AuthService.getCompletedStep();
      }
      _isAuthenticated = true;
    } on AuthException {
      // Token rejected by server — wipe local session.
      await AuthService.logout();
      _isAuthenticated = false;
      _completedStep = 0;
    } catch (_) {
      // Unexpected error — fall back to cached state.
      _isAuthenticated = true;
      _completedStep = await AuthService.getCompletedStep();
    }

    _initialized = true;
    notifyListeners();
  }

  void markAuthenticated({int? completedStep}) {
    var changed = false;
    if (!_isAuthenticated || !_initialized) {
      _isAuthenticated = true;
      _initialized = true;
      changed = true;
    }
    if (completedStep != null && completedStep != _completedStep) {
      _completedStep = completedStep;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void markUnauthenticated() {
    if (_isAuthenticated || _completedStep != 0 || !_initialized) {
      _isAuthenticated = false;
      _completedStep = 0;
      _initialized = true;
      notifyListeners();
    }
  }

  /// Updates the cached completed step. Ratchets forward — never goes backwards.
  void updateCompletedStep(int step) {
    if (step > _completedStep) {
      _completedStep = step;
      notifyListeners();
    }
  }
}
