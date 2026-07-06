import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/dashboard/main_dashboard.dart';
import '../screens/discovery/discovery_screen.dart';
import '../screens/discovery/likes_screen.dart';
import '../screens/permissions/location_permission_screen.dart';
import '../screens/profile/profile_setup_screen.dart';
import '../screens/settings/privacy_settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/therapy/therapy_screen.dart';
import '../services/auth_state.dart';

class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';

  // Protected
  static const profileSetup = '/profile-setup';
  static const locationPermission = '/location-permission';
  static const dashboard = '/dashboard';
  static const discovery = '/discovery';
  static const likes = '/likes';
  static const therapy = '/therapy';
  static const privacySettings = '/settings/privacy';

  static const _publicRoutes = <String>{
    splash,
    welcome,
    login,
    signup,
  };

  static const _authOnlyRoutes = <String>{
    welcome,
    login,
    signup,
  };

  static bool isPublic(String path) => _publicRoutes.contains(path);
  static bool isAuthOnly(String path) => _authOnlyRoutes.contains(path);
}

GoRouter buildRouter() {
  final authState = AuthState.instance;

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authState,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Wait for the initial auth check before routing decisions.
      if (!authState.isInitialized) return null;

      final location = state.matchedLocation;
      final loggedIn = authState.isAuthenticated;

      // Splash owns its own animation/timing; let it render and navigate itself.
      if (location == AppRoutes.splash) return null;

      final isPublic = AppRoutes.isPublic(location);

      // Block unauthenticated access to protected routes.
      if (!loggedIn && !isPublic) {
        return AppRoutes.login;
      }

      // Don't let a logged-in user revisit welcome/login/signup. Always
      // land them on the dashboard — incomplete-profile users see a banner
      // there that prompts them to finish their profile when they're ready.
      if (loggedIn && AppRoutes.isAuthOnly(location)) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const MainDashboard(),
      ),
      GoRoute(
        path: AppRoutes.discovery,
        builder: (context, state) => const DiscoveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.likes,
        builder: (context, state) => const LikesScreen(),
      ),
      GoRoute(
        path: AppRoutes.therapy,
        builder: (context, state) => const TherapyScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySettings,
        builder: (context, state) => const PrivacySettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const _NotFoundScreen(),
  );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Page not found'));
  }
}
